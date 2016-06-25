$meyer = ["21", "31", "66", "55", "44", "33", "22", "11", "65", "64", "63", "62",  "61", "54", "53", "52", "51", "43", "42", "41", "32"]

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

# Dette er den centrale bot, som udregner computerens træk.
# "melding" er den aktuelle melding. Hvis det er første slag, så er melding = ""
# "nyt_slag" bruges kun, hvis bot'en ryster terningerne.
# NB: Det er muligt for bot'en at snyde, ved at kigge på nyt_slag, men det er forbudt!
def comp_melding(melding, nyt_slag)
	# Det er min tur!
	if melding == "" # Tom streng betyder, at det er første slag
		# Find bare en tilfældig melding, uafhængig af hvad terningerne viser.
		# TBD1 : Meldingen må godt tage højde for, hvad terningerne viser.
		melding = $meyer[rand($meyer.size)]
	elsif rand < 0.5 # TBD2 : Om vi vælger at stole på spilleren kan godt afhænge af den seneste melding.
		# Vi stoler på spilleren og ryster terningerne.
		if $meyer.index(nyt_slag) > $meyer.index(melding)
			# Øv. Mit nye slag er mindre end det sidst meldte.
			# Jeg må lyve.
			# Jeg vælger en tilfældig af de mulige meldinger.
			antal_lovlige_meldinger = $meyer.index(melding) + 1
			melding = $meyer[rand(antal_lovlige_meldinger)]
		else
			# Jeg melder bare det mine terninger viser.
			melding = nyt_slag # TBD3 : Vores nye melding må godt være både bedre og dårligere en vores terninger.
		end
	else
		# Vi stoler ikke på spilleren, så vi løfter terningerne
		melding = ""
	end
	
	return melding
end

def spiller_melding(melding, nyt_slag)

	aktion = "ryst"
	if melding != "" # Tom streng betyder, at det er første slag
		print "\nDu kan enten skrive løft eller ryst\n"
		aktion = gets.chomp.encode(Encoding::UTF_8)
	end

	if aktion == "løft"
		return ""
	elsif aktion == "ryst"
		print "\nDu ryster\n"
		print "Terningerne viser nu #{nyt_slag}. Hvad vil du melde?\n"

		lovlig_melding = false
		begin
			ny_melding = gets.chomp
			if $meyer.include?(ny_melding)
				print "\nDu melder #{ny_melding}\n"
				if melding != "" and $meyer.index(ny_melding) > $meyer.index(melding)
					print "Det er ikke lovligt. Prøv igen.\n"
				else
					lovlig_melding = true
				end
			else
				print "Det forstår jeg ikke. Prøv igen.\n"
			end
		end while not lovlig_melding
		melding = ny_melding
	end
	
	return melding
end

def spil_en_runde(min_tur)
    print "=====================\n\n"

    melding = ""
	aktuelt_slag = ""
    vinder = 0
    while vinder == 0

        if min_tur
			# Det er computerens tur!
			nyt_slag = gen_slag # Vi genererer et nyt slag. Det bruges, hvis bot'en ryster terningerne
			ny_melding = comp_melding(melding, nyt_slag)
			if ny_melding == ""
				print "Jeg løfter.\n"
				print "Terningerne viser #{aktuelt_slag}\n"
				print "Du havde meldt #{melding}\n"

				if $meyer.index(aktuelt_slag) > $meyer.index(melding)
					print "Du har tabt\n\n"
					vinder = 1
				else
					print "Jeg har tabt\n\n"
					vinder = -1
				end
			else
				aktuelt_slag = nyt_slag
				melding = ny_melding
                print "Jeg ryster terningerne og kigger.\n"
                print "Jeg melder #{melding}.\n"
			end
			
        else
            # Det er spillerens tur!
			nyt_slag = gen_slag # Vi genererer et nyt slag. Det bruges, hvis bot'en ryster terningerne
			ny_melding = spiller_melding(melding, nyt_slag)
			
			if ny_melding == ""
                print "\nDu løfter\n"
                print "Terningerne viser #{aktuelt_slag}\n"
                if $meyer.index(aktuelt_slag) > $meyer.index(melding)
                    print "Jeg har tabt\n\n"
                    vinder = -1
                else
                    print "Du har tabt\n\n"
                    vinder = 1
                end
			else
				aktuelt_slag = nyt_slag
				melding = ny_melding
			end
        end
        
        min_tur = not(min_tur)
    end # while winder == 0

    return vinder
end

print "Velkommen til spillet meyer.\n"

mine_point = 6
dine_point = 6

min_tur = true
while mine_point > 0 and dine_point > 0
    print "Aktuel score er: #{mine_point} point til mig og #{dine_point} point til dig.\n"
    vinder = spil_en_runde(min_tur)
    if vinder == 1
        dine_point -= 1
        min_tur = false
    else
        mine_point -= 1
        min_tur = true
    end

end

if mine_point == 0
    print "TILLYKKE! Du er den nye mester.\n"
end
if dine_point == 0
    print "HAHAHAHA. Jeg tværede dig ud, noob!\n"
end

