class Player
  
  attr_reader :x, :y
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/Fish.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
	@score = 0
	@health = 100
  end

  def warp(x, y)
    @x, @y = x, y
  end
  
  def turn_left
    @angle -= 4.5
  end
  
  def turn_right
    @angle += 4.5
  end
  
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.3)
    @vel_y += Gosu::offset_y(@angle, 0.3)
  end
  
  def update
	if @health <= 0
		return true
	end
	return false
  end
  
  def takedamage(damage)
	@health = @health-damage
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 400
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def shoot 
	@nimph = Nimph.new(@window)
    @nimph.warp(@x, @y, rand(20)+@angle-10)
	return @nimph
  end
  
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
	@font.draw("Player Health: #{@health.round}", 10, 45, 2, 1.0, 1.0, 0xffffff00)
  end
end