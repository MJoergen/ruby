class Face
   def initialize(window, j)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @size   = 25

      # Initialize colour placement
      @pieces = [6]*49
      @pieces[24] = j
   end

   def clear
      tmp = @pieces[24]
      @pieces = [6]*49
      @pieces[24] = tmp
   end

   def full
      tmp = @pieces[24]
      @pieces = [tmp]*49
   end

   def save(f)
      for y in 0..6
         s = ""
         for x in 0..6
            s += "#{@pieces[7*y+x]}"
         end
         s += "\n"
         f.write(s)
      end
      f.write("\n")
   end

   def load(f)
      for y in 0..6
         line = f.gets
         for x in 0..6
            @pieces[7*y+x] = line[x].to_i
         end
      end
      line = f.gets
   end

   def draw(pos)
      for x in 0..6
         for y in 0..6
            @image.draw(pos[:x] + @size*x, pos[:y] + @size*y, 0, 
                        (@size-4.0)/225, (@size-4.0)/225,
                        @window.get_col(@pieces[7*y+x]))
         end
      end
   end

   def draw_line(x1, y1, x2, y2, thickness, col)
      if x1 < x2
         @window.draw_quad(x1+thickness, y1,           col,
                           x1,           y1+thickness, col,
                           x2,           y2-thickness, col,
                           x2-thickness, y2,           col)
      else
         @window.draw_quad(x1-thickness, y1,           col,
                           x1,           y1+thickness, col,
                           x2,           y2-thickness, col,
                           x2+thickness, y2,           col)
      end
   end

   def draw_illegal_face(pos, x, y, c)
      if @pieces[7*y+x] == c
         draw_illegal(pos, x, y)
      end
      if @pieces[7*(6-x)+y] == c
         draw_illegal(pos, y, 6-x)
      end
      if @pieces[7*(6-y)+(6-x)] == c
         draw_illegal(pos, 6-x, 6-y)
      end
      if @pieces[7*x+(6-y)] == c
         draw_illegal(pos, 6-y, x)
      end

      if x != y and y != 3
         if @pieces[7*x+y] == c
            draw_illegal(pos, y, x)
         end
         if @pieces[7*(6-y)+x] == c
            draw_illegal(pos, x, 6-y)
         end
         if @pieces[7*(6-x)+(6-y)] == c
            draw_illegal(pos, 6-y, 6-x)
         end
         if @pieces[7*y+(6-x)] == c
            draw_illegal(pos, 6-x, y)
         end
      end
   end

   def draw_illegal(pos, x, y)
      draw_line(pos[:x] + @size*x,         pos[:y] + @size*y,
                pos[:x] + @size*(x+1) - 4, pos[:y] + @size*(y+1) - 4,
                @size/4, @window.error_col)
      draw_line(pos[:x] + @size*(x+1) - 4, pos[:y] + @size*y,
                pos[:x] + @size*x,         pos[:y] + @size*(y+1) - 4,
                @size/4, @window.error_col)
   end

   def get_col(x, y)
      return @pieces[7*y+x]
   end

   def count_colour(c, x, y)
      r = 0
      if @pieces[7*y+x] == c
         r += 1
      end
      if @pieces[7*(6-x)+y] == c
         r += 1
      end
      if @pieces[7*(6-y)+(6-x)] == c
         r += 1
      end
      if @pieces[7*x+(6-y)] == c
         r += 1
      end

      if x != y and y != 3
         if @pieces[7*x+y] == c
            r += 1
         end
         if @pieces[7*(6-y)+x] == c
            r += 1
         end
         if @pieces[7*(6-x)+(6-y)] == c
            r += 1
         end
         if @pieces[7*y+(6-x)] == c
            r += 1
         end
      end

      return r
   end

   def mouse(x_rel, y_rel, colour)
      x = (x_rel / @size).floor
      y = (y_rel / @size).floor
      if x != 3 or y != 3 
         if @pieces[7*y+x] < 6
            @pieces[7*y+x] = 6
         else
            @pieces[7*y+x] = colour
         end
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

