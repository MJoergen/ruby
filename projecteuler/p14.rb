# Problem 14
#
# The following iterative sequence is defined for the set of positive integers:
#
# n → n/2 (n is even)
# n → 3n + 1 (n is odd)
#
# Using the rule above and starting with 13, we generate the following sequence:
#
# 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1
# It can be seen that this sequence (starting at 13 and finishing at 1) contains 10 terms. Although it has not been proved yet (Collatz Problem), it is thought that all starting numbers finish at 1.
#
# Which starting number, under one million, produces the longest chain?
#
# NOTE: Once the chain starts the terms are allowed to go above one million.

def collatz(n)
    if n%2 == 0
        return n/2
    else
        return 3*n+1
    end
end


def seq_len(n)
    count = 1
#    print("#{n} ")
    while n != 1
        if n < $lengths.size and $lengths[n] > 0
            count += $lengths[n]-1
            break
        end
        n = collatz(n)
        count += 1
#        print("#{n} ")
    end
#    print("=> #{count}\n")
    return count
end

limit = 1000000
max_count = 0
max_n = 0
$lengths = Array.new(limit, 0)

for i in 1..limit-1
    count = seq_len(i)
    $lengths[i] = count
    if count > max_count
        max_count = count
        max_n = i
    end
end

# p $lengths
print "Starting point #{max_n} gives a sequence with #{max_count} terms\n"
