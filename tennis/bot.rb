class Bot

    attr_reader :x, :y, :radius

    def initialize(window)
        @window = window
        @image = Gosu::Image.new(@window, "media/halvmåne.png", false)
        @radius = @image.height
        @margin = 10
        @x = 400
        @y = @window.height - @image.height + @radius - @margin
        @vel_x = -3
    end

    def update
        @vel_x = @window.ball.x - @x
        @vel_x = [3, @vel_x].min
        @vel_x = [-3, @vel_x].max

        @x += @vel_x

        if @x-@radius < @window.width/2 + @window.wall.width/2 + @margin
            @x = @window.width/2 + @window.wall.width/2 + @margin + @radius
        end
        if @x+@radius > @window.width - @margin
            @x = @window.width - @margin - @radius
        end
    end

    def draw
        @image.draw(@x-@radius, @y-@radius, 2)
    end

end
