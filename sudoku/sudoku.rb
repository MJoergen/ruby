
# This reads a text file containing many sudoku problems and returns an
# array of problems
def read_problems(fname)
    problems = []
    problem = []
    dat = File.read(fname) # Read entire file
    row_num = 0

    dat.each_line { |l| 
        if row_num == 0
            problem_num = l.match('Grid (..)')[1]
            problem = []
        else
            row = l.chomp.split('')
            problem << row
        end

        row_num += 1
        if row_num > 9
            problems << problem
            row_num = 0
        end
    }
    return problems
end

def print_board(prob)
    for i in 0..8
        for j in 0..8
            print prob[i][j]
        end
        print "\n"
    end
end

# This accepts a single problem and attempts to solve it
def solve_problem(prob)
    #print_board(prob)

    min_legal = []
    min_i = 99
    min_j = 99
    # First we loop over the board and find all the legal moves
    # in each position
    for i in 0..8
        for j in 0..8
            if prob[i][j] == "0"
                legal_moves = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

                # Remove elements in the current row and column
                for w in 0..8
                    legal_moves -= [prob[w][j]]
                    legal_moves -= [prob[i][w]]
                end

                # Remove elements in the current square block
                bi = (i/3)*3
                bj = (j/3)*3
                for wi in bi..bi+2
                    for wj in bj..bj+2
                        legal_moves -= [prob[wi][wj]]
                    end
                end

                if legal_moves.size == 0
                    #print "Illegal position! Go back one step.\n\n"
                    return prob
                end

                if min_legal == [] or legal_moves.size < min_legal.size
                    min_legal = legal_moves
                    min_i = i
                    min_j = j
                end
            end
        end 
    end

    if min_i == 99
        print "Done!\n"
        print_board(prob)
        return prob
    end

    #print "Best choice is position (#{min_i}, #{min_j}), with the following legal moves:\n"
    #p min_legal
    #print "\n"
    for legal in min_legal
        #print "Trying #{legal} in position (#{min_i}, #{min_j})\n"
        prob[min_i][min_j] = legal
        solve_problem(prob)
        prob[min_i][min_j] = "0"
    end
end

problems = read_problems('2.txt')
problems.each { |prob| solve_problem(prob) }

