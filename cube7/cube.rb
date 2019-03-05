require_relative 'face.rb'

class Cube
   def initialize(window)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @size   = 25
      @margin = 10
      @xpos   = 200
      @ypos   = 200

      # Initialize positions on screen of the six faces
      @positions = []
      @positions << {x:@xpos, y:@ypos}
      @positions << {x:@xpos, y:@ypos - 7*@size - @margin}
      @positions << {x:@xpos - 7*@size - @margin, y:@ypos}
      @positions << {x:@xpos + 7*@size + @margin, y:@ypos}
      @positions << {x:@xpos, y:@ypos + 7*@size + @margin}
      @positions << {x:@xpos + 2*7*@size + 2*@margin, y:@ypos}

      @faces = []
      for i in 0..5
         @faces << Face.new(window, i)
      end
   end

   def draw
      for i in 0..5
         @faces[i].draw(@positions[i])
      end
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

