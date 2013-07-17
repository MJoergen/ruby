# This adds the "gosu" library to the game, which enables various extra features!
require 'gosu'
# These are nessecary for THIS code/file to cooperate with the other files/codes
require_relative 'player.rb'
require_relative 'nimph.rb'
require_relative 'fighter.rb'
require_relative 'bomb.rb'
require_relative 'whale.rb'
# This adds the actual "object" to the game, which in this case works as a controler!	
class GameWindow < Gosu::Window
  # This is the event that occurs when you start the game, like when the object is "created"
  def initialize
	super(640, 400, false)
    self.caption = "Gosu Tutorial Game"
    
	@background_image = Gosu::Image.new(self, "media/Psuedo.png", true)
    @player = Player.new(self)
    @player.warp(320, 200)
	@fighter = Fighter.new(self)
    @fighter.warp(rand(640), rand(400))
	@nimphs = [] # empty array of nimphs
	@bombs = [] # empty array of bombs
	@whales = [] #empty array of whales
    @keyztimer = @keyzmax = 5
	@energy = @energymax = 300
	@energyregen = 0.5
	@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
	@losegame = false
  end
  # This event is checked 60 times per second.

  
  def update
	if @energy < @energymax and @keyztimer == @keyzmax then
	  @energy = [@energy+@energyregen, @energymax].min
	end
	
	if @keyztimer < @keyzmax
	  @keyztimer += 1
	end
	
	if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @player.turn_left
    end
    
	if button_down? Gosu::KbZ and @keyztimer == @keyzmax and @energy > 5 then
      @nimphs.push(@player.shoot)  # Add new nimph to array
	  @keyztimer = 0
	  @energy = [0, @energy-5].max
	end
	
	if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @player.turn_right
    end
    
	if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    
	@player.move
	if  @player.update
		@losegame = true
	end
	
	if @fighter.update #This is called when fighter is dead
		@fighter = Fighter.new(self)
		@fighter.warp(rand(640), rand(400))
	end
	@fighter.collision(@nimphs)
	
	# This runs the collision check for the whale object!
	@whales.each { |whale| if whale.collision(@player) then @whales.delete(whale) end }
	
	# Move all the nimphs and destroy them when they go outside screen:
    @nimphs.each { |nimph| if nimph.move then @nimphs.delete(nimph) end }
	
	# This creates all the whales and destroys the bomb afterwards
	@bombs.each { |bomb|
		if bomb.update then
			for i in 0..14
				@whales.push(bomb.shoot(i*24))
			end
			@bombs.delete(bomb)
		end
	}
	
	# This moves all the whales and destroy them when they go outside screen:
	@whales.each { |whale| if whale.move then @whales.delete(whale) end }
	# This runs the update method for the whales and destroys them when their speed hits zero!
	@whales.each { |whale| if whale.update then @whales.delete(whale) end }
	
	# This creates tha bomb!
	if @fighter.updatebombtimer
		@bombs.push(@fighter.shoot)
	end
	
  end
  # This controls the graphics in the game. Also checks around 60 times per second...
  def draw
    if @losegame == false
		@player.draw
	else
		@font.draw("HAHA! You lost the game :P", 260, 190, 2, 1.0, 1.0, 0xffffff00)
	end
	@fighter.draw
	@nimphs.each { |nimph| nimph.draw } # Draw all nimphs
	@bombs.each { |bomb| bomb.draw } # Draw all bombs
	@whales.each { |whale| whale.draw } # Draw all whales
	@background_image.draw(0, 0, 0);
	@font.draw("Energy: #{@energy.round}", 10, 5, 2, 1.0, 1.0, 0xffffff00)
  end
  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show