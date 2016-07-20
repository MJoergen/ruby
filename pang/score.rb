class Score

    def initialize(window)
        @window    = window
        @font      = Gosu::Font.new(@window, Gosu::default_font_name, 24)
        @score     = 0
        @timer     = 60*60 # One minute
        @miss      = 0
    end

    def hit(points)
        @score += points
        @miss = (@score/1000).round * 10
    end

    def miss
        @score -= @miss
        @miss = (@score/1000).round * 10
    end

    def update
        @timer -= 1
        if @timer <= 0
            @window.game_over
        end
    end

    def draw
        @font.draw("Miss: #{@miss}", @window.width*0.00, 100, 2)
        @font.draw("Score: #{@score}", @window.width*0.25, 100, 2)
        @font.draw("Timer: #{@timer/6}", @window.width*0.50, 100, 2)
        points = @window.ball.points
        @font.draw("Points: #{points}", @window.width*0.75, 100, 2)
    end

end
