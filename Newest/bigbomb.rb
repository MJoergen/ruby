class BigBomb
	def initialize(window)
		@window = window
		@timer = 90
		@dir = 0
		@index = 0
	end
	
	def not_in_menu #This is just here to identify that the instance does not belong in the menu
	
    end
	
	def kill
		@window.destroy_instance(self)
    end
	
	def update
	
		if @window.menu == true
			self.kill
		end
		
		if @timer <= 0
			#This is the detonation
            for i in 0..11
                @window.create_instance(shoot(i*30))
            end
            @window.destroy_instance(self)
		end
		
		@index = (10-@timer/9).floor
		@timer = [@timer-1, 0].max
	end
	
	def shoot(dir)
		@bigwhale = BigWhale.new(@window)
		@bigwhale.warp(@x, @y, dir)
		return @bigwhale
	end
  
	def warp(x, y)
		@x, @y = x, y
	end
	
	def draw
		@image = Gosu::Image.new(@window, "media/BigBomb/#{@index}.png", false)
		@image.draw(@x-6, @y-6, 1)
	end

  end
