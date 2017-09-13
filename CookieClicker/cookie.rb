class Cookie
    attr_reader :cookies

    def initialize(x, y, img_file)
        @x, @y, @img_file = x, y, img_file
        @image = Gosu::Image.new(@img_file)
        @cookies = 0
    end

    def increase(cookies)
        @cookies += cookies
    end

    def in_range?(x, y)
        (x >= @x and x < @x + @image.width and
         y >= @y and y < @y + @image.height)
    end

    def draw
        @image.draw(@x, @y, 0)
    end
end
