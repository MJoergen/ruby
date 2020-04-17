SIZE=4
MAX=SIZE-1
class Face
   def initialize(window, j)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @size   = 25
      @id     = j

      # Initialize colour placement
      @pieces = [6]*(SIZE*SIZE)
   end

   def clear
      @pieces = [6]*(SIZE*SIZE)
   end

   def full
      @pieces = [@id]*(SIZE*SIZE)
   end

   def save(f)
      for y in 0..MAX
         s = ""
         for x in 0..MAX
            s += "#{@pieces[SIZE*y+x]}"
         end
         s += "\n"
         f.write(s)
      end
      f.write("\n")
   end

   def load(f)
      for y in 0..MAX
         line = f.gets
         for x in 0..MAX
            @pieces[SIZE*y+x] = line[x].to_i
         end
      end
      line = f.gets
   end

   def draw(pos)
      for x in 0..MAX
         for y in 0..MAX
            @image.draw(pos[:x] + @size*x, pos[:y] + @size*y, 0, 
                        (@size-4.0)/225, (@size-4.0)/225,
                        @window.get_col(@pieces[SIZE*y+x]))
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
      if @pieces[SIZE*y+x] == c
         draw_illegal(pos, x, y)
      end
      if @pieces[SIZE*(MAX-x)+y] == c
         draw_illegal(pos, y, MAX-x)
      end
      if @pieces[SIZE*(MAX-y)+(MAX-x)] == c
         draw_illegal(pos, MAX-x, MAX-y)
      end
      if @pieces[SIZE*x+(MAX-y)] == c
         draw_illegal(pos, MAX-y, x)
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
      return @pieces[SIZE*y+x]
   end

   def count_colour(c, x, y)
      r = 0
      if @pieces[SIZE*y+x] == c
         r += 1
      end
      if @pieces[SIZE*(MAX-x)+y] == c
         r += 1
      end
      if @pieces[SIZE*(MAX-y)+(MAX-x)] == c
         r += 1
      end
      if @pieces[SIZE*x+(MAX-y)] == c
         r += 1
      end

      return r
   end

   def mouse(x_rel, y_rel, colour)
      x = (x_rel / @size).floor
      y = (y_rel / @size).floor
      if @pieces[SIZE*y+x] < 6
         @pieces[SIZE*y+x] = 6
      else
         @pieces[SIZE*y+x] = colour
      end
   end

   def rotate
      for x in 0..(MAX/2)
         for y in 0..(SIZE/2-1)
            tmp = @pieces[SIZE*y+x]
            @pieces[SIZE*y+x] = @pieces[SIZE*(MAX-x)+y]
            @pieces[SIZE*(MAX-x)+y] = @pieces[SIZE*(MAX-y)+(MAX-x)]
            @pieces[SIZE*(MAX-y)+(MAX-x)] = @pieces[SIZE*x+(MAX-y)]
            @pieces[SIZE*x+(MAX-y)] = tmp
         end
      end
   end

end

