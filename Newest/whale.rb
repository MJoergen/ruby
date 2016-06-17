class Whale
	
	attr_reader :x, :y
	
	def initialize(window,friction)
		@image = Gosu::Image.new(window, "media/Whale.png", false)
		@speed = 6.5
		@friction = friction
		@window = window
	end
	
	def not_in_menu #This is just here to identify that the instance does not belong in the menu
	
	end
	
	def kill
		@window.destroy_instance(self)
    end
	
	def update
		@x += @vel_x
		@y += @vel_y
		if (@x > 640 or @x < 0 or @y > 400 or @y < 0) then # Return true if outside screen
            @window.destroy_instance(self)
        end
		@speed += -@friction
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
		if @speed <= 0
            @window.destroy_instance(self)
		end

        if @window.collisionplayer(@x, @y, 17) then
			@window.player.takedamage(5)
            @window.destroy_instance(self)
		end
		
		if @window.menu == true
			@window.destroy_instance(self)
		end
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end
	
	def warp(x, y, angle)
		@x, @y = x, y
		@angle = angle
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
	end
	
end
