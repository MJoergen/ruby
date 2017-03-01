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
        @size = 5
        @circle = Gosu::Image.new('filled_circle.png')
        @open_circle = Gosu::Image.new('circle.png')
        @blinking = false
        @blinking_time = 0
        @blinking_time_max = 10

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
       
        @thinking_time = 0
        @thinking_time_max = 60
        
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

        reset
    end

    def reset
        @board = Array.new(@size) {Array.new(@size)}
        @game_over = false
        @help = false
        @thinking = false
        @selected = []
        @last_move = [0, 0]
        @line = []
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

    def get_index
        index = [0]*10
        (0..@size-1).each {|row|
            (0..@size-1).each {|col|
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
            }
        }
        return index
    end

    def eval # Returns the value of the board for the player to move. The value is between 0 and 1, and
        # represents the probability to win
        if is_dead?
            return 1
        end

        values = [
            545, 487, 701, 811, 654, 792, 857, 929,
            732, 766, 857, 653, 822, 654, 400, 923,
            754, 766, 811, 811, 821, 743, 778, 1000,
            871, 760, 809, 906, 685, 902, 1000, 1000,
            716, 740, 754, 744, 839, 732, 900, 909,
            786, 721, 853, 867, 709, 870, 833, 0,
            778, 747, 745, 773, 715, 801, 1000, 750,
            743, 857, 786, 750, 868, 630, 500, 1000,
            748, 780, 758, 789, 797, 786, 684, 955,
            731, 675, 673, 913, 714, 914, 800, 250,
            724, 688, 841, 878, 761, 842, 1000, 167,
            686, 783, 889, 697, 889, 741, 1000, 1000,
            714, 681, 769, 858, 754, 834, 818, 727,
            704, 771, 895, 825, 890, 818, 0, 1000,
            710, 732, 800, 712, 847, 734, 545, 750,
            776, 770, 714, 905, 833, 875, 750, 250,
            754, 778, 761, 836, 785, 679, 533, 1000,
            713, 712, 797, 815, 654, 786, 1000, 400,
            705, 694, 785, 828, 704, 810, 833, 778,
            702, 799, 926, 641, 875, 618, 0, 1000,
            696, 687, 723, 772, 695, 832, 1000, 333,
            722, 783, 871, 667, 863, 643, 500, 800,
            736, 753, 855, 891, 836, 685, 0, 1000,
            783, 717, 773, 1000, 750, 925, 1000, 1000,
            616, 584, 595, 752, 663, 767, 833, 700,
            689, 752, 849, 691, 833, 676, 600, 1000,
            699, 762, 795, 763, 853, 751, 833, 1000,
            807, 732, 655, 897, 620, 944, 1000, 1000,
            732, 727, 752, 763, 837, 733, 733, 929,
            799, 768, 853, 892, 539, 910, 1000, 333,
            794, 761, 833, 808, 737, 881, 750, 750,
            749, 818, 917, 690, 738, 703, 0, 500,
            720, 765, 711, 746, 846, 715, 833, 857,
            747, 702, 432, 964, 609, 813, 1000, 500,
            762, 724, 838, 786, 644, 841, 1000, 286,
            681, 818, 900, 500, 722, 533, 0, 1000,
            740, 706, 776, 762, 657, 843, 1000, 667,
            718, 803, 944, 765, 868, 688, 250, 1000,
            727, 779, 778, 720, 923, 689, 250, 1000,
            886, 721, 818, 1000, 500, 720, 1000, 1000,
            710, 678, 789, 805, 695, 826, 750, 750,
            720, 784, 933, 722, 725, 712, 500, 1000,
            731, 774, 848, 780, 842, 709, 500, 1000,
            812, 695, 750, 800, 826, 880, 750, 0,
            704, 737, 632, 757, 800, 718, 1000, 250,
            843, 732, 737, 880, 600, 906, 1000, 667,
            781, 737, 818, 760, 676, 865, 1000, 250,
            752, 823, 1000, 800, 889, 778, 1000, 1000,
            677, 614, 769, 676, 732, 822, 875, 900,
            720, 786, 857, 667, 849, 644, 1000, 1000,
            715, 754, 722, 700, 824, 682, 750, 1000,
            831, 678, 692, 1000, 520, 938, 0, 0,
            687, 753, 722, 797, 877, 696, 583, 1000,
            828, 772, 722, 947, 674, 929, 500, 1000,
            786, 729, 771, 724, 679, 871, 667, 800,
            791, 794, 1000, 563, 793, 545, 0, 0,
            705, 778, 737, 814, 745, 721, 143, 1000,
            785, 672, 813, 810, 759, 909, 1000, 1000,
            772, 730, 794, 964, 574, 805, 1000, 500,
            683, 797, 778, 615, 941, 625, 0, 1000,
            763, 736, 836, 662, 741, 817, 857, 571,
            703, 809, 818, 824, 897, 650, 0, 1000,
            774, 753, 742, 760, 868, 623, 333, 1000,
            822, 709, 1000, 1000, 680, 1000, 0, 0,
            712, 797, 526, 750, 879, 667, 750, 0,
            796, 661, 1000, 1000, 727, 1000, 0, 0,
            844, 686, 800, 500, 833, 1000, 1000, 0,
            723, 894, 1000, 1000, 750, 333, 0, 0,
            763, 737, 800, 724, 708, 679, 1000, 667,
            671, 924, 1000, 1000, 857, 500, 0, 1000,
            735, 876, 750, 750, 882, 706, 0, 0,
            755, 705, 1000, 1000, 667, 600, 0, 0,
            758, 691, 765, 667, 723, 788, 1000, 0,
            685, 856, 600, 800, 923, 571, 0, 1000,
            742, 840, 500, 625, 762, 667, 0, 0,
            875, 677, 1000, 1000, 167, 1000, 0, 0,
            724, 765, 500, 625, 813, 750, 0, 1000,
            917, 709, 571, 0, 857, 765, 0, 0,
            804, 707, 1000, 800, 889, 1000, 0, 0,
            750, 816, 1000, 1000, 1000, 750, 0, 0,
            764, 686, 850, 750, 805, 862, 1000, 1000,
            684, 867, 750, 0, 1000, 750, 0, 0,
            724, 809, 667, 833, 750, 875, 0, 1000,
            867, 571, 500, 0, 1000, 1000, 0, 0,
            714, 777, 286, 818, 775, 692, 0, 1000,
            793, 672, 1000, 1000, 600, 938, 0, 1000,
            804, 735, 1000, 667, 750, 889, 1000, 0,
            718, 896, 0, 1000, 1000, 750, 0, 0,
            673, 795, 267, 857, 893, 786, 1000, 1000,
            898, 725, 1000, 1000, 750, 778, 0, 0,
            804, 742, 1000, 1000, 750, 957, 0, 1000,
            679, 844, 0, 0, 1000, 571, 0, 0,
            828, 740, 889, 583, 813, 839, 1000, 0,
            731, 870, 500, 0, 1000, 500, 0, 0,
            752, 835, 1000, 1000, 667, 615, 1000, 0,
            863, 816, 1000, 1000, 750, 1000, 0, 0,
            808, 671, 727, 692, 639, 833, 1000, 1000,
            667, 798, 1000, 571, 800, 750, 0, 0,
            692, 813, 889, 667, 773, 636, 0, 0,
            897, 688, 1000, 1000, 286, 889, 0, 0,
            710, 820, 750, 769, 810, 658, 0, 1000,
            800, 800, 500, 1000, 643, 750, 0, 0,
            836, 685, 889, 600, 842, 941, 0, 0,
            554, 929, 1000, 667, 1000, 1000, 0, 0,
            712, 842, 600, 692, 875, 650, 1000, 1000,
            855, 707, 1000, 1000, 429, 889, 0, 0,
            842, 723, 714, 889, 739, 826, 0, 1000,
            698, 900, 0, 0, 1000, 833, 0, 0,
            801, 741, 833, 545, 806, 929, 0, 1000,
            732, 883, 833, 250, 1000, 643, 0, 0,
            674, 840, 1000, 800, 1000, 714, 0, 0,
            811, 796, 0, 1000, 1000, 1000, 0, 0,
            718, 822, 455, 857, 763, 912, 0, 1000,
            783, 857, 500, 889, 500, 1000, 0, 1000,
            811, 712, 667, 1000, 621, 917, 1000, 0,
            741, 846, 1000, 500, 1000, 667, 1000, 0,
            794, 687, 867, 556, 711, 861, 1000, 1000,
            684, 903, 1000, 1000, 1000, 583, 0, 0,
            766, 811, 0, 1000, 1000, 500, 1000, 0,
            936, 563, 0, 0, 400, 1000, 0, 0,
            787, 699, 615, 714, 677, 816, 1000, 1000,
            617, 913, 1000, 714, 875, 462, 0, 0,
            656, 816, 667, 0, 875, 636, 0, 1000,
            860, 667, 0, 0, 250, 833, 0, 0,
            719, 821, 706, 846, 721, 533, 1000, 1000,
            821, 729, 500, 1000, 714, 1000, 0, 0,
            845, 756, 833, 750, 733, 952, 0, 0,
            744, 889, 1000, 500, 1000, 1000, 0, 0
        ]

        index = get_index
    end

    def search(levels)

    end

    def find_best_move
        moves = []
        legal = []
        min_val = 10

        # Look through all empty squares
        (0..@size-1).each {|row|
            (0..@size-1).each {|col|
                if not @board[row][col]
                    # This square is empty
                    sq = [row, col]
                    legal << sq
                    vals = get_line_counts(sq)
                    if vals[2] == 0 # We've found a move that does not lose
                        if vals[1] <= min_val
                            if vals[1] < min_val
                                moves = []
                                min_val = vals[1]
                            end
                            moves << sq # These are the best moves found so far
                        end
                    end
                end
            }
        }
        if moves.size > 0 # Any good moves?
            row, col = (moves.shuffle)[0]
        else # OK, just choose a legal move. We're screwed as all moves lose
            row, col = (legal.shuffle)[0]
        end
        return row, col
    end

    def update
        @blinking_time -= 1
        if @blinking_time <= 0
            @blinking_time = @blinking_time_max
            @blinking = !@blinking
        end

        if @thinking
            @thinking_time -= 1
            if @thinking_time > 0
                return
            end

            # It is our turn
            if is_dead?
                # We won!
                @game_over = true
            else
                row, col = find_best_move
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
                if @selected[0] == row and @selected[1] == col and @blinking
                    @open_circle.draw(col*@cell_size+5, row*@cell_size+5, 0, 0.4, 0.4, @col_red)
                end
                if @help
                    vals = get_line_counts([row, col])
                    if vals[2] == 0 and !@board[row][col]
                        @font.draw("#{vals[1]}", col*@cell_size+20, row*@cell_size+20, 0)
                    end
                end
            }
        }
        if @help
            index = get_index
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
        when Gosu::KbR
            reset
        when Gosu::KbH
            @help = !@help
        when Gosu::MsLeft
            if not @thinking
                col = (mouse_x / @cell_size).to_i
                row = (mouse_y / @cell_size).to_i
                if row >= 0 and row < @size and col >= 0 and col < @size
                    if [row, col] == @selected
                        @board[row][col] = 1
                        @last_move = [row, col]
                        @thinking = true
                        @thinking_time = @thinking_time_max
                        @selected = []
                    else
                        @selected = [row, col]
                    end
                else
                    @selected = []
                end
            end
        end
    end
end

Window.new.show

