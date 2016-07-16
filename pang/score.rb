class Score

    def initialize(window)
        @window    = window
        @font      = Gosu::Font.new(@window, Gosu::default_font_name, 24)
        @score     = 0
        @timer     = 600
    end

    def hit
        @score += 1
    end

    def update
        @timer -= 1
        if @timer <= 0
            @window.game_over
        end
    end

    def draw
        @font.draw("Score: #{@score}", @window.width*0.25, 100, 2)
        @font.draw("Timer: #{@timer/6}", @window.width*0.75, 100, 2)
    end

end
