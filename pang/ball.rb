class Ball
    attr_reader :x, :y, :radius

    def initialize(window)
        @window = window
        @beep = Gosu::Sample.new('media/beep.wav')

        @image = Gosu::Image.new('media/bold.png', false)
        @radius = @image.height / 2

        @x = 150        # Boldens start-position (centrum af bolden)
        @y = 200
        @vel_x = 3      # Boldens start-hastighed
        @vel_y = 3

        @top_margin = 40
    end

    def update
        @x += @vel_x    # Flyt bolden
        @y += @vel_y

        collision = false

        # Har vi ramt den venstre kant?
        if @x - @radius < 0 && @vel_x < 0
            @vel_x = -@vel_x
            @x = @radius
            collision = true

        # Har vi ramt den højre kant?
        elsif @x + @radius > @window.width && @vel_x > 0
            @vel_x = -@vel_x
            @x = @window.width - @radius
            collision = true

        # Har vi ramt den øverste kant?
        elsif @y - @radius < @top_margin && @vel_y < 0
            @vel_y = -@vel_y
            @y = @top_margin + @radius
            collision = true

        # Har vi ramt den nederste kant?
        elsif @y + @radius > @window.height && @vel_y > 0
            @vel_y = -@vel_y
            @y = @window.height - @radius
            collision = true
        end

        # Hver gang vi rammer væggen, så bliver bolden en smule langsommere.
        if collision
            @vel_x *= 0.95
            @vel_y *= 0.95
        end
    end

    # Udregner hvor mange point bolden er værd lige nu
    def points
        vel = Math.sqrt(@vel_x * @vel_x + @vel_y * @vel_y)  # Størrelsen af farten
        (vel * 10 + 0.5).to_i * 10
    end

    # Bliver kaldt, når vi har ramt bolden
    def clicked
        @beep.play

        # Teleportér bolden et tilfældigt sted hen
        @x = rand(@window.width - 2 * @radius) + @radius
        @y = rand(@window.height - 2 * @radius - @top_margin) + @radius + @top_margin

        # Forøg hastigheden med en lille smule
        @vel_x += (@vel_x <=> 0) * rand * 0.5
        @vel_y += (@vel_y <=> 0) * rand * 0.5
    end

    def draw
        @window.draw_line(0, @top_margin, Gosu::Color::WHITE, @window.width, @top_margin, Gosu::Color::WHITE)
        @image.draw(@x - @radius, @y - @radius, 2)
    end
end

