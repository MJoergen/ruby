class Bomb
	def initialize(window)
		@window = window
		@timer = 90
		@dir = 0
		@index = 0
	end
	
	def update
		if @timer <= 0
			#This is the detonation
			return true
		end
		
		@index = (10-@timer/9).floor
		
		@timer = [@timer-1, 0].max
		return false
	end
	
	def shoot(dir)
		@whale = Whale.new(@window)
		@whale.warp(@x, @y, dir)
		return @whale
	end
  
	def warp(x, y)
		@x, @y = x, y
	end
	
	def draw
		@image = Gosu::Image.new(@window, "media/Bomb/#{@index}.png", false)
		@image.draw(@x, @y, 1)
	end

  end