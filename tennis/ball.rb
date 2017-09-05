# This controls the movement and display of the ball
require_relative 'utils'

class Ball
  # This is it!
  attr_reader :x, :y, :radius

  def initialize(window)
    @window = window
    @image  = Gosu::Image.new('media/bold.png')
    @beep   = Gosu::Sample.new('media/beep.wav')
    @radius = @image.height / 2
    @x      = 100
    reset
  end

  def reset
    @y     = 200
    @vel_x = 0
    @vel_y = 0
    @timer = 200

    # (@x, @y) are the coordinates of the center of the ball.
  end

  # This moves the ball one small step.
  def move
    @x += @vel_x
    @y += @vel_y
    @vel_y += 0.1       # Gravity pulls the ball down.

    # If ball moves out of screen, reset ball and update scores.
    if @y > @window.height
      if @x < @window.width / 2
        @window.score.dead_player
      else
        @window.score.dead_bot
      end
      reset             # Reset ball position.
    end
  end

  def update
    if @timer > 0       # If timer is positive, ball doesn't move.
      @timer -= 1
      return
    end

    move

    collision = false
    # Check for collision with left side of screen
    if @x < @radius && @vel_x < 0
      @x = @radius                                          # Move ball back into the game.
      @vel_x = -@vel_x                                      # Adjust direction.
      collision = true
    end

    # Check for collision with right side of screen
    if @x > @window.width - @radius && @vel_x > 0
      @x = @window.width - @radius                          # Move ball back into the game.
      @vel_x = -@vel_x                                      # Adjust direction.
      collision = true
    end

    # Check for collision with player
    if Gosu.distance(@window.player.x, @window.player.y, @x, @y) <=
       @window.player.radius + @radius
      adjust_ball(@window.player.x, @window.player.y,
                  @window.player.radius + @radius)          # Move ball 'out' of the player.
      collision_point(@window.player.x, @window.player.y)   # Adjust direction.
      collision = true
    end

    # Check for collision with bot
    if Gosu.distance(@window.bot.x, @window.bot.y, @x, @y) <=
       @window.bot.radius + @radius
      adjust_ball(@window.bot.x, @window.bot.y,
                  @window.bot.radius + @radius)             # Move ball 'out' of the bot.
      collision_point(@window.bot.x, @window.bot.y)         # Adjust direction.
      collision = true
    end

    # Check for collision with left side of wall
    if @y > @window.wall.y
      if @x + @radius > @window.wall.x && @x < @window.wall.x && @vel_x > 0
        @x = @window.wall.x - @radius                       # Move ball 'out' of the wall.
        @vel_x = -@vel_x                                    # Adjust direction.
        collision = true
      end
    end

    # Collision with right side of wall
    if @y > @window.wall.y
      if @x - @radius < @window.wall.x + @window.wall.width &&
         @x > @window.wall.x + @window.wall.width && @vel_x < 0
        @x = @window.wall.x + @window.wall.width + @radius  # Move ball 'out' of the wall.
        @vel_x = -@vel_x                                    # Adjust direction.
        collision = true
      end
    end

    # Collision with top of wall
    if @x > @window.wall.x && @x < @window.wall.x + @window.wall.width
      if @y + @radius > @window.wall.y && @vel_y > 0
        @y = @window.wall.y - @radius                       # Move ball 'out' of the wall.
        @vel_y = -@vel_y                                    # Adjust direction.
        collision = true
      end
    end

    # Collision with left corner
    if @y < @window.wall.y && @x < @window.wall.x
      if Gosu.distance(@window.wall.x, @window.wall.y, @x, @y) <= @radius
        adjust_ball(@window.wall.x, @window.wall.y, @radius)    # Move ball 'out' of the wall.
        collision_point(@window.wall.x, @window.wall.y)         # Adjust direction.
        collision = true
      end
    end

    # Collision with right corner
    if @y < @window.wall.y && @x > @window.wall.x + @window.wall.width
      if Gosu.distance(@window.wall.x + @window.wall.width, @window.wall.y,
                       @x, @y) <= @radius
        adjust_ball(@window.wall.x + @window.wall.width, @window.wall.y,
                    @radius)                                # Move ball 'out' of the wall.
        collision_point(@window.wall.x + @window.wall.width, @window.wall.y)
                                                            # Adjust direction.
        collision = true
      end
    end

    # At each collision, make a random change to the velocity
    if collision
      @beep.play

      # Generate two random variables with a normal distribution
      z0, z1 = Utils.rand_norm
      @vel_x += z0 * 0.25   # Adjust velocity.
      @vel_y += z1 * 0.25   # Adjust velocity.
    end
  end

  # Move the ball so that it is at the distance d from the point (x,y)
  def adjust_ball(x, y, d)
    p2b = [@x - x, @y - y] # This is a vector from the point (x,y) to the Ball.
    scale = d / Utils.len(p2b)
    @x = x  + p2b[0] * scale
    @y = y  + p2b[1] * scale
  end

  # Adjust the direction of the ball after a collision.
  def collision_point(x, y)
    p2b = [@x - x, @y - y] # This is a vector from the point to the Ball.
    vel = [@vel_x, @vel_y] # This is the balls velocity vector.
    angle = Utils.angle(p2b, vel)

    # If the ball is already moving away from the point, just leave it alone.
    if angle < Math::PI / 2.0
      return
    end

    # This calculates the bounce by using the projection of the velocity vector
    # onto the normal vector.  The vector p2b is indeed a vector normal to the
    # plane of reflection.
    proj = Utils.projection(vel, p2b)
    @vel_x -= 2 * proj[0]
    @vel_y -= 2 * proj[1]
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 0)
  end
end

