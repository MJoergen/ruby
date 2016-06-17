class Minion

  attr_reader :x, :y, :angle
  
  def initialize(window)
    @window = window
	@point = Gosu::Image.new(@window, "media/Point.png", false)
	@slowimage = Gosu::Image.new(@window, "media/Slow2.png", false)
	@shootcur = @shootrate = 60
	@slow = 1
	@slowtime = 0
	@angle = 0
	@vel_x = 0
	@vel_y = 0
	@dir_change_cur = @dir_change_max = 80
	@getx = rand(440)+100
	@gety = rand(200)+100
	@doubleshot = false
	@doubletimer = @doublemax = 6
	@health = @maxhealth = 70
	@summontime = 45
	@summoning = true
	@minionindex = 0
	@index = 1
	@indexdelay = @indexdelaymax = 5
	@color = 0x10101010
	@summonarray = Array.new(10)
	for @i in 1..9
		@summonarray[@i] = Gosu::Image.new(@window, "media/Summon/#{@i}.png", false)
	end
  end
  
  def point_direction(x1,y1,x2,y2)
	return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
  end
  
  def shoot
	@friction = 0
	@dir = point_direction(@x,@y,@window.player.x,@window.player.y)+rand(10)-5
	@whale = Whale.new(@window,@friction)
	@whale.warp(@x, @y, @dir)
	return @whale
  end
  
  def warp(x, y)
    @x, @y = x, y
  end
  
  def not_in_menu #This is just here to identify that the instance does not belong in the menu
	
  end
  
  def takedamage(damage)
	@health = @health-damage
  end
  
  def minion #This is also here to identify the minion itself
	
  end
  
  def kill
	@window.destroy_instance(self)
  end
  
  def index
	if @index > 8
		@index = 1
	else
		@index += 1
	end
  end
  
  def update
	
	# Slow
	@slowtime = [0, @slowtime-1].max
	if @slowtime == 0
		@slow = 1
	end
	
	# Check health and do not belong in menu :P
    if @health <= 0 or @window.menu == true
		self.kill
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
	else
		@shootcur = [0, @shootcur-1].max
		@dir_change_cur = [0, @dir_change_cur-1].max
		
		if @doubleshot == true
			@doubletimer = [0, @doubletimer-1].max
			if @doubletimer == 0
				@doubletimer = @doublemax
				@window.create_instance(shoot)
				@doubleshot = false
			end
		end
		
		if @shootcur == 0
			@shootcur = @shootrate
			@window.create_instance(shoot)
			@doubleshot = true
		end
		
		# Accelerate!
		@vel_x += Gosu::offset_x(@angle, 0.17)
		@vel_y += Gosu::offset_y(@angle, 0.17)
		
		#Check Collision
		
		
		@window.checkCollision( @x, @y, method(:collision_nimph), "checkCollisionA")
		@window.checkCollision( @x, @y, method(:collision_supnimph), "checkCollisionB")
		@window.checkCollision( @x, @y, method(:collision_spark), "checkCollisionC")
		
		#Move!
		self.move
	
		if @dir_change_cur == 0 # Change Direction
			@dir_change_cur = @dir_change_max
			@getx = rand(640)
			@gety = rand(400)
		end
	
		@getdir = point_direction(@x,@y,@getx,@gety)
		@dir_to_turn = @getdir - @angle
		# Make sure that dir_to_turn is between -180 and 180
		
		if @dir_to_turn >= 180
			@dir_to_turn += -360
		end
	
		if @dir_to_turn <= -180
			@dir_to_turn += 360
		end
	
		if @dir_to_turn > 0 # Turn right
			turn_right
		end	
	
		if @dir_to_turn < 0 # Turn left
			turn_left
		end	
	
	end
	
	return false
  end
  
  def collision_nimph(inst)   # If there is a collision do the following:
    self.takedamage(8)        # Take 7 damage...
    inst.collision_minion     # The instance you collide with shall call collision_minion
  end
  
  def collision_supnimph(inst)   # If there is a collision do the following:
    self.kill                    # Die!
    inst.collision_minion        # The instance you collide with shall call collision_minion
  end
  
  def collision_spark(inst)      # If there is a collision do the following:
    self.takedamage(2)           # Take damage
    inst.collision_minion        # The instance you collide with shall call collision_minion
	self.sparkslow(70)           # Get slowwwed
  end
  
  def sparkslow(time)
	@slow = 0.4
	@slowtime = time
  end
  
  def turn_left
    @angle -= 4
	@angle = @angle % 360
  end

  def turn_right
    @angle += 4
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
  
  def targetable(sender)
	#self.kill
	@slow = 0.4
	@slowtime = 60
  end
  
  def draw
	
	@c_black = 0xff000000
  	@c_green = 0xff00ff60
	@c_red = 0xffff0000
	@c_yellow = 0xffffff00
	
	@image = Gosu::Image.new(@window, "media/Minion/#{@minionindex}.png", false)
	@image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, @color) #The minion itself
	@window.draw_bar(@x-16,@y-20,@x+16,@y-16,(@health*1.0)/@maxhealth,@c_green,@c_red,@c_black,true) #Healthbar...
	#@point.draw_rot(@getx, @gety, 1, @angle, 0.5, 0.5, 1, 1)
	
	if @summoning == true
		#@summon = Gosu::Image.new(@window, "media/summon/#{@index}.png", false)
		@summonarray[@index].draw(@x-16, @y-16, 1)
	end
	
	if @slow < 1
		@slowimage.draw_rot(@x, @y, 2, @angle, 0.5, 0.5, 1, 1)
	end
	
  end
end
