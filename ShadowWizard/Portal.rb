class Portal
	
	attr_reader :x, :y, :id, :color
	
	def initialize(window, x, y, color, angle, id)
		@x = x
		@y = y
		@id = id
		@window = window
		@color = color
		@angle = angle
		@sub = 0
		@sub_timer_max = 5
		@sub_timer = 0
		
		@light_color = @color
		@light_scale = 0.6
		@light1 = @window.create_light(@x, @y, @light_scale, @light_color, 2, false)
	end
	
	def destroy
		@window.destroy_light(@light1)
		$portals.delete(self)
	end
	
	def update
		
		@sub_timer = @sub_timer - 1.0 * $time_diff_ms*60/1000
		
		# Animation
		if @sub_timer <= 0
			
			@sub_timer += @sub_timer_max
			
			# Change subimage
			@sub += 1
			@sub = @sub % 20
			
			# Change color and size of the light
			blue = @light_color%256
			green = (@light_color/256)%256
			red = (@light_color/65536)%256
			alpha = (@light_color/16777216)%256
			
			
			@light1.set_color(alpha*16777216 + [[red-15+rand(30), 0].max, 255].min*65536 + [[green-15+rand(30), 0].max, 255].min*256 + [[blue-15+rand(30), 0].max, 255].min)
			
			scale_rand = rand(6)
			@light1.set_scale(@light_scale - 0.03 + scale_rand.to_f/100)
		end
	end
	
	def checkCollision(x, y, r) # r is necessary for the other collisions
		return Gosu::distance(@x, @y, x, y) < 22
	end
	
	def draw
		@window.portal_array[@sub].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.5, @angle, 0.5, 0.5, 1, 1, @color)
		@window.portal_edge.draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.5, @angle, 0.5, 0.5, 1, 1, 0xffffffff)
	end
	
end
