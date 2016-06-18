
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

# This accepts a single problem and attempts to solve it
def solve_problem(prob)
    p prob
end

problems = read_problems('2.txt')
problems.each { |prob| solve_problem(prob) }
