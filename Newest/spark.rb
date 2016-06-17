class Spark
	
	attr_reader :x, :y
	
	def initialize(window, pos_x, pos_y, player, vel_x, vel_y, angle, x, y)
		@window = window
		@index = 0
		@angle = angle
		@player = player
		@vel_x = vel_x*1.1
		@vel_y = vel_y*1.1
		@line = 3
		@x = x
		@y = y
		@varx = @player.x
		@vary = @player.y
		@drawx = x
		@drawy = y
		@summonarray = Array.new(12)
		for @i in 0..11
			@summonarray[@i] = Gosu::Image.new(@window, "media/Electricity/#{(@i).floor}.png", false)
		end
	end
	
	def destroy
		@window.destroy_instance(self)
	end
	
	def update
		@index = [12,@index+0.5].min #first number here and below is refering to the exact amount of subimages in the "Elektricity" folder.
		if @index == 12
			self.destroy
		end
		
		if @line > 0 then
			if @window.collisionfighter(@x, @y) and @window.fighterexist then
				@window.fighter.takedamage(9)
				@window.fighter.sparkslow(80)
			end
		end
		
		@line = [0, @line-1].max
		
		@x += @vel_x
		@y += @vel_y
		@drawx += @vel_x
		@drawy += @vel_y
		@x %= 640
		@y %= 400
		self.move
	end
	
	def draw
		@c_yellow = 0xffffff00
		@c_cyan = 0xff90ffff
		
		#@image = Gosu::Image.new(@window, "media/Electricity/#{(@index).floor}.png", false)	
		@summonarray[(@index).floor].draw_rot(@x, @y, 1, @angle)
		
		if @line > 0
			@window.draw_line(@varx, @vary, @c_cyan, @drawx, @drawy, @c_cyan, 1)
			@window.draw_line(@varx-640, @vary, @c_cyan, @drawx-640, @drawy, @c_cyan, 1)
			@window.draw_line(@varx+640, @vary, @c_cyan, @drawx+640, @drawy, @c_cyan, 1)
			@window.draw_line(@varx, @vary-400, @c_cyan, @drawx, @drawy-400, @c_cyan, 1)
			@window.draw_line(@varx, @vary+400, @c_cyan, @drawx, @drawy+400, @c_cyan, 1)
			@window.draw_line(@varx-640, @vary-400, @c_cyan, @drawx-640, @drawy-400, @c_cyan, 1)
			@window.draw_line(@varx-640, @vary+400, @c_cyan, @drawx-640, @drawy+400, @c_cyan, 1)
			@window.draw_line(@varx+640, @vary-400, @c_cyan, @drawx+640, @drawy-400, @c_cyan, 1)
			@window.draw_line(@varx+640, @vary+400, @c_cyan, @drawx+640, @drawy+400, @c_cyan, 1)
		end
	end
	
	def move
		@vel_x *= 0.95
		@vel_y *= 0.95
	end
	
	def checkCollisionC(x,y)
		if @line > 0
			return Gosu::distance(@x, @y, x, y) < 20
		end
	end
	
	def collision_minion
		
	end
	
	def warp(x, y)
		@x, @y = x, y
		@drawx, @drawy = x, y
	end
	
end
