# This controls the player
class Player
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @margin = 5                 # Don't go too close to the edge.

    @image  = Gosu::Image.new('media/halvmaane.png')
    @radius = @image.height     # Read size of player from the image.

    @x = 100
    @y = @window.height - @image.height + @radius - @margin     # This is just a constant.

    # (@x, @y) are the coordinates of the center of the player.
  end

  def move_left
    @x -= 6

    # Make sure player doesn't go off the left side
    @x = [@x, @margin + @radius].max
  end

  def move_right
    @x += 6
 
    # Make sure player doesn't go off the right side
    @x = [@x, @window.width - @radius - @margin].min
  end

  # This controls the movement of the player
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
    @image.draw(@x - @radius, @y - @radius, 0)
  end
end

