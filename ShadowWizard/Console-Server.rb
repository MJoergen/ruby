
# Gems, gems are truly outrageous, they're truly TRULY outrageous ;) 
require 'rubygems'
require 'renet'
require 'gosu'
require 'socket'

require_relative 'Server_Phantom.rb'
require_relative 'Server_Block.rb'
require_relative 'Server_Crate.rb'
require_relative 'Server_Undead.rb'

include Gosu

# define a new window class
class GameWindow < Gosu::Window
	
	WIDTH = 640
	HEIGHT = 480
	TITLE = "RenetMP Server"
	
	attr_reader :server
	
	def initialize
		
		super(WIDTH, HEIGHT, false)
		self.caption = TITLE
		
		# Generation stuff
		$gen_x = 240
		$gen_y = 480
		
		# The most important variable
		@playing = false
		
		# Player stuff
		@clients = {}
		@players_online = [0, 0, 0]
		@players_ingame = [0, 0, 0]
		@players_alive = [0, 0, 0]
		@player_x_array = [$gen_x, $gen_x, $gen_x]
		@player_y_array = [$gen_y, $gen_y, $gen_y]
		@player_angle_array = [0, 0, 0]
		
		# Weapons
		$players_weapon_slot = [0, 0, 0] # This number represents the actual ID of the weapon. Eg 0 = nothing, 1 = stick, 2 = rod, 3 = wand, and so on...
		$players_weapon_array_num = [0, 0, 0] # This number provides the position of the weapon ID in the @weapon_array
		$players_weapon_array = []
		player1_array = [0, 1, 2, 3] # Starting weapons for the players
		player2_array = [0, 1, 2, 3] # Starting weapons for the players
		player3_array = [0, 1, 2, 3] # Starting weapons for the players
		$players_weapon_array.push(player1_array, player2_array, player3_array) # This array contains all the available weapons for each individual player.
		
		# Attacking
		@players_attacking = [0, 0, 0]
		@players_attack_timer = [0, 0, 0]
		
		# Countdown stuff
		@count = 3
		@counting = false
		# Room generation stuff
		@room_num = nil
		@boxes = []
		@crate_coords = []
		@torchlights = []
		$undeads = []
		$portals = []
		$path_blockers = []
		$crates = []
		$room_data = []
		# Phantom
		@phantom = Server_Phantom.new(1160.0, 0)
		@phantom_coords = [@phantom.x, @phantom.y]
		# create a new server object ( port, clients allowed, number of channels, download bandwidth, upload bandwidth)
		@server = ENet::Server.new(8000, 3, 33, 0, 0)
		# Set our handlers to the server (I really have no idea what this is.. xD )
		@server.on_connection(method(:connections_handler))
		@server.on_packet_receive(method(:packets_handler))
		@server.on_disconnection(method(:disconnections_handler))
		
		# Synchronize FPS (gives the server a type of "dynamic FPS")
		@new_ms = Gosu::milliseconds
		@last_ms = @new_ms
		$time_diff_ms = 1
		
		
		@font = Gosu::Font.new(self, Gosu::default_font_name, 14)
		@tile = Gosu::Image.new(self, "media/tile.png", true)
		@door = Gosu::Image.new(self, "media/door.png", true)
		
		# Let Ocra do its thing
		exit if defined?(Ocra) # This was made so the server would automatically exit when ocra checked for dependencies, but is no longer needed.
	end

	def update
		# send queued packets and wait for new packets
		@server.update(5)
		if @playing == true
			
			# Undead
			if !$undeads.empty?
				$undeads.each { |undead| undead.update(@player_x_array, @player_y_array, @players_ingame, @players_alive) }
			end
			
			# Player weapon stuff
			for i in 0..2 # For each player
				if @players_attacking[i] == 1 # If attacking
					
					@players_attack_timer[i] = @players_attack_timer[i] - 1.0 * $time_diff_ms*60/1000
					
					if @players_attack_timer[i] <= 0 # If the attack hit is triggered
						@players_attacking[i] = 0
						
						# Check which weapon is triggered
						if $players_weapon_slot[i] == 1 # If player weapon is staff
							getx = Gosu::offset_x(@player_angle_array[i]+60, 17.88) # This gets the point where the staff begins.
							gety = Gosu::offset_y(@player_angle_array[i]+60, 17.88)
							angle_start = @player_angle_array[i]-62
							angle_end = @player_angle_array[i]+42
							$undeads.each { |u|  u.checkCollisionStaff(@player_x_array[i] + getx, @player_y_array[i] + gety, 40, angle_start, angle_end, "staff") }
						end
						if $players_weapon_slot[i] == 3 # If player weapon is staff
							getx = Gosu::offset_x(@player_angle_array[i]+60, 17.88) # This gets the point where the staff begins.
							gety = Gosu::offset_y(@player_angle_array[i]+60, 17.88)
							angle_start = @player_angle_array[i]-62
							angle_end = @player_angle_array[i]+42
							$undeads.each { |u|  u.checkCollisionStaff(@player_x_array[i] + getx, @player_y_array[i] + gety, 65, angle_start, angle_end, "halberd") }
						end
					end
				end
			end
			
		end
		
		# show our client FPS
		self.caption = "RenetMP Server - [FPS: #{Gosu::fps.to_s}]"
		
		@last_ms = @new_ms
		@new_ms = Gosu::milliseconds
		$time_diff_ms = @new_ms - @last_ms
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
	end
	
	
	def draw
		
		if !$room_data.empty?
            gen_x, gen_y = 60, 400
            scale = 32.0 / 480
            off_x = -20
            off_y = -40
            fontscale = 1.5
			
			if @players_ingame[0] != 0 
                @font.draw("1", gen_x+@player_x_array[0]*scale+off_x, gen_y+@player_y_array[0]*scale+off_y, 4, fontscale, fontscale, 0xFF6464FF)
            end
			if @players_ingame[1] != 0 
                @font.draw("2", gen_x+@player_x_array[1]*scale+off_x, gen_y+@player_y_array[1]*scale+off_y, 4, fontscale, fontscale, 0xFF41CC41)
            end
			if @players_ingame[2] != 0 
                @font.draw("3", gen_x+@player_x_array[2]*scale+off_x, gen_y+@player_y_array[2]*scale+off_y, 4, fontscale, fontscale, 0xFFFF6464)
            end
				
			$room_data.each_index do |i|
					
				@tile.draw_rot(gen_x+32*(($room_data[i][0]-1) % 6), gen_y-(32*(($room_data[i][0]-1)/6).ceil), 2, 0)
				
				case $room_data[i][1]
					when 1
						@door.draw_rot(gen_x+32*(($room_data[i][0]-1) % 6), gen_y-(32*(($room_data[i][0]-1)/6).ceil)-16, 3, 0)
				end
				case $room_data[i][2]
					when 1
						@door.draw_rot(gen_x+32*(($room_data[i][0]-1) % 6)+16, gen_y-(32*(($room_data[i][0]-1)/6).ceil), 3, 0)
				end

			end
		else
			@font.draw(Socket.ip_address_list.find {|a| a.ipv4? and !(a.ipv4_loopback?) }.ip_address, WIDTH/2-40, HEIGHT/2-6, 0)
		end
	end

	# define a custom handler for new client connections, it will be automatically called
	def connections_handler(id, ip)
		# show who connected
		puts "[ID #{id}] connected from #{ip}"
		# delete the hash entry if it already exists
		@clients.delete_if {|key, value| key == id }
		# add the new entry to the clients hash
		@clients[id] = { :ip => ip }
		#show how many clients we have
		puts "Clients connected: #{@server.clients_count} of #{@server.max_clients}"
		#give client its ID
		@players_online[id] = 1
		@server.send_packet(id, "#{id}", true, 6)
		@server.broadcast_packet("#{id}", true, 3)
	end
	
	# define a custom handler for client disconnections, it will be automatically called
	def disconnections_handler(id)
		# show who left
		puts "#{@clients[id][:ip]} with ID #{id} disconnected"
		# delete its entry in the clients hash
		@clients.delete_if {|key, value| key == id }
		@players_online[id] = 0
		@players_ingame[id] = 0
		if id == 0 and @counting == true
			@count = 3
			@counting = false
			puts 'Countdown interrupted'
		end
		if @players_ingame == [0, 0, 0] and @playing == true
			@playing = false
			puts 'Game has ended...'
		end
		# sends a packet to all clients informing about the disconnection (data, reliable or not, channel ID)
		@server.broadcast_packet("#{id} disconnected", true, 1)
		if @playing == true
			@server.broadcast_packet(@players_ingame.join(' '), true, 9)
		end
	end

	# define a custom handler for incoming data packets, it will be automatically called
	def packets_handler(id, data, channel)
		
		# Put string in the console
		if ![10, 11, 12, 15, 16, 17, 18, 22, 28, 29, 30, 31].include? channel 
			puts "packet from [peer #{id}] -> [#{data}] - [#{channel}]" 
		end
		if [10, 11, 12, 15, 16, 17, 18, 22, 25, 28, 29, 30, 31].include? channel
			@server.broadcast_packet(data, true, channel)
		end
		
		case channel
			when 0 # Ping
				@server.send_packet(id, data, true, channel)
			when 2 # Text
				case data.chomp("\u0000")
					
					when "<start"
						if id == 0
							if @counting == false
								if @playing == false
									@room_num = [0, 1, 2].sample
									countdown(id)
									@counting = true
								else
									@server.send_packet(id, "Game is already in progress", true, 4)
								end
							end
						else
							@server.send_packet(id, "Only host can send commands", true, 4)
						end
					when "<start0"
						if id == 0
							if @counting == false
								if @playing == false
									@room_num = 0
									countdown(id)
									@counting = true
								else
									@server.send_packet(id, "Game is already in progress", true, 4)
								end
							end
						else
							@server.send_packet(id, "Only host can send commands", true, 4)
						end
					when "<start1"
						if id == 0
							if @counting == false
								if @playing == false
									@room_num = 1
									countdown(id)
									@counting = true
								else
									@server.send_packet(id, "Game is already in progress", true, 4)
								end
							end
						else
							@server.send_packet(id, "Only host can send commands", true, 4)
						end	
					when "<start2"
						if id == 0
							if @counting == false
								if @playing == false
									@room_num = 2
									countdown(id)
									@counting = true
								else
									@server.send_packet(id, "Game is already in progress", true, 4)
								end
							end
						else
							@server.send_packet(id, "Only host can send commands", true, 4)
						end				
					else
						@server.broadcast_packet("From ID #{id}: " + data, true, channel)
				end
			when 10 # Keyboard input from player 0
				temp = data.split.map(&:to_f)
				turn_right = temp[1]
				turn_left = temp[3]
				@player_angle_array[0] = @player_angle_array[0] + turn_right - turn_left
				@player_angle_array[0] = @player_angle_array[0] % 360
				
			when 11 # Keyboard input from player 1
				temp = data.split.map(&:to_f)
				turn_right = temp[1]
				turn_left = temp[3]
				@player_angle_array[1] = @player_angle_array[1] + turn_right - turn_left
				@player_angle_array[1] = @player_angle_array[1] % 360
				
			when 12 # Keyboard input from player 2
				temp = data.split.map(&:to_f)
				turn_right = temp[1]
				turn_left = temp[3]
				@player_angle_array[2] = @player_angle_array[2] + turn_right - turn_left
				@player_angle_array[2] = @player_angle_array[2] % 360
				
			when 13 
				countdown(id)
				
			when 15	# Player coordinates
				coords = data.split.map(&:to_f)
				id = coords[0]
				@player_x_array[id] = coords[1]
				@player_y_array[id] = coords[2]
				
			when 17 # Change weapon!!
				temp = data.split
				id = temp[0].to_i # 0, 1 or 2
				is_q = temp[1].to_i # 0 = e  or  1 = q
				weapon_array = $players_weapon_array[id]
				
				if is_q == 1
					$players_weapon_array_num[id] = [0, $players_weapon_array_num[id]-1].max
				else
					$players_weapon_array_num[id] = [weapon_array.length-1, $players_weapon_array_num[id]+1].min
				end
				
				$players_weapon_slot[id] = weapon_array[$players_weapon_array_num[id]]
				
				p $players_weapon_array
				
				puts "...."
				puts "Changing Weapon vv"
				puts "Id: #{id}"
				puts "Weapon_Slot: #{$players_weapon_slot[id]}"
				puts " "
				
			when 18 # Start attack animation
				temp = data.split
				id = temp[0].to_i # 0, 1 or 2
				
				puts "Attacking vv"
				puts "Id: #{id}"
				puts "Weapon_Slot: #{$players_weapon_slot[id]}"
				
				if $players_weapon_slot[id] == 1
					@players_attacking[id] = 1
					@players_attack_timer[id] = 15
				end
				if $players_weapon_slot[id] == 3
					@players_attacking[id] = 1
					@players_attack_timer[id] = 20
				end
				
			when 25 # A crate is destroyed
				temp = data.split
				$crates.each_with_index do |num, i|
					if $crates[i].respond_to?('destroy_at_position')
						if $crates[i].destroy_at_position(temp[0], temp[1])
							$crates[i] = nil
						end
					end
				end
				$crates.delete(nil)
			when 28 # An undead is damaged
				temp = data.split
				$undeads.each { |u| u.take_damage(temp[1].to_i, temp[2].to_i) }
			when 30
				
				temp = data.split
				
				id = temp[0].to_i
				condition = temp[1]
				
				if condition == "died"
					@players_alive[id] = 0
				end
				if condition == "revived"
					@players_alive[id] = 1
				end
				
		end
	end

	def countdown(id)
		if @count == 0
			send_room
			@count = 3
			@counting = false
		else
			@server.broadcast_packet("Starting in #{@count}...", true, 4)
			@server.send_packet(id, "", true, 13)
			@count = [0, @count-1].max
		end
	end

	def send_room
		
		@player_x_array = [$gen_x, $gen_x, $gen_x]
		@player_y_array = [$gen_y, $gen_y, $gen_y]
		@player_angle_array = [0, 0, 0]
		$players_weapon_slot = [0, 0, 0] # This number represents the actual ID of the weapon. Eg 0 = nothing, 1 = stick, 2 = rod, 3 = wand, and so on...
		$players_weapon_array_num = [0, 0, 0] # This number provides the position of the weapon ID in the @weapon_array
		$players_weapon_array = []
		player1_array = [0, 1, 2, 3] # The starting weapons for the players
		player2_array = [0, 1, 2, 3] # The starting weapons for the players
		player3_array = [0, 1, 2, 3] # The starting weapons for the players
		$players_weapon_array.push(player1_array, player2_array, player3_array) # This array contains all the available weapons for each individual player.
		@players_attacking = [0, 0, 0]
		@players_attack_timer = [0, 0, 0]
		
		@phantom = Server_Phantom.new(1160.0, 0)
		@phantom_coords = [@phantom.x, @phantom.y]
		
		@boxes = (1...35).to_a.shuffle.take(10) # boxes is now an array with 10 different values between 2 and 36
		@server.broadcast_packet(@boxes.join(' '), true, 8) # send the array as a string to the clients
		
		$crates.clear
		$path_blockers.clear
		
		for i in 1..10 
			@crate_coords = []
			crates = []
			amount = [1, 2, 3, 4].sample
			crates = (1...4).to_a.shuffle.take(amount)
			
			crates.each_index do |e|
				case crates[e]
					when 1
						cen_x = -60
						cen_y = -60
						@crax = cen_x + rand(100) - 50
						@cray = cen_y + rand(100) - 50
					when 2
						cen_x = 60
						cen_y = -60
						@crax = cen_x + rand(100) - 50
						@cray = cen_y + rand(100) - 50
					when 3
						cen_x = 60
						cen_y = 60
						@crax = cen_x + rand(100) - 50
						@cray = cen_y + rand(100) - 50
					when 4
						cen_x = -60
						cen_y = 60
						@crax = cen_x + rand(100) - 50
						@cray = cen_y + rand(100) - 50
				end
				
				@crate_coords.push(@crax, @cray)
				bx = $gen_x + 480*(@boxes[i-1] % 6)
				by = $gen_y - 480*(@boxes[i-1] / 6).ceil
				create_crate(bx + @crax, by + @cray)
			end
			@server.broadcast_packet(@crate_coords.join(' '), true, 14)
			
		end
		
		send_torches
		send_portals
		send_undead
		
		construct_map
		
		@server.broadcast_packet("#{@room_num}", true, 7) # Basically start the game... (which is why its after the boxes)
		@players_ingame[0] = @players_online[0]
		@players_ingame[1] = @players_online[1]
		@players_ingame[2] = @players_online[2]
		@players_alive = [1, 1, 1]
		@server.broadcast_packet(@players_ingame.join(' '), true, 9)
		puts 'Game Started...'
		@playing = true
	end

	def construct_map
		
		$room_data.clear
		
		case @room_num
			when 0
				File.open('room0data.txt') do |f|
					f.lines.each do |line|
						$room_data << line.split.map(&:to_i)
					end
				end
			when 1
				File.open('room1data.txt') do |f|
					f.lines.each do |line|
						$room_data << line.split.map(&:to_i)
					end
				end
			when 2
				File.open('room2data.txt') do |f|
					f.lines.each do |line|
						$room_data << line.split.map(&:to_i)
					end
				end
		end
		
		create_walls
		
	end

	def create_walls
		$path_blockers.clear
		
		# Each one of the four edges on the map
		create_block(  $gen_x-330, $gen_y-480*5-330,  180, 3060) # Right - relative to tile 30
		create_block(  $gen_x-330, $gen_y-480*5-330,  3060, 180) # Top - relative to tile 30
		create_block(  $gen_x+480*5+150, $gen_y-480*5-330,  180, 3060) # Left - relative to tile 35
		create_block(  $gen_x-330, $gen_y+150,  3060, 180) # Bottom - relative to tile 0
		
		$room_data.each_index do  |i| # Check each and every room, and create "phantom walls"
			
			room_center_x = $gen_x+480*(($room_data[i][0]-1) % 6)
			room_center_y = $gen_y-(480*(($room_data[i][0]-1)/6).ceil)
			
			if $room_data[i][0].between?(31, 36) and $room_data[i][2] == 1 # Top row of rooms
				create_block(room_center_x+150, room_center_y-150, 180, 75)
			end
			
			if ($room_data[i][0]-1) % 6 == 0 and $room_data[i][1] == 1 # Left row of rooms
				create_block(room_center_x-150, room_center_y-330, 75, 180)
			end
			
			if $room_data[i][1] == 1 # Top doorway
				create_block(  room_center_x+75, room_center_y-330, 330, 180) # Right doorway block
			else
				create_block(  room_center_x-150, room_center_y-330, 555, 180) # Top wall
			end
			
			if $room_data[i][2] == 1 # Right doorway
				create_block(  room_center_x+150, room_center_y+75, 180, 330) # Bottom doorway block
			else
				create_block(  room_center_x+150, room_center_y-150, 180, 555) # Right wall
			end
		end
	end

	def create_block(x, y, width, height)
		$path_blockers.push(Server_Block.new(x, y, width, height))
	end
	
	def create_crate(x, y)
		$crates.push(Server_Crate.new(x, y))
	end
	
	def create_undead(x, y, angle, id)
		$undeads[id] = Server_Undead.new(self, x, y, angle, id)
	end
	
	def checkCollisionUndead(x, y, r, id, meth, collision)
		$undeads.each     { |u|  
			if u.respond_to?(collision)
				if u.send collision,x,y,r,id
					meth.call(u)
				end
			end
		}
	end
	
	def checkCollisionPathblock(x, y, r, meth)
		$path_blockers.each     { |p|    # Server_Block
			if p.checkCollisionA(x,y,r)
				meth.call(p)
			end
		}
	end
	
	def checkCollisionCrate(x, y, r, meth)
		$crates.each     { |c|  
			if c.checkCollisionB(x,y,r)
				meth.call(c)
			end
		}
	end
	
	def get_dir_dif(dir1,dir2)
		
		dir_to_turn = dir1 - dir2 #This gives a value between -360 and 360
			
		# Make sure that value is between -180 and 180, which is the relative direction.
		if dir_to_turn >= 180
			dir_to_turn += -360
		end
		if dir_to_turn <= -180
			dir_to_turn += 360
		end
		#This outputs only the difference in terms of angle (for example -15 or 25 degrees)
		#So in order to get the absolute difference you need to do .abs!
		return dir_to_turn
	end

	def send_portals
		$portals.clear # Incase the game is restarted, we want to reset this array.
		
		for i in 0..3
			tile = [1, 2, 3, 4, 5, 6].sample
			$portals[i] = tile
		end
		
		@server.broadcast_packet($portals.join(' '), true, 21)
		$portal_pos_x = []
		$portal_pos_y = []
		
		for i in 0..3 # For each portal
			
			room_edge_x = 130 * (((i%2)*2-1) * (i/2).floor) # uuhh
			room_edge_y = 130 * ((1 - (i%2))*2 - 1) * (1 - i/2).floor # yeahh
				
			temp1 = 480 * 5 * (i/3).floor # The right-most portal (otherwise = 0)
			temp2 = 480 * 5 * (1-((i+1)/3).floor) * (i%2) # The top-most portal (otherwise = 0)
				
			x = $gen_x + 480 * ($portals[i]-1) * (1-(i/2).floor) + room_edge_x + temp1
			y = $gen_y - 480 * ($portals[i]-1) * (i/2).floor + room_edge_y - temp2
			
			$portal_pos_x[i] = x
			$portal_pos_y[i] = y
		end
	end
	
	def send_undead
		$undeads.clear # This is important to clear when restarting a game.
		undead_coords = []
		valid_rooms = []
		undead_rooms = []
		for i in 0..35 # Checks every room aka tile
			if ![0, 1, 6].include? i and !@boxes.include? i # Excludes the rooms close to spawn, and rooms wich has crates.
				valid_rooms.push(i) # Pushes the room number to a new array, wich includes all the "valid rooms" that CAN contain undead.
			end
		end
		undead_rooms = valid_rooms.shuffle.take(10) # Out of the valid rooms, take 10 random.
		undead_rooms.each_index do |i| # For each of the 10 random valid rooms:
			amount = [1, 2, 3, 4].sample # Pick a random number
			ran_numbs = []
			ran_numbs = (1...5).to_a.shuffle.take(amount) # Take a random amount of random numbers between 1 and 4 (I know it says 1...5, but 1...4 didn't work for me)
			ran_numbs.each_index do |e| # For each random number
				case ran_numbs[e] # Check the value, which indicates which corner to spawn the undead.
					when 1 # Top left
						cen_x = -60
						cen_y = -60
						unx = cen_x + rand(80) - 40
						uny = cen_y + rand(80) - 40
					when 2 # Top right
						cen_x = 60
						cen_y = -60
						unx = cen_x + rand(80) - 40
						uny = cen_y + rand(80) - 40
					when 3 # Bottom right
						cen_x = 60
						cen_y = 60
						unx = cen_x + rand(80) - 40
						uny = cen_y + rand(80) - 40
					when 4 # Bottom left
						cen_x = -60
						cen_y = 60
						unx = cen_x + rand(80) - 40
						uny = cen_y + rand(80) - 40
				end
				undead_x = $gen_x + 480 * (undead_rooms[i] % 6) + unx # Get the X coordinate for the undead
				undead_y = $gen_y - 480 * ((undead_rooms[i]/6 + 0.1).ceil - 1) + uny # Get the Y coordinate for the undead
				undead_coords.push(undead_x, undead_y, rand(360)) # Push the coords + a random direction into an array.
				# The array will have 3 indexes per undead.
			end
			
		end
		@server.broadcast_packet(undead_coords.join(' '), true, 23) # Send the entire array to each client
		
		for i in 0..undead_coords.length/3-1 
			create_undead(undead_coords[i*3], undead_coords[i*3+1], undead_coords[i*3+2], i) # Create the undead instances for the server.
		end
		
	end

	def send_torches
		@torchlights.clear
		for i in 0..143
			torch_chance = rand(100)
			if torch_chance < 12 # = % chance of placing a torch
				
				tile = (i/4+0.1).ceil # A number between 1..36, which specifies the tile
				tile_x = $gen_x+480*((tile-1) % 6) # The center coordinates of the given tile
				tile_y = $gen_y-(480*((tile-1)/6).ceil) # The center coordinates of the given tile
				
				n = i%4 # A number between 0..3, which specifies the corner in the room.
				
				torch_x = tile_x - 151 + 302*(n%2) # The coordinates of the torch **NOT THE LIGHT** 
				torch_y = tile_y - 151 + 302*((n+0.9)/2).floor # The coordinates of the torch **NOT THE LIGHT**
				torch_dir = 135 + 90 * (n - (((n+0.9)/2).floor*((n%2)*2-1))) # The direction of the torch
				
				@torchlights.push(torch_x) # Add the values to the array
				@torchlights.push(torch_y) # Add the values to the array
				@torchlights.push(torch_dir) # Add the values to the array
			end
		end
		@server.broadcast_packet(@torchlights.join(' '), true, 19)
	end

end

GameWindow.new.show
