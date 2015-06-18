class Square
	
	attr_reader :x, :y, :width, :height
	
	def initialize(window, x, y, width, height)
		@window = window
		@x = x
		@y = y
		@width = width
		@height = height
	end
	
	def draw
		@window.draw_line(@x, @y, 0xff40ff00, @x + @width, @y, 0xff40ff00, 0)
		@window.draw_line(@x + @width, @y, 0xff40ff00, @x + @width, @y + @height, 0xff40ff00, 0)
		@window.draw_line(@x + @width, @y + @height, 0xff40ff00, @x, @y + @height, 0xff40ff00, 0)
		@window.draw_line(@x, @y + @height, 0xff40ff00, @x, @y, 0xff40ff00, 0)
	end

end
