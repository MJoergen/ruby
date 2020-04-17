#!/usr/bin/env ruby

require 'gosu'

require_relative 'cube.rb'
require_relative 'square.rb'

class GameWindow < Gosu::Window

   attr_reader :colour
   attr_reader :error_col

   def initialize(filename)
      super(1300, 600, false)
      self.caption = 'Cube Colouring'

      @filename = filename
      @cube     = Cube.new(self)
      @square   = Square.new(self)
      @font     = Gosu::Font.new(24)

      if @filename == nil
         @filename = "cube.txt"
      end

      @error_col = Gosu::Color.argb(0xff_ff80FF) # Cyan

      @colour = {
         'R' => Gosu::Color.argb(0xff_ff0000), # Red
         'B' => Gosu::Color.argb(0xff_0000ff), # Blue
         'W' => Gosu::Color.argb(0xff_ffffff), # White
         'Y' => Gosu::Color.argb(0xff_ffff00), # Yellow
         'G' => Gosu::Color.argb(0xff_00C000), # Green
         'O' => Gosu::Color.argb(0xff_ff8000), # Orange
         '.' => Gosu::Color.argb(0xff_004000)  # Dark Green
      }

      @colour_index = 0
      @colour_map = [   # 24 possible orientations of the colours.
         "BOWYRG.",
         "BRYWOG.",
         "BWROYG.",
         "BYORWG.",
         "GOYWRB.",
         "GRWYOB.",
         "GWORYB.",
         "GYROWB.",
         "OBYWGR.",
         "OGWYBR.",
         "OWBGYR.",
         "OYGBWR.",
         "RBWYGO.",
         "RGYWBO.",
         "RWGBYO.",
         "RYBGWO.",
         "WBORGY.",
         "WGROBY.",
         "WOGBRY.",
         "WRBGOY.",
         "YBROGW.",
         "YGORBW.",
         "YOBGRW.",
         "YRGBOW."]
   end

   def get_col(col)
      return @colour[@colour_map[@colour_index][col]]
   end

   def needs_cursor?
      true
   end

   # This event is checked 60 times per second.
   def update
      self.caption = "Cube - [FPS: #{Gosu::fps.to_s}]"
   end

   # This controls the graphics in the game. Also checks around 60 times per
   # second...
   def draw
      @cube.draw
      @square.draw
      @font.draw_text("<Esc> : Quit program",                              800,  50, 0)
      @font.draw_text("   F  : Fill board",                                800,  80, 0)
      @font.draw_text("   C  : Clear board",                               800, 110, 0)
      @font.draw_text("   S  : Save to #{@filename}",                      800, 140, 0)
      @font.draw_text("   L  : Load from #{@filename}",                    800, 170, 0)
      @font.draw_text("   N  : Change colour index (#{@colour_index})",    800, 200, 0)
      @font.draw_text("Use left mouse button to change individual tiles.", 800, 230, 0)
      @font.draw_text("Click on large tile to change default colour.",     800, 260, 0)
      @font.draw_text("Use arrow keys to turn entire cube.",               800, 290, 0)
   end

   # This checks when you press ESC
   def button_down(id)
      case id
      when Gosu::KbEscape
         close
      when Gosu::KbLeft
         @cube.left
      when Gosu::KbRight
         @cube.right
      when Gosu::KbUp
         @cube.up
      when Gosu::KbDown
         @cube.down
      when Gosu::KbF
         @cube.full
      when Gosu::KbC
         @cube.clear
      when Gosu::KbN
         @colour_index = (@colour_index + 1) % 24
      when Gosu::KbS
         @cube.save(@filename)
      when Gosu::KbL
         @cube.load(@filename)
      when Gosu::MsLeft
         @cube.mouse(mouse_x, mouse_y, @square.colour)
         @square.mouse(mouse_x, mouse_y)
      end
   end
end

window = GameWindow.new(ARGV[0])
window.show

