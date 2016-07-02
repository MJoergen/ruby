# Problem 46
#
# It was proposed by Christian Goldbach that every odd composite number can be written as the sum of a prime and twice a square.
#
# 9 = 7 + 2×1^2
# 15 = 7 + 2×2^2
# 21 = 3 + 2×3^2
# 25 = 7 + 2×3^2
# 27 = 19 + 2×2^2
# 33 = 31 + 2×1^2
#
# It turns out that the conjecture was false.
#
# What is the smallest odd composite that cannot be written as the sum of a prime and twice a square?

def read_primes(fname)
    primes = []
    File.foreach(fname) { |l|
        primes += l.chomp.split
    }
    primes.map!(&:to_i)
end

def is_square(n)
    sqrt = Math.sqrt(n).to_i
    return sqrt*sqrt == n
end

primes = read_primes("primes.txt")

3.step(primes.max, 2).each do |n| # This forces n odd
    if primes.index(n)
        next # This skips all primes
    end

#    print "#{n} : "
    # Now n is an odd composite number
    solved = false
    for prim in primes
        sq = (n-prim)/2
        if sq < 0
            break
        end
#        print "#{sq} "
        if is_square(sq)
            sqrt = Math.sqrt(sq).to_i
            print "#{n} = #{prim} + 2*#{sqrt}^2\n"
            solved = true
            break
        end
    end
    if not solved
        p n
        break
    end
#    print "\n"
end
