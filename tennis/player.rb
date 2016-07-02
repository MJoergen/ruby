class Player
  
  attr_reader :x, :y, :radius
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/halvmåne.png", false)
	@x = 100
	@y = 360
	@radius = 30
  end
  
  def move_left
	@x -= 3
	if @x < 40
		@x = 40
	end
  end
  
  def move_right
	@x += 3
	if @x > 600
		@x = 600
	end
  end
  
  def update
	
	if @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft then
		move_left
	end
	
	if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight then
		move_right
	end
	
  end
  
  def draw
	@image.draw(@x-@radius, @y-@radius, 2)
  end
  
end
