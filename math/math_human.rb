# This file shows how a human could calculate 
# logarithms and powers, without a calculator
# This might not be the BEST method,
# but it is simple to understand.

# Use Newton's method to calculate square roots.
def msqrt(x)
    if x < 0
        return Float::NAN
    end

    res = 1.0;
    begin 
        delta = (x/res - res)*0.5;
        res += delta;
        max_err = res * Float::EPSILON;
    end while  delta > max_err or delta < -max_err;

    return res;
end

# This array contains the numbers
# 10^0.5, 10^0.25, 10^0.125, etc.
$pow_10_5 = []

def make_pow_10_5()
    pow = 10.0;
    pow_2 = (Float::DIG+1)/0.301 # Approximately number of bits in the mantissa
    pow_2.to_i.times do
        pow = msqrt(pow);
        $pow_10_5 << pow;
    end
end

# Calculate 10^x
def pow_10(x)
    if $pow_10_5.size == 0
        make_pow_10_5
    end

    if x<0
        return 1.0/pow10(-x)
    end

    # Now x is positive
   
    i = x.to_i
    res = 1.0;
    i.times do
        res *= 10.0;
    end
    x -= i;

    # Now x is between 0 and 1

    # Essentially, we're converting the number x
    # into a binary number.
    $pow_10_5.each {|val|
        if (x >= 0.5)
            res *= val
            x -= 0.5
        end
        x *= 2.0
    }

    return res;
end

# Calculate log_10(x)
def log_10(x)
    if $pow_10_5.size == 0
        make_pow_10_5
    end

    if x <= 0
        return Float::NAN
    end

    # Now x is positive
    res = 0.0
    while x >= 10.0
        x *= 0.1
        res += 1.0
    end
    while x < 1.0
        x *= 10.0
        res -= 1.0
    end

    # Now x is between 1 and 10
    
    delt = 0.5
    $pow_10_5.each {|fact|
        if x >= fact
            x /= fact
            res += delt
        end
        delt *= 0.5
    }
    
    return res
end

def test_pow_10
    puts "Testing pow_10 in the range 0.000 to 1.000 in steps of 0.001"
    max_diff = 0.0
    max_x = 0.0
    (0..1000).each {|i|
        x = i*0.001;

        app = pow_10(x)
        re = 10.0**x

        diff = (app - re)/re
        if diff < 0
            diff = -diff
        end
        if diff > max_diff
            max_x = x
            max_diff = diff
        end
    }

    puts "#{max_x}, #{max_diff}"

end

def test_log_10
    puts "Testing log_10 in the range 1.001 to 10.000 in steps of 0.001"
    max_diff = 0.0
    max_x = 0.0
    (1..900).each {|i|
        x = 1.0+i*0.01;

        app = log_10(x)
        re = Math::log10(x)

        diff = (app - re)/re
        if diff < 0
            diff = -diff
        end
        if diff > max_diff
            max_x = x
            max_diff = diff
        end
    }

    puts "#{max_x}, #{max_diff}"
end

test_pow_10
test_log_10

