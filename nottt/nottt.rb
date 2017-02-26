require 'gosu'

class Window < Gosu::Window
    def initialize
        super(640, 480)
        self.caption = 'NoTTT'

        @col_white = Gosu::Color.new(0xffffffff)
        @col_black = Gosu::Color.new(0xff000000)
        @col_red   = Gosu::Color.new(0xffff8080)
        @col_green = Gosu::Color.new(0xff80ff80)
        @col_blue  = Gosu::Color.new(0xff8080ff)

        @cell_size = 50
        @size = 4
        @board = Array.new(@size) {Array.new(@size)}
        @circle = Gosu::Image.new('filled_circle.png')

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
       
        @thinking = false
        @game_over = false
        @help = false
        
        @last_move = [0, 0]
        @line = []

        # Build list of lines
        @lines = []
        (0..@size-1).each {|row|
            (0..@size-3).each {|col|
                @lines << [[row, col], [row, col+1], [row, col+2]]
            }
        }
        (0..@size-3).each {|row|
            (0..@size-1).each {|col|
                @lines << [[row, col], [row+1, col], [row+2, col]]
            }
        }
        (0..@size-3).each {|row|
            (0..@size-3).each {|col|
                @lines << [[row, col], [row+1, col+1], [row+2, col+2]]
            }
        }
        (2..@size-1).each {|row|
            (0..@size-3).each {|col|
                @lines << [[row, col], [row-1, col+1], [row-2, col+2]]
            }
        }
    end

    def needs_cursor?
        true
    end

    def is_dead?
        @lines.each {|line|
            if @board[line[0][0]][line[0][1]] and 
                    @board[line[1][0]][line[1][1]] and
                    @board[line[2][0]][line[2][1]]
                @line = line
                return true
            end
        }

        return false
    end

    def get_line_counts(sq)
        vals = [0, 0, 0, 0]
        @lines.each {|line|
            if line.index(sq)
                count = 0
                if @board[line[0][0]][line[0][1]]
                    count += 1
                end
                if @board[line[1][0]][line[1][1]]
                    count += 1
                end
                if @board[line[2][0]][line[2][1]]
                    count += 1
                end
                # count is now between 0 and 3.
                vals[count] += 1
            end
        }
        return vals
    end

    def update
        if @thinking
            # It is our turn
            if is_dead?
                # We won!
                @game_over = true
            else
                # Look through all empty squares
                moves = []
                legal = []
                min_val = 10
                (0..@size-1).each {|row|
                    (0..@size-1).each {|col|
                        if not @board[row][col]
                            # This square is empty
                            sq = [row, col]
                            legal << sq
                            vals = get_line_counts(sq)
                            if vals[2] == 0
                                if vals[1] <= min_val
                                    if vals[1] < min_val
                                        moves = []
                                        min_val = vals[1]
                                    end
                                    moves << sq
                                end
                            end
                        end
                    }
                }
                if moves.size > 0 # Any good moves?
                    row, col = (moves.shuffle)[0]
                else # OK, just choose a legal move.
                    row, col = (legal.shuffle)[0]
                end
                @board[row][col] = true
                @last_move = [row, col]
                @thinking = false

                if is_dead?
                    # You won!
                    @game_over = true
                end
            end
        end
    end

    def draw_rect(x,y,width,height,col)
        draw_quad(x,y,col, x+width,y,col, x+width,y+height,col, x,y+height,col)
    end

    def draw
        @line = []
        is_dead?
        index = [0]*10
        (0..@size-1).each {|row|
            (0..@size-1).each {|col|
                draw_rect(col*@cell_size, row*@cell_size, @cell_size, @cell_size, @col_white)
                draw_rect(col*@cell_size+1, row*@cell_size+1, @cell_size-2, @cell_size-2, @col_black)
                if @board[row][col]
                    if @last_move[0] == row and @last_move[1] == col
                        @circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_red)
                    elsif @line.index([row, col])
                        @circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_blue)
                    else
                        @circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_green)
                    end
                end
                if @help
                    vals = get_line_counts([row, col])
                    if vals[2] > 0
                        index[0] += 1
                    elsif vals[1] >= 8
                        index[1] += 1
                    elsif vals[1] == 7
                        index[2] += 1
                    elsif vals[1] == 6
                        index[3] += 1
                    elsif vals[1] == 5
                        index[4] += 1
                    elsif vals[1] == 4
                        index[5] += 1
                    elsif vals[1] == 3
                        index[6] += 1
                    elsif vals[1] == 2
                        index[7] += 1
                    elsif vals[1] == 1
                        index[8] += 1
                    elsif vals[0] > 0
                        index[9] += 1
                    end

                    if vals[2] == 0
                        @font.draw("#{vals[1]}", col*@cell_size+20, row*@cell_size+20, 0)
                    end
                end
            }
        }
        if @help
            @font.draw("#{index}", 0, @size*@cell_size+20, 0)
        end

        if @game_over
            @font.draw("Game over!", @size*@cell_size+10, 0, 0);
        end

    end

    # This checks when you press ESC
    def button_down(id)
        case id
        when Gosu::KbEscape
            close
        when Gosu::KbH
            @help = !@help
        when Gosu::MsLeft
            if not @thinking
                col = mouse_x / @cell_size
                row = mouse_y / @cell_size
                if row >= 0 and row < @size and col >= 0 and col < @size
                    @board[row][col] = 1
                    @last_move = [row, col]
                    @thinking = true
                end
            end
        end
    end
end

Window.new.show

