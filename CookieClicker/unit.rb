class Unit
    attr_reader :cost, :number, :cps

    def initialize(x, y, img_file, name, cost, cps)
        @x, @y, @img_file, @name, @cost, @cps = x, y, img_file, name, cost, cps

        @image  = Gosu::Image.new(@img_file)
        @number = 0
    end

    def buy
        @number += 1
        @cost *= 1.15
    end

    # Check if (x,y) is within the image of the unit
    def in_range?(x, y)
        (x >= @x and x < @x + @image.width and
         y >= @y and y < @y + @image.height)
    end

    def draw
        @image.draw(@x, @y, 0)
    end
end
