class Attackspeed 
  
  def initialize(window ,type)
	@image = Gosu::Image.new(window, "media/Attackspeed.png", false)
    @window = window
	@angle = 0
	@font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
	@type = type
  end
  
  def update
    @angle += 1
	@angle = @angle % 360
	
	if @window.menu == true
		self.killbuff
	end
	
	if @window.collisionplayer(@x, @y, 20) then
		
		@window.player.getbuff(@type)
		@window.destroy_instance(self)
    end
  end
  
  def killbuff
	@window.destroy_instance(self)
  end
  
  def warp(x, y)
    @x, @y = x, y
  end
  
  def draw
	@c_fuschia = 0xffff00ff
	@font.draw(@type, @x-5, @y-7, 2, 1.0, 1.0, @c_fuschia)
    @image.draw_rot(@x, @y, 1, @angle, 0.5, 0.65)
  end
end
