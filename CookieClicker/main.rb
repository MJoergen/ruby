#!/bin/env ruby

# This adds the "gosu" library to the game, which enables various extra
# features!
require 'gosu'

# These are nessecary for THIS code/file to cooperate with the other
# files/codes
require_relative 'cookie.rb'
require_relative 'unit.rb'

# This adds the actual window to the game, which in this case works as a
# controller!
class GameWindow < Gosu::Window
    attr_reader :player, :score

    # This is the event that occurs when you start the game, like when the object
    # is "created"
    def initialize
        super(940, 600, false)  # Set size of window

        @cookie = Cookie.new(100, 100, "media/PerfectCookie.png")

        @units = []
        @units.push(Unit.new(0, 0, "media/CursorIconTransparent.png", "Cursor", 15, 0.1))

    end

    def needs_cursor?
        true
    end

    # This event is checked 60 times per second.
    def update
        self.caption = "Cookie Clicker - [Cookies: #{@cookie.cookies.to_i}, CPS: #{0}]"

        @units.each { |inst|
            @cookie.increase(inst.cps * inst.number / 60.0)
        }
    end

    def mouse(x, y)
        if @cookie.in_range?(x, y)
            @cookie.increase(1)
        end
        @units.each { |inst| 
            if inst.in_range?(x, y)
                if @cookie.cookies >= inst.cost
                    @cookie.increase(-inst.cost)
                    inst.buy
                end
            end
        }
    end

    # This draws all the elements in the game. Also checks around 60 times per
    # second...
    def draw
        @cookie.draw
        @units.each { |inst|  inst.draw }
    end

    # This checks when you press ESC
    def button_down(id)
        if id == Gosu::KbEscape
            close
        end
        if id == Gosu::MsLeft
            mouse(mouse_x, mouse_y)
        end
    end
end

GameWindow.new.show

