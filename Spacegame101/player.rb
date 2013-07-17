# This is the player script
class Player# Here we define the class called player and assigned variables, which we can access from other scripts
  def initialize(window)
    @image = Gosu::Image.new(window, "media/ship.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @sound_collect = Gosu::Sample.new(window, "media/collect.wav")
    @sound_upgrade = Gosu::Sample.new(window, "media/upgrade.wav")
    
    @level = 0
    @score = 0
    @speed = 0.2
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
      @vel_x += Gosu::offset_x(@angle, @speed)
      @vel_y += Gosu::offset_y(@angle, @speed)
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def boost# This function is called when we press the upgrade button "Speed upgrade"
    if @score > 49 && @level < 10
      @score -= 50
      @speed += 0.01
      @level += 1
      @sound_upgrade.play
    end
  end
  
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
    @score
  end
  def level
    @level
  end

  def collect_stars(stars)# This function is called when we hit a star with our ship
    if stars.reject! {|star| Gosu::distance(@x, @y, star.x, star.y) < 35 } then
      @score += 1
      @sound_collect.play
    end
  end
  
  def asteroid_hit(asteroid)
    if asteroid.reject! {|asteroid| Gosu::distance(@x, @y, asteroid.x, asteroid.y) < 35 } then
      close
    end
  end
end