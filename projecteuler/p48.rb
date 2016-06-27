# Problem 48
#
# The series, 1^1 + 2^2 + 3^3 + ... + 10^10 = 10405071317.
#
# Find the last ten digits of the series, 1^1 + 2^2 + 3^3 + ... + 1000^1000.

# This calculates a^b mod n
def mod_exp(a, b, n)
    res = 1
    for i in 1..b
        res = (res*a) % n
    end
    return res
end

mod = 10000000000
sum = 0
for i in 1..1000
    sum += mod_exp(i, i, mod)
end
p sum%mod
