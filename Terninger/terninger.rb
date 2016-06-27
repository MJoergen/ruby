# Terninger

# Regler:
# Spillerne skiftes til at kaste en terning et antal gange. Efter hver kast lægges terningens øjne til en midlertidig sum. Hvis terningen
# viser 1, så slettes den midlertidige sum, og det er den næste spillers tur. Man kan når som helst vælge at stoppe (i stedet for at kaste terningen igen),
# og så gøres den midlertidige sum permanent, og det er den næste spillers tur. Det gælder om at nå op til (eller passere) 100 point først.

# Dette er den centrale funktion som styrer computerens strategi
# Hvis den returnerer True, så vælger computeren at kaste med terningen igen.
# Hvis den returnerer False, så vælger computeren at gemme den midlertidige sum.
class Comp
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		return rand < 0.5 # TBD : Dette er bare en dum strategi indtil videre
	end
	
	def navn
		return "Computer"
	end
end

class Spiller
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		print "Du har indtil videre #{midlertidig_sum} midlertidige point.\n"
		print "Du mangler #{rest_spiller} point, mens jeg mangler #{rest_modstander} point for at vinde.\n"
		print "Vil du fortsætte?\n"
		svar = gets.chomp
		return svar[0] == 'j'
	end
	
	def navn
		return "Spiller"
	end
end

# Denne funktion spiller en enkelt tur for en spiller
# Den returnerer den samlede midlertidige sum, som spilleren tager med sig.
# Den returnerer nul, hvis spilleren endte med at slå 1.
def spil_en_tur(spiller, spiller_mangler, modstander_mangler)
	navn = spiller.send(:navn)
	print "\nDet er nu #{navn}'s tur\n"
	midlertidig_sum = 0
	while true
		fortsæt = spiller.send(:fortsæt, midlertidig_sum, spiller_mangler, modstander_mangler)
		if fortsæt 
			print "#{navn} fortsætter\n"
			terning = rand(6) + 1
			print "Terningerne viser #{terning}\n"
			if terning == 1
				midlertidig_sum = 0
				print "#{navn} mister det hele\n"
				break
			else
				midlertidig_sum += terning
			end
		else
			print "#{navn} stopper og sætter #{midlertidig_sum} i banken\n"
			break
		end
	end
	
	return midlertidig_sum
end

# Denne funktion spiller en helt spil
def spil_et_spil(spillere, aktuel_tur)
	rest_point = [10, 10]
	
	while true
		spiller = spillere[aktuel_tur]
		rest_point[aktuel_tur] -= spil_en_tur(spiller, rest_point[aktuel_tur], rest_point[1-aktuel_tur])
		aktuel_tur = 1-aktuel_tur
		
		if rest_point[0] <= 0
			print "#{spillere[0].send(:navn)} har vundet!\n"
			break
		end
		if rest_point[1] <= 0
			print "#{spillere[1].send(:navn)} har vundet!\n"
			break
		end
	end
end

# Dette er den tilsvarende

srand # Nulstil generatoren af tilfældige tal
print "Velkommen til spillet Terninger\n"

spillere = [Spiller.new, Comp.new]
while true
	spil_et_spil(spillere, 0)
	spil_et_spil(spillere, 1)
end
