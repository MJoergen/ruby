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

# Find bare en tilfældig melding
melding = meyer[rand(meyer.size)]
aktuelt_slag = gen_slag

spil_igang = true
begin
    print "Jeg ryster terningerne og kigger.\n"
    print "Jeg melder #{melding}.\n"

    print "\nDu kan enten skrive løft eller ryst\n"
    aktion = gets.chomp.encode(Encoding::UTF_8)
    if aktion == "løft"
        print "\nDu løfter\n"
        print "Terningerne viser #{aktuelt_slag}\n"
        if meyer.index(aktuelt_slag) > meyer.index(melding)
            print "Jeg har tabt\n"
        else
            print "Du har tabt\n"
        end
        spil_igang = false
    elsif aktion == "ryst"
        print "\nDu ryster\n"
        aktuelt_slag = gen_slag
        print "Terningerne viser nu #{aktuelt_slag}. Hvad vil du melde?\n"

        lovlig_melding = false
        begin
            ny_melding = gets.chomp
            if meyer.include?(ny_melding)
                print "\nDu melder #{ny_melding}\n"
                if meyer.index(ny_melding) > meyer.index(melding)
                    print "Det er ikke lovligt. Prøv igen.\n"
                else
                    lovlig_melding = true
                end
            else
                print "Det forstår jeg ikke. Prøv igen.\n"
            end
        end while not lovlig_melding
        melding = ny_melding

        print "Nu er det min tur igen.\n"
        if rand < 0.4
            print "Jeg løfter.\n"
            print "Terningerne viser #{aktuelt_slag}\n"
            print "Du havde melddt #{melding}\n"

            if meyer.index(aktuelt_slag) > meyer.index(melding)
                print "Du har tabt\n"
            else
                print "Jeg har tabt\n"
            end
            spil_igang = false
        else
            aktuelt_slag = gen_slag

            if meyer.index(aktuelt_slag) > meyer.index(melding)
                # Jeg må lyve.
                antal_lovlige_meldinger = meyer.index(melding) + 1
                melding = meyer[rand(antal_lovlige_meldinger)]
            else
                melding = aktuelt_slag
            end
        end
    end
end while spil_igang

