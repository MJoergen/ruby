require 'gosu'
require_relative 'lommeregner'

class GUI < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Lommeregner"
        @font = Gosu::Font.new(20)
        @lommeregner = Lommeregner.new

        @knapper = ['7', '8', '9', 'C',
                    '4', '5', '6', '-',
                    '1', '2', '3', '+',
                    '0', '.', '+/-', '=']
        @pressed = false

        @size = 60          # Størrelsen af hvert felt
        @margin = 10        # Placeringen af tekst i feltet
        @offset_x = 40
        @offset_y = 40
    end

    def update
        if button_down?(Gosu::MsLeft)
            if @pressed == false

                # Udregn først hvilket felt vi har trykket på
                felt_x = (mouse_x - @offset_x) / @size
                felt_y = (mouse_y - @offset_y) / @size

                # Check om vi har ramt et gyldigt felt
                if (felt_x >= 0 and felt_x < 4 and felt_y >= 0 and felt_y < 4)
                    index = felt_y.floor * 4 + felt_x.floor
                    knap = @knapper[index]
                    @lommeregner.input(knap)
                end
            end
            @pressed = true
        else
            @pressed = false
        end
    end

    # Tegn et rektangel
    def draw_rect(x, y, width, height, color, z=0, mode=:default)
        draw_line(x,       y,        color,
                  x+width, y,        color, z, mode)
        draw_line(x,       y+height, color,
                  x+width, y+height, color, z, mode)
        draw_line(x,       y,        color,
                  x,       y+height, color, z, mode)
        draw_line(x+width, y,        color,
                  x+width, y+height, color, z, mode)
    end

    def draw
        draw_rect(0, 0, 0 + @size*5, 0 + @size*5, Gosu::Color::YELLOW)

        @lommeregner.draw(@font, 20, 10, Gosu::Color::YELLOW)
        @knapper.each_with_index do |knap, index|
            x = @offset_x + @size*(index % 4)
            y = @offset_y + @size*(index / 4)
            draw_rect(x, y, @size-2*@margin, @size-2*@margin, Gosu::Color::WHITE)
            @font.draw("#{knap}", x+@margin, y+@margin, 0, 1.0, 1.0, Gosu::Color::YELLOW)
        end 
    end

    def needs_cursor?
        true
    end

    def button_down(id)
        case id
        when Gosu::KbEscape
            close
        when Gosu::KB_0
            @lommeregner.input('0')
        when Gosu::KB_1
            @lommeregner.input('1')
        when Gosu::KB_2
            @lommeregner.input('2')
        when Gosu::KB_3
            @lommeregner.input('3')
        when Gosu::KB_4
            @lommeregner.input('4')
        when Gosu::KB_5
            @lommeregner.input('5')
        when Gosu::KB_6
            @lommeregner.input('6')
        when Gosu::KB_7
            @lommeregner.input('7')
        when Gosu::KB_8
            @lommeregner.input('8')
        when Gosu::KB_9
            @lommeregner.input('9')
        when Gosu::KB_NUMPAD_PLUS
            @lommeregner.input('+')
        when Gosu::KB_NUMPAD_MINUS
            @lommeregner.input('-')
        when Gosu::KB_ENTER, Gosu::KB_RETURN
            @lommeregner.input('=')
        when Gosu::KB_C
            @lommeregner.input('C')
        when Gosu::KB_PERIOD
            @lommeregner.input('.')
        end
    end
end

GUI.new.show

