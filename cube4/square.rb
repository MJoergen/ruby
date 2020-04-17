class Square
   attr_reader :colour

   def initialize(window)
      @window  = window
      @image   = Gosu::Image.new('square.png')
      @size    = 75
      @xpos    = 500
      @ypos    =  80
      @colour  = 0
   end

   def draw
      @image.draw(@xpos, @ypos, 0, @size/225.0, @size/225.0,
                  @window.get_col(@colour))
   end

   def mouse(x, y)
      if x >= @xpos and x < @xpos + @size and
         y >= @ypos and y < @ypos + @size
         @colour = (@colour+1) % 6
      end
   end
end

