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

      # 24 edge pieces close to the corner
      @edges1 = []
      @edges1 << [0, 1, 0, 1, 1, 6]
      @edges1 << [0, 0, 5, 2, 6, 5]
      @edges1 << [0, 6, 1, 3, 0, 1]
      @edges1 << [0, 5, 6, 4, 5, 0]
      @edges1 << [2, 1, 0, 1, 0, 1]
      @edges1 << [3, 1, 0, 1, 6, 5]
      @edges1 << [5, 1, 0, 1, 5, 0]
      @edges1 << [2, 5, 6, 4, 0, 1]
      @edges1 << [5, 6, 1, 2, 0, 1]
      @edges1 << [4, 6, 1, 3, 1, 6]
      @edges1 << [5, 0, 5, 3, 6, 5]
      @edges1 << [5, 5, 6, 4, 1, 6]
      @edges1 << [1, 5, 6, 0, 5, 0]
      @edges1 << [2, 6, 1, 0, 0, 1]
      @edges1 << [3, 0, 5, 0, 6, 5]
      @edges1 << [4, 1, 0, 0, 1, 6]
      @edges1 << [1, 0, 5, 2, 5, 0]
      @edges1 << [1, 6, 1, 3, 5, 0]
      @edges1 << [1, 1, 0, 5, 5, 0]
      @edges1 << [4, 0, 5, 2, 1, 6]
      @edges1 << [2, 0, 5, 5, 6, 5]
      @edges1 << [3, 5, 6, 4, 6, 5]
      @edges1 << [3, 6, 1, 5, 0, 1]
      @edges1 << [4, 5, 6, 5, 1, 6]

      # 24 edge pieces close to the centre
      @edges2 = []
      @edges2 << [0, 2, 0, 1, 2, 6]
      @edges2 << [0, 0, 4, 2, 6, 4]
      @edges2 << [0, 6, 2, 3, 0, 2]
      @edges2 << [0, 4, 6, 4, 4, 0]
      @edges2 << [2, 2, 0, 1, 0, 2]
      @edges2 << [3, 2, 0, 1, 6, 4]
      @edges2 << [5, 2, 0, 1, 4, 0]
      @edges2 << [2, 4, 6, 4, 0, 2]
      @edges2 << [5, 6, 2, 2, 0, 2]
      @edges2 << [4, 6, 2, 3, 2, 6]
      @edges2 << [5, 0, 4, 3, 6, 4]
      @edges2 << [5, 4, 6, 4, 2, 6]
      @edges2 << [1, 4, 6, 0, 5, 0]
      @edges2 << [2, 6, 2, 0, 0, 2]
      @edges2 << [3, 0, 4, 0, 6, 4]
      @edges2 << [4, 2, 0, 0, 2, 6]
      @edges2 << [1, 0, 4, 2, 4, 0]
      @edges2 << [1, 6, 2, 3, 4, 0]
      @edges2 << [1, 2, 0, 5, 4, 0]
      @edges2 << [4, 0, 4, 2, 2, 6]
      @edges2 << [2, 0, 4, 5, 6, 4]
      @edges2 << [3, 4, 6, 4, 6, 4]
      @edges2 << [3, 6, 2, 5, 0, 2]
      @edges2 << [4, 4, 6, 5, 2, 6]

      # 12 edge pieces at the centre (and swapped)
      @edges3 = []
      @edges3 << [0, 3, 0, 1, 3, 6]
      @edges3 << [0, 0, 3, 2, 6, 3]
      @edges3 << [0, 6, 3, 3, 0, 3]
      @edges3 << [0, 3, 6, 4, 3, 0]
      @edges3 << [2, 3, 0, 1, 0, 3]
      @edges3 << [3, 3, 0, 1, 6, 3]
      @edges3 << [5, 3, 0, 1, 3, 0]
      @edges3 << [2, 3, 6, 4, 0, 3]
      @edges3 << [5, 6, 3, 2, 0, 3]
      @edges3 << [4, 6, 3, 3, 3, 6]
      @edges3 << [5, 0, 3, 3, 6, 3]
      @edges3 << [5, 3, 6, 4, 3, 6]
      @edges3 << [1, 3, 6, 0, 3, 0]
      @edges3 << [2, 6, 3, 0, 0, 3]
      @edges3 << [3, 0, 3, 0, 6, 3]
      @edges3 << [4, 3, 0, 0, 3, 6]
      @edges3 << [1, 0, 3, 2, 3, 0]
      @edges3 << [1, 6, 3, 3, 3, 0]
      @edges3 << [1, 3, 0, 5, 3, 0]
      @edges3 << [4, 0, 3, 2, 3, 6]
      @edges3 << [2, 0, 3, 5, 6, 3]
      @edges3 << [3, 3, 6, 4, 6, 3]
      @edges3 << [3, 6, 3, 5, 0, 3]
      @edges3 << [4, 3, 6, 5, 3, 6]
   end

   def draw
      for i in 0..5
         @faces[i].draw(@positions[i])
      end

      if not legal?
         @font.draw("Illegal", 10, 45, 2, 1.0, 1.0,
                    Gosu::Color.argb(0xff_ffffff))
      end

      draw_colour_count(800, 60)
   end

   def get_colour_count(c, i, j)
      count = 0
      for f in 0..5
         count += @faces[f].count_colour(c, i, j)
      end
      return count
   end

   def draw_colour_count(x, y)
      xpos = x
      for c in 0..5
         @image.draw(xpos+30*c, 60, 0, @size/225.0, @size/225.0,
                     @window.colour[c])
         ypos =  y
         for i in 0..2
            for j in i..3
               ypos += 40
               count = get_colour_count(c, i, j)
               @font.draw("#{count}", xpos + 30*c, ypos, 2, 1.0, 1.0,
                          Gosu::Color.argb(0xff_ffffff))
            end
         end
      end
   end

   def check_colour_count(i, j)
      if i != j and j != 3
         exp = 8
      else
         exp = 4
      end

      errors = 0
      for c in 0..5
         count = get_colour_count(c, i, j)
         if count > exp
            errors += 1
         end
      end
      return errors
   end

   def check_edges(edges)
      errors = 0
      # Check edges close to the corner
      pairs = [0]*36
      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            pairs[colour_pair] += 1
         end
      end
      for c1 in 0..5
         for c2 in 0..5
            if c1==c2 or c1+c2==5 
               exp = 0
            else
               exp = 1
            end
            if pairs[c1*6+c2] > exp
               errors += 1
            end
         end
      end

      return errors
   end

   def legal?
      errors = 0
      for i in 0..2
         for j in i..3
            errors += check_colour_count(i, j)
         end
      end

      errors += check_edges(@edges1)
      errors += check_edges(@edges2)
      errors += check_edges(@edges3)

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

