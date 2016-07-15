class Ball
  
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, "media/bold.png", false)
	@x = 100
	@y = 200
	@vel_x = 0
	@vel_y = 0
	@radius = @image.height/2
  end
  
  def move
	@x += @vel_x
	@y += @vel_y
	@vel_y += 0.1
	
	if @x < @radius or @x > (@window.width - @radius)  ## If the ball collides with the LEFT wall OR the RIGHT wall
		@vel_x = -@vel_x  ## Reverse the horisontal direction
		@x = [[@radius, @x].max , @window.width - @radius].min     ## Keep the ball inside the room 
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

  # This calculates the projection of vector a onto vector b
  def projection(vec_a, vec_b)
      scale = dotp(vec_a, vec_b) / dotp(vec_b, vec_b)
      return [scale*vec_b[0], scale*vec_b[1]]
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
	p2b = [@x - player.x, @y - player.y] # This is a vector frmo the Player to the Ball.
	vel = [@vel_x, @vel_y] # This is the balls velocity vector.
	angle = angle(p2b, vel)
	
	if angle < Math::PI/2.0 # The ball is already moving out of the player, so just leave it alone.
		return
	end
	
    # This calculates the bounce by using the projection of the velocity vector onto the normal vector.
    # The vector p2b is indeed a vector normal to the plane of reflection.
    proj = projection(vel, p2b)
	@vel_x -= 2*proj[0]
	@vel_y -= 2*proj[1]
  end
  
  def draw
	@image.draw(@x-@radius, @y-@radius, 2)
  end
  
end
