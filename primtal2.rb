print "Primtals generator\n"

tal = (2..100).to_a
for mult in (2..100) do
  tal = tal - (2*mult..100).step(mult).to_a
end
p tal

