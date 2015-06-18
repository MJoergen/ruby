class Server_Crate

	attr_reader :x, :y, :width, :height

	def initialize(x, y)
		@x = x
		@y = y
		@width = 34
		@height = 34
	end
	
	def destroy_at_position(x, y)
		if @x == x.to_i and @y == y.to_i
			return true
		end
	end
	
	def checkCollisionB(cx, cy, radius) # This is a collision detection between a circle and a rectangle.
        if Geom.collision_circle_box(cx, cy, radius, @x, @y, @width, @height) != 0
			return true
		end
    end
	
end