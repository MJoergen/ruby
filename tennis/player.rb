class Player
  
  attr_reader :x, :y, :radius
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/halvmåne.png", false)
	@radius = @image.height
    @margin = 10
	@x = 100
	@y = @window.height - @image.height + @radius - @margin
  end
  
  def move_left
    @x = [@x-3, @margin + @radius].max
  end
  
  def move_right
    @x = [@x+3, @window.width/2 - @window.wall.width/2 - @radius - @margin].min
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
