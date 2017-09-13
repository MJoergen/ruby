class Unit
    attr_reader :number, :cps

    def initialize(window, x, y, img_file, name, cost, cps)
        @window, @x, @y, @img_file, @name, @cost, @cps = window, x, y, img_file, name, cost, cps

        @image  = Gosu::Image.new(@img_file)
        @scale  = 50.0 / @image.height
        @number = 0
    end

    def buy
        @number += 1
        @cost *= 1.15
    end

    def cost
        @cost.ceil
    end

    # Check if (x,y) is within the image of the unit
    def in_range?(x, y)
        (x >= @x and x < @x + @image.width*@scale and
         y >= @y and y < @y + @image.height*@scale)
    end

    def draw
        @image.draw(@x, @y, 0, @scale, @scale)
        @window.font.draw(@name, @x+100, @y+20, 0)
        @window.font.draw("#{cost}", @x+200, @y+20, 0)
        @window.font.draw("#{(cost/@cps).ceil}", @x+300, @y+20, 0)
    end
end
