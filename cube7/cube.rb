require_relative 'face.rb'

class Cube
   def initialize(window)
      @window   = window
      @image    = Gosu::Image.new('square.png')
      @font     = Gosu::Font.new(48)
      @size     = 25
      @margin   = 10
      @xpos     = 200
      @ypos     = 200

      # Initialize positions on screen of the six faces
      #
      #     1
      #   2 0 3 5
      #     4
      #
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
      @edges1 << [0, 0, 5,  2, 6, 5]
      @edges1 << [0, 1, 0,  1, 1, 6]
      @edges1 << [0, 5, 6,  4, 5, 0]
      @edges1 << [0, 6, 1,  3, 0, 1]
      @edges1 << [1, 0, 5,  2, 5, 0]
      @edges1 << [1, 1, 0,  5, 5, 0]
      @edges1 << [1, 5, 6,  0, 5, 0]
      @edges1 << [1, 6, 1,  3, 5, 0]
      @edges1 << [2, 0, 5,  5, 6, 5]
      @edges1 << [2, 1, 0,  1, 0, 1]
      @edges1 << [2, 5, 6,  4, 0, 1]
      @edges1 << [2, 6, 1,  0, 0, 1]
      @edges1 << [3, 0, 5,  0, 6, 5]
      @edges1 << [3, 1, 0,  1, 6, 5]
      @edges1 << [3, 5, 6,  4, 6, 5]
      @edges1 << [3, 6, 1,  5, 0, 1]
      @edges1 << [4, 0, 5,  2, 1, 6]
      @edges1 << [4, 1, 0,  0, 1, 6]
      @edges1 << [4, 5, 6,  5, 1, 6]
      @edges1 << [4, 6, 1,  3, 1, 6]
      @edges1 << [5, 0, 5,  3, 6, 5]
      @edges1 << [5, 1, 0,  1, 5, 0]
      @edges1 << [5, 5, 6,  4, 1, 6]
      @edges1 << [5, 6, 1,  2, 0, 1]

      # 24 edge pieces close to the centre
      @edges2 = []
      @edges2 << [0, 0, 4,  2, 6, 4]
      @edges2 << [0, 2, 0,  1, 2, 6]
      @edges2 << [0, 4, 6,  4, 4, 0]
      @edges2 << [0, 6, 2,  3, 0, 2]
      @edges2 << [1, 0, 4,  2, 4, 0]
      @edges2 << [1, 2, 0,  5, 4, 0]
      @edges2 << [1, 4, 6,  0, 4, 0]
      @edges2 << [1, 6, 2,  3, 4, 0]
      @edges2 << [2, 0, 4,  5, 6, 4]
      @edges2 << [2, 2, 0,  1, 0, 2]
      @edges2 << [2, 4, 6,  4, 0, 2]
      @edges2 << [2, 6, 2,  0, 0, 2]
      @edges2 << [3, 0, 4,  0, 6, 4]
      @edges2 << [3, 2, 0,  1, 6, 4]
      @edges2 << [3, 4, 6,  4, 6, 4]
      @edges2 << [3, 6, 2,  5, 0, 2]
      @edges2 << [4, 0, 4,  2, 2, 6]
      @edges2 << [4, 2, 0,  0, 2, 6]
      @edges2 << [4, 4, 6,  5, 2, 6]
      @edges2 << [4, 6, 2,  3, 2, 6]
      @edges2 << [5, 0, 4,  3, 6, 4]
      @edges2 << [5, 2, 0,  1, 4, 0]
      @edges2 << [5, 4, 6,  4, 2, 6]
      @edges2 << [5, 6, 2,  2, 0, 2]

      # 12 edge pieces at the centre (and swapped)
      @edges3 = []
      @edges3 << [0, 0, 3,  2, 6, 3]
      @edges3 << [0, 3, 0,  1, 3, 6]
      @edges3 << [0, 3, 6,  4, 3, 0]
      @edges3 << [0, 6, 3,  3, 0, 3]
      @edges3 << [1, 0, 3,  2, 3, 0]
      @edges3 << [1, 3, 0,  5, 3, 0]
      @edges3 << [1, 3, 6,  0, 3, 0]
      @edges3 << [1, 6, 3,  3, 3, 0]
      @edges3 << [2, 0, 3,  5, 6, 3]
      @edges3 << [2, 3, 0,  1, 0, 3]
      @edges3 << [2, 3, 6,  4, 0, 3]
      @edges3 << [2, 6, 3,  0, 0, 3]
      @edges3 << [3, 0, 3,  0, 6, 3]
      @edges3 << [3, 3, 0,  1, 6, 3]
      @edges3 << [3, 3, 6,  4, 6, 3]
      @edges3 << [3, 6, 3,  5, 0, 3]
      @edges3 << [4, 0, 3,  2, 3, 6]
      @edges3 << [4, 3, 0,  0, 3, 6]
      @edges3 << [4, 3, 6,  5, 3, 6]
      @edges3 << [4, 6, 3,  3, 3, 6]
      @edges3 << [5, 0, 3,  3, 6, 3]
      @edges3 << [5, 3, 0,  1, 3, 0]
      @edges3 << [5, 3, 6,  4, 3, 6]
      @edges3 << [5, 6, 3,  2, 0, 3]

      # 24 corner pieces (incl rotations)
      @corners = []
      @corners << [0, 0, 0,  1, 0, 6,  2, 6, 0]
      @corners << [0, 0, 6,  2, 6, 6,  4, 0, 0]
      @corners << [0, 6, 0,  3, 0, 0,  1, 6, 6]
      @corners << [0, 6, 6,  4, 6, 0,  3, 0, 0]
      @corners << [1, 0, 6,  2, 6, 0,  0, 0, 0]
      @corners << [1, 0, 6,  5, 0, 0,  2, 6, 0]
      @corners << [1, 6, 6,  0, 6, 0,  3, 0, 0]
      @corners << [1, 6, 6,  3, 0, 0,  5, 6, 0]
      @corners << [2, 6, 0,  0, 0, 0,  1, 0, 6]
      @corners << [2, 6, 0,  1, 0, 6,  5, 0, 0]
      @corners << [2, 6, 6,  4, 0, 0,  0, 0, 6]
      @corners << [2, 6, 6,  5, 0, 6,  4, 0, 0]
      @corners << [3, 0, 0,  0, 6, 6,  4, 6, 0]
      @corners << [3, 0, 0,  1, 6, 6,  0, 6, 0]
      @corners << [3, 0, 0,  4, 6, 0,  5, 6, 6]
      @corners << [3, 0, 0,  5, 6, 0,  1, 6, 6]
      @corners << [4, 0, 0,  0, 0, 6,  2, 6, 6]
      @corners << [4, 0, 0,  2, 6, 6,  5, 0, 6]
      @corners << [4, 6, 0,  3, 0, 0,  0, 6, 6]
      @corners << [4, 6, 0,  5, 6, 6,  3, 0, 0]
      @corners << [5, 0, 0,  2, 6, 0,  1, 0, 6]
      @corners << [5, 0, 6,  4, 0, 0,  2, 6, 6]
      @corners << [5, 6, 0,  1, 6, 6,  3, 0, 0]
      @corners << [5, 6, 6,  3, 0, 0,  4, 6, 0]
   end

   def clear
      for i in 0..5
         @faces[i].clear
      end
   end

   def full
      for i in 0..5
         @faces[i].full
      end
   end

   def save(filename)
      f = File.open(filename, "w")
      for i in 0..5
         @faces[i].save(f)
      end
      f.close()
   end

   def load(filename)
      f = File.open(filename, "r")
      for i in 0..5
         @faces[i].load(f)
      end
      f.close()
   end

   def draw
      for i in 0..5
         @faces[i].draw(@positions[i])
      end

      if not legal?
         @font.draw_text("Illegal", 10, 45, 2, 1.0, 1.0,
                         Gosu::Color.argb(0xff_ffffff))
      end
   end

   def check_edges(edges)
      errors = 0
      # Check edges close to the corner
      exp = []
      for col1 in 0..5
         for col2 in 0..5
            colour_pair = 6*col1 + col2
            if col1==col2 or col1+col2==5 
               exp[colour_pair] = 0
            else
               exp[colour_pair] = 1
            end
         end
      end
      pairs = [0]*36
      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            pairs[colour_pair] += 1
            if pairs[colour_pair] > exp[colour_pair]
               @faces[edge[0]].draw_illegal(@positions[edge[0]], edge[1], edge[2])
               @faces[edge[3]].draw_illegal(@positions[edge[3]], edge[4], edge[5])
               errors += 1
            end
         end
      end

      return errors
   end

   def check_corners
      errors = 0
      exp = [0]*216
      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         exp_colour_pair = 36*corner[0] + 6*corner[3] + corner[6]
         exp[exp_colour_pair] += 1
      end

      obs = [0]*216
      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         if col1 < 6 and col2 < 6 and col3 < 6
            colour_pair = 36*col1 + 6*col2 + col3
            obs[colour_pair] += 1
            if obs[colour_pair] > exp[colour_pair]
               @faces[corner[0]].draw_illegal(@positions[corner[0]], corner[1], corner[2])
               @faces[corner[3]].draw_illegal(@positions[corner[3]], corner[4], corner[5])
               @faces[corner[6]].draw_illegal(@positions[corner[6]], corner[7], corner[8])
               errors += 1
            end
         end
      end

      return errors
   end

   def check_faces
      errors = 0
      for i in 0..2
         for j in i..3
            if i != j and j != 3
               exp = 8
            else
               exp = 4
            end
            for c in 0..5
               count = 0
               for f in 0..5
                  count += @faces[f].count_colour(c, i, j)
               end
               if count > exp
                  for g in 0..5
                     @faces[g].draw_illegal_face(@positions[g], i, j, c)
                  end
                  errors += 1
               end
            end
         end
      end
      return errors
   end

   def legal?
      errors  = check_faces
      errors += check_edges(@edges1)
      errors += check_edges(@edges2)
      errors += check_edges(@edges3)
      errors += check_corners

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
      @faces[5].rotate
      @faces[5].rotate

      @faces[2].rotate
      @faces[2].rotate
      @faces[2].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[1]
      @faces[1] = @faces[0]
      @faces[0] = @faces[4]
      @faces[4] = tmp

      @faces[5].rotate
      @faces[5].rotate
   end

   def down
      @faces[5].rotate
      @faces[5].rotate

      @faces[2].rotate
      @faces[3].rotate
      @faces[3].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[4]
      @faces[4] = @faces[0]
      @faces[0] = @faces[1]
      @faces[1] = tmp

      @faces[5].rotate
      @faces[5].rotate
   end

end

