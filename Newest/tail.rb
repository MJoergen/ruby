class Tail
	
	attr_reader :x, :y
	
	def initialize(window, x, y)
		@window = window
		@index = 0
		@x = x
		@y = y
		@angle = 0
	end
	
	def destroy
		@window.destroy_instance(self)
	end
	
	def update
		@index = [8,@index+1].min #first number here and below is refering to the exact amount of subimages in the "Elektricity" folder.
		if @index == 8
			self.destroy
		end
	end
	
	def draw
		@c_yellow = 0xffffff00
		@c_cyan = 0xff90ffff
		
		@image = Gosu::Image.new(@window, "media/Tail/#{(@index).floor}.png", false)
		@image.draw_rot(@x, @y, 1, @angle)
	end
end
