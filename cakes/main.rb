#!/bin/env ruby

# This adds the "gosu" library to the game, which enables various extra
# features!
require 'gosu'

# These are nessecary for THIS code/file to cooperate with the other
# files/codes
require_relative 'cake.rb'
require_relative 'enemy.rb'
require_relative 'player.rb'
require_relative 'score.rb'

# This adds the actual window to the game, which in this case works as a
# controller!
class GameWindow < Gosu::Window
  attr_reader :player, :score

  # This is the event that occurs when you start the game, like when the object
  # is "created"
  def initialize
    super(940, 600, false)  # Set size of window
    
    @music = Gosu::Song.new("media/Darude - Sandstorm.ogg")
    @music.play

    @cakes = []             # Initially, there are no cakes on the screen
    @enemies = []           # Initially, there are no enemies on the screen
    @player = Player.new(self)
    @score  = Score.new(self)
  end

  # This event is checked 60 times per second.
  def update
    self.caption = "Cake Game - [FPS: #{Gosu::fps.to_s}, Cakes: #{@cakes.size}]"

    # Randomly create new cakes.
    if rand(100) < 4 then
      @cakes.push(Cake.new(self))
    end

    # Randomly create new enemies.
    if rand(100) < 1 then
      @enemies.push(Enemy.new(self))
    end

    # Update all cakes and enemies
    @cakes.each { |inst|  inst.update }
    @enemies.each { |inst|  inst.update }

    # Delete cakes and enemies that are dead.
    @cakes.reject! {|inst| inst.dead? }
    @enemies.reject! {|inst| inst.dead? }

    # Update the player
    @player.update
  end

  # This draws all the elements in the game. Also checks around 60 times per
  # second...
  def draw
    @cakes.each { |inst|  inst.draw }
    @enemies.each { |inst|  inst.draw }
    @player.draw
    @score.draw
  end

  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show

