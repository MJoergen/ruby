# This adds the "gosu" library to the game, which enables various extra features!
require 'gosu'

# These are nessecary for THIS code/file to cooperate with the other files/codes
require_relative 'player.rb'
require_relative 'ball.rb'
require_relative 'wall.rb'
require_relative 'bot.rb'
require_relative 'score.rb'

# This adds the actual "object" to the game, which in this case works as a controler!	
class GameWindow < Gosu::Window
  # This is the event that occurs when you start the game, like when the object is "created"
  attr_reader :player
  attr_reader :wall
  attr_reader :ball
  attr_reader :bot
  attr_reader :score
  
  def initialize
	super(640, 400, false)
    self.caption = "Tennis Game"
    
	@player = Player.new(self)
	@bot    = Bot.new(self)
	@ball   = Ball.new(self)
	@wall   = Wall.new(self)
    @score  = Score.new(self)
  end

  # This event is checked 60 times per second.
  def update
	@player.update
	@bot.update
	@ball.update
    # No need to call update on wall, since it doesn't move :-)
  end
  
  # This controls the graphics in the game. Also checks around 60 times per second...
  def draw
	@player.draw
	@bot.draw
	@ball.draw
	@wall.draw
	@score.draw
  end

  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
  
  def ball_collision_player(bx, by, radius, meth)
	if Gosu::distance(@player.x, @player.y, bx, by) <= @player.radius + radius
		meth.call(@player)
	end
  end
end

window = GameWindow.new
window.show

