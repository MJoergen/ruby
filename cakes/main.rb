#!/bin/env ruby
# This adds the "gosu" library to the game, which enables various extra
# features!
require 'gosu'

# These are nessecary for THIS code/file to cooperate with the other
# files/codes
require_relative 'cake.rb'

# This adds the actual window to the game, which in this case works as a
# controller!
class GameWindow < Gosu::Window

  # This is the event that occurs when you start the game, like when the object
  # is "created"
  def initialize
    super(940, 600, false)

    @cakes = []
  end

  # This event is checked 60 times per second.
  def update
    self.caption = "Cake Game - [FPS: #{Gosu::fps.to_s}, Cakes: #{@cakes.size}]"

    # Randomly create new cakes.
    if rand(100) < 4 then
      @cakes.push(Cake.new(self))
    end

    # Move all cakes.
    @cakes.each { |inst|  inst.update }

    # Delete cakes that pass out of the screen.
    @cakes.reject! {|inst| inst.y > self.height }

  end

  # This controls the graphics in the game. Also checks around 60 times per
  # second...
  def draw
    @cakes.each { |inst|  inst.draw }
  end

  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show

