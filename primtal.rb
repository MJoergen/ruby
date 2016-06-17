print "Primtals generator\n"

$primtal = []

def er_primtal(tal)
	lim = Math.sqrt(tal)
	for divisor in 2..lim do
		if (tal % divisor) == 0
			return false
		end
	end
	
	return true
end

for tal in 2..1000000 do
	if er_primtal(tal)
		$primtal << tal
	end
end

#print "#{primtal}\n"
print "I alt #{$primtal.size} primtal\n"
