# Denne metode spørger spilleren om, hvad han vil gøre.
# Parametre:
#   egne_kort    : En liste over de kort, som spilleren har
#   antal_kort   : Et tal, som angiver det samlede antal kort i spillet.
#   spurgt_kort  : Et tal, som angiver navnet på det sidste kort, der er spurgt om.
#   spurgt_svar  : true/false, som angiver svaret på det sidst spurgte kort.
#   alle_spurgte : En liste over alle de kort, som der er blevet spurgt om.
# Returværdier:
#   gæt          : true, hvis spilleren vil gætte. false, hvis spilleren vil spørge.
#   kort         : Det kort, som spilleren vil gætte eller spørge om.
def spiller_valg(egne_kort, antal_kort, spurgt_kort, spurgt_svar, alle_spurgte)
    puts ”Du sidder med ” + egne_kort.to_s
    #osv.
    puts ”Vil du spørge eller gætte?”
    #osv.
    kort = 0     # SKAL RETTES
    gæt  = false # SKAL RETTES
    return gæt, kort
end

# Denne metode udregner computerens strategi
def comp_valg(egne_kort, antal_kort, spurgt_kort, spurgt_svar, alle_spurgte)
    # Find selv på en mere smart strategi for computeren.
    kort = rand(antal_kort) + 1 # Vælger et helt tilfældigt kort
    gæt  = rand(100) < 50       # Er true i 50 % af tiden.
    return gæt, kort
end

antal_kort = 11 # Skal være et ulige antal

# Fordel alle kortene blandt spilleren, computeren, og det skjulte kort.
alle_kort = (1..antal_kort).to_a # Lav en liste med alle kort.

skjult_kort = alle_kort.sample # Vælg et tilfældigt kort.

spiller_kort = []
spiller_kort << (alle_kort-[skjult_kort]).sample(antal_kort/2)

computer_kort = alle_kort - [skjult_kort] - spiller_kort

spurgt_kort = nil # Det sidste kort, der er spurgt om.
spurgt_svar = nil # Det sidste svar, der blev givet.
alle_spurgte = [] # Alle de kort, som der er blevet spurgt om.

while true
    # Nu er det spillerens tur
    gæt, kort = spiller_valg(spiller_kort, antal_kort, spurgt_kort, spurgt_svar, alle_spurgte)
    if gæt
        # Har spilleren vundet eller tabt?
        # HER SKAL INDSÆTTES NOGET KODE.
        break
    else
        puts "Du spurgte om kortet " + kort.to_s
        spurgt_kort = kort
        spurgt_svar = computer_kort.index(kort) != nil # Har computeren kortet?
        alle_spurgte << kort
    end

    # Nu er det computerens tur
    gæt, kort = computer_valg(computer_kort, antal_kort, spurgt_kort, spurgt_svar, alle_spurgte)
    if gæt
        # Har computeren vundet eller tabt?
        # HER SKAL INDSÆTTES NOGET KODE.
        break
    else
        puts "Jeg spurgte om kortet " + kort.to_s
        spurgt_kort = kort
        spurgt_svar = spiller_kort.index(kort) != nil # Har spilleren kortet?
        alle_spurgte << kort
    end
end

puts "Spillet er slut."

