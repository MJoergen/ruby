# Dette program spiller spillet "Guess-It".
# Man får et antal kort hver, og så ligger der et enkelt kort på bordet
# som ingen kan se. Det gælder om at gætte dette kort.
# Når det er en spillers tur, så kan man enten "gætte" eller "spørge".
# Hvis man gætter, så er spillet slut. Enten har man gættet rigtigt, eller
# også har man ikke.
# Hvis man spørger, så siger man et kort til den anden spiller, som så 
# skal svare (ærligt) om han har det kort eller ej.

class Comp
    # Denne funktion styrer computerens strategi
    # Første argument er en liste over alle kort på computerens hånd.
    # Andet argument er en liste over de resterende kort.
    # Tredje argument er det kort, som modstanderen lige har spurgt om.
    # Funktionen returnerer to værdier, den ene betyder "gæt", den anden
    # "spørg".
    def handling(egne, alle, spurgt)
        gæt = nil
        spørg = nil

        resten = alle - egne

        if egne.size > resten.size
            gæt = resten[rand(resten.size)]
        else
            spørg = resten[rand(resten.size)]
        end

        return gæt, spørg
    end

    def navn
        return "Computer"
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
def spil_et_spil(spillere, tur)
    # Bland kortene
    alle = (1..$cards).to_a
    kort = []
    kort << alle.sample($cards/2)
    skjult = (alle - kort[0]).sample
    kort << alle - kort[0] - [skjult]

    while true
        spiller = spillere[tur]
        navn = spiller.send(:navn)
        gæt, spørg = spiller.send(:handling, kort[tur], alle, spørg)
        if gæt
            print "#{navn} gætter på #{gæt}\n"
            if gæt == skjult
                print "Det er rigtigt! #{navn} vinder\n"
                vinder = tur
            else
                print "Det er forkert! #{navn} taber\n"
                vinder = 1-tur
            end
            break
        else
            print "#{navn} spørger om kortet #{spørg}\n"
            if kort[1-tur].index(spørg)
                print "Svaret er ja.\n"
                kort[1-tur].delete(spørg)
                alle.delete(spørg)
                spørg = nil
            else
                print "Svaret er nej.\n"
            end
        end
        tur = 1-tur
        print("\n")
    end
    return vinder
end

def turnering(spillere, antal_runder)
    tur = 0
    points = [0, 0]
    for i in 1..antal_runder
        vinder = spil_et_spil(spillere, tur)
        points[vinder] += 1
        tur = 1-tur
    end

    for i in 0..1
        spiller = spillere[i]
        navn = spiller.send(:navn)
        printf("#{navn} : #{points[i]}\n")
    end
end

spillere = [Comp.new, Comp.new]
turnering(spillere, 2)

spillere = [Spiller.new, Comp.new]
#spil_et_spil

