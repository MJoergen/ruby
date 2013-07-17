# This script is still W.I.P
class Asteroid
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff000000)
    @x = rand * 640
    @y = rand * 480
  end
  
  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0, ZOrder::Elements, 1, 1, @color, :add)
  end
end