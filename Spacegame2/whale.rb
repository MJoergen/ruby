class Whale
	
	attr_reader :x, :y
	
	def initialize(window)
		@image = Gosu::Image.new(window, "media/Whale.png", false)
		@speed = 7
	end
	
	def update
		@speed += -0.2
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
		if @speed <= 0
			return true
		end
		return false
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end
	
	def move
		@x += @vel_x
		@y += @vel_y
		return (@x > 640 or @x < 0 or @y > 400 or @y < 0)  # Return true if outside screen
	end
	
	def warp(x, y, angle)
		@x, @y = x, y
		@angle = angle
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
	end
	
	def collision(player)
		if Gosu::distance(player.x, player.y, @x, @y) < 17
			player.takedamage(5)
			return true
		end
		return false
	end
end