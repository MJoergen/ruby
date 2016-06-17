meyer = ["21", "31", "66", "55", "44", "33", "22", "11", "65", "64", "63", "62", "61", "54", "53", "52", "51", "43", "42", "41", "32"]

print "Terninger\n"

srand  # Nulstil generering af tilfælde tal

antal_slag = 100000
fordeling_slag = {}
for i in 1..antal_slag do
	terning1 = rand(6)
	terning2 = rand(6)
	if terning1 > terning2
		slag = (terning1+1).to_s + (terning2+1).to_s
	else
		slag = (terning2+1).to_s + (terning1+1).to_s
	end
	if fordeling_slag.key?(slag)
		fordeling_slag[slag] += 1
	else
		fordeling_slag[slag] = 1
	end
end

kum_sum = 0
meyer.each {|slag| print "#{slag}  ->  #{fordeling_slag[slag]}"; kum_sum += fordeling_slag[slag]; print " #{(kum_sum*100+0.5).to_i/antal_slag}\n"}

