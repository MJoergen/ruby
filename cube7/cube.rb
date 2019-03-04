class Cube
  def initialize(window)
    @window = window
    @image  = Gosu::Image.new('square.png')
    @size   = 50
    @colour = [
       Gosu::Color.argb(0xff_ffffff), # White
       Gosu::Color.argb(0xff_0000ff), # Blue
       Gosu::Color.argb(0xff_ffff00), # Yellow
       Gosu::Color.argb(0xff_ff0000), # Red
       Gosu::Color.argb(0xff_00ff00), # Green
       Gosu::Color.argb(0xff_ff8000)  # Orange
    ]

    @pieces = []
    for i in 0..5
       @pieces[i] = []
       for j in 0..48
          @pieces[i] += [j%6]
       end
    end
  end

  def update
  end

  def draw
     for x in 0..6
        for y in 0..6
           @image.draw(100 + @size*x, 100 + @size*y, 0, 
                       (@size-2.0)/225, (@size-2.0)/225,
                       @colour[@pieces[0][7*y+x]])
        end
     end
  end

  def left
  end

  def right
  end

  def up
  end

  def down
  end
end

