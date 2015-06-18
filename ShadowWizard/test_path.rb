require_relative 'Server_Phantom'

room_data = []
File.open(ARGV[0]) do |f|
    f.each_line do |line|
        room_data << line.split.map(&:to_i)
    end
end

portals = []
for i in 0..3
    tile = [1, 2, 3, 4, 5, 6].sample
    portals[i] = tile
end
puts "portals = #{portals}"

$gen_x = 240
$gen_y = 480

s = Server_Phantom.new(0, 0)
s.make_path(room_data, portals, 35, 0)
