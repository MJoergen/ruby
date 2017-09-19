# This class holds information for each type of unit
# This includes:
# number : Number of units owned
# cost   : The price of the next unit
# cps    : Cookies pr. second for each unit
class Unit
    attr_reader :number, :cps

    def initialize(window, x, y, img_file, name, cost, cps)
        @window, @x, @y, @img_file, @name, @cost, @cps = window, x, y, img_file, name, cost, cps

        @image  = Gosu::Image.new(@img_file)
        @scale  = 50.0 / @image.height          # Make sure all images on screen
                                                # have the same height (50 pixels).
        @number = 0
    end

    def buy
        @number += 1
        @cost *= 1.15
    end

    # When buying units, the price is always rounded up.
    def cost
        @cost.ceil
    end

    # Check if (x,y) is within the image of the unit
    def in_range?(x, y)
        (x >= @x and x < @x + @image.width*@scale and
         y >= @y and y < @y + @image.height*@scale)
    end

    def draw
        # "Zoom in" when mouse is pressed
        if Gosu::button_down?(Gosu::MsLeft) and in_range?(@window.mouse_x, @window.mouse_y)
            @image.draw(@x-2, @y-2, 0, @scale*1.08, @scale*1.08) 
        else
            @image.draw(@x, @y, 0, @scale, @scale)
        end
        @window.font.draw(@name,                 @x+100, @y+20, 0)
        @window.font.draw("#{cost}",             @x+200, @y+20, 0)
        @window.font.draw("#{(cost/@cps).ceil}", @x+300, @y+20, 0)
    end
end

