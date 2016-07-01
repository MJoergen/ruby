$legal_vals = ["1", "2", "3", "4", "5", "6", "7", "8", "9",
               "A", "B", "C", "D", "E", "F", "G"]

# This reads a text file containing many sudoku problems and returns an
# array of problems
def read_problems(fname)
    problems = []
    problem = []
    dat = File.read(fname) # Read entire file
    row_num = 0

    dat.each_line { |l| 
        if row_num == 0
            problem_num = l.match('Grid (.*)')[1]
            problem = []
        else
            row = l.chomp.split('')
            problem << row.map{ |i| $legal_vals.index(i) }
        end

        row_num += 1
        if row_num > 16
            problems << problem
            row_num = 0
        end
    }
    return problems
end

def print_board(prob)
    for i in 0..15
        if i>0 and (i%4) == 0
            print "----+----+----+----\n"
        end
        for j in 0..15
            if j>0 and (j%4) == 0
                print "|"
            end
            if prob[i][j] == nil
                print "#"
            else
                print $legal_vals[prob[i][j]]
            end
        end
        print "\n"
    end
end

def count_empty(prob)
    empty = 0
    for i in 0..15
        for j in 0..15
            if prob[i][j] == nil
                empty += 1
            end
        end
    end
    return empty
end

# This accepts a single problem and attempts to solve it
def solve_problem(prob)
    #print ("\n")
    #print_board(prob)

    empty = count_empty(prob)
    if empty < $min_empty
        $min_empty = empty
        print_board(prob)
        print ("#{empty}\n\n")
    end

    # Really just initialize to anything with a size larger than 16.
    min_legal = $legal_vals

    min_i = 99
    min_j = 99
    # First we loop over the board and find all the legal moves
    # in each position
    for pos in 0..255
        i = pos/16
        j = pos%16
        if prob[i][j] == nil
            legal_moves = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

            # Remove elements in the current row and column
            for w in 0..15
                legal_moves -= [prob[w][j]]
                legal_moves -= [prob[i][w]]
            end

            # Remove elements in the current square block
            bi = (i/4)*4
            bj = (j/4)*4
            for wi in bi..bi+3
                for wj in bj..bj+3
                    legal_moves -= [prob[wi][wj]]
                end
            end

            #print "#{i},#{j} -> #{legal_moves}\n"

            if legal_moves.size < min_legal.size
                min_legal = legal_moves
                min_i = i
                min_j = j

                # This is an optimization.
                # If only one move at this square, just play it. Don't bother searching the remaining squares.
                # If no legal moves at this square, break out immediately, because the board can't be solved.
                if min_legal.size <= 1
                    break
                end
            end
        end
    end

    if min_i == 99
        print_board(prob)
        exit
    end

    #print "Best choice is position (#{min_i}, #{min_j}), with the following legal moves:\n"
    #p min_legal
    #print "\n"

    #if min_legal.size > 1
    #    exit
    #end
    for legal in min_legal
        #print "Trying #{legal} in position (#{min_i}, #{min_j})\n"
        prob[min_i][min_j] = legal
        solve_problem(prob)
        prob[min_i][min_j] = nil
        #print "Removing #{legal} from position (#{min_i}, #{min_j})\n"
    end
end

$sum = 0
$min_empty = 256

problems = read_problems('s16.txt')
problems.each { |prob| solve_problem(prob);  }

p $sum
