s = [1, 2]
begin
    sum = s[-2] + s[-1]
    s << sum
end while sum < 4000000

p s

p s.select { |a| (a%2)==0 }

p (s.select { |a| (a%2)==0 }).inject(0, :+)

