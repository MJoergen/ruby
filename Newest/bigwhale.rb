class BigWhale
	
	attr_reader :x, :y
	
	def initialize(window)
		@image = Gosu::Image.new(window, "media/BigWhale.png", false)
		@speed = 7
		@window = window
	end
	
	def not_in_menu #This is just here to identify that the instance does not belong in the menu
	
    end
	
	def kill
		@window.destroy_instance(self)
    end
	
	def point_direction(x1,y1,x2,y2)
    	return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
	def update
	    move

		@speed += -0.15
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
		if @speed <= 0
            @dire = point_direction(@x,@y,@window.player.x,@window.player.y)
			@window.create_instance(shoot(@dire,0.1))
			@window.destroy_instance(self)
		end

        if @window.collisionplayer(@x, @y, 17) then
			@window.player.takedamage(10)
            @window.destroy_instance(self)
		end
		
		if @window.menu == true
			@window.destroy_instance(self)
		end

	end
	
	def shoot(dir,friction)
		@whale = Whale.new(@window,friction)
		@whale.warp(@x, @y, dir)
		return @whale
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end
	
	def move
		@x += @vel_x
		@y += @vel_y
		@x %= 640
		@y %= 400
	end
	
	def warp(x, y, angle)
		@x, @y = x, y
		@angle = angle
		@vel_x = Gosu::offset_x(@angle, @speed)
		@vel_y = Gosu::offset_y(@angle, @speed)
	end
end
