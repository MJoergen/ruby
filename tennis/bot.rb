# This is the AI for the opponent
class Bot
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @image = Gosu::Image.new('media/halvmåne.png')
    @radius = @image.height
    @margin = 5
    @x = 400
    @y = @window.height - @image.height + @radius - @margin
    @vel_x = -3
  end

  def update
    # Calculate movement of the bot.
    @vel_x = (@window.ball.x + 5) - @x  # Aim slightly to the right of the ball.
    @vel_x = [3, @vel_x].min            # Limit the speed of the bot.
    @vel_x = [-3, @vel_x].max

    # Move the bot.
    @x += @vel_x

    # Make sure bot stays in the game.
    @x = [@x, @window.width / 2 + @window.wall.width / 2 + @radius + @margin].max
    @x = [@x, @window.width - @radius - @margin].min
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 0)
  end
end
