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
  
  # This returns the length squared of a vector
  def len2(a)
    return dotp(a, a)
  end
  
  # This returns the length of a vector
  def len(a)
    return Math.sqrt(len2(a))
  end
  
  # This returns the angle between two vectors, in the range 0 .. pi
  def angle(vec_a, vec_b)
	return Math.acos(dotp(vec_a, vec_b)/(len(vec_a)*len(vec_b)))
  end
  
  # This solves a quadratic equation, and returns the two solutions
  def solve_quadratic(a, b, c)
  	d = b*b - 4*a*c
	if d < 0
		return nil
	else
		return [(-b+Math.sqrt(d))/(2*a), (-b-Math.sqrt(d))/(2*a)]
	end
  end
  
  # This calculates the coordinates of the ball at the time of collision
  # The inputs are:
  # n_vec   : Vector from player to ball
  # vel_vec : Current direction of ball's movement
  # dist    : Distance between ball and player at time of collision
  #
  # Essentially, this function solves the following simulataneous equations:
  # (1) c_vec = n_vec + alpha*vel_vec
  # (2) length(c_vec) = dist
  # where alpha is a scalar.
  # The function returns c_vec.
  def calc_orig(n_vec, vel_vec, dist)
	# First we set up a quadratic equation
	a = dotp(vel_vec, vel_vec)
	b = 2*dotp(n_vec, vel_vec)  # b will always be negative, when the ball is moving towards the player
	c = dotp(n_vec, n_vec) - dist*dist
	alpha = solve_quadratic(a, b, c)[1] # We want the second solution, because that will be positiv
	return [n_vec[0]+alpha*vel_vec[0], n_vec[1] + alpha*vel_vec[1]]
  end
  
  # This calculates the projection of vector a onto vector b
  def project(vec_a, vec_b)
	scale = dotp(vec_a, vec_b) / len2(vec_b)
	return [scale*vec_b[0], scale*vec_b[1]]
  end

  # This reflects the vector a in a plane perpendicular to vector b  
  def reflect(vec_a, vec_b)
    vect_project = project(vec_a, vec_b)
	vec_a[0] -= 2*vect_project[0]
	vec_a[1] -= 2*vect_project[1]
	return vec_a
  end
  
  def collision_player(player)
	# This is complicated, because when this function is called, the ball is actually partially *inside* the player.
	# In other words, this functions is called some time *after* the actual collision - there is a delay.
	
	# So first we check if the ball is already moving away from the player. In that case,
	# don't do anything.
	# This is the most important step. Without this step, the ball will circle endlessly inside or around the player.
	vect_player_to_ball = [@x - player.x, @y - player.y]
	vect_velocity_ball  = [@vel_x,        @vel_y]
	angle = angle(vect_player_to_ball, vect_velocity_ball)
	if angle < Math::PI/2.0 # The ball is moving out of the player, so just leave it alone.
		return
	end
	
	# Second we must calculate the position of the ball at the time of the collision.
	# This is really just a small optimization of the ball movement. 
	orig_dist = player.radius + @radius
	vect_player_to_ball_orig = calc_orig(vect_player_to_ball, vect_velocity_ball, orig_dist) # This is the vector at the time of collision.
	
	# Now we are ready to calculate the reflection.
	vect_velocity_new = reflect(vect_velocity_ball, vect_player_to_ball_orig)
	@vel_x = vect_velocity_new[0]
	@vel_y = vect_velocity_new[1]
  end
  
  def draw
	@image.draw(@x-@radius, @y-@radius, 2)
  end
  
end
