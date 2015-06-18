class Server_Block

	attr_reader :x, :y, :width, :height

	def initialize(x, y, width, height)
		@x = x
		@y = y
		@width = width
		@height = height
	end
	
	def checkCollisionA(cx, cy, radius) # Circle vs Square
		if Geom.collision_circle_box(cx, cy, radius, @x, @y, @width, @height) != 0
			return true
		end
	end
	
end