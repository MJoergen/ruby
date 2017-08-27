class Score
    def initialize(window)
        @window    = window
        @font      = Gosu::Font.new(@window, Gosu.default_font_name, 24)
        @score     = 0  # Det aktuelle antal points
        @miss      = 0  # Antal straf-point, hvis man rammer ved siden af
        @timer     = 0  # Antal tiendedele sekunder, der er tilbage
        
        # Spillets længde i sekunder.
        # Det skal passe med sangens længde :-)
        @længde    = 2.85 * 60
    end

    def hit(points)
        @score += points
        @miss = (@score / 1000).round * 10
    end

    def miss
        @score -= @miss
        @miss = (@score / 1000).round * 10
    end

    def update
        @timer = (@længde * 10 - Gosu.milliseconds / 100).to_i
        if @timer <= 0
            @window.game_over
        end
    end

    def draw
        points = @window.ball.points
        @font.draw("Hit: #{points}",   @window.width * 0.00,  0, 2)
        @font.draw("Miss: #{@miss}",   @window.width * 0.00, 20, 2)
        @font.draw("Timer: #{@timer}", @window.width * 0.50,  0, 2)
        @font.draw("Score: #{@score}", @window.width * 0.75,  0, 2)
    end
end
