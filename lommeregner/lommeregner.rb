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

    def input(knap)
        if knap.to_i.to_s == knap
            if @clear == true
                @value = knap
            else
                @value = @value + knap
            end
            @clear = false

        elsif knap == '.'
            if @clear == true
                @value = '0'
            end
            if @value[-1] != '.'            # Der må højst være ét komma
                @value = @value + '.'
            end
            @clear = false

        elsif knap == '+/-'
            if @value[0] == '-'             # Hvis første tegn er et minus ...
                @value = @value[1..-1]      # ... så slet det.
            else
                @value = '-' + @value       # Ellers indsæt et minus-tegn foran tallet
            end

        elsif knap == '+' or knap == '-'
            calc
            @operand = @value
            @operator = knap
            @value = ''
            @clear = true

        elsif knap == '='
            calc
            @operator = ''
            @clear = true

        elsif knap == 'C'
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

