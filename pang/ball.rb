class Ball

    attr_reader :x, :y, :radius

    def initialize(window)
        @window = window
        @image = Gosu::Image.new(@window, "media/bold.png", false)
        @beep   = Gosu::Sample.new("media/beep.wav")
        @x = 150
        @y = 200
        @vel_x = 3
        @vel_y = 3
        @radius = @image.height/2
        @top_margin = 40
    end

    def move
        @x += @vel_x
        @y += @vel_y
    end

    # Generates two random variables with independent normal distribution
    def rand_norm
        # This is the so-called Box-Muller transform
        u1 = rand
        u2 = rand
        r = Math.sqrt(-2.0*Math.log(u1))
        z0 = r*Math.cos(2*Math::PI*u2)
        z1 = r*Math.sin(2*Math::PI*u2)
        return [z0,z1]
    end

    def update
        move

        collision = false
        # Check for collision with left wall
        if @x-@radius < 0 and @vel_x < 0
            @vel_x = -@vel_x
            @x = @radius
            collision = true
        end

        # Check for collision with right wall
        if @x+@radius > @window.width and @vel_x > 0
            @vel_x = -@vel_x
            @x = @window.width - @radius
            collision = true
        end

        # Check for collision with top wall
        if @y-@radius < @top_margin and @vel_y < 0
            @vel_y = -@vel_y
            @y = @top_margin + @radius
            collision = true
        end

        # Check for collision with bottom wal
        if @y+@radius > @window.height and @vel_y > 0
            @vel_y = -@vel_y
            @y = @window.height - @radius
            collision = true
        end

        # At each collision, make a random change to the velocity
        if collision
            #@beep.play

            @vel_x *= 0.95
            @vel_y *= 0.95
        end
    end

    def points
        vel = Math.sqrt(@vel_x*@vel_x + @vel_y*@vel_y)
        return (vel*10+0.5).to_i * 10
    end

    def clicked
        @x = rand(@window.width - 2*@radius) + @radius
        @y = rand(@window.height - 2*@radius) + @radius
        @beep.play

        @vel_x += (@vel_x <=> 0) * rand * 0.5
        @vel_y += (@vel_y <=> 0) * rand * 0.5
    end

    def draw
        @image.draw(@x-@radius, @y-@radius, 2)
    end

end
