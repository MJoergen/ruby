print "Velkommen til spillet Nim\n"
antal = 21
while true
    while true
        print "Der er #{antal} brikker tilbage. Hvor mange vil du tage?\n"
        spiller = gets.chomp.to_i
        if spiller >=1 and spiller <= 3
            break
        end
        if spiller > antal
            spiller = antal
        end
        print "Det forstår jeg ikke. Prøv igen.\n"
    end
    print "Du har taget #{spiller} brikker\n"
    antal -= spiller
    print "Der er nu #{antal} brikker tilbage.\n"
    if antal <= 0
        print "Du har vundet!!!!\n"
        exit
    end
    print "Nu er det min tur.\n"
    computer = rand(3) + 1
    if computer > antal
        computer = antal
    end
    print "Jeg tager #{computer} brikker\n"
    antal -= computer
    if antal <= 0
        print "Jeg har vundet!!!!\n"
        exit
    end
end
