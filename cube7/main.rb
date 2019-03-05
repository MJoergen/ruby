#!/usr/bin/env ruby

require 'gosu'

require_relative 'cube.rb'
require_relative 'square.rb'

class GameWindow < Gosu::Window

   attr_reader :colour

   def initialize
      super(1000, 600, false)
      self.caption = 'Cube Colouring'

      @cube   = Cube.new(self)
      @square = Square.new(self)

      @colour = [
         Gosu::Color.argb(0xff_ff0000), # Red
         Gosu::Color.argb(0xff_0000ff), # Blue
         Gosu::Color.argb(0xff_ffffff), # White
         Gosu::Color.argb(0xff_ffff00), # Yellow
         Gosu::Color.argb(0xff_00C000), # Green
         Gosu::Color.argb(0xff_ff8000), # Orange
         Gosu::Color.argb(0xff_004000)  # Dark Green
      ]
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
      when Gosu::MsLeft
         @cube.mouse(mouse_x, mouse_y, @square.colour)
         @square.mouse(mouse_x, mouse_y)
      end
   end
end

window = GameWindow.new
window.show

