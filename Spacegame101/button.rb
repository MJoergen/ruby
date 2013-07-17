# This script is still W.I.P
class Button# The class for our buttons
  def initialize(window, x, y, w, h, text, textx, texty)
    @x = x
    @y = y
    @w = w
    @h = h
    @textx = textx
    @texty = texty
    @button_image = Gosu::Image.new(window, "media/button.png", false)
    @text = text
    @font = Gosu::Font.new(window, Gosu::default_font_name, 20)
    @mx = window.mouse_x
    @my = window.mouse_y
  end
  def pressed(mx, my)# When a button is pressed, this will check if there is a button there
    return mx > @x && mx < @x + 130 && my > @y && my < @y + 30
  end
  def draw
    @button_image.draw(@x, @y, ZOrder::UI, @w,  @h, 0xffffffff)
    @font.draw(@text, @x + @textx, @y + @texty, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
end

class Upgradebutton < Button
end