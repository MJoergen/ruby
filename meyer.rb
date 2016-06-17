meyer = ["21", "31", "66", "55", "44", "33", "22", "11", "65", "64", "63", "62",  "61", "54", "53", "52", "51", "43", "42", "41", "32"]

srand  # Nulstil generering af tilfælde tal

def gen_slag
	terning1 = rand(6)
	terning2 = rand(6)
	if terning1 > terning2
		slag = (terning1+1).to_s + (terning2+1).to_s
	else
		slag = (terning2+1).to_s + (terning1+1).to_s
	end
	return slag
end

print "Velkommen til spillet meyer.\n"
print "\nJeg starter!\n"
print "Jeg ryster terningerne, kigger, og jeg melder 62\n"

aktuelt_slag = gen_slag
melding = "62"

print "\nDu kan enten skrive løft, ryst, eller retur\n"
aktion = gets.chomp.encode(Encoding::UTF_8)
if aktion == "løft"
	print "\nDu løfter\n"
	print "Terningerne viser #{aktuelt_slag}\n"
	if meyer.index(aktuelt_slag) > meyer.index(melding)
		print "Jeg har tabt\n"
	else
		print "Du har tabt\n"
	end
elsif aktion == "ryst"
	print "Du ryster\n"
	aktuelt_slag = gen_slag
	print "Terningerne viser nu #{aktuelt_slag}. Hvad vil du gøre?\n"
	print "Du kan kun lave en melding\n"

	melding = gets.chomp
	if meyer.include?(melding)
		print "Du melder #{melding}\n"
	else
		print "Det forstår jeg ikke"
	end

end
