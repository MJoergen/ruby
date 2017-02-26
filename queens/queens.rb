require 'gosu'

class GameWindow < Gosu::Window
    def initialize
        super(640, 480)
        self.caption = 'Queens'
        @cell_size = 40

        reset
        @col_white = Gosu::Color.new(0xffffffff)
        @col_black = Gosu::Color.new(0xff000000)
        @col_red   = Gosu::Color.new(0xffff8080)
        @col_green = Gosu::Color.new(0xff80ff80)

        @slow = true
        @pause = true
        @slow_count = 0
        @slow_count_max = 60
        @solved = false

        @positions = 0
        @solutions = 0

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    end

    def reset
        @nqueens = 8
        @pos = [0]*@nqueens
    end

    def needs_cursor?
        true
    end

    def is_valid? (row1)
        (0..row1-1).each {|row2|
            pos1 = @pos[row1]
            pos2 = @pos[row2]
            pos_diff = (pos1-pos2).abs
            row_diff = (row1-row2).abs

            if pos_diff == 0 or pos_diff == row_diff
                false
                return
            end
        }
        true
    end

    def bump(row)
        @positions += 1
        @pos[row] += 1
        while @pos[row] >= @nqueens
            @pos[row] = 0
            row -= 1
            if (row < 0)
                # We've searched all possible positions
                reset
                @pause = true
                return
            end
            @pos[row] += 1
        end
    end

    def update
        if @pause or @solved
            return
        end
        if @slow
            @slow_count -= 1
            if @slow_count < 0
                @slow_count = @slow_count_max
            else
                return
            end
        end

        (1..@nqueens-1).each {|row|
            if not is_valid?(row)
                bump(row)
                return
            end
        }

        # We've reached a valid solution
        @solutions += 1
        @solved = true
    end

    def draw_rect(x,y,width,height,col)
        draw_quad(x,y,col, x+width,y,col, x+width,y+height,col, x,y+height,col)
    end

    def draw
        (0..@nqueens-1).each {|row|
            (0..@nqueens-1).each {|col|
                draw_rect(col*@cell_size, row*@cell_size, @cell_size, @cell_size, @col_white)
                if @pos[row] == col
                    if is_valid?(row)
                        draw_rect(col*@cell_size+1, row*@cell_size+1, @cell_size-2, @cell_size-2, @col_green)
                    else
                        draw_rect(col*@cell_size+1, row*@cell_size+1, @cell_size-2, @cell_size-2, @col_red)
                    end
                else
                    draw_rect(col*@cell_size+1, row*@cell_size+1, @cell_size-2, @cell_size-2, @col_black)
                end
            }
        }

        @font.draw("Positions searched: #{@positions}", 0, @cell_size*@nqueens+10, 0)
        @font.draw("Solutions found: #{@solutions}", 0, @cell_size*@nqueens+35, 0)

        @font.draw("Press P for pause", @cell_size*@nqueens + 10, 10, 0)
        @font.draw("Press S for slow", @cell_size*@nqueens + 10, 35, 0)
        @font.draw("Press N for next", @cell_size*@nqueens + 10, 60, 0)
    end

    # This checks when you press ESC
    def button_down(id)
        case id
        when Gosu::KbEscape
            close
        when Gosu::KbP
            @pause = !@pause
        when Gosu::KbS
            @slow = !@slow
        when Gosu::KbN
            if @solved
                bump(@nqueens-1)
                @solved = false
            end
        end
    end
end

window = GameWindow.new
window.show

