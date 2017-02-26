require 'gosu'

class Window < Gosu::Window
    def initialize
        super(640, 480)
        self.caption = 'NoTTT'

        @col_white = Gosu::Color.new(0xffffffff)
        @col_black = Gosu::Color.new(0xff000000)
        @col_red   = Gosu::Color.new(0xffff8080)
        @col_green = Gosu::Color.new(0xff80ff80)

        @cell_size = 50
        @size = 4
        @board = Array.new(@size) {Array.new(@size)}
        @circle = Gosu::Image.new('filled_circle.png')

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
       
        @thinking = false
        @game_over = false
        
        @last_move = [0, 0]
    end

    def needs_cursor?
        true
    end

    def is_dead?
        (0..@size-1).each {|row|
            (0..@size-3).each {|col|
                if @board[row][col] and @board[row][col+1] and @board[row][col+2]
                    return true
                end
            }
        }

        (0..@size-3).each {|row|
            (0..@size-1).each {|col|
                if @board[row][col] and @board[row+1][col] and @board[row+2][col]
                    return true
                end
            }
        }

        (0..@size-3).each {|row|
            (0..@size-3).each {|col|
                if @board[row][col] and @board[row+1][col+1] and @board[row+2][col+2]
                    return true
                end
            }
        }

        (2..@size-1).each {|row|
            (0..@size-3).each {|col|
                if @board[row][col] and @board[row-1][col+1] and @board[row-2][col+2]
                    return true
                end
            }
        }

        return false
    end

    def update
        if @thinking
            # It is our turn
            if is_dead?
                # We won!
                @game_over = true
            else
                # Look through all empty square
                moves = []
                legal = []
                (0..@size-1).each {|row|
                    (0..@size-1).each {|col|
                        if not @board[row][col]
                            legal << [row, col]
                            @board[row][col] = true
                            if not is_dead?
                                moves << [row, col]
                            end
                            @board[row][col] = false
                        end
                    }
                }
                if moves.size > 0
                    row, col = (moves.shuffle)[0]
                else
                    row, col = (legal.shuffle)[0]
                    # You won!
                    @game_over = true
                end
                @board[row][col] = true
                @last_move = [row, col]
                @thinking = false
            end
        end
    end

    def draw_rect(x,y,width,height,col)
        draw_quad(x,y,col, x+width,y,col, x+width,y+height,col, x,y+height,col)
    end

    def draw
        (0..@size-1).each {|row|
            (0..@size-1).each {|col|
                draw_rect(col*@cell_size, row*@cell_size, @cell_size, @cell_size, @col_white)
                draw_rect(col*@cell_size+1, row*@cell_size+1, @cell_size-2, @cell_size-2, @col_black)
                if @board[row][col]
                    if @last_move[0] == row and @last_move[1] == col
                        @circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_red)
                    else
                        @circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_green)
                    end
                end
            }
        }

        if @game_over
            @font.draw("Game over!", @size*@cell_size+10, 0, 0);
        end

    end

    # This checks when you press ESC
    def button_down(id)
        case id
        when Gosu::KbEscape
            close
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

