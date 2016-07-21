class Score

    def initialize(window)
        @window    = window
        @font      = Gosu::Font.new(@window, Gosu::default_font_name, 24)
        @score     = 0
        @timer     = (2.9*60*60).to_i # Almost three minutes. This matches the length of the song.
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
        points = @window.ball.points
        @font.draw("Hit: #{points}",     @window.width*0.00,  0, 2)
        @font.draw("Miss: #{@miss}",     @window.width*0.00, 20, 2)

        @font.draw("Timer: #{@timer/6}", @window.width*0.50,  0, 2)
        @font.draw("Score: #{@score}",   @window.width*0.75,  0, 2)
    end

end
