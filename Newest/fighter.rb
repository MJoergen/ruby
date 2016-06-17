class Fighter

  attr_reader :x, :y, :angle, :dead
  
  def initialize(window)
    @window = window
	@bar = Gosu::Image.new(@window, "media/Bar.png", false)
    @bar2 = Gosu::Image.new(@window, "media/Bar2.png", false)
    @x = @y = @vel_x = @vel_y = 0.0
    @score = 0
	@font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
	@slowimage = Gosu::Image.new(@window, "media/Slow.png", false)
  end
  
  def create
    #@oldcolor = 0xfefefefe
	@color = 0x10101010
    @summontime = 45
	@summoning = true
	@domove = false
	@angle = @directionget = 0
	@turning = true
	@dirswapcur = @dirswapmax = 40
	#@window.startTimer(@dirswapmax, self.method( :set_direction ), 0 )
	@health = @maxhealth = 500
	@bombtimercur = @bombtimermax = 40
	#@window.startTimer(@bombtimermax, self.method( :create_bomb ), 0 )
	@bombshuffle = @bombshufflemax = 6
	warp(rand(640), rand(400))
	@vel_x = @vel_y = 0.0
	@slow = 1
	@supslow = 1
	@supslowtime = 0
	@sparkslow = 1
	@sparkslowtime = 0
	@dead = false
	self.warp(rand(440)+100, rand(200)+100)
	@fighterindex = 0
	@index = 1
	@indexdelay = @indexdelaymax = 5
	@redtime = 0
  end
  
  def shoot 
	@bomb = Bomb.new(@window)
	@bomb.warp(@x, @y)
	return @bomb
  end
  
  def bigshoot 
	@bigbomb = BigBomb.new(@window)
	@bigbomb.warp(@x, @y)
	return @bigbomb
  end
  
  def create_bomb(arg)
	# Only create bomb when living!
	if @health > 0
		@bombshuffle = [@bombshuffle-1, 0].max
			if @bombshuffle > 0
				@window.create_instance(shoot)
			else
				@window.create_instance(bigshoot)
				@bombshuffle = @bombshufflemax
			end
	end
  end
  
  def warp(x, y)
    @x, @y = x, y
  end
  
  def takedamage(damage)
	@health = @health-damage
  end

  def takesupdamage
    @health = @health-150
  end
  
  def supslow(time)
	@supslow = 0.5
	@supslowtime = time
  end
  
  def sparkslow(time)
	@sparkslow = 0.4
	@sparkslowtime = time
  end
  
  def kill
	@dead = true
  end
  
  def respawn #This is what happends after the fighter has finished the death animation. This is where it returns to the menu...
	#@dead = true #This might look stupid, but its necessary for the fighter to stop updating/drawing while playing other challenges!
	@window.startmenu
  end
  
  def update #UPDATE --------------------------------------------------- UPDATE#
	
	#Slooooow
	@slow = [@supslow, @sparkslow].min
	
	if @slow < 1 #Only update and check slowtimer when being slowed! (it makes it faster)
		#Sparkslow
		@sparkslowtime = [0, @sparkslowtime-1].max
		if @sparkslowtime == 0
			@sparkslow = 1
		end
		
		#Supslow
		@supslowtime = [0, @supslowtime-1].max
		if @supslowtime == 0
			@supslow = 1
		end
	end
	
	# Summoning animation
	@indexdelay = [@indexdelay-1,0].max
	if @indexdelay == 0
		@indexdelay = @indexdelaymax
		self.index
	end
	# Summoning timer
	if @summoning == true
		@summontime = [@summontime-1, 0].max
		@color += 0x05050505
		if @summontime == 0
			@summoning = false
		end
	end
	
	# Check health!
	if @health <= 0
		@color -= 0x01010101
		if @window.menuwaiting == false and @summoning == false
			@window.menutimer(120)
		end
		return
	end
	
	if @summoning == false
		#Timers
		@dirswapcur = [@dirswapcur-1, 0].max
		@bombtimercur = [@bombtimercur-1, 0].max
		
		if @dirswapcur <= 0
			@dirswapcur = @dirswapmax
			self.set_direction(0)
		end
		
		if @bombtimercur <= 0 and @dead == false
			@bombtimercur = @bombtimermax
			self.create_bomb(0)
		end
		
		# Accelerate!
		@vel_x += Gosu::offset_x(@angle, 0.15)
		@vel_y += Gosu::offset_y(@angle, 0.15)
		
		#Move!
		self.move
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
  
  def index
	if @index > 8
		@index = 1
	else
		@index += 1
	end
  end
  
  def set_direction(arg)
	@directionget = rand(360)
  end
  
  def turn_left
    @angle -= 3.2
	@angle = @angle % 360
  end

  def turn_right
    @angle += 3.2
	@angle = @angle % 360
  end
  
  def move
    @x += @vel_x*@slow
    @y += @vel_y*@slow
    @x %= 640
    @y %= 400
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  
  def draw
  	
	@c_black = 0xff000000
  	@c_green = 0xff00ff60
	@c_red = 0xffff0000
	@c_yellow = 0xffffff00
	@image = Gosu::Image.new(@window, "media/Fighter/#{@fighterindex}.png", false)
	@image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, @color) #The fighter itself
	if @health > 0
		@window.draw_bar(@x-16,@y-20,@x+16,@y-16,(@health*1.0)/@maxhealth,@c_green,@c_red,@c_black,true)
	end
	@font.draw("Fighter Health: #{@health.round}", 10, 25, 2, 1.0, 1.0, @c_yellow)
	
	if @summoning == true
		@summon = Gosu::Image.new(@window, "media/Summon/#{@index}.png", false)
		@summon.draw(@x-16, @y-20, 1)
	end
	
	if @slow < 1
		@slowimage.draw_rot(@x, @y, 2, @angle, 0.5, 0.5, 1, 1)
	end
  end
end
