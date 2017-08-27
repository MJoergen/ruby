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

        elsif button == '.'
            if @clear == true
                @value = '0'
            end
            @value = @value + '.'

        elsif button == '+/-'
            if @value[0] == '-'
                @value = @value[1..-1]
            else
                @value = '-' + @value
            end

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
            font.draw("#{@operator}", x + @operand.length*font.height, y, 0, 1.0, 1.0, c)
        end
        font.draw("#{@value}", x + (@operand.length+1)*font.height, y, 0, 1.0, 1.0, c)
    end
end

