require_relative 'face.rb'

class Cube
   def initialize(window)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @font   = Gosu::Font.new(48)
      @size   = 25
      @margin = 10
      @xpos   = 200
      @ypos   = 200

      # Initialize positions on screen of the six faces
      @positions = []
      @positions << {x:@xpos,                         y:@ypos}
      @positions << {x:@xpos,                         y:@ypos - (7*@size + @margin)}
      @positions << {x:@xpos - (7*@size + @margin),   y:@ypos}
      @positions << {x:@xpos + (7*@size + @margin),   y:@ypos}
      @positions << {x:@xpos,                         y:@ypos + (7*@size + @margin)}
      @positions << {x:@xpos + 2*(7*@size + @margin), y:@ypos}

      @faces = []
      for i in 0..5
         @faces << Face.new(window, i)
      end
   end

   def draw
      for i in 0..5
         @faces[i].draw(@positions[i])
      end

      if not legal?
         @font.draw("Illegal", 10, 45, 2, 1.0, 1.0,
                    Gosu::Color.argb(0xff_ffffff))
      end

      draw_col_count(800, 60)
   end

   def get_col_count(c, i, j)
      count = 0
      for f in 0..5
         count += @faces[f].count_col(c, i, j)
      end
      return count
   end

   def draw_col_count(x, y)
      xpos = x
      for c in 0..5
         @image.draw(xpos+30*c, 60, 0, @size/225.0, @size/225.0,
                     @window.colour[c])
         ypos =  y
         for i in 0..2
            for j in i..3
               ypos += 40
               count = get_col_count(c, i, j)
               @font.draw("#{count}", xpos + 30*c, ypos, 2, 1.0, 1.0,
                          Gosu::Color.argb(0xff_ffffff))
            end
         end
      end
   end

   def check_col_count(i, j)
      if i != j and j != 3
         exp = 8
      else
         exp = 4
      end

      errors = 0
      for c in 0..5
         count = get_col_count(c, i, j)
         if count > exp
            errors += 1
         end
      end
      return errors
   end

   def legal?
      errors = 0
      for i in 0..2
         for j in i..3
            errors += check_col_count(i, j)
         end
      end
      return (errors == 0)
   end

   def mouse(x, y, colour)
      for i in 0..5
         if x >= @positions[i][:x] and x < @positions[i][:x] + 7*@size and
            y >= @positions[i][:y] and y < @positions[i][:y] + 7*@size
            @faces[i].mouse(x - @positions[i][:x], y - @positions[i][:y], colour)
         end
      end
   end

   def left
      @faces[1].rotate
      @faces[4].rotate
      @faces[4].rotate
      @faces[4].rotate
      tmp = @faces[5]
      @faces[5] = @faces[2]
      @faces[2] = @faces[0]
      @faces[0] = @faces[3]
      @faces[3] = tmp
   end

   def right
      @faces[1].rotate
      @faces[1].rotate
      @faces[1].rotate
      @faces[4].rotate
      tmp = @faces[5]
      @faces[5] = @faces[3]
      @faces[3] = @faces[0]
      @faces[0] = @faces[2]
      @faces[2] = tmp
   end

   def up
      @faces[2].rotate
      @faces[2].rotate
      @faces[2].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[1]
      @faces[1] = @faces[0]
      @faces[0] = @faces[4]
      @faces[4] = tmp
   end

   def down
      @faces[2].rotate
      @faces[3].rotate
      @faces[3].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[4]
      @faces[4] = @faces[0]
      @faces[0] = @faces[1]
      @faces[1] = tmp
   end

end

