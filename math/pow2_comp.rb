# The table below contains the numbers
# 2^64 * log(1+2^-n) / log(2)
# It is generated by the following command line in the program 'bc':
# obase=16; for(n=0; n<64; n++) {scale=30; a=l(1+2^-n)/l(2.0)*2^64+0.5; scale=0; a/1}
$log_pow_2 = [
   0x10000000000000000,
    0x95C01A39FBD687A0, # log_2(1.5)
    0x5269E12F346E2BF9, # log_2(1.25)
    0x2B803473F7AD0F3F, # log_2(1.125)
    0x1663F6FAC913167D,
    0x0B5D69BAC77EC399,
    0x05B9E5A170B48A63,
    0x02DFCA16DDE10A30,
    0x01709C46D7AAC775,
    0x00B87C1FF853AB26,
    0x005C4994DD0FD150,
    0x002E27AC5EF2AF86,
    0x0017148EC2A1BFC9,
    0x000B8A7588FD29B2,
    0x0005C5464EC5F4D7,
    0x0002E2A60A005C96,
    0x00017153BDA8F822,
    0x0000B8AA0CFEDCB1,
    0x00005C55120A0C46,
    0x00002E2A8BE7AE57,
    0x0000171546AC8150,
    0x00000B8AA3846B34,
    0x000005C551CDC03D,
    0x000002E2A8E9C2C7,
    0x0000017154759A0E,
    0x000000B8AA3AFB32,
    0x0000005C551D8923,
    0x0000002E2A8EC774,
    0x0000001715476473,
    0x0000000B8AA3B268,
    0x00000005C551D93F,
    0x00000002E2A8ECA3,
    0x0000000171547652,
    0x00000000B8AA3B29,
    0x000000005C551D95,
    0x000000002E2A8ECA,
    0x0000000017154765,
    0x000000000B8AA3B3,
    0x0000000005C551D9,
    0x0000000002E2A8ED,
    0x0000000001715476,
    0x0000000000B8AA3B,
    0x00000000005C551E,
    0x00000000002E2A8F,
    0x0000000000171547,
    0x00000000000B8AA4,
    0x000000000005C552,
    0x000000000002E2A9,
    0x0000000000017154,
    0x000000000000B8AA,
    0x0000000000005C55,
    0x0000000000002E2B,
    0x0000000000001715,
    0x0000000000000B8B,
    0x00000000000005C5,
    0x00000000000002E3,
    0x0000000000000171,
    0x00000000000000B9,
    0x000000000000005C,
    0x000000000000002E,
    0x0000000000000017,
    0x000000000000000C,
    0x0000000000000006,
    0x0000000000000003,
    0x0000000000000001]

def pow_2(x)
    e = x.to_i
    x -= e
    if (x<0)
        x+=1
        e-=1
    end

    ix = (x*2**64+0.5).to_i
    ox = 0x10000000000000000

    $log_pow_2.each_with_index {|val, index|
        if (ix >= val)
            ox += ox >> index
            ix -= val
        end
    }

    return ox/(2.0**(64-e))
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

def pow_2_math(x)
    return 2.0**x
end

def test_pow_2
    puts "Testing pow_2"
    max_x, max_diff = test_func(-5.0, 5.0, 0.001, :pow_2, :pow_2_math)
    puts "#{max_x}, #{max_diff}"
end

test_pow_2

