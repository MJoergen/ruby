# This is the main script, this is where the magic happens
# First we requre the gosu library which we need for this project
require 'gosu'
# Then we requre the other scripts reletive to this script so we can access them later
require_relative 'player.rb'
require_relative 'star.rb'
require_relative 'button.rb'
require_relative 'asteroid.rb'

module ZOrder# ZOrder is the depth of how graphics will be placed, the higest number will always be ontop
  Background, Elements, Player, UI, Mouse = *0..4
end

class GameWindow < Gosu::Window# The game window class, this is controlling what you see on the screen
  def initialize(fullscreen)
    super(640, 480, fullscreen)
    self.caption = "Space Game 101"
    @sound_switch = Gosu::Sample.new(self, "media/switch.wav")
    @sound_alarm = Gosu::Sample.new(self, "media/alarm.wav")
    @song = Gosu::Song.new(self, "media/song.ogg")
	@fullscreen = fullscreen

    @cursor = Gosu::Image.new(self, "media/cursor.png", false)
    
    @background_image = Gosu::Image.new(self, "media/bg_space.png", true)
    @background_image_menu = Gosu::Image.new(self, "media/bg_spacemenu.png", true)
    @background_image_menu_upgrade = Gosu::Image.new(self, "media/bg_spaceupgrademenu.png", true)
    
    @player = Player.new(self)
    @player.warp(320, 240)
    
    @star_anim = Gosu::Image::load_tiles(self, "media/star2.png", 32, 32, false)
	@asteroid_anim = Gosu::Image::load_tiles(self, "media/asteroid.png", 32, 32, false)
	@asteroids = []
    @stars = []
    @buttons = []
    @upgradebuttons = []
	
    @upgrademenu = false
    @menu = true
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @song.play(true)
    
    @buttons.push(Button.new(self, 10, 120, 1, 0.25, "Start Game", 20, 5))
    @buttons.push(Button.new(self, 10, 160, 1, 0.25, "Quit Game", 20, 5))
    if !@fullscreen
	  @buttons.push(Button.new(self, 150, 120, 1, 0.25, "Fullscreen", 20, 5))
	else
      @buttons.push(Button.new(self, 150, 120, 1, 0.25, "Window", 20, 5))
	end
    @upgradebuttons.push(Upgradebutton.new(self, 10, 145, 1, 0.25, "Speed Upgrade", 1, 5))
	
	@mouse_debug = false
	@debug = false
  end

  def update
    if @menu
      if mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 120 && mouse_y < 120 + 30 || mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 160 && mouse_y < 160 + 30 || mouse_x > 150 && mouse_x < 150 + 130 && mouse_y > 120 && mouse_y < 120 + 30
	    @mouse_debug = true
	  else
	    @mouse_debug = false
	  end
	end
	if @upgrademenu
	  if mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 145 && mouse_y < 145 + 30
	    @mouse_debug = true
      else
	    @mouse_debug = false
	  end
	end
	
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      if !@menu && !@upgrademenu
        @player.turn_left
      end
    end
    
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      if !@menu && !@upgrademenu
        @player.turn_right
      end
    end
    
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      if !@menu && !@upgrademenu
        @player.accelerate
      end
    end

    @player.move
    @player.collect_stars(@stars)

    if rand(100) < 4 and @stars.size < 25 then
      if !@menu && !@upgrademenu
      @stars.push(Star.new(@star_anim))
      end
    end
	
	if rand(100) < 4 and @asteroids.size < 1 then
      if !@menu && !@upgrademenu
      @asteroids.push(Asteroid.new(@asteroid_anim))
      end
    end
  end

  def draw
    if !@menu && !@upgrademenu
      @background_image.draw(0, 0, ZOrder::Background)
      @player.draw
      @stars.each { |star| star.draw }
	  @asteroids.each { |asteroid| asteroid.draw }
      @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end
    
    if @menu
	  if @debug
        @font.draw("Debug: Mouse x: #{mouse_x}, Mouse y: #{mouse_y} OK?: #{@mouse_debug}", 5, 5, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
	  @buttons.each { |button| button.draw }
      @cursor.draw(mouse_x, mouse_y, ZOrder::Mouse)
      @background_image_menu.draw(0, 0, ZOrder::Background)
    end
    
    if @upgrademenu
	  if @debug
        @font.draw("Debug: Mouse x: #{mouse_x}, Mouse y: #{mouse_y} OK?: #{@mouse_debug}", 5, 5, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
	  @upgradebuttons.each { |button| button.draw }
      @cursor.draw(mouse_x, mouse_y, ZOrder::Mouse)
      @background_image_menu_upgrade.draw(0, 0, ZOrder::Background)
      @font.draw("costs 50 score. Level: #{@player.level}/10", 150, 150, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      @font.draw("Score: #{@player.score}.", 10, 120, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end
    
    if !@menu && !@upgrademenu
      @font.draw("Press X to go to the upgrade menu, Press ESC to go back to the main menu.", 10, 30, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end
  end

  def button_down(id)# This functon detects which buttons are pressed.
    if id == Gosu::KbEscape# Kb*button* for keyboard buttons and Ms*button* for mouse buttons
      if @menu
        @sound_switch.play
        close
      end
      if !@menu && !@upgrademenu
        @sound_switch.play
        @menu = true
      end
      if @upgrademenu
        @sound_switch.play
        @upgrademenu = false
      end
    end
    if id == Gosu::MsLeft
	  if @menu
	    if @buttons[0].pressed(mouse_x, mouse_y)# Start game
          @sound_alarm.play
          @menu = false
		end
	    if @buttons[1].pressed(mouse_x, mouse_y)# Quit game
		  close
		end
		if @buttons[2].pressed(mouse_x, mouse_y)# Screen res
		  if @fullscreen
	        @sound_switch.play
            close
            gamewindow = GameWindow.new(false).show
		  else
		    @sound_switch.play
            close
            gamewindow = GameWindow.new(true).show
		  end
		end
      end
	  if @upgrademenu
	    if @upgradebuttons[0].pressed(mouse_x, mouse_y)# Speed upgrade
		  @player.boost
		end
	  end
    end
    if id == Gosu::KbX
      if !@menu && !@upgrademenu
        @sound_switch.play
        @upgrademenu = true
      end
	end
	if id == Gosu::KbZ
	  if @debug
		@debug = false
      else
		@debug = true
	  end
    end
  end
end
gamewindow = GameWindow.new(false).show# This triggers the GameWindow class to start the game