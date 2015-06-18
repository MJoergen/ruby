require_relative 'geom.rb'

class Block

	attr_reader :x, :y, :width, :height

	def initialize(window, x, y, width, height)
		@window = window
		@x = x
		@y = y
		@width = width
		@height = height
		@c_fuschia = 0xffff00ff
		@c_black = 0xff000000
		@drawing = false # Used for testing purposes
	end
	
	def update
		# Placeholder
	end
	
	def draw
		if @drawing == true
			@window.draw_quad(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, @c_black, 
							  @x+@width+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, @c_black, 
							  @x+@width+@window.width/2-@window.player_x, @y+@height+@window.height/2-@window.player_y, @c_black, 
							  @x+@window.width/2-@window.player_x, @y+@height+@window.height/2-@window.player_y, @c_black, 4)
			
			@window.draw_quad(@x+@window.width/2-@window.player_x+2, @y+@window.height/2-@window.player_y+2, @c_fuschia, 
							  @x+@width+@window.width/2-@window.player_x-2, @y+@window.height/2-@window.player_y+2, @c_fuschia, 
							  @x+@width+@window.width/2-@window.player_x-2, @y+@height+@window.height/2-@window.player_y-2, @c_fuschia, 
							  @x+@window.width/2-@window.player_x+2, @y+@height+@window.height/2-@window.player_y-2, @c_fuschia, 5)
		end
	end
	
	def checkCollision(cx, cy, radius) # Circle vs Square
		if Geom.collision_circle_box(cx, cy, radius, @x, @y, @width, @height) != 0
			return true
		end
	end
	
end
