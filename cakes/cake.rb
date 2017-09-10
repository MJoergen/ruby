# This controls the movement and display of the ball

class Cake
  # This is it!
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @image  = Gosu::Image.new('media/bold.png')
    @radius = @image.height / 2
    @x      = rand(@window.width - 2*@radius) + @radius
    @y      = 0
    @speed  = rand(4)+2 # Random select values 2, 3, 4, 5
  end

  def update
    @y += @speed
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 0)
  end
end

