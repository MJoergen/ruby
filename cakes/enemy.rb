# This controls the movement and display of the enemies

class Enemy
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @beep   = Gosu::Sample.new('media/dead.wav')

    @image  = Gosu::Image.new('media/Point_big.png')
    @radius = @image.height / 2

    @x      = rand(@window.width - 2*@radius) + @radius
    @y      = 0
  end

  def update
    @y += 3
  end

  def dead?
    if Gosu::distance(@x, @y, @window.player.x, @window.player.y) < @radius + @window.player.radius then
      @beep.play
      @window.score.dead
      true # Remove enemy
    elsif y > @window.height # Remove enemy if beyond screen
      true # Remove enemy
    else
      false # Leave the cake alone!
    end
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 0)
  end
end

