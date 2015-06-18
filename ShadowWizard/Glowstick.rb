class Glowstick

	attr_reader :x, :y

	def initialize(window, x, y, vel_x, vel_y, color, angle)
		@window = window
		@color = color
		@x = x
		@y = y
		@vel_x = vel_x
		@vel_y = vel_y
		@angle = angle
		@collision_radius = 10
		@turning_speed = 12
		
		@lightscale = 0.3
		@shrink_light = false
		@flickclock = @flickclockmax = 5
		
		@flickblue = @color%256
		@flickgreen = (@color/256)%256
		@flickred = (@color/65536)%256
		@flickalpha = (@color/16777216)%256
		@flickscale_rand = rand(12)
		
		@light = Light.new(@window, @x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, @lightscale, @color, 2, true)
		$lights.push(@light)
		
		@death_call = false
		@death_timer = 45
	end
	
	def update
		self.move
		
		@light.set_coords(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y)
		
		@angle += @turning_speed
		@angle = @angle % 360
		
		@turning_speed -= 0.028 * @turning_speed * $time_diff_ms*60/1000
		
		@flickclock = [0, @flickclock-1].max
				
		if @flickclock == 0
			
			@flickblue = @color%256
			@flickgreen = (@color/256)%256
			@flickred = (@color/65536)%256
			@flickalpha = (@color/16777216)%256
			
			
			@light.set_color(@flickalpha*16777216 +
							[[@flickred-15+rand(30), 0].max, 255].min*65536 +
							[[@flickgreen-15+rand(30), 0].max, 255].min*256 +
							[[@flickblue-15+rand(30), 0].max, 255].min)
			
			@flickscale_rand = rand(12)
			@flickclock = @flickclockmax
		end
		
		@light.set_scale(@lightscale - 0.06 + @flickscale_rand.to_f/130)
		
		if @lightscale > 1.8
			@shrink_light = true
		end
		
		if @shrink_light == false
			@lightscale += 0.02
		else
			@lightscale = [@lightscale - 0.01*$time_diff_ms*60/1000, 0].max
			if @lightscale <= 0
				@light.set_scale(0)
				$lights.delete(@light)
				@death_call = true
			else
				@light.set_scale(@lightscale - 0.06 + @flickscale_rand.to_f/130)
			end
		end
		
		if @death_call == true
			@death_timer = [@death_timer - 1 * $time_diff_ms*60/1000, 0].max
			if @death_timer == 0
				$glowsticks.delete(self)
			end
		end
		
	end
	
	def move
		@x = @x + @vel_x * $time_diff_ms*60/1000
		@x = [@x, 0].max
		@x = [@x, 2880].min
		
		@y = @y + @vel_y * $time_diff_ms*60/1000
		@y = [@y, @window.height-2880].max
		@y = [@y, 720].min
		
		@window.blockCheckCollision( @x, @y, @collision_radius, method(:collision_block)) # Block
		@window.crateCheckCollision( @x, @y, @collision_radius, method(:collision_block)) # Crate
		
		@vel_x -= 0.028 * @vel_x * $time_diff_ms*60/1000
		@vel_y -= 0.028 * @vel_y * $time_diff_ms*60/1000
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
		
		@dir_orb_pos1 = point_direction(bx, by, @x, @y)
		@dir_orb_pos2 = point_direction(bx, by, @x-@vel_x, @y-@vel_y)
		
		@angle_Comp_21p        = @window.get_dir_dif(@dir_orb_pos2, @dir_orb_pos1).abs
		@angle_player_orb_rad  = @angle_Comp_21p * Math::PI / 180
		
		@some_value = Gosu::distance(bx, by, @x-@vel_x, @y-@vel_y) * Math.cos(@angle_player_orb_rad)
		@move_speed = ( @some_value - Gosu::distance(bx, by, @x, @y) ) * 2 * 1
		
		@vel_x += Gosu::offset_x(@move_angle, [@move_speed, 1].max)
		@vel_y += Gosu::offset_y(@move_angle, [@move_speed, 1].max)
	end
	
	def point_direction(x1,y1,x2,y2)
		return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
	def draw
		
		blue = @color%256
		green = (@color/256)%256
		red = (@color/65536)%256
		alpha = (@color/16777216)%256
		
		temp = ([alpha*@death_timer/45, 0].max).round*16777216 + (255 - ((255 - red) / 3)).round*65536 + (255 - ((255 - green) / 3)).round*256 + (255 - ((255 - blue) / 3)).round
		
		@window.glowstick_obj_img.draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.8, @angle, 0.5, 0.5, 1, 1, temp)
	end
	
end
