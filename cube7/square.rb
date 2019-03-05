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
                  @window.colour[@colour])
   end

   def num(num)
      @colour = num
   end

end

