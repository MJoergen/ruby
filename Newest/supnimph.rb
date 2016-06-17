class Supnimph
  
  attr_reader :x, :y
  
  def initialize(window)
    @vel_x = @vel_y = 0
    @window = window
	@directions = [] #Make array for directions (movement AI)
	@timeleft = @window.startTimer(135, self.method( :delete ), 0 )
	@test = 0
	@font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
	@target_scope = Gosu::Image.new(@window, "media/Target.png", false)
  end
  
  def get_target
	@target = nil

	# Get array of possible targets.
	@targets = @window.find_target
	@best_dist = 360000
	
	# Choose the "best" target
	@targets.each     { |inst|  
		if inst != nil
#			@dir = point_best_direction(@x,@y,@x,@y);
			@dir = point_best_direction(@x,@y,inst.x + Gosu::offset_x(inst.angle, 10) ,
			   	                              inst.y + Gosu::offset_y(inst.angle, 10));
			@dist = @best_val
			if @dist < @best_dist
				@target = inst
				@best_dist = @dist
			end
		end
    }
	#@target = @window.fighter 
  end
  
  def kill
	@window.destroy_instance(self)
  end
  
  def delete(arg)
	@window.destroy_instance(self)
  end
  
  def collision_minion
	self.kill
  end
  
  def not_in_menu #This is just here to identify that the instance does not belong in the menu
	
  end
  
  def move
	#This is the horizontal/vertical speed!!
	@vel_x = Gosu::offset_x(@angle, 8)
    @vel_y = Gosu::offset_y(@angle, 8)
	#Move to that position!!
	@x += @vel_x
    @y += @vel_y
    #Warp when outside the screen
	@x %= 640
    @y %= 400
  end
  
  def try_dir(x1,y1,x2,y2)
	# This was the method we initially went with, but the problem with this was that it had a very significant flaw:
	# Because it takes the value and makes it direction-differene * distance, the value gets very tiny once you get close to
	# the target. That means that it tends to prioritize targets that are closer even though you're missile is facing the wrong way,
	# Which pretty much ruined it...
	
	dir = point_direction(x1 ,y1 ,x2 ,y2 )
	val = (get_dir_dif(dir, @angle).abs+3) * Gosu::distance(x1, y1, x2, y2)
	if val < @best_val
	  @best_val = val
	  @best_dir = dir
	end
  end
  
  def try_better_dir(x1, y1, x2, y2)
	@dist = 100 # This value determines how it prioritises ditance over direction when finding the optimal target. Higher number means more long-distance targeting.
	# Here we just set the difference between our direction and point_direction to calculate whether its rational to follow this target.
	dir = point_direction(x1 ,y1 ,x2 ,y2 )
	dir_dif = get_dir_dif(dir, @angle).abs
	val = Gosu::distance(x1, y1, x2, y2)
	
	# Here it creates two "ghost points" on the sides of the instance. 
	# These points represents the center of two circles.
	# These circles mark the area where our missile cant possibly reach.
	cent1_x = Gosu::offset_x(@angle + 90, @dist) + x1
	cent1_y = Gosu::offset_y(@angle + 90, @dist) + y1
	cent2_x = Gosu::offset_x(@angle - 90, @dist) + x1
	cent2_y = Gosu::offset_y(@angle - 90, @dist) + y1
	
	# So it starts by checking if the absolute distance difference is smaller than 90 (you dont want to turn that much)
	# And then it checks whether our target is outside both of the ghost circles that we cannot reach.
	if dir_dif < 90 and Gosu::distance(cent1_x, cent1_y, x2, y2) > @dist-4 \
	                and Gosu::distance(cent2_x, cent2_y, x2, y2) > @dist-4
		# If those conditions are met, it checks whether we already have a better target.
		# The priority lies only on the distance to the target apparently... (not really sure why actually) :o
		# If not, then set this as our new target!
		if val < @best_val
		  @best_val = val
		  @best_dir = dir
		end
	end
  end
  
  def point_best_direction(x1,y1,x2,y2)
	
	# This method was created mostly by my dad, so I dont actually know that much about how it works, but its awesome!!
	
	# This giant mess basically creates an additional 8 copies of the initial enemy targes and takes their coordinates to 
	# find the optimal target to follow. Its pretty complicated but its necessary :c !
	# The 8 "ghost coordiantes" each represent adjacent "rooms" where the target could potentially be,
	# after our supnimph has teleported to the other side of the room
	
	# This is just a dummy value... Its basically there to prevent any errors
    @best_val = 360000
	@best_dir = @angle
	# Total of 8 "ghost coordinates" + the initial target coordinate
    try_better_dir(x1 ,y1 ,x2     ,y2     )
	try_better_dir(x1 ,y1 ,x2     ,y2-400 )
	try_better_dir(x1 ,y1 ,x2+640 ,y2-400 )
	try_better_dir(x1 ,y1 ,x2+640 ,y2     )
	try_better_dir(x1 ,y1 ,x2+640 ,y2+400 )
	try_better_dir(x1 ,y1 ,x2     ,y2+400 )
	try_better_dir(x1 ,y1 ,x2-640 ,y2+400 )
	try_better_dir(x1 ,y1 ,x2-640 ,y2     )
	try_better_dir(x1 ,y1 ,x2-640 ,y2-400 )
	#if @best_val != 360000
		#@test += 1
	return @best_dir
	#end
	#try_dir(x1 ,y1 ,x2     ,y2     )
	#try_dir(x1 ,y1 ,x2     ,y2-400 )
	#try_dir(x1 ,y1 ,x2+640 ,y2-400 )
	#try_dir(x1 ,y1 ,x2+640 ,y2     )
	#try_dir(x1 ,y1 ,x2+640 ,y2+400 )
	#try_dir(x1 ,y1 ,x2     ,y2+400 )
	#try_dir(x1 ,y1 ,x2-640 ,y2+400 )
	#try_dir(x1 ,y1 ,x2-640 ,y2     )
	#try_dir(x1 ,y1 ,x2-640 ,y2-400 )
	#@test = 0
	#return @best_dir
  end
  
  def checkCollisionB(x,y)
	return Gosu::distance(@x, @y, x, y) < 17
  end
  
  # Just a function for finding the direction towards (Fighturh)<-- Hell no its "target" now!!
  def point_direction(x1,y1,x2,y2)
	return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
  end
  
  def get_dir_dif(dir1,dir2)
	
	dir_to_turn = dir1 - dir2 #This gives a value between -360 and 360
		
	# Make sure that value is between -180 and 180, which is the relative direction.
	if dir_to_turn >= 180
		dir_to_turn += -360
	end
	if dir_to_turn <= -180
		dir_to_turn += 360
	end
	#This outputs only the difference in terms of angle (for example -15 or 25 degrees)
	#So in order to get the absolute difference you need to do .abs!
	return dir_to_turn
  end
  
  def tail
	@tail = Tail.new(@window, @x, @y)
	return @tail
  end
  
  def update
	
	#move...
	self.move
	
	#Creates the "tail" behind it
	if @window.graphics == 1
		@window.create_instance(tail)
	end
	
	#This instance does not belong in the menu... 
	if @window.menu == true
		self.kill
	end
	
	# If there is a collision with the fighter...
	# It's important to notice that the collision with minion is called by the minion itself. 
	# But the actual method in "supnimph" is called collision_minion
	if @window.collisionfighter(@x, @y) and @window.fighterexist then
		@window.fighter.takesupdamage
		@window.fighter.supslow(180)
		@window.destroy_instance(self)
	end
	
#	if @window.fighterexist #or @window.minion_exist # If there is an existing "Fighter" in the game
	if @target != nil
		
		# Dir is the direction you want to be facing in order to successfully hit an enemy!
		# This function has 2 coordinates: 1 for the instance itself, and one for the enemy target.
		# The reason for this complication is that it predicts where the enemy target will be when it hits in order to increase accuracy!
		# The function returns the optimal direction to follow in order to catch the target. (so its not just point_direction)
		@dir = point_best_direction(@x,@y,@target.x + Gosu::offset_x(@target.angle, 6) ,
		                                  @target.y + Gosu::offset_y(@target.angle, 6));
		
		# This is either < , = or > 0 and it defines the direction to turn in order to achieve the optimal direction. 
		@dir_to_turn = get_dir_dif(@dir, @angle) #Get the difference bewteen @dir and @angle
		
		# Here it turns either left or right (@angle += x) where x is the amount of degrees to turn (which means how fast its turning)
		if @dir_to_turn > 0 # Turn right
			@angle += 1.5 #turn_left
			@angle = @angle % 360
		end	
		if @dir_to_turn < 0 # Turn left
			@angle += -1.5 #turn_right
			@angle = @angle % 360
		end	
		
	end
  end
  
  def warp(x, y, angle)
    @x, @y = x, y
	@angle = angle
	self.get_target # Must be called AFTER the coordinates have been set.
  end
  
  def draw
	@c_yellow = 0xffffff00
	#@font.draw(@test, 140, 5, 2, 1.0, 1.0, @c_yellow)
	@index = [((135-@timeleft.getvalue)/(135/14)).floor, 13].min # Complicated formular o.O
	@image = Gosu::Image.new(@window, "media/Supnimph/#{@index}.png", false)
	@image.draw_rot(@x, @y, 1, @angle)
	
	if @target != nil
		@target_scope.draw_rot(@target.x, @target.y, 0.5, 0)
	end
  end
end
