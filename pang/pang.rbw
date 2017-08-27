require 'gosu'

require_relative 'ball.rb'
require_relative 'score.rb'

class GameWindow < Gosu::Window
    attr_reader :ball

    def initialize
        super(640, 400, false, 2)
        self.caption = 'Pang Game'

        @ball      = Ball.new(self)
        @score     = Score.new(self)
        @music     = Gosu::Song.new('media/popeye.ogg')
        @game_over = Gosu::Sample.new('media/game_over.wav')
        @playing   = true
        @music.play
    end

    def needs_cursor?
        true
    end

    # Denne metode bliver kaldt 60 gange i sekundet.
    # Bruges til at flytte bolden, opdatere score, osv.
    def update
        if @playing
            @ball.update
            @score.update
        end
    end

    # Denne metode kaldes også 60 gange i sekundet.
    # Bruges til at tegne de forskellige objekter.
    def draw
        @ball.draw
        @score.draw
    end

    def game_over
        @game_over.play
        @playing = false
    end

    # This checks when you press ESC
    def button_down(id)
        if id == Gosu::KbEscape
            close
        end

        if id == Gosu::MsLeft && @playing
            if Gosu.distance(mouse_x, mouse_y, @ball.x, @ball.y) < @ball.radius
                @score.hit @ball.points
                @ball.clicked
            else
                @score.miss
            end
        end
    end
end

GameWindow.new.show

