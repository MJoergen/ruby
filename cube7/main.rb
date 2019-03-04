#!/usr/bin/env ruby

require 'gosu'

require_relative 'cube.rb'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)
    self.caption = 'Cube Colouring'

    @cube = Cube.new(self)
  end

  # This event is checked 60 times per second.
  def update
    self.caption = "Cube - [FPS: #{Gosu::fps.to_s}]"
  end

  # This controls the graphics in the game. Also checks around 60 times per
  # second...
  def draw
    @cube.draw
  end

  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
    if id == Gosu::KbLeft
      @cube.left
    end
    if id == Gosu::KbRight
      @cube.right
    end
    if id == Gosu::KbUp
      @cube.up
    end
    if id == Gosu::KbDown
      @cube.down
    end
  end
end

window = GameWindow.new
window.show

