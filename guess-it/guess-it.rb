# Dette program spiller spillet "Guess-It".
# Man får et antal kort hver, og så ligger der et enkelt kort på bordet
# som ingen kan se. Det gælder om at gætte dette kort.
# Når det er en spillers tur, så kan man enten "gætte" eller "spørge".
# Hvis man gætter, så er spillet slut. Enten har man gættet rigtigt, eller
# også har man ikke.
# Hvis man spørger, så siger man et kort til den anden spiller, som så 
# skal svare (ærligt) om han har det kort eller ej.


# Denne klasse implementerer en rudimentær bot, som spiller et hæderligt spil.
class CompBasic
    # Denne funktion styrer computerens strategi
    # Første argument er en liste over alle kort på computerens hånd.
    # Andet argument er en liste over de resterende kort.
    # Tredje argument er det kort, som modstanderen lige har spurgt om OG hvor svaret var nej.
    # Funktionen returnerer to værdier, den ene betyder "gæt", den anden
    # "spørg".
    def handling(egne, alle, spurgt)
        #print "egne=#{egne}, alle=#{alle}, spurgt=#{spurgt}\n"
        gæt = nil
        spørg = nil

        resten = alle - egne

        if egne.size <= 1 # Hvis vi har 0 eller 1 kort tilbage, så gæt på det skjulte kort.
            gæt = resten[rand(resten.size)]
        else
            spørg = alle[rand(alle.size)] # Vi bluffer nogen gange!
        end

        return gæt, spørg
    end

    def navn
        return "Basic"
    end
end

# Denne klasse implementer en meget mere sofistikeret algoritme.
class CompBetter
    # Denne funktion styrer computerens strategi
    # Første argument er en liste over alle kort på computerens hånd.
    # Andet argument er en liste over de resterende kort.
    # Tredje argument er det kort, som modstanderen lige har spurgt om OG hvor svaret var nej.
    # Funktionen returnerer to værdier, den ene betyder "gæt", den anden
    # "spørg".
    def handling(egne, alle, spurgt)
        #print "egne=#{egne}, alle=#{alle}, spurgt=#{spurgt}\n"

        # Hvis modstanderen har lige har spurgt og fået nej, så skal vi overveje, om
        # vi vil gætte på det kort, eller om modstanderen har bluffet.
        gæt = nil
        spørg = nil

        resten = alle - egne

        if egne.size <= 1 # Hvis vi har 0 eller 1 kort tilbage, så gæt på det skjulte kort.
            gæt = resten[rand(resten.size)]
        else
            spørg = alle[rand(alle.size)] # Vi bluffer nogen gange!
        end

        return gæt, spørg
    end

    def navn
        return "Better"
    end
end

class Spiller
    def handling(egne, alle, spurgt)
        gæt = nil
        spørg = nil

        while true
            print("Der er følgende kort i spillet: #{alle}\n")
            print("Du har følgende kort på hånden: #{egne}\n")
            if spurgt
                print("Jeg har lige spurgt om kortet: #{spurgt}\n")
            end
            print("Vil du Gætte eller Spørge?\n")
            valg = gets.chomp
            case valg[0]
            when "G", "g"
                print("Du vil altså gætte på det skjulte kort. Hvad tror du det er?\n")
                gæt = gets.chomp.to_i
                break
            when "S", "s"
                print("Du vil altså spørge mig om et kort. Hvad vil du spørge om?\n")
                spørg = gets.chomp.to_i
                break
            else
                print("Du skal svare enten G eller S\n")
                next
            end
        end

        return gæt, spørg
    end

    def navn
        return "Spiller"
    end
end

$cards = 11
def spil_et_spil(spillere, tur, verbose)
    # Bland kortene
    alle = (1..$cards).to_a
    kort = []
    kort << alle.sample($cards/2)
    skjult = (alle - kort[0]).sample
    kort << alle - kort[0] - [skjult]

    while true
        spiller = spillere[tur]
        navn = spiller.navn
        gæt, spørg = spiller.handling(kort[tur], alle, spørg)
        if gæt
            if verbose
                print "#{navn} gætter på #{gæt}\n"
            end
            if gæt == skjult
                if verbose
                    print "Det er rigtigt! #{navn} vinder\n"
                end
                vinder = tur
            else
                if verbose
                    print "Det er forkert! #{navn} taber\n"
                end
                vinder = 1-tur
            end
            break
        else
            if verbose
                print "#{navn} spørger om kortet #{spørg}\n"
            end
            if kort[1-tur].index(spørg)
                if verbose
                    print "Svaret er ja.\n"
                end
                kort[1-tur].delete(spørg)
                alle.delete(spørg)
                spørg = nil
            else
                if verbose
                    print "Svaret er nej.\n"
                end
            end
        end
        tur = 1-tur
        if verbose
            print("\n")
        end
    end
    return vinder
end

def turnering(spillere, antal_runder, verbose = false)
    tur = 0
    points = [0, 0]
    for i in 1..antal_runder
        vinder = spil_et_spil(spillere, tur, verbose)
        points[vinder] += 1
        tur = 1-tur
    end

    for i in 0..1
        spiller = spillere[i]
        navn = spiller.navn
        printf("#{navn} : #{points[i]}\n")
    end
end

#spillere = [CompBasic.new, CompBetter.new]
#turnering(spillere, 20000)

spillere = [Spiller.new, CompBetter.new]
spil_et_spil(spillere, 0, true)

