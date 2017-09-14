#!/usr/bin/env ruby

require 'gosu'

require_relative 'cookie.rb'
require_relative 'unit.rb'

class GameWindow < Gosu::Window
    attr_reader :font

    def initialize
        super(940, 600, false)  # Set size of window
        @font   = Gosu::Font.new(self, Gosu.default_font_name, 24)

        @cookie = Cookie.new(self, 100, 100, "media/PerfectCookie.png")

        @units = []
        @units.push(Unit.new(self, 400, 50,  "media/CursorIconTransparent.png", "Cursor",   15.0,   0.1))
        @units.push(Unit.new(self, 400, 120, "media/AlienGrandma.png",          "Grandma", 100.0,   1))
        @units.push(Unit.new(self, 400, 190, "media/FarmIconTransparent.png",   "Farm",      1.1e3, 8))
    end

    def needs_cursor?
        true
    end

    # This event is checked 60 times per second.
    def update
        totalCps = 0
        @units.each { |inst|
            totalCps += inst.cps * inst.number
            @cookie.increase(inst.cps * inst.number / 60.0)
        }
        self.caption = "Cookie Clicker - [Cookies: #{@cookie.cookies.to_i}, CPS: #{totalCps.round(1)}]"
    end

    def mouse(x, y)
        # Have we clicked the cookie?
        if @cookie.in_range?(x, y)
            @cookie.increase(1) # We gain 1 cookie for each click.
        end

        # Have we clicked on a unit?
        @units.each { |inst| 
            if inst.in_range?(x, y)
                if @cookie.cookies >= inst.cost # Can we afford to buy the unit?
                    @cookie.increase(-inst.cost)
                    inst.buy
                end
            end
        }
    end

    # This draws all the elements in the game. Also checks around 60 times per
    # second...
    def draw
        @font.draw("Name", 400+100, 20, 0)
        @font.draw("Cost", 400+200, 20, 0)
        @font.draw("Time", 400+300, 20, 0)
        @cookie.draw
        @units.each { |inst|  inst.draw }
    end

    # This checks when you press ESC or click the mouse
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

