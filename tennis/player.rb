# This controls the user input from the player
class Player
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @image = Gosu::Image.new('media/halvmåne.png')
    @radius = @image.height
    @margin = 5
    @x = 100
    @y = @window.height - @image.height + @radius - @margin
  end

  def move_left
    @x = [@x - 3, @margin + @radius].max
  end

  def move_right
    @x = [@x + 3,
          @window.width / 2 - @window.wall.width / 2 - @radius - @margin].min
  end

  def update
    if (@window.button_down? Gosu::KbLeft) ||
       (@window.button_down? Gosu::GpLeft)
      move_left
    end

    if (@window.button_down? Gosu::KbRight) ||
       (@window.button_down? Gosu::GpRight)
      move_right
    end
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 2)
  end
end
