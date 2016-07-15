class Ball

    attr_reader :x, :y, :radius

    def initialize(window)
        @window = window
        @image = Gosu::Image.new(@window, "media/bold.png", false)
        @beep   = Gosu::Sample.new("media/beep.wav")
        @x = 100
        @y = 200
        @vel_x = 0
        @vel_y = 0
        @radius = @image.height/2
        @timer = 0
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
                @timer = 200
            else
                @window.score.dead_bot
                @timer = 200
            end
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
            collision_point(@window.player.x, @window.player.y)
            collision = true
        end

        # Check for collision with bot
        if Gosu::distance(@window.bot.x, @window.bot.y, @x, @y) <= @window.bot.radius + @radius
            collision_point(@window.bot.x, @window.bot.y)
            collision = true
        end

        # Check for collision with left side of wall
        if @y > @window.wall.y
            if @x+@radius > @window.wall.x and @x < @window.wall.x and @vel_x > 0
                @vel_x = -@vel_x
                collision = true
            end
        end

        # Collision with right side of wall
        if @y > @window.wall.y
            if @x-@radius < @window.wall.x + @window.wall.width and @x > @window.wall.x + @window.wall.width and @vel_x < 0
                @vel_x = -@vel_x
                collision = true
            end
        end

        # Collision with top of wall
        if @x > @window.wall.x and @x < @window.wall.x + @window.wall.width
            if @y+@radius > @window.wall.y and @vel_y > 0
                @vel_y = -@vel_y
                collision = true
            end
        end

        # Collision with left corner
        if @y < @window.wall.y and @x < @window.wall.x
            if Gosu::distance(@window.wall.x, @window.wall.y, @x, @y) <= @radius
                collision_point(@window.wall.x, @window.wall.y)
                collision = true
            end
        end

        # Collision with right corner
        if @y < @window.wall.y and @x > @window.wall.x + @window.wall.width
            if Gosu::distance(@window.wall.x + @window.wall.width, @window.wall.y, @x, @y) <= @radius
                collision_point(@window.wall.x + @window.wall.width, @window.wall.y)
                collision = true
            end
        end

        # At each collision, make a random change to the velocity
        if collision
            @beep.play

            # Generate two random variables with a normal distribution
            u1 = rand
            u2 = rand
            r = Math.sqrt(-2.0*Math.log(u1))
            z0 = r * Math.cos(2*Math::PI*u2)
            z1 = r * Math.sin(2*Math::PI*u2)

            @vel_x += z0 * 0.25
            @vel_y += z1 * 0.25
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
        if @timer > 0
            return
        end
        @image.draw(@x-@radius, @y-@radius, 2)
    end

end
