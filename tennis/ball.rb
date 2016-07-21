require_relative 'utils'

class Ball

    attr_reader :x, :y, :radius

    def initialize(window)
        @window = window
        @image  = Gosu::Image.new(@window, "media/bold.png", false)
        @beep   = Gosu::Sample.new("media/beep.wav")
        @radius = @image.height/2
        reset
    end

    def reset
        @x     = 100
        @y     = 200
        @vel_x = 0
        @vel_y = 0
        @timer = 200
    end

    def move
        if @timer > 0
            @timer -= 1
            return
        end
        @x += @vel_x
        @y += @vel_y
        @vel_y += 0.1 # Gravity

        # If ball moves out of screen, reset ball and update scores.
        if @y > @window.height
            if @x < @window.width/2
                @window.score.dead_player
            else
                @window.score.dead_bot
            end
            @timer = 200
            @y = 200
            @vel_x = 0
            @vel_y = 0
        end
    end

    def update
        move

        collision = false
        # Check for collision with left side of screen
        if @x < @radius 
            @vel_x = -@vel_x
            @x = @radius
            collision = true
        end

        # Check for collision with right side of screen
        if @x > @window.width - @radius
            @vel_x = -@vel_x
            @x = @window.width - @radius
            collision = true
        end

        # Check for collision with player
        if Gosu::distance(@window.player.x, @window.player.y, @x, @y) <= @window.player.radius + @radius
            adjust_ball(@window.player.x, @window.player.y, @window.player.radius + @radius)
            collision_point(@window.player.x, @window.player.y)
            collision = true
        end

        # Check for collision with bot
        if Gosu::distance(@window.bot.x, @window.bot.y, @x, @y) <= @window.bot.radius + @radius
            adjust_ball(@window.bot.x, @window.bot.y, @window.bot.radius + @radius)
            collision_point(@window.bot.x, @window.bot.y)
            collision = true
        end

        # Check for collision with left side of wall
        if @y > @window.wall.y
            if @x+@radius > @window.wall.x and @x < @window.wall.x and @vel_x > 0
                @x = @window.wall.x - @radius
                @vel_x = -@vel_x
                collision = true
            end
        end

        # Collision with right side of wall
        if @y > @window.wall.y
            if @x-@radius < @window.wall.x + @window.wall.width and @x > @window.wall.x + @window.wall.width and @vel_x < 0
                @x = @window.wall.x + @window.wall.width + @radius
                @vel_x = -@vel_x
                collision = true
            end
        end

        # Collision with top of wall
        if @x > @window.wall.x and @x < @window.wall.x + @window.wall.width
            if @y+@radius > @window.wall.y and @vel_y > 0
                @y = @window.wall.y - @radius
                @vel_y = -@vel_y
                collision = true
            end
        end

        # Collision with left corner
        if @y < @window.wall.y and @x < @window.wall.x
            if Gosu::distance(@window.wall.x, @window.wall.y, @x, @y) <= @radius
                adjust_ball(@window.wall.x, @window.wall.y, @radius)
                collision_point(@window.wall.x, @window.wall.y)
                collision = true
            end
        end

        # Collision with right corner
        if @y < @window.wall.y and @x > @window.wall.x + @window.wall.width
            if Gosu::distance(@window.wall.x + @window.wall.width, @window.wall.y, @x, @y) <= @radius
                adjust_ball(@window.wall.x + @window.wall.width, @window.wall.y, @radius)
                collision_point(@window.wall.x + @window.wall.width, @window.wall.y)
                collision = true
            end
        end

        # At each collision, make a random change to the velocity
        if collision
            @beep.play

            # Generate two random variables with a normal distribution
            z0, z1 = Utils::randNorm
            @vel_x += z0 * 0.25
            @vel_y += z1 * 0.25
        end
    end

    # Move the ball so that it is at the distance d from the point (x,y)
    def adjust_ball(x, y, d)
        p2b = [@x - x, @y - y] # This is a vector frmo the Player to the Ball.
        scale = d / Utils::len(p2b)
        @x = x  + p2b[0]*scale
        @y = y  + p2b[1]*scale
    end

    def collision_point(x, y)
        p2b = [@x - x, @y - y] # This is a vector frmo the Player to the Ball.
        vel = [@vel_x, @vel_y] # This is the balls velocity vector.
        angle = Utils::angle(p2b, vel)

        if angle < Math::PI/2.0 # The ball is already moving out of the player, so just leave it alone.
            return
        end

        # This calculates the bounce by using the projection of the velocity vector onto the normal vector.
        # The vector p2b is indeed a vector normal to the plane of reflection.
        proj = Utils::projection(vel, p2b)
        @vel_x -= 2*proj[0]
        @vel_y -= 2*proj[1]
    end

    def draw
        @image.draw(@x-@radius, @y-@radius, 2)
    end

end
