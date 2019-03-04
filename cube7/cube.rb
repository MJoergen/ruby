class Cube
   def initialize(window)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @size   = 25
      @margin = 10
      @xpos   = 300
      @ypos   = 200
      @colour = [
         Gosu::Color.argb(0xff_ffffff), # White
         Gosu::Color.argb(0xff_0000ff), # Blue
         Gosu::Color.argb(0xff_ffff00), # Yellow
         Gosu::Color.argb(0xff_ff0000), # Red
         Gosu::Color.argb(0xff_00ff00), # Green
         Gosu::Color.argb(0xff_ff8000)  # Orange
      ]

      # Initialize colour placement
      @pieces = []
      for i in 0..5
         @pieces[i] = []
         for j in 0..48
            @pieces[i] += [(i+j)%6]
         end
      end
   end

   def draw_face(face, off_x, off_y)
      for x in 0..6
         for y in 0..6
            @image.draw(off_x + @size*x, off_y + @size*y, 0, 
                        (@size-4.0)/225, (@size-4.0)/225,
                        @colour[@pieces[face][7*y+x]])
         end
      end
   end

   def draw
      # Shown on the board is the following
      #    1
      #  2 0 3
      #    4
      #  And hidden on the back (not shown) is 5.
      #
      draw_face(0, @xpos, @ypos)
      draw_face(1, @xpos, @ypos - 7*@size - @margin)
      draw_face(2, @xpos - 7*@size - @margin, @ypos)
      draw_face(3, @xpos + 7*@size + @margin, @ypos)
      draw_face(4, @xpos, @ypos + 7*@size + @margin)
   end

   def rotate(face)
      for x in 0..3
         for y in 0..2
            tmp = @pieces[face][7*y+x]
            @pieces[face][7*y+x] = @pieces[face][7*(6-x)+y]
            @pieces[face][7*(6-x)+y] = @pieces[face][7*(6-y)+(6-x)]
            @pieces[face][7*(6-y)+(6-x)] = @pieces[face][7*x+(6-y)]
            @pieces[face][7*x+(6-y)] = tmp
         end
      end
   end

   def left
      rotate(1)
      rotate(4)
      rotate(4)
      rotate(4)
      tmp = @pieces[5]
      @pieces[5] = @pieces[2]
      @pieces[2] = @pieces[0]
      @pieces[0] = @pieces[3]
      @pieces[3] = tmp
   end

   def right
      rotate(1)
      rotate(1)
      rotate(1)
      rotate(4)
      tmp = @pieces[5]
      @pieces[5] = @pieces[3]
      @pieces[3] = @pieces[0]
      @pieces[0] = @pieces[2]
      @pieces[2] = tmp
   end

   def up
      rotate(2)
      rotate(2)
      rotate(2)
      rotate(3)
      tmp = @pieces[5]
      @pieces[5] = @pieces[1]
      @pieces[1] = @pieces[0]
      @pieces[0] = @pieces[4]
      @pieces[4] = tmp
   end

   def down
      rotate(2)
      rotate(3)
      rotate(3)
      rotate(3)
      tmp = @pieces[5]
      @pieces[5] = @pieces[4]
      @pieces[4] = @pieces[0]
      @pieces[0] = @pieces[1]
      @pieces[1] = tmp
   end
end

