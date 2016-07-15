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
    end

    def move
        @x += @vel_x
        @y += @vel_y
    end

    def update
        move

        collision = false
        if @x-@radius < 0 and @vel_x < 0
            @vel_x = -@vel_x
            @x = @radius
            collision = true
        end

        if @x+@radius > @window.width and @vel_x > 0
            @vel_x = -@vel_x
            @x = @window.width - @radius
            collision = true
        end

        if @y-@radius < 0 and @vel_y < 0
            @vel_y = -@vel_y
            @y = @radius
            collision = true
        end

        if @y+@radius > @window.height and @vel_y > 0
            @vel_y = -@vel_y
            @y = @window.height - @radius
            collision = true
        end

        # At each collision, make a random change to the velocity
        if collision
            #@beep.play

        end
    end

    def clicked
        @x = rand(@window.width - 2*@radius) + @radius
        @y = rand(@window.height - 2*@radius) + @radius
        @beep.play

        @vel_x += (@vel_x <=> 0) * rand * 0.3
        @vel_y += (@vel_y <=> 0) * rand * 0.3
    end

    def draw
        @image.draw(@x-@radius, @y-@radius, 2)
    end

end
