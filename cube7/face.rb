class Face
   def initialize(window, j)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @size   = 25

      # Initialize colour placement
      @pieces = []
      for i in 0..48
         @pieces += [6]
      end
      @pieces[24] = j
   end

   def draw(pos)
      for x in 0..6
         for y in 0..6
            @image.draw(pos[:x] + @size*x, pos[:y] + @size*y, 0, 
                        (@size-4.0)/225, (@size-4.0)/225,
                        @window.colour[@pieces[7*y+x]])
         end
      end
   end

   def mouse(x_rel, y_rel, colour)
      x = (x_rel / @size).floor
      y = (y_rel / @size).floor
      if x != 3 or y != 3 
         @pieces[7*y+x] = colour
      end
   end

   def rotate
      for x in 0..3
         for y in 0..2
            tmp = @pieces[7*y+x]
            @pieces[7*y+x] = @pieces[7*(6-x)+y]
            @pieces[7*(6-x)+y] = @pieces[7*(6-y)+(6-x)]
            @pieces[7*(6-y)+(6-x)] = @pieces[7*x+(6-y)]
            @pieces[7*x+(6-y)] = tmp
         end
      end
   end

end

