# This displays the current score
class Score
  attr_reader :player, :bot

  def initialize(window)
    @window    = window
    @font      = Gosu::Font.new(@window, Gosu.default_font_name, 24)
    @dead      = Gosu::Sample.new('media/dead.wav')
    @game_over = Gosu::Sample.new('media/game_over.wav')
    reset
  end

  def reset
    @player    = 5
    @bot       = 5
  end

  def dead_player
    @player -= 1
    if @player <= 0
      @game_over.play
      @window.game_over = true
    else
      @dead.play
    end
  end

  def dead_bot
    @bot -= 1
    if @bot <= 0
      @game_over.play
      @window.game_over = true
    else
      @dead.play
    end
  end

  def draw
    @font.draw(@player.to_s, @window.width * 0.25, 100, 2)
    @font.draw(@bot.to_s, @window.width * 0.75, 100, 2)

    if @window.game_over
      @font.draw('GAME OVER', @window.width * 0.40, 100, 2)
      @font.draw('Tryk R for at spille igen', @window.width * 0.3, 200, 2)
    end
  end
end
