class Phantom
	
	attr_reader :x, :y
	
	def initialize(window, x, y)
		@window = window
		@x = x
		@y = y
		@sub = 0
		@subtimer = @subtimer_max = 5
		@line_array = []
	end
	
	def set_coords(x, y)
		if Gosu::distance(@x, @y, x, y) > 1000
			@line_array.clear
		end
		@x, @y = x, y
	end
	
	def update
		
		@subtimer = @subtimer-1.0*$time_diff_ms*60/1000
		if @subtimer <= 0
			@sub = rand(7)
			@subtimer += @subtimer_max
		end
		
		line_x = @x + Gosu::offset_x(rand(360), rand(35) + 20)
		line_y = @y + Gosu::offset_y(rand(360), rand(35) + 20)
		@line_array.push(line_x, line_y, 0xff000000)
		
		for i in 0..@line_array.length/3-1
			
			alpha = [(@line_array[i*3+2]/16777216) - (4.0*$time_diff_ms*60/1000).round, 0].max
			
			@line_array[i*3+2] = alpha*16777216
			
			if @line_array[i*3+2] == 0x00000000
				@line_array[i*3+2] = nil
				@line_array[i*3+1] = nil
				@line_array[i*3] = nil
			end
		end
		@line_array.delete(nil)
		
	end
	
	def draw
		@window.phantom_array[@sub].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, 0, 0.5, 0.5, 1.5, 1.5)
		@window.phantom_array[@sub].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.8, 0, 0.5, 0.5, 2.3, 2.3, 0x80ffffff)
		if !@line_array.empty?
			for i in 0..@line_array.length/3-1
				@window.draw_line(@x+@window.width/2-@window.player_x,
								  @y+@window.height/2-@window.player_y,
								  @line_array[i*3+2],
								  @line_array[i*3]+@window.width/2-@window.player_x,
								  @line_array[i*3+1]+@window.height/2-@window.player_y,
								  @line_array[i*3+2],
								  5.9)
			end
		end
	end
	
end