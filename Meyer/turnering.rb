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

class Comp0
    # Dette er den centrale bot, som udregner computerens træk.
    # "melding" er den aktuelle melding. Hvis det er første slag, så er melding = ""
    # "nyt_slag" bruges kun, hvis bot'en ryster terningerne.
    # NB: Det er muligt for bot'en at snyde, ved at kigge på nyt_slag, men det er forbudt!
    def melding(melding, nyt_slag)
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

    def navn
        return "DUM!"
    end
end

class Comp1
    # Dette er den centrale bot, som udregner computerens træk.
    # Denne bot skulle meget gerne spille mere strategisk, og dermed vinde oftere.
    def melding(melding, nyt_slag)
        # Det er min tur !

        if melding == "" # Tom streng betyder, at det er første slag
            # Find bare en tilfældig melding, uafhængig af hvad terningerne viser.
            # TBD1 : Meldingen må godt tage højde for, hvad terningerne viser.
            melding = $meyer[rand($meyer.size)]
            return melding
        end

        # Beregn sandsynligheden for at ryste
        r = $meyer.index(melding) / 20.0 # Dette er en værdi mellem 0.00 og 1.00. Hvis sidste melding er 21, så er r=0.00.

        if rand < r
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

    def navn
        return "KLOG"
    end
end

def spil_en_runde(spillere, denne_spiller, verbose)
    melding = ""
	aktuelt_slag = ""
    vinder = nil
    while vinder == nil

        nyt_slag = gen_slag # Vi genererer et nyt slag. Det bruges, hvis bot'en ryster terningerne
        spiller = spillere[denne_spiller]
        spiller_navn = spiller.send(:navn)
        ny_melding = spiller.send(:melding, melding, nyt_slag)
        sidste_spiller = (denne_spiller-1)%2
        sidste_spiller_navn = spillere[sidste_spiller].send(:navn)

        if ny_melding == ""
            if verbose
                print "Spiller #{spiller_navn} løfter.\n"
                print "Terningerne viser #{aktuelt_slag}\n"
                print "Spiller #{sidste_spiller_navn} havde meldt #{melding}\n"
            end

            if $meyer.index(aktuelt_slag) > $meyer.index(melding)
                # Meldingen var en løgn.
                if verbose
                    print "Spiller #{sidste_spiller_navn} har tabt\n\n"
                end
                vinder = denne_spiller
            else
                if verbose
                    print "Spiller #{spiller_navn} har tabt\n\n"
                end
                vinder = sidste_spiller
            end
        else
            aktuelt_slag = nyt_slag
            melding = ny_melding
            if verbose
                print "Spiller #{spiller_navn} ryster terningerne og kigger.\n"
                print "Spiller #{spiller_navn} melder #{melding}.\n"
            end
        end
			
        denne_spiller = (denne_spiller+1)%2
    end # while winder == 0

    return vinder
end

def spil_en_turnering(spillere, antal_spil, verbose=false)
    point = [0, 0]
    start = 0
    for i in 1..antal_spil
        if verbose
            print "\nRunde #{i}:\n"
        end

        vinder = spil_en_runde(spillere, start, verbose)
        point[vinder] += 1
        start = (vinder-1)%2
    end
    return point
end

print "Velkommen til spillet meyer.\n"

spillere = [Comp0.new, Comp1.new]
resultat = spil_en_turnering(spillere, 20000)
for i in 0..spillere.size-1
    print "Spiller #{spillere[i].send(:navn)} : #{resultat[i]}\n"
end

