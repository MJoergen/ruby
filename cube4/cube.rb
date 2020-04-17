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
      @positions << {x:@xpos,                            y:@ypos}
      @positions << {x:@xpos,                            y:@ypos - (SIZE*@size + @margin)}
      @positions << {x:@xpos - (SIZE*@size + @margin),   y:@ypos}
      @positions << {x:@xpos + (SIZE*@size + @margin),   y:@ypos}
      @positions << {x:@xpos,                            y:@ypos + (SIZE*@size + @margin)}
      @positions << {x:@xpos + 2*(SIZE*@size + @margin), y:@ypos}

      @faces = []
      for i in 0..5
         @faces << Face.new(window, i)
      end

      @edges0 = make_edge_list(0)
      @edges1 = make_edge_list(1)

      # 24 corner pieces (incl rotations)
      @corners = []
      @corners << [0,   0,   0,  1,   0, MAX,  2, MAX,   0]
      @corners << [0,   0, MAX,  2, MAX, MAX,  4,   0,   0]
      @corners << [0, MAX,   0,  3,   0,   0,  1, MAX, MAX]
      @corners << [0, MAX, MAX,  4, MAX,   0,  3,   0, MAX]
      @corners << [1,   0,   0,  5, MAX,   0,  2,   0,   0]
      @corners << [1,   0, MAX,  2, MAX,   0,  0,   0,   0]
      @corners << [1, MAX,   0,  3, MAX,   0,  5,   0,   0]
      @corners << [1, MAX, MAX,  0, MAX,   0,  3,   0,   0]
      @corners << [2,   0,   0,  1,   0,   0,  5, MAX,   0]
      @corners << [2,   0, MAX,  5, MAX, MAX,  4,   0, MAX]
      @corners << [2, MAX,   0,  0,   0,   0,  1,   0, MAX]
      @corners << [2, MAX, MAX,  4,   0,   0,  0,   0, MAX]
      @corners << [3,   0,   0,  1, MAX, MAX,  0, MAX,   0]
      @corners << [3,   0, MAX,  0, MAX, MAX,  4, MAX,   0]
      @corners << [3, MAX,   0,  5,   0,   0,  1, MAX,   0]
      @corners << [3, MAX, MAX,  4, MAX, MAX,  5,   0, MAX]
      @corners << [4,   0,   0,  0,   0, MAX,  2, MAX, MAX]
      @corners << [4,   0, MAX,  2,   0, MAX,  5, MAX, MAX]
      @corners << [4, MAX,   0,  3,   0, MAX,  0, MAX, MAX]
      @corners << [4, MAX, MAX,  5,   0, MAX,  3, MAX, MAX]
      @corners << [5,   0,   0,  1, MAX,   0,  3, MAX,   0]
      @corners << [5,   0, MAX,  3, MAX, MAX,  4, MAX, MAX]
      @corners << [5, MAX,   0,  2,   0,   0,  1,   0,   0]
      @corners << [5, MAX, MAX,  4,   0, MAX,  2,   0, MAX]
   end

   def make_edge_list(i)
      j = MAX-i
      edges = []
      edges << [0,   0,   j,  2, MAX,   j]
      edges << [0,   i,   0,  1,   i, MAX]
      edges << [0,   j, MAX,  4,   j,   0]
      edges << [0, MAX,   i,  3,   0,   i]
      edges << [1,   0,   j,  2,   j,   0]
      edges << [1,   i,   0,  5,   j,   0]
      edges << [1,   j, MAX,  0,   j,   0]
      edges << [1, MAX,   i,  3,   j,   0]
      edges << [2,   0,   j,  5, MAX,   j]
      edges << [2,   i,   0,  1,   0,   i]
      edges << [2,   j, MAX,  4,   0,   i]
      edges << [2, MAX,   i,  0,   0,   i]
      edges << [3,   0,   j,  0, MAX,   j]
      edges << [3,   i,   0,  1, MAX,   j]
      edges << [3,   j, MAX,  4, MAX,   j]
      edges << [3, MAX,   i,  5,   0,   i]
      edges << [4,   0,   j,  2,   i, MAX]
      edges << [4,   i,   0,  0,   i, MAX]
      edges << [4,   j, MAX,  5,   i, MAX]
      edges << [4, MAX,   i,  3,   i, MAX]
      edges << [5,   0,   j,  3, MAX,   j]
      edges << [5,   i,   0,  1,   j,   0]
      edges << [5,   j, MAX,  4,   i, MAX]
      edges << [5, MAX,   i,  2,   0,   i]

      return edges
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
      exp = [0]*36
      obs = [0]*36
      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         exp_colour_pair = 6*edge[3] + edge[0]
         exp[exp_colour_pair] += 1
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            obs[colour_pair] += 1
         end
      end

      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            if obs[colour_pair] > exp[colour_pair]
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
      obs = [0]*216
      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         exp_colour_pair = 36*corner[0] + 6*corner[3] + corner[6]
         exp[exp_colour_pair] += 1
         if col1 < 6 and col2 < 6 and col3 < 6
            colour_pair = 36*col1 + 6*col2 + col3
            obs[colour_pair] += 1
         end
      end

      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         if col1 < 6 and col2 < 6 and col3 < 6
            colour_pair = 36*col1 + 6*col2 + col3
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
         for j in 0..3
            for c in 0..5
               count = 0
               for f in 0..5
                  count += @faces[f].count_colour(c, i, j)
               end
               if count > 4
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
      errors += check_edges(@edges0)
      errors += check_edges(@edges1)
      errors += check_corners

      return (errors == 0)
   end

   def mouse(x, y, colour)
      for i in 0..5
         if x >= @positions[i][:x] and x < @positions[i][:x] + SIZE*@size and
            y >= @positions[i][:y] and y < @positions[i][:y] + SIZE*@size
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

