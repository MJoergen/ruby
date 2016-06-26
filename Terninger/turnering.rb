# Terninger

# Regler:
# Spillerne skiftes til at kaste en terning et antal gange. Efter hver kast lægges terningens øjne til en midlertidig sum. Hvis terningen
# viser 1, så slettes den midlertidige sum, og det er den næste spillers tur. Man kan når som helst vælge at stoppe (i stedet for at kaste terningen igen),
# og så gøres den midlertidige sum permanent, og det er den næste spillers tur. Det gælder om at nå op til (eller passere) 100 point først.

# Dette er den centrale funktion som styrer computerens strategi
# Hvis den returnerer True, så vælger computeren at kaste med terningen igen.
# Hvis den returnerer False, så vælger computeren at gemme den midlertidige sum.
class Comp1
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		return rand < 0.5 # TBD : Dette er bare en dum strategi indtil videre
	end
	
	def navn
		return "Dum  "
	end
end

# Dette er den centrale funktion som styrer computerens strategi
# Hvis den returnerer True, så vælger computeren at kaste med terningen igen.
# Hvis den returnerer False, så vælger computeren at gemme den midlertidige sum.
class Comp2
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		return rand < Math.exp(-midlertidig_sum / 19.0)
	end
	
	def navn
		return "Klog "
	end
end

# Dette er den centrale funktion som styrer computerens strategi
# Hvis den returnerer True, så vælger computeren at kaste med terningen igen.
# Hvis den returnerer False, så vælger computeren at gemme den midlertidige sum.
class Comp3
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		return midlertidig_sum < 19
	end
	
	def navn
		return "Smart"
	end
end

# Denne funktion spiller en enkelt tur for en spiller
# Den returnerer den samlede midlertidige sum, som spilleren tager med sig.
# Den returnerer nul, hvis spilleren endte med at slå 1.
def spil_en_tur(spiller, spiller_mangler, modstander_mangler, verbose)
	navn = spiller.send(:navn)
	if verbose
		print "\nDet er nu #{navn}'s tur\n"
	end
	midlertidig_sum = 0
	while true
		fortsæt = spiller.send(:fortsæt, midlertidig_sum, spiller_mangler, modstander_mangler)
		if fortsæt 
			if verbose
				print "#{navn} fortsætter\n"
			end
			terning = rand(6) + 1
			if verbose
				print "Terningerne viser #{terning}\n"
			end
			if terning == 1
				midlertidig_sum = 0
				if verbose
					print "#{navn} mister det hele\n"
				end
				break
			else
				midlertidig_sum += terning
			end
		else
			if verbose
				print "#{navn} stopper og sætter #{midlertidig_sum} i banken\n"
			end
			break
		end
	end
	
	return midlertidig_sum
end

# Denne funktion spiller en helt spil
# Den returnerer nummeret på den spiller som har vundet
def spil_et_spil(spillere, aktuel_tur, verbose = false)
	rest_point = [100, 100]
	
	while true
		spiller = spillere[aktuel_tur]
		rest_point[aktuel_tur] -= spil_en_tur(spiller, rest_point[aktuel_tur], rest_point[1-aktuel_tur], verbose)
		aktuel_tur = 1-aktuel_tur
		
		if rest_point[0] <= 0
			if verbose
				print "#{spillere[0].send(:navn)} har vundet!\n"
			end
			return 0
		end
		if rest_point[1] <= 0
			if verbose
				print "#{spillere[1].send(:navn)} har vundet!\n"
			end
			return 1
		end
	end
end

# Dette er den tilsvarende

srand # Nulstil generatoren af tilfældige tal
print "Velkommen til spillet Terninger\n"

gevinster = [0, 0]
spillere = [Comp2.new, Comp3.new]

antal_runder = 20000
for i in 1..antal_runder
	for j in 0..1
		vinder = spil_et_spil(spillere, 0)
		gevinster[vinder] += 1
	end
end

for i in 0..1
	print "#{spillere[i].send(:navn)} har vundet #{gevinster[i]} gange.\n"
end
