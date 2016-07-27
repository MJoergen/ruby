# This displays the current score on the window.
class Score
  def initialize(window)
    @window    = window
    @font      = Gosu::Font.new(@window, Gosu.default_font_name, 24)
    @score     = 0
    # The value of @timer should match the length of the song.
    @timer     = (2.9 * 60 * 10).to_i # Almost three minutes.
    @miss      = 0
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
    @timer = (2.85 * 60 * 60 - (Gosu.milliseconds * 60) / 1000).to_i
    if @timer <= 0
      @window.game_over
    end
  end

  def draw
    points = @window.ball.points
    @font.draw("Hit: #{points}",       @window.width * 0.00,  0, 2)
    @font.draw("Miss: #{@miss}",       @window.width * 0.00, 20, 2)
    @font.draw("Timer: #{@timer / 6}", @window.width * 0.50,  0, 2)
    @font.draw("Score: #{@score}",     @window.width * 0.75,  0, 2)
  end
end
