class Light
	
	attr_reader :x, :y
	
	def initialize(window, x, y, scale, color, blur, follow_camera)
		@window = window
		@x = x
		@y = y
		@scale = scale
		@color = color
		@blur = blur
		@follow_camera = follow_camera
		case blur
			when 0
				@radius = @scale*50
			when 1
				@radius = @scale*80
			when 2
				@radius = @scale*100
		end
	end
	
	def set_coords(x, y)
		@x, @y = x, y
	end
	
	def set_scale(scale)
		@scale = scale
	end
	
	def set_color(color)
		@color = color
	end
	
	def set_blur(blur)
		@blur = blur
	end
	
	def get_x
		return @x
	end
	
	def get_y
		return @y
	end
	
	def get_scale
		return @scale
	end
	
	def get_color
		return @color
	end
	
	def draw

		if @follow_camera == true
			if @x.between?(0 - @radius, @window.width + @radius) and @y.between?(0 - @radius, @window.height + @radius)
				@window.light_array[@blur].draw_rot(@x, @y, 9.5, 0, 0.5, 0.5, @scale, @scale, @color, :additive)
			end
		else
			if (@x+@window.width/2-@window.player_x).between?(0 - @radius, @window.width + @radius) and
				(@y+@window.height/2-@window.player_y).between?(0 - @radius, @window.height + @radius)
				@window.light_array[@blur].draw_rot(@x+@window.width/2-@window.player_x,
													@y+@window.height/2-@window.player_y,
													9.5, 0, 0.5, 0.5, @scale, @scale, @color, :additive)
			end
		end
	end
	
end
