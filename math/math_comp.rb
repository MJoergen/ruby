# This file shows how to program a computer to calculate
# logarithms and powers, without a calculator.
# The benefit of this method is that it does not 
# require any multiplications. It can be implemented 
# entirely with shift and additions. Therefore, it
# is well suited for a FPGA.
# TODO: Change the logarithms, so they are base 2 instead of base 20
# TODO: Change all floating point numbers to fixed point numbers.

# Use Newton's method to calculate square roots.
def msqrt(x)
    res = 1.0;
    begin 
        delta = (x/res - res)*0.5;
        res += delta;
        max_err = res * Float::EPSILON;
    end while  delta > max_err or delta < -max_err;

    return res;
end

# This is the method used to calculate the below table of logarithms.
def make_log_2_5()
    pow = 1.0;
    pow_2 = (Float::DIG+1)/0.301
    pow_2.to_i.times do
        $log_2_5 << Math.log10(1.0+pow)
        pow *= 0.5
    end
end

# This table contains log_10(2), log_10(1.5), log_10(1.25), log_10(1.125), etc.
$log_2_5 = [
0.3010299956639812,
0.17609125905568124,
0.09691001300805642,
0.05115252244738129,
0.026328938722349145,
0.013363961557981502,
0.006733382658968403,
0.003379740651380597,
0.0016931580194449753,
0.0008474041359855164,
0.00042390875196115195,
0.00021200609740185334,
0.00010601598536797005,
5.30112276402169e-05,
2.6506422657881923e-05,
1.3253413550725743e-05,
6.626757332351867e-06,
3.3133913056160403e-06,
1.6566988126921545e-06,
8.283501963201243e-07,
4.141752956539506e-07,
2.0708769720049452e-07,
1.0354386094363294e-07,
5.1771933557663626e-08,
2.5885967550293695e-08,
1.2942983968012329e-08,
6.471492032222536e-09,
3.2357460281653614e-09,
1.6178730170962039e-09,
8.089365093014828e-10,
4.044682548390866e-10,
2.022341274666296e-10,
1.0111706374508637e-10,
5.055853187548608e-11,
2.5279265938478767e-11,
1.2639632969423313e-11,
6.3198164847576394e-12,
3.1599082423903154e-12,
1.5799541211980316e-12,
7.899770605997343e-13,
3.9498853030004676e-13,
1.9749426515006829e-13,
9.874713257504538e-14,
4.937356628752549e-14,
2.468678314376345e-14,
1.23433915718819e-14,
6.171695785940993e-15,
3.0858478929705076e-15,
1.5429239464852566e-15,
7.71461973242629e-16,
3.857309866213147e-16,
1.9286549331065737e-16,
9.64327466553287e-17
]


def pow_10(x)
    res = 1.0
    while x >= $log_2_5[0]
        res *= 2.0
        x -= $log_2_5[0]
    end
    while x < 0
        res *= 0.5
        x += $log_2_5[0]
    end
 
    # Now x is between 0 and log(2)

    fact = 1.0
    $log_2_5.each {|val|
        if (x >= val)
            res *= (1 + fact)
            x -= val
        end
        fact *= 0.5
    }

    return res;
end

def log_10(x)
    if x <= 0
        return Float::NAN
    end

    # Now x is positive
    #
    res = 0.0
    while x >= 2.0
        x *= 0.5
        res += $log_2_5[0]
    end
    while x < 1.0
        x *= 2.0
        res -= $log_2_5[0]
    end

    # Now x is between 1 and 2
    
    fact = 1.0
    temp = 1.0
    $log_2_5.each {|delt|
        temp2 = temp * (1 + fact)
        if x >= temp2
            temp = temp2
            res += delt
        end
        fact *= 0.5
    }
    
    return res
end

def test_func(xmin, xmax, xstep, f1, f2)
    puts "Testing in the range #{xmin} to #{xmax} in steps of #{xstep}"
    max_diff = 0.0
    max_x = 0.0
    (0..((xmax-xmin)/xstep).to_i).each {|i|
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

def pow_10_math(x)
    return 10.0**x
end

def test_pow_10
    puts "Testing pow_10"
    max_x, max_diff = test_func(-5.0, 5.0, 0.001, :pow_10, :pow_10_math)
    puts "#{max_x}, #{max_diff}"
end

def log_10_math(x)
    return Math::log10(x)
end

def test_log_10
    puts "Testing log_10"
    max_x, max_diff = test_func(0.10, 100.0, 0.01, :log_10, :log_10_math)
    puts "#{max_x}, #{max_diff}"
end

test_pow_10
test_log_10

