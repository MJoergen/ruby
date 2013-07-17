class Fighter
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/Fighter.png", false)
    @x = @y = @vel_x = @vel_y = 0.0
    @score = 0
	@domove = false
	@angle = @directionget = 0
	@turning = true
	@dirswap = 0
	@dirswapmax = 30
	@health = @maxhealth = 40
	@font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
	@color = 0xfefefefe
	@bombtimer = @bombtimermax = 50
  end
  
  def shoot 
	@bomb = Bomb.new(@window)
	@bomb.warp(@x, @y)
	return @bomb
  end
  
  def warp(x, y)
    @x, @y = x, y
  end
  
  def updatebombtimer
	@bombtimer = [@bombtimer-1, 0].max
	if @bombtimer == 0 and @health > 0
		@bombtimer = @bombtimermax
		return true
	end
	return false
  end
  
  def collision(nimphs)
	if @health > 0
		if nimphs.reject! {|nimph| Gosu::distance(@x, @y, nimph.x, nimph.y) < 17 } then
		@health -= 5
		end
	end
  end
  
  def update
	
	if @health <= 0
		@color -= 0x02020202
		if @color == 0
			return true # Tell the gamewindow that we are now dead.
		end
		
		return false # Don't do anything, just stand still while fading.
	end
	
	accelerate
	move
	@dirswap = [@dirswap+1, @dirswapmax].min
	if @dirswap == @dirswapmax
		@dirswap = 0
		@directionget = rand(360)
	end
		
	if @turning == true
		    
		@dir_to_turn = @directionget - @angle
		# Make sure that dir_to_turn is between -180 and 180
		
		if @dir_to_turn >= 180
			@dir_to_turn += -360
		end
		
		if @dir_to_turn <= -180
			@dir_to_turn += 360
		end
		
		if @dir_to_turn > 0 # Turn right
			turn_left
		end	
		
		if @dir_to_turn < 0 # Turn left
			turn_right
		end	
	end
	
	return false
  
  end
  
  def turn_left
    @angle -= 4
	if @angle < 0
		@angle += 360
	end
  end
  
  def turn_right
    @angle += 4
	if @angle >= 360
		@angle -=360
	end
  end
  
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.2)
    @vel_y += Gosu::offset_y(@angle, 0.2)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 400
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  
  def draw
    @image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, @color)
	@font.draw("Fighter Health: #{@health.round}", 10, 25, 2, 1.0, 1.0, 0xffffff00)
  end
end