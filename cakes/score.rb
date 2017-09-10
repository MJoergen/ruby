# This displays the current score
class Score

  def initialize(window)
    @window    = window
    @font      = Gosu::Font.new(@window, Gosu.default_font_name, 24)
    @health    = 3
    @points    = 0
  end

  def add(val) # When we hit a cake
    @points += val
  end

  def dead     # When we hit an enemy
    @health -= 1
  end

  def draw
    @font.draw("Points=#{@points}, Health=#{@health}", @window.width * 0.25, @window.height * 0.1, 1)
  end
end
