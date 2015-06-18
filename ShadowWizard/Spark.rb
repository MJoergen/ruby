class Spark

	attr_reader :x, :y

	def initialize(window, x, y, color)
		@window = window
		@color = color
		@x = x
		@y = y
		@index = 0
		@indextimer = @indextimermax = 3
	end
	
	def update
		@indextimer = [0, @indextimer-1].max
		if @indextimer == 0
			@indextimer = @indextimermax
			@index += 1
			if @index == 4
				$sparks.delete(self)
			end
		end
	end
	
	def draw
		@window.spark_array[@index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.5, 0, 1, 1, 1, 1, @color)
	end
	
end
