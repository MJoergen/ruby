class Ball
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/bold.png", false)
	@x = 100
	@y = 200
	@vel_x = 0
	@vel_y = 0
	@radius = 15
  end
  
  def move
	@x += @vel_x
	@y += @vel_y
	@vel_y += 0.1
	
	if @x < (10 + @radius) or @x > (630 - @radius)  ## If the ball collides with the LEFT wall OR the RIGHT wall
		@vel_x = -@vel_x  ## Reverse the horisontal direction
		@x = [[10 + @radius, @x].max , 630 - @radius].min     ## Keep the ball inside the room 
	end
	
  end
  
  def update
	move
	@window.ball_collision_player(@x, @y, @radius, method(:collision_player))
  end
  
  # Thia returns the dot product of two vectors
  def dotp(a, b)
	return a[0]*b[0] + a[1]*b[1]
  end
  
  # This returns the length of a vector
  def len(a)
    return Math.sqrt(dotp(a, a))
  end
  
  # This returns the angle between two vectors, in the range 0 .. pi
  def angle(vec_a, vec_b)
	return Math.acos(dotp(vec_a, vec_b)/(len(vec_a)*len(vec_b)))
  end
  
  # This calculates the coordinates of the ball at the time of collision
  # The inputs are:
  # n_vec : Vector from player to ball
  # vel_vec : Current direction of ball's movement
  # dist : Distance between ball and player at time of collision
  def calc_orig(n_vec, vel_vec, dist)
	# First we set up a quadratic equation
	a = dotp(vel_vec, vel_vec)
	b = 2*dotp(n_vec, vel_vec)  # b will always be negative, when the ball is moving towards the player
	c = dotp(n_vec, n_vec) - dist*dist
	d = b*b-4*a*c
	alpha = (-b-Math.sqrt(d))/(2*a) # We only want the negativ solution
	return [n_vec[0]+alpha*vel_vec[0], n_vec[1] + alpha*vel_vec[1]]
  end
  
  def collision_player(player)
	# This is complicated, because when this function is called, the ball is actually partially *inside* the player.
	# In other words, this functions is called some time *after* the actual collision. There is a delay.
	# So first we must calculate the position of the ball at the time of the collision.
	
	dist_now = Gosu::distance(player.x, player.y, @x, @y)   # This is the actual distance now
	dist_coll = player.radius + @radius                     # This is the distance at the actual time of collision.
	vect_player_to_ball = [@x - player.x, @y - player.y]
	vel = [@vel_x, @vel_y]
	angle = angle(vect_player_to_ball, vel)
	
	if angle < Math::PI/2.0 # The ball is moving out of the player, so just leave it alone.
		return
	end
	
	vect_player_to_ball_orig = calc_orig(vect_player_to_ball, vel, dist_coll)
	
	scale = dotp([@vel_x, @vel_y], vect_player_to_ball_orig) / dotp(vect_player_to_ball_orig, vect_player_to_ball_orig)
	@vel_x -= scale*2*vect_player_to_ball_orig[0]
	@vel_y -= scale*2*vect_player_to_ball_orig[1]
  end
  
  def draw
	@image.draw(@x-@radius, @y-@radius, 2)
  end
  
end
