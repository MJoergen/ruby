class Player
  
  attr_reader :x, :y, :energy, :energymax, :dead
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/Fish.png", false)
	@bar = Gosu::Image.new(@window, "media/Bar.png", false)
    @bar2 = Gosu::Image.new(@window, "media/Bar2.png", false)
	@speedbuff = Gosu::Image.new(@window, "media/Aspeed.png", false)
	@quad = 0
	@x = @y = @vel_x = @vel_y = @angle = 0.0
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
  end
  
  def create
	@x = @y = @vel_x = @vel_y = @angle = 0.0
	@health = @maxhealth = 80
	@healthregen = 0.02
	@superinitiate = false
	@supercooldownmax = 200
	@lasermax = 5
	@lasercost = 3
	@elmax = 4
	@elcost = 3
	@aspeedmax = 200 #The amount of steps before your attackspeedbuff runs out
	@energy = @energymax = 300
	@energyregen = 0.4
	@energydelay = 0
	@superchannelmax = 30
	@super = 0
    @weaponenable = true
	@supershotenable = true
	@dead = false
	@speed_timer = 0
	@speed_display = 0
	self.warp(rand(440)+100, rand(200)+100)
  end

  def warp(x, y)
    @x, @y = x, y
  end
  
  def turn_left
    @angle -= 3.5
	@angle = @angle % 360
  end
  
  def turn_right
    @angle += 3.5
	@angle = @angle % 360
  end
  
  def reset_aspeed(arg)
	@lasermax = 5
	@elmax = 4
  end
  
  def getbuff(type)
	
	case(type)
	
	when "S"
		@lasermax = 2
		@elmax = 2
		@window.startTimer(@aspeedmax, self.method( :reset_aspeed ), 0 )
	when "E"
		@energy = [@energy + 100 ,@energymax].min
	when "H"
		@health = [@health + 30 ,@maxhealth].min
	
	end
  end
  
  def accelerate
    if @superinitiate == false
		@vel_x += Gosu::offset_x(@angle, 0.25)
		@vel_y += Gosu::offset_y(@angle, 0.25)
    end
  end
  
  def supershot
	@supnimph = Supnimph.new(@window)
	@supnimph.warp(@x, @y, @angle)
	return @supnimph
  end

  def weaponenable(arg)
    @weaponenable = true
  end
  
  def endsuperchannel(arg)
	if @superinitiate == true
		@superinitiate = false
		@window.create_instance(supershot)
	end
  end
  
  def endsupercooldown(arg)
	@supershotenable = true
  end
  
  def update
	
	@speed_timer = @speed_timer+1
	if @x < 40 and @speed_timer > 10
		@speed_display = @speed_timer
		@speed_timer = 0
	end
	
	#Controls the energy for the player
	if @energy < @energymax and @weaponenable == true and @energydelay == 0
		@energy = [@energy+@energyregen, @energymax].min
	end

	#Controls the delay before the energy-regeneration
	@energydelay = [0, @energydelay-1].max
	
	# If you press "Z"
	if @window.button_down? Gosu::KbZ and @weaponenable
		if @window.slot1 == 1 and @energy > @lasercost then
			# Create Shot!
			@window.create_instance(shoot)
			@window.startTimer(@lasermax, self.method( :weaponenable ), 0 )
			@weaponenable = false
			@energy = [0, @energy-@lasercost].max
			@energydelay = 10
		end
		if @window.slot1 == 2 and @energy > @elcost then
			# Create Shot!
			@window.create_instance(spark)
			@window.startTimer(@elmax, self.method( :weaponenable ), 0 )
			@weaponenable = false
			@energy = [0, @energy-@elcost].max
			@energydelay = 30
		end
	end
	# If you press "X" (AKA Channel the supershot!)
	if @window.button_down? Gosu::KbX and @energy >= 100 and @superinitiate == false and @supershotenable and @window.slot2 == 1
		@superinitiate = true
		@supershotenable = false
		@supercooldown = @window.startTimer(@supercooldownmax, self.method( :endsupercooldown ), 0 )
		@superchannel = @window.startTimer(@superchannelmax, self.method( :endsuperchannel ), 0 )
		@energy += -100
		@energydelay = 30
	end
	
	if @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft then
		turn_left
	end
	
	if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight then
		turn_right
	end
    
	if @window.button_down? Gosu::KbUp or @window.button_down? Gosu::GpButton0 then
		accelerate
	end
	
	move
	
	if @health <= 0
		@dead = true
		@window.startmenu
		return true
	end
	@health = [@maxhealth , @health + @healthregen].min
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
  
  def spark
	pos_x = Gosu::offset_x(@angle-25+rand(50), 4+Math.sqrt((@vel_x.abs)**2 + (@vel_y.abs)**2)*(34/4.75)+rand(27))
	pos_y = Gosu::offset_y(@angle-25+rand(50), 4+Math.sqrt((@vel_x.abs)**2 + (@vel_y.abs)**2)*(34/4.75)+rand(27))
	angle = point_direction(@x, @y, @x + pos_x, @y + pos_y)
	@spark = Spark.new(@window, pos_x, pos_y, self, @vel_x, @vel_y, @angle, @x, @y)
    @spark.warp(@x + pos_x, @y + pos_y)
	return @spark
  end
  
  def point_direction(x1,y1,x2,y2)
	return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
  end
  
  def draw
    @c_fuschia = 0xffff00ff
	@c_black = 0xff000000
	@c_yellow = 0xffffff00
	@c_green = 0xff00ff60
	@c_red = 0xffff0000
	@image.draw_rot(@x, @y, 2, @angle)
	@font.draw("Player Health: #{@health.round}", 10, 45, 2, 1.0, 1.0, @c_yellow)
	@font.draw("Graphics: #{@window.graphics}", 145, 25, 2, 1.0, 1.0, @c_yellow)
	#@font.draw("Speed: #{Math.sqrt((@vel_x.abs)**2 + (@vel_y.abs)**2)}", 140, 5, 2, 1.0, 1.0, @c_yellow)
	if @lasermax < 5
		@speedbuff.draw_rot(@x, @y, 2, @angle)
	end
	if @health > 0
		# Draw Healthbar!!
		@window.draw_bar(@x-15,@y-20,@x+15,@y-16,(@health*1.0)/@maxhealth,@c_green,@c_red,@c_black,true)
	end
	# Draw the channel-bar
	if @superinitiate == true
		@window.draw_bar(@x-15,@y-26,@x+15,@y-22,(@superchannel.getvalue*1.0)/@superchannelmax,@c_fuschia,0,0,false)
	end
	# Draw the cooldown-bar
	if @supershotenable == false
		@window.draw_bar(150,4,350,10,(@supercooldown.getvalue*1.0)/@supercooldownmax,@c_fuschia,0,@c_black,true)
	end
  end
  
end
