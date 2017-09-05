# This displays the centre wall.
class Wall
  attr_reader :width
  attr_reader :height
  attr_reader :x, :y

  def initialize(window)
    @window = window
    @image = Gosu::Image.new('media/bjælke.png')
    @width  = @image.width
    @height = @image.height

    @x = @window.width / 2 - @width / 2
    @y = @window.height - @height
  end

  def draw
    @image.draw(@x, @y, 0)
  end
end
