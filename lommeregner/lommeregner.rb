require 'gosu'

class Lommeregner
    attr_reader :value
    def initialize
        @value   = '0'
        @clear   = true

        @operand  = '0'
        @operator = ''
    end

    def calc
        if @operator == '+'
            @value = (@operand.to_f + @value.to_f).to_s
        elsif @operator == '-'
            @value = (@operand.to_f - @value.to_f).to_s
        end

        # Afrunding til heltal
        if @value.to_i == @value.to_f
            @value = @value.to_i.to_s
        end
    end

    def input(button)
        if button.to_i.to_s == button
            if @clear == true
                @value = button
            else
                @value = @value + button
            end
            @clear = false

        elsif button == '+/-'
            if @value[0] == '-'
                @value = @value[1..-1]
            else
                @value = '-' + @value
            end

        elsif button == '.'
            @decimal = true
            @value = @value + '.'

        elsif button == '+' or button == '-'
            calc
            @operand = @value
            @operator = button
            @clear = true

        elsif button == '='
            calc
            @operator = ''
            @clear = true

        elsif button == 'C'
            initialize

        end
    end

    def draw(font, x, y, c)
        if @operator != '' 
            font.draw("#{@operand}", x, y, 0, 1.0, 1.0, c)
            font.draw("#{@operator}", x + font.height, y, 0, 1.0, 1.0, c)
        end
        font.draw("#{@value}", x + 2*font.height, y, 0, 1.0, 1.0, c)
    end
end

class GUI < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Lommeregner"
        @font = Gosu::Font.new(20)
        @pressed = false
        @size = 60
        @margin = 10 
        @buttons = ['7', '8', '9', 'C',
                    '4', '5', '6', '-',
                    '1', '2', '3', '+',
                    '0', '.', '+/-', '=']
        @lommeregner = Lommeregner.new
    end

    def update
        if button_down?(Gosu::MsLeft)
            tile_x = (mouse_x - 40) / @size
            tile_y = (mouse_y - 40) / @size
            if (tile_x >= 0 and tile_x < 4 and tile_y >= 0 and tile_y < 4 and @pressed == false)
                index = tile_y.floor * 4 + tile_x.floor
                button = @buttons[index]
                @lommeregner.input(button)
                @pressed = true
            end
        else
            @pressed = false
        end
    end

    def draw_rect(x, y, width, height, c, z=0, mode=:default)
        draw_line(x,       y, c,
                  x+width, y, c,
                  z, mode)
        draw_line(x,       y+height, c,
                  x+width, y+height, c,
                  z, mode)
        draw_line(x, y, c,
                  x, y+height, c,
                  z, mode)
        draw_line(x+width, y, c,
                  x+width, y+height, c,
                  z, mode)
    end

    def draw
        draw_rect(0, 0, 0 + @size*5, 0 + @size*5, Gosu::Color::YELLOW)

        @lommeregner.draw(@font, 20, 10, Gosu::Color::YELLOW)
        @buttons.each_with_index do |button, index|
            x = 40 + @size*(index % 4)
            y = 40 + @size*(index / 4)
            draw_rect(x, y, @size-2*@margin, @size-2*@margin, Gosu::Color::WHITE)
            @font.draw("#{button}", x+@margin, y+@margin, 0, 1.0, 1.0, Gosu::Color::YELLOW)
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
