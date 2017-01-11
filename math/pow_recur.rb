# This attempts to calculate 2^x using the following identity
# 2^x = I_0(ln2) + 2*\sum_{n=1} I_n(ln2) * T_n(x)
# where I_n(x) is the modified Bessel function of the first kind
# and T_n(x) is the Chebyshev polynomial of the first kind


# This calculates the modified bessel function I_n(ln2) using
# the recurrence relation I_{r-1}(x) = I_{r+1}(x) + 2r/x * I_r(x)
# This is unstable for increasing r, but stable for decreasing r.
# We therefore use Miller's approach and choose an arbitrary
# starting value r = 2n+14, and the arbitrary values 
# I_{r+1}(x) = 1.0 and I_{r+2}(x) = 0.0.
# See http://www.ams.org/journals/mcom/1964-18-085/S0025-5718-1964-0169406-9/S0025-5718-1964-0169406-9.pdf
def besselI_ln2(n)
    ln2 = 0.693147180559945309417232121458176568075500134360255254120
    tl2 = 2.0/ln2

    r = 2*n + 14
    i2 = 0.0
    i1 = 1.0

    sum = 0.0
    while r>=0
        # Invariant at start of loop:
        # i2 = I_{r+2}(x)
        # i1 = I_{r+1}(x)

        sum += 2.0*i2
        sum += 2.0*i1

        i0 = i2 + (r+1)*tl2*i1 # I_r(x)
        i = i1 + r*tl2*i0 # I_{r-1}(x)
        if r==n
            val = i0
        elsif r-1==n
            val = i
        end

        r -= 2
        i2 = i0
        i1 = i
    end

    sum += i2
    # When normalized properly, this sum should evaluate to exp(ln2) = 2.0

    return val*2.0/sum
end

# This calculates the chebyshev polynomial T_n(x)
def cheb(n,x)
    if n==0
        return 1.0
    elsif n==1
        return x
    else
        return 2.0*x*cheb(n-1,x) - cheb(n-2,x)
    end
end

# 2^x = I_0(ln2) + 2*\sum_{n=1} I_n(ln2) * T_n(x)
def pow2(x)
    sum = 0.0
    (14).downto(1) do |n|
        val = 2.0*besselI_ln2(n) * cheb(n,x)
        sum += val
    end
    sum += besselI_ln2(0)
    return sum
end

def test_func(xmin, xmax, xstep, f1, f2)
    puts "Testing in the range #{xmin} to #{xmax} in steps of #{xstep}"
    max_diff = 0.0
    max_x = 0.0
    (0..((xmax-xmin)/xstep+0.5).to_i).each {|i|
        x = i*xstep + xmin;

        app = method(f1).call(x)
        re = method(f2).call(x)

        diff = (app - re)/re
        if diff < 0
            diff = -diff
        end
        if diff > max_diff
            max_x = x
            max_diff = diff
        end
    }

    return max_x, max_diff
end

def pow2_math(x)
    return 2.0**x
end

def test_pow2
    puts "Testing pow2"
    max_x, max_diff = test_func(-1.0, 1.0, 0.001, :pow2, :pow2_math)
    puts "#{max_x}, #{max_diff}"
end

test_pow2



