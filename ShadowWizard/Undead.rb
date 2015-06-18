class Undead
	
	attr_reader :x, :y
	
	def initialize(window, x, y, angle, id)
		
		@window = window
		@id = id
		@x = x
		@y = y
		@angle = angle
		
		@collision_radius = 12
		
		@target_x = @x # The position you are moving towards
		@target_y = @y # The position you are moving towards
		@player_x = @x # The player position you are moving towards
		@player_y = @y # The player position you are moving towards
		@player_target = "false"
		
		@speed = 3
		@a_speed = 0.20
		@vel_x = 0
		@vel_y = 0
		
		@index = 0
		@attacking = false
		@attack_anim_timer = @attack_anim_timer_max = 8
		
		@taking_damage = false
		@taking_damage_timer = 0
		
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
		
		if @taking_damage == true
			@taking_damage_timer = @taking_damage_timer-1.0*$time_diff_ms*60/1000
			if @taking_damage_timer <= 0
				@taking_damage = false
			end
		end
		
		if @attacking == true
			@attack_anim_timer = @attack_anim_timer-1.0*$time_diff_ms*60/1000
			if @attack_anim_timer <= 0
				@attack_anim_timer += @attack_anim_timer_max
				@index = [7, @index+1].min
				if @index == 6
					self.do_attack # When index is 6, you are attacking
				end
				if @index > 6
					@attacking = false
					@index = 0
				end
			end
		end
		
		if @player_target != "false"
			#@player_x = player_x_array[@player_target.to_i]  # Do you want fast turning or slower turning?
			#@player_y = player_y_array[@player_target.to_i]  # Uncomment for faster turning, comment for slower turning.
		end
		
		@angle = point_direction(@x, @y, @player_x, @player_y) ## Always point towards @player_x, @player_y
		
	end
	
	def set_player_target(id, index)
		if @id == id
			
			@player_target = index
			
		end
	end
	
	def checkCollision(x, y, radius, id)
		if Gosu::distance(@x, @y, x, y) < radius + @collision_radius and @id != id
			return true
		end
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
	
	def checkCollisionWeapon(cx, cy, radius, angle_start, angle_end, id, type) # This is basically one big cone-collision-check.
		
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
				self.collision_staff(cx, cy, id)
		end
	end
	
	def update_target_pos(id, target_x, target_y, player_x, player_y)
		if @id == id
			@target_x = target_x
			@target_y = target_y
			@player_x = player_x
			@player_y = player_y
		end
	end
	
	def update_coords(id, x, y, vel_x, vel_y)
		if @id == id
			@x = x
			@y = y
			@vel_x = vel_x
			@vel_y = vel_y
		end
	end
	
	def animate_attack(id)
		if @id == id
			@attacking = true
		end
	end
	
	def do_attack
		# Put attack stuff here!
		getx = @x + Gosu::offset_x(@angle, 26) # This gets the point where the staff begins.
		gety = @y + Gosu::offset_y(@angle, 26)
		$players.each { |p| p.checkCollisionUndeadAttack(@x, @y, getx, gety) }
	end
	
	def collision_staff(x, y, id)
		@taking_damage = true
		@taking_damage_timer = 11
		if id == @window.my_id.to_i
			damage = 16
			self.take_damage(@id, damage)
			data = [@window.my_id, @id, damage]
			@window.send_pack(data.join(' '), true, 28)
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
	
	def draw
		
		if @dying == false
			@window.draw_bar(@x-15+@window.width/2-@window.player_x, @y-15+@window.height/2-@window.player_y, @x+15+@window.width/2-@window.player_x, @y-10+@window.height/2-@window.player_y, 5.90, @health*1.0/@maxhealth, 0x99CE3608, 0x99FFFFFF, 0x77000000, true)
			if @taking_damage == true
				@window.undead_array[@index+8].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.85, @angle-90, 0.5, 0.5, 1, 1, 0xffffffff)
			else
				@window.undead_array[@index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.85, @angle-90, 0.5, 0.5, 1, 1, 0xffffffff)
			end
		else
			alpha = [255, (@deathtimer * (255/40)).round].min # A number between 0 and 255
			red = 255
			green = (((@deathtimer+40) * 255)/120).round # A number between 0 and 255
			blue = (((@deathtimer+40) * 255)/120).round # A number between 0 and 255
			
			death_color = alpha*16777216 + red*65536 + green*256 + blue
			
			if @taking_damage == true
				@window.undead_array[@index+8].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.85, @angle-90, 0.5, 0.5, 1, 1, 0xffffffff)
			else
				@window.undead_array[0].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.85, @angle-90, 0.5, 0.5, 1, 1, death_color)
			end
		end
	end
	
end
