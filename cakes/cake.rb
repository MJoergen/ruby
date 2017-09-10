# This controls the movement and display of alle the cakes

class Cake
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @beep   = Gosu::Sample.new('media/beep.wav')

    @image  = Gosu::Image.new('media/filled_circle.png')
    @scale  = 0.3 # Billed-filen er alt for stor, så den skal skaleres ned.
    @radius = @image.height / 2 * @scale

    @x      = rand(@window.width - 2*@radius) + @radius
    @y      = 0
  end

  def update
    @y += 3
  end

  def dead?
    if Gosu::distance(@x, @y, @window.player.x, @window.player.y) < @radius + @window.player.radius then
      @beep.play
      @window.score.add(1)
      true # Remove cake
    else
      y > @window.height # Remove cake if beyond screen
    end
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 0, @scale, @scale)
  end
end

