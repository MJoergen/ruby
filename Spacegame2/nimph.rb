class Nimph
  
  attr_reader :x, :y
  
  def initialize(window)
	@image = Gosu::Image.new(window, "media/Nimph.png", false)
    @vel_x = @vel_y = 0
  end
  
  def move
	@x += @vel_x
    @y += @vel_y
    return (@x > 640 or @x < 0 or @y > 400 or @y < 0)  # Return true if outside screen
  end
  
  def warp(x, y, angle)
    @x, @y = x, y
	@angle = angle
	@vel_x = Gosu::offset_x(@angle, 9)
    @vel_y = Gosu::offset_y(@angle, 9)
  end
  
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end