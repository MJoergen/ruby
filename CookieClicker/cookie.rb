# This class holds information for the current cookie collection
# This includes:
# cookies : Current number of cookies owned.
class Cookie
    attr_reader :cookies

    def initialize(window, x, y, img_file)
        @window, @x, @y, @img_file = window, x, y, img_file
        @image = Gosu::Image.new(@img_file)
        @scale = 200.0 / @image.height          # Make sure image on screen 
                                                # has a height of 200 pixels
        @cookies = 0
    end

    # Called whenever time passes or we buy a unit
    def increase(cookies)
        @cookies += cookies
    end

    # Called whenever the mouse is clicked
    def in_range?(x, y)
        (x >= @x and x < @x + @image.width*@scale and
         y >= @y and y < @y + @image.height*@scale)
    end

    def draw
        if (Gosu::button_down?(Gosu::MsLeft) and in_range?(@window.mouse_x, @window.mouse_y))
            @image.draw(@x-8, @y-8, 0, @scale*1.08, @scale*1.08)
        else
            @image.draw(@x, @y, 0, @scale, @scale)
        end
    end
end
