#!/usr/bin/env ruby

require 'gosu'

class GameWindow < Gosu::Window

   def initialize()
      super(1300, 600, false)
      self.caption = 'Bowling Hat'

      @font   = Gosu::Font.new(24)
      @colour = Gosu::Color.argb(0xff_ff0000) # Red
   end

   def needs_cursor?
      false
   end

   # This event is checked 60 times per second.
   def update
      self.caption = "Bowling Hat - [FPS: #{Gosu::fps.to_s}]"
   end

   def plot(x,y)
      dx=1
      dy=1
      draw_quad(x+dx, y,    @colour,
                x,    y+dy, @colour,
                x,    y-dy, @colour,
                x-dx, y,    @colour)
   end

   # This controls the graphics in the game. Also checks around 60 times per
   # second...
   def draw
      @font.draw_text("<Esc> : Quit program",                              800,  50, 0)

      xs=2
      ys=2
      a=256
      b=a*a
      c=192

      for x in (0..a).step(xs)
         s=x*x
         p=Math.sqrt(b-s)

         for i in (-p..p).step(6*ys)
            r=Math.sqrt(s+i*i)/a
            q=(r-1)*Math.sin(10*r)
            y=(i/3+q*c).floor()
            if i==-p
               m=y
               n=y
            end
            if y>m
               m=y
            end
            if y<n
               n=y
            end
            if m==y or n==y
               x1=x/2
               y1=100-y/2
               plot(128+x1,y1)
               plot(128-x1,y1)
            end
         end
      end
   end

   # This checks when you press ESC
   def button_down(id)
      case id
         when Gosu::KbEscape
            close
      end
   end
end

window = GameWindow.new()
window.show

