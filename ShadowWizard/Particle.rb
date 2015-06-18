class Particle

	attr_reader :x, :y

	def initialize(window, x, y, color, img, scale)
		
		@window = window
		@x = x
		@y = y
		@color = color
		@img = img
		@scale = scale
		
		@angle = rand(360)
		@friction = 0.08
		@vel_x = Gosu::offset_x(@angle, 3.3 + rand(10)/10)
		@vel_y = Gosu::offset_y(@angle, 3.3 + rand(10)/10)
		
		@time = 10
		
	end
	
	def move
		
		delta_x = @vel_x * $time_diff_ms*60/1000
		delta_y = @vel_y * $time_diff_ms*60/1000
		
		@x = @x + delta_x
		@y = @y + delta_y
		
		@vel_x -= @friction * delta_x
		@vel_y -= @friction * delta_y
		
	end
	
	def update
		
		self.move
		
		@time = [0, @time - 1.0*$time_diff_ms*60/1000].max
		
		if @time == 0
			
			blue = @color%256
			green = (@color/256)%256
			red = (@color/65536)%256
			alpha = [(@color/16777216)%256 - (8.0*$time_diff_ms*60/1000).round, 0].max
			
			@color = alpha*16777216 + [[red, 0].max, 255].min*65536 + [[green, 0].max, 255].min*256 + [[blue, 0].max, 255].min
		end
		
		if @color == 0x00000000
			$particles.delete(self)
		end
		
	end
	
	def draw
		@img.draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.6, @angle, 0.5, 0.5, @scale, @scale, @color)
	end
	
end
