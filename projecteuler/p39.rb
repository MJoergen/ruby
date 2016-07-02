# Problem 39
#
# If p is the perimeter of a right angle triangle with integral length sides,
# {a,b,c}, there are exactly three solutions for p = 120.
#
# {20,48,52}, {24,45,51}, {30,40,50}
#
# For which value of p ≤ 1000, is the number of solutions maximised?

# This function generates all pythagorean tripples exactly once
# Requirements:
# m>n
# m and n coprime
# m-n odd
def pythag_tripple(m, n, k)
    a = k*(m*m - n*n)
    b = k*(2*m*n)
    c = k*(m*m + n*n)
    return [a, b, c]
end

def perim(tripple)
    return tripple[0] + tripple[1] + tripple[2]
end

max_perim = 1000
perims = Array.new(max_perim + 1, 0)
max_mn = Math.sqrt(max_perim*0.5).to_i + 1

for m in 1..max_mn
    printf("m=%3d\n", m)
    (m-1).step(1, -2).each do |n| # This forces m>n and m-n odd
        if m.gcd(n) != 1
            next
        end
        printf(".. n=%3d \n", n)
        for k in 1..max_perim
            tripple = pythag_tripple(m,n,k)
            peri = perim(tripple)
            if peri > max_perim
                break
            end
            printf(".... k=%3d,  =>  [%3d, %3d, %3d]  =>  %3d\n", k, tripple[0], tripple[1], tripple[2], peri)
            perims[peri] += 1
        end
    end
end

p perims

p perims.index(perims.max)
