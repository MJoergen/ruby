# Terninger

# Regler:
# Spillerne skiftes til at kaste en terning et antal gange. Efter hvert kast
# lægges terningens øjne til en midlertidig sum. Hvis terningen viser 1, så
# slettes den midlertidige sum, og det er den næste spillers tur. Man kan når
# som helst vælge at stoppe (i stedet for at kaste terningen igen), og så gøres
# den midlertidige sum permanent, og det er den næste spillers tur. Det gælder
# om at nå op til (eller passere) 100 point først.

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

# Dette er den centrale funktion som styrer computerens strategi
# Hvis den returnerer True, så vælger computeren at kaste med terningen igen.
# Hvis den returnerer False, så vælger computeren at gemme den midlertidige sum.
class Comp4
	def fortsæt(midlertidig_sum, rest_spiller, rest_modstander)
		mere = winProbContinue(midlertidig_sum, rest_spiller, rest_modstander)
		stop = winProbStay(midlertidig_sum, rest_spiller, rest_modstander)
		#print "mere=#{mere}, stop=#{stop}\n"
		return mere >= stop
	end
	
	# Denne funktion giver sandsynligheden for at vinde.
    # Det er kun en tilnærmet værdi.
	# Den opfylder følgende:
	# winProb(0, 100, 100) = 0.5 : I virkeligheden er værdien lidt højere, fordi det er en fordel at starte
	# winProb(0,   0, 100) = 1.0 : Spilleren har allerede vundet
	# winProb(0, 100,   0) = 0.0 : Spilleren har allerede tabt
	# winProb(100, 0,   0) = 1.0 : Spilleren kan nu vinde
	def winProb(midlertidig_sum, rest_spiller, rest_modstander)
		if rest_modstander <= 0
			return 0.0
		end
		if midlertidig_sum > rest_spiller
			return 1.0
		end
		res = (100  + midlertidig_sum - rest_spiller + rest_modstander)*0.5/100
		#print "winProb(#{midlertidig_sum}, #{rest_spiller}, #{rest_modstander}) = #{res}\n"
		return res
	end
	
	# Denne funktion giver sandsynligheden for at vinde, givet at man stopper runden nu
	def winProbStay(midlertidig_sum, rest_spiller, rest_modstander)
		return 1.0 - winProb(0, rest_modstander, rest_spiller - midlertidig_sum)
	end
	
	# Denne funktion giver sandsynligheden for at vinde, givet at man kaster terningen igen
	def winProbContinue(midlertidig_sum, rest_spiller, rest_modstander)
		return  ( winProb(midlertidig_sum+2, rest_spiller, rest_modstander) \
				+ winProb(midlertidig_sum+3, rest_spiller, rest_modstander) \
				+ winProb(midlertidig_sum+4, rest_spiller, rest_modstander) \
				+ winProb(midlertidig_sum+5, rest_spiller, rest_modstander) \
				+ winProb(midlertidig_sum+6, rest_spiller, rest_modstander) \
				+ 1.0 - winProb(0, rest_modstander, rest_spiller)) / 6
	end
	
	def navn
		return "Geni "
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
# Argumentet er et array på præcist to spillere, hvor den første spiller starter.
def spil_et_spil(spillere, verbose = false)
	rest_point = [100, 100]
	
	aktuel_tur = 0
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

# Denne funktion spiller en hel turnering
def spil_turnering(spillere, antal_runder, verbose = false)
	gevinster = Array.new(spillere.size, 0)

	for i in 1..antal_runder
		if verbose
			print "\nNu går vi i gang med runde #{i}\n"
		end
		for første in 0..spillere.size-1
			for forskel in 1..spillere.size-1
				anden = (første+forskel)%spillere.size
				spiller1 = spillere[første]
				spiller2 = spillere[anden]
				if verbose
					print "#{spiller1.send(:navn)} mod #{spiller2.send(:navn)}"
				end
				vinder = spil_et_spil([spiller1, spiller2], verbose)
				if vinder == 0
					gevinster[første] += 1
					navn = spiller1.send(:navn)
				else
					gevinster[anden] += 1
					navn = spiller2.send(:navn)
				end
				if verbose
					print "  ==>  #{navn} vandt\n"
				end
			end
		end
	end
	
	return gevinster
end

# Dette er den tilsvarende

srand # Nulstil generatoren af tilfældige tal
print "Velkommen til spillet Terninger\n"

spillere = [Comp1.new, Comp2.new, Comp3.new, Comp4.new]

gevinster = spil_turnering(spillere, 18000)

print "\n"
for i in 0..spillere.size-1
	print "#{spillere[i].send(:navn)} har vundet #{gevinster[i]} gange.\n"
end
