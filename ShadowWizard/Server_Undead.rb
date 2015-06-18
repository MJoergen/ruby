require_relative 'geom.rb'

class Server_Undead
	
	attr_reader :x, :y
	
	def initialize(window, x, y, angle, id)
		@window = window
		@id = id
		@x = x
		@y = y
		@angle = angle
		@collision_radius = 12
		@speed = 3
		@target_x = @x
		@target_y = @y
		@player_x = @x
		@player_y = @y
		@a_speed = 0.20
		@vel_x = 0
		@vel_y = 0
		@attack_timer = @attack_timer_max = 43
		
		# Health
		@maxhealth = 120
		@health = @maxhealth
		@dying = false
		@deathtimer = 80
		
	end
	
	def update(player_x_array, player_y_array, players_ingame, players_alive)
		
		if @health <= 0
			
			@dying = true
			@deathtimer = @deathtimer-1.0*$time_diff_ms*60/1000
			
			if @deathtimer <= 0
				$undeads.delete(self)
			end
		end
		
		# This sorts the players that are ingame, and finds the "best" target.
		valid_coords = []
		valid_dist = []
		for i in 0..2 # For each player
			if players_ingame[i] == 1 and players_alive[i] == 1 # If the player is online and alive
				dist_player = Gosu::distance(@x, @y, player_x_array[i], player_y_array[i]) # Check the distance
				if dist_player < 340 # Is it less than 340?
					if path_clear(player_x_array[i], player_y_array[i]) # Can you see it?
						valid_coords.push(player_x_array[i]) # Add the coordinates to the array target_coords
						valid_coords.push(player_y_array[i])
						valid_dist.push(dist_player) # Add the distance to a seperate array
					end
				end
			end
		end
		
		# Check each valid target
		if !valid_coords.empty? # Do you have a valid target?
			
			min_dist_index = valid_dist.index(valid_dist.min) # The index of the minimal target distance
			
			data = [@id, min_dist_index]
			@window.server.broadcast_packet(data.join(' '), true, 32)
			
			@player_x = valid_coords[min_dist_index*2] # Set the x value for the closest valid target
			@player_y = valid_coords[min_dist_index*2+1] # Set the y value for the closest valid target
			target_x = @player_x + Gosu::offset_x(point_direction(@player_x, @player_y, @x, @y), 35) # Make sure the desired target location is infront of the player
			target_y = @player_y + Gosu::offset_y(point_direction(@player_x, @player_y, @x, @y), 35)
			dist_player = valid_dist[min_dist_index] # Not sure why I have this...
			dist_target = Gosu::distance(@x, @y, target_x, target_y)
			if dist_player < 36 and @attack_timer == 0
				@window.server.broadcast_packet(@id.to_s, true, 27)
				@attack_timer = @attack_timer_max
			end
		else
			
			data = [@id, false]
			@window.server.broadcast_packet(data.join(' '), true, 32)
			
			target_x = @x # If no valid targets are found; target = yourself
			target_y = @y # If no valid targets are found; target = yourself
			dist_player = 0 # And not sure about this one either...
			dist_target = 0
		end
		
		old_target_x = @target_x # Save the old target values in a temporary variable
		old_target_y = @target_y
		
		@target_x = target_x # Set the new target values
		@target_y = target_y
		
		if @target_x != old_target_x or @target_y != old_target_y # If the target position has changed
			@angle = point_direction(@x, @y, @target_x, @target_y)
			data = [@id, @target_x, @target_y, @player_x, @player_y]
			@window.server.broadcast_packet(data.join(' '), true, 24)
		end
		
		
		move_angle_with_speed(dist_target) # This is why
		
		@attack_timer = [0, @attack_timer-1].max
		
	end
	
	def checkCollisionStaff(cx, cy, radius, angle_start, angle_end, type) # This is basically one big cone-collision-check.
		
		cone_center_angle = (angle_start + angle_end)/2 # The center angle of the cone
		cone_angle_radius = cone_center_angle - angle_start # Always positive
		cone_center_angle = cone_center_angle % 360 # Sync the angle between 0 - 360
		
		if Gosu::distance(@x, @y, cx, cy) < radius + @collision_radius and
			(
			 get_dir_dif(point_direction(cx, cy, @x, @y), cone_center_angle).abs < cone_angle_radius or 
			 Geom.collision_radius_to_line_segment(cx, cy, cx + Gosu::offset_x(angle_start, radius), cy + Gosu::offset_y(angle_start, radius),
				@x, @y, @collision_radius) != 0 or
			 Geom.collision_radius_to_line_segment(cx, cy, cx + Gosu::offset_x(angle_end, radius), cy + Gosu::offset_y(angle_end, radius),
				@x, @y, @collision_radius) != 0
			)
				self.collision_staff(cx, cy)
		end
	end
	
	def take_damage(id, amount)
		if @id == id
			@health = [0, @health-amount].max
		end
	end
	
	def point_direction(x1, y1, x2, y2)
		return (((Math::atan2(y2-y1, x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
	def path_clear(x, y)
		if !$path_blockers.empty?
			if !$path_blockers.find_index { |sq| Geom.collision_line_segment_box(@x, @y, x, y, sq.x, sq.y, sq.width, sq.height) != 0 } and
			   !$crates.find_index { |sq| Geom.collision_line_segment_box(@x, @y, x, y, sq.x, sq.y, sq.width, sq.height) != 0 }
				return true
			end
		end
	end
	
	def move_angle_with_speed(dist) # This function is made for performance optimisation.
		
		if dist > 2 # Checks that we aren'r already close to the target
			move_direction(@angle, @a_speed) # Moves towards target
		end
		
		self.move
		
		if @vel_x.abs + @vel_y.abs > 0.01
			@window.checkCollisionUndead( @x, @y, @collision_radius, @id, method(:collision_undead), "undead_collision_circle") # Undead
			@window.checkCollisionPathblock( @x, @y, @collision_radius, method(:collision_block)) # Wall
			@window.checkCollisionCrate( @x, @y, @collision_radius, method(:collision_block)) # Crate
		end
	end
	
	def undead_collision_circle(x, y, radius, id)
		if Gosu::distance(@x, @y, x, y) < radius + @collision_radius and @id != id
			return true
		end
	end
	
	def collision_staff(x, y)
		# Knockback
		dir = point_direction(x, y, @x, @y)
		@vel_x += Gosu::offset_x(dir, 5)
		@vel_y += Gosu::offset_y(dir, 5)
	end
	
	def collision_undead(inst)
		bounce_point(inst.x, inst.y)
	end
	
	def get_dir_dif(dir1,dir2)
		# Only works with directions between 0 - 360
		
		dir_to_turn = dir1 - dir2 #This gives a value between -360 and 360
			
		# Make sure that value is between -180 and 180, which is the relative direction.
		if dir_to_turn >= 180
			dir_to_turn += -360
		end
		if dir_to_turn <= -180
			dir_to_turn += 360
		end
		#This outputs only the difference in terms of angle (for example -15 or 25 degrees)
		#So in order to get the absolute difference you need to do .abs!
		return dir_to_turn
    end
	
	def collision_block(inst)
		
		# All this code basically checks which side/corner you are colliding with
		
		if @x < inst.x # Are you to the left of the block?
			if @y < inst.y
				bounce_point(inst.x, inst.y) # uppper-left corner
			end
			if @y.between?(inst.y, inst.y + inst.height) 
				bounce_point(inst.x, @y) # left side
			end
			if @y > inst.y + inst.height
				bounce_point(inst.x, inst.y + inst.height) # lower-left corner
			end
		end
		if @x.between?(inst.x, inst.x + inst.width) # Are you directly above or below the block?
			if @y < inst.y
				bounce_point(@x, inst.y) # top side
			end
			if @y > inst.y + inst.height
				bounce_point(@x, inst.y + inst.height) # bottom side
			end
		end
		if @x > inst.x + inst.width # Are you to the right of the block?
			if @y < inst.y
				bounce_point(inst.x + inst.width, inst.y) # upper-right corner
			end
			if @y.between?(inst.y, inst.y + inst.height)
				bounce_point(inst.x + inst.width, @y) # right side
			end
			if @y > inst.y + inst.height
				bounce_point(inst.x + inst.width, inst.y + inst.height) # lower-right corner
			end
		end
	end
	
	def bounce_point(bx, by)
		@move_angle = point_direction(bx, by, @x, @y)
		
		temp_vel_x = @vel_x
		temp_vel_y = @vel_y
		
		@dir_orb_pos1 = point_direction(bx, by, @x, @y)
		@dir_orb_pos2 = point_direction(bx, by, @x-temp_vel_x, @y-temp_vel_y)
		
		@angle_Comp_21p        = @window.get_dir_dif(@dir_orb_pos2, @dir_orb_pos1).abs
		@angle_player_orb_rad  = @angle_Comp_21p * Math::PI / 180
		
		@some_value = Gosu::distance(bx, by, @x-temp_vel_x, @y-temp_vel_y) * Math.cos(@angle_player_orb_rad)
		@move_speed = ( @some_value - Gosu::distance(bx, by, @x, @y) ) * 2 * 1
		
		@vel_x += Gosu::offset_x(@move_angle, [@move_speed, 1].max)
		@vel_y += Gosu::offset_y(@move_angle, [@move_speed, 1].max)
	end
	
	def move_direction(dir, speed)
		if @dying == false
			@vel_x += Gosu::offset_x(dir, speed * $time_diff_ms*60/1000)
			@vel_y += Gosu::offset_y(dir, speed * $time_diff_ms*60/1000)
		end
	end
	
	def move
		@x = @x + @vel_x * $time_diff_ms*60/1000
		@y = @y + @vel_y * $time_diff_ms*60/1000
		
		if @dying == false
			@vel_x -= 0.08 * @vel_x * $time_diff_ms*60/1000
			@vel_y -= 0.08 * @vel_y * $time_diff_ms*60/1000
		else
			@vel_x -= 0.16 * @vel_x * $time_diff_ms*60/1000
			@vel_y -= 0.16 * @vel_y * $time_diff_ms*60/1000
		end
		
		if @vel_x.abs + @vel_y.abs > 0.005 # Only send coords when moving
			data = [@id, @x, @y, @vel_x, @vel_y]
			@window.server.broadcast_packet(data.join(' '), true, 26)
		end
	end
		
end