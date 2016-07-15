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
	@vel_y += 0.1 # Gravity
	
	if @x < @radius or @x > @window.width - @radius  ## If the ball collides with the LEFT wall OR the RIGHT wall
		@vel_x = -@vel_x  ## Reverse the horizontal direction
	end

    if @y > @window.height
        @x = 100
        @y = 200
        @vel_x = 0
        @vel_y = 0
    end
	
  end
  
  def update
	move

    # Check for collision with player
	if Gosu::distance(@window.player.x, @window.player.y, @x, @y) <= @window.player.radius + @radius
		collision_point(@window.player.x, @window.player.y)
	end

    # Check for collision with left side of wall
    if @y > @window.wall.y
        if @x+@radius > @window.wall.x and @x < @window.wall.x and @vel_x > 0
            @vel_x = -@vel_x
        end
    end

    # Collision with right side of wall
    if @y > @window.wall.y
        if @x-@radius < @window.wall.x + @window.wall.width and @x > @window.wall.x + @window.wall.width and @vel_x < 0
            @vel_x = -@vel_x
        end
    end

    # Collision with top of wall
    if @x > @window.wall.x and @x < @window.wall.x + @window.wall.width
        if @y+@radius > @window.wall.y and @vel_y > 0
            @vel_y = -@vel_y
        end
    end

    # Collision with left corner
    if @y < @window.wall.y and @x < @window.wall.x
        if Gosu::distance(@window.wall.x, @window.wall.y, @x, @y) <= @radius
            collision_point(@window.wall.x, @window.wall.y)
        end
    end

    # Collision with right corner
    if @y < @window.wall.y and @x > @window.wall.x + @window.wall.width
        if Gosu::distance(@window.wall.x + @window.wall.width, @window.wall.y, @x, @y) <= @radius
            collision_point(@window.wall.x + @window.wall.width, @window.wall.y)
        end
    end
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
  
  def collision_point(x, y)
	p2b = [@x - x, @y - y] # This is a vector frmo the Player to the Ball.
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
