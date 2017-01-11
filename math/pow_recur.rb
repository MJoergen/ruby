# This attempts to calculate 2^x using the following identity
# 2^x = I_0(ln2) + 2*\sum_{n=1} I_n(ln2) * T_n(x)
# where I_n(x) is the modified Bessel function of the first kind
# and T_n(x) is the Chebyshev polynomial of the first kind


# This calculates the modified bessel function of ln2 using
# the recurrence relation I_{r-1}(x) = I_{r+1}(x) + 2r/x * I_r(x)
# This is unstable for increasing r, but stable for decreasing r.
# We therefore use Miller's approach and choose an arbitrary
# starting value r = 2n+18, and the arbitrary values 
# I_{r+1}(x) = 1.0 and I_{r+2}(x) = 0.0.
# See http://www.ams.org/journals/mcom/1964-18-085/S0025-5718-1964-0169406-9/S0025-5718-1964-0169406-9.pdf
def besselI_ln2(n)
    ln2 = 0.693147180559945309417232121458176568075500134360255254120

    r = 2*n + 18
    i2 = 0.0
    i1 = 1.0

    sum = 0.0
    while r>=0
        # Invariant at start of loop:
        # i2 = I_{r+2}(x)
        # i1 = I_{r+1}(x)

        sum += 2.0*i2
        sum += 2.0*i1

        i0 = i2 + 2.0*(r+1)/ln2*i1 # I_r(x)
        i = i1 + 2.0*r/ln2*i0 # I_{r-1}(x)
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
    for r in 1..10
        n = 11-r
        val = 2*besselI_ln2(n) * cheb(n,x)
        sum += val
    end
    sum += besselI_ln2(0)
    return sum
end

puts besselI_ln2(0)
puts 1.123768551030333847647796246661799357350157861381998354841

puts pow2(-1.0)
puts pow2(-0.5)
puts pow2( 0.0)
puts pow2( 0.5)
puts pow2( 1.0)

exit

ln2 = 0.693147180559945309417232121458176568075500134360255254120
val3 = 2.0
for n in 0..10
    val = 2*besselI_ln2(n)
    val2 = 2*besselI_ln2_old(n)
    puts "#{n} -> #{val}, #{val2}, #{val3}"
    val3 *= (ln2/2.0) / (n+1)
end
