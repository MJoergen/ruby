# This adds the "gosu" library to the game, which enables various extra features!
require 'gosu'

# These are nessecary for THIS code/file to cooperate with the other files/codes
require_relative 'ball.rb'

# This adds the actual "object" to the game, which in this case works as a controler!	
class GameWindow < Gosu::Window
    # This is the event that occurs when you start the game, like when the object is "created"

    def initialize
        super(640, 400, false)
        self.caption = "Pang Game"

        @ball      = Ball.new(self)
    end
    
    def needs_cursor?
        true
    end

    # This event is checked 60 times per second.
    def update
        @ball.update
    end

    # This controls the graphics in the game. Also checks around 60 times per second...
    def draw
        @ball.draw
    end

    # This checks when you press ESC
    def button_down(id)
        if id == Gosu::KbEscape
            close
        end

        if id == Gosu::MsLeft
            if Gosu::distance(mouse_x, mouse_y, @ball.x, @ball.y) < @ball.radius
                @ball.clicked
            end
        end
    end

end

window = GameWindow.new
window.show

