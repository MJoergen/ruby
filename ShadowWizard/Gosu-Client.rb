# require gosu and renet libs!
require 'rubygems'
require 'gosu'
require 'renet'
require 'ashton'

require_relative 'TextClass.rb'
require_relative 'Player.rb'
require_relative 'Block.rb'
require_relative 'Crate.rb'
require_relative 'Spark.rb'
require_relative 'Particle.rb'
require_relative 'Light.rb'
require_relative 'Phantom.rb'
require_relative 'Portal.rb'
require_relative 'Undead.rb'
require_relative 'Glowstick.rb'

include Gosu

# define a new window class
class GameWindow < Gosu::Window
	
	WIDTH = 960
	HEIGHT = 600
	TITLE = "Gosu & ENet"
	
	attr_reader :playing, :my_id, :window_width, :window_height, :player_img, :player_x, 
	            :player_y, :block_img, :crate_img, :spark_array, :hood_array, 
				:particle_img, :staff_array, :player_dash_cd, :player_dash_cd_max, 
				:crate_tilearray, :light_array, :do_draw_lights, :phantom_array, :portal_array, :portal_edge, 
				:undead_array, :smallfont, :font, :blow_array, :cross_img, :glowstick_img, :glowstick_obj_img, :halberd_array
				
	
	def initialize
		
		super(960, 600, false)
		self.caption = TITLE
		
		# Load images
		@player_img = Gosu::Image.new(self, "media/player.png", true)
		@tile = Gosu::Image.new(self, "media/tile_big_update2.png", true)
		@door1 = Gosu::Image.new(self, "media/door1_big_update2.png", true)
		@door2 = Gosu::Image.new(self, "media/door2_big_update2.png", true)
		@box = Gosu::Image.new(self, "media/box_big.png", true)
		@torch = Gosu::Image.new(self, "media/torch.png", true)
		@point = Gosu::Image.new(self, "media/Point.png", true)
		@player_img = Gosu::Image.new(self, "media/player.png", true)
		@block_img = Gosu::Image.new(self, "media/block.png", true)
		@crate_img = Gosu::Image.new(self, "media/crate.png", true)
		@particle_img = Gosu::Image.new(self, "media/particle.png", true)
		@cross_img = Gosu::Image.new(self, "media/cross.png", true)
		@glowstick_img = Gosu::Image.new(self, "media/Glowstick/sticky.png", true)
		@glowstick_obj_img = Gosu::Image.new(self, "media/Glowstick/object.png", true)
		
		@crate_tilearray = Gosu::Image.load_tiles(self, "media/crate.png", -3, -3, true)
		
		@window_width = 960
		@window_height = 600
		
		@darkness = Ashton::WindowBuffer.new # be careful of @width and @height
		@do_draw_lights = 1
		@torchlights = []
		@flickerlights = []
		@torchcolor = 0xffEAA547
		@torchscale = 2.2
		@flickclock = @flickclockmax = 5
		
		@new_ms = Gosu::milliseconds
		@last_ms = @new_ms
		$time_diff_ms = 16
		
		$lights = []
		
		@light_array = Array.new(3)
		for i in 0..2 
			@light_array[i] = Gosu::Image.new(self, "media/Lighting/#{i}.png", false) 
		end
		
		@undead_array = Array.new(16)
		for i in 0..15 
			@undead_array[i] = Gosu::Image.new(self, "media/Undead/#{i}.png", true) 
		end
		
		@phantom_array = Array.new(7)
		for i in 0..6 
			@phantom_array[i] = Gosu::Image.new(self, "media/Phantom/#{i}.png", false) 
		end
		
		@portal_edge = Gosu::Image.new(self, "media/Portal/edge.png", false)
		@portal_array = Array.new(20)
		for i in 0..19 
			@portal_array[i] = Gosu::Image.new(self, "media/Portal/#{i}.png", false) 
		end
		
		@spark_array = Array.new(4)
		for i in 0..3 
			@spark_array[i] = Gosu::Image.new(self, "media/Spark/#{i}.png", false) 
		end
		
		@hood_array = Array.new(14)
		for i in 0..13 
			@hood_array[i] = Gosu::Image.new(self, "media/Player/#{i}.png", false) 
		end
		
		@blow_array = Array.new(20)
		for i in 0..19
			@blow_array[i] = Gosu::Image.new(self, "media/Blowkiss/#{i}.png", false) 
		end
		
		@staff_array = Array.new(14)
		for i in 0..13
			@staff_array[i] = Gosu::Image.new(self, "media/Staff/#{i}.png", false) 
		end
		
		@halberd_array = Array.new(18)
		for i in 0..17
			@halberd_array[i] = Gosu::Image.new(self, "media/Halberd/#{i}.png", false) 
		end
		
		# create a font to draw the information
		@smallfont = Gosu::Font.new(self, Gosu::default_font_name, 14)
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		@bigfont = Gosu::Font.new(self, Gosu::default_font_name, 18)
		@biggerfont = Gosu::Font.new(self, Gosu::default_font_name, 20)
		@biggestfont = Gosu::Font.new(self, Gosu::default_font_name, 54)
		
		# Handle various stuff
		@width = WIDTH
		@height = HEIGHT
		@address_menu = true
		@writing = false
		@my_id = "undefined"
		@connecting_in_progress = false
		@connecting_timer = 0
		@room_num = nil
		@room_data = []
		@playing = false
		@gen_x = 240
		@gen_y = 480
		@spawn_tile = 1
		@view_x = 320
		@view_y = 240
		@player_x, @player_y = 160, 320
		@counter = 0
		@counting = false
		@crate_count = 0
		@tim = Time.now
		@anti_mega_lag_compensator = false
		
		$player_alive = true # This array is used to monitor if the player is alive, 
		# and is used to make sure the player doesn't spam the server when it's dead!
		
		# The following arrays contain various instances in the game. I've seperated them into differen arrays because it makes collision-detection easier!
		$players = [] # This array will contain all 3 player-instances , typically used for collision and updating
		$blocks = []
		$crates = []
		$particles = []
		$portals = []
		$sparks = []
		$undeads = []
		$glowsticks = []
		
		@player_x_array = [@gen_x, @gen_x, @gen_x]
		@player_y_array = [@gen_y, @gen_y, @gen_y]
		@players_online = [0, 0, 0]
		@players_ingame = [0, 0, 0]
		@players_alive = [0, 0, 0]

		# Textfields
		@text_field = TextField.new(self, @biggerfont, @window_width/2-65, @window_height/2-30)
		self.text_input = @text_field
		self.text_input.text = File.open('default_ip.txt', 'rb') { |f| f.read }
		self.text_input.move_caret(0) unless self.text_input.nil?
		
		# an array to store the incoming packets
		@packets = []
		
	end
	
	def draw_bar(x1, y1, x2, y2, z, value, color1, color2, color3, border)
		# Value is supposed to be between 0..1
		# This function is made to draw a type of health-bar
		self.draw_quad(x1,y1,color1,x1+(x2-x1)*value,y1,color1,x1,y2,color1,x1+(x2-x1)*value,y2,color1,z+0.2)
		self.draw_quad(x1,y1,color2,x2,y1,color2,x1,y2,color2,x2,y2,color2,z+0.1)
		if border == true
			self.draw_quad(x1-2,y1-2,color3,x2+2,y1-2,color3,x1-2,y2+2,color3,x2+2,y2+2,color3,z)
		end
    end
	
	def begin_connecting
		@socket.connect(2000)
		if @socket.online? != true
			self.on_packet("Failed to connect to IP: #{@connection_ip}", 4)
		end
		@connecting_in_progress = false
		@connecting_timer = 0
	end
	
	def crate(x, y)
		@crate = Crate.new(self, x, y)
		return @crate
	end
	
	def create_undead(x, y, angle, id)
		$undeads.push(Undead.new(self, x, y, angle, id))
	end
	
	def set_player_array(id, x, y)
		@player_x_array[id] = x
		@player_y_array[id] = y
	end

	def update
		
		if @counting == true
			@counter = [0, @counter-1].max
			if @counter == 0
				@counting = false
				self.send_pack("", true, 13)
			end
		end
		
		if @playing == true

			$players.each { |p| p.update }
			$undeads.each { |u| u.update(@player_x_array, @player_y_array, @players_online, @players_alive) }
			
			@last_ms = @new_ms
			@new_ms = Gosu::milliseconds
			$time_diff_ms = @new_ms - @last_ms
			
			if @anti_mega_lag_compensator == true # This is not even worth trying to understand...
				$time_diff_ms = 16 # Actually it's there to compensate for the amount of lag that happends at the start of a game
				@anti_mega_lag_compensator = false # Which made everything go super fast the first "tick"!
			end
			
			if !@flickerlights.empty?
				@flickclock = [0, @flickclock-1].max
				
				if @flickclock == 0
					@flickerlights.each { |flick| 
						blue = @torchcolor%256
						green = (@torchcolor/256)%256
						red = (@torchcolor/65536)%256
						alpha = (@torchcolor/16777216)%256
						
						
						flick.set_color(alpha*16777216 +
                                        [[red-15+rand(30), 0].max, 255].min*65536 +
                                        [[green-15+rand(30), 0].max, 255].min*256 +
                                        [[blue-15+rand(30), 0].max, 255].min)
						
						scale_rand = rand(12)
						flick.set_scale(@torchscale - 0.06 + scale_rand.to_f/130)
					}
					@flickclock = @flickclockmax
				end
			end
			
			# @player_x and @player_y are used to position the camera
			@player_x , @player_y = $players[@my_id.to_i].x, $players[@my_id.to_i].y # Update your own player_x and player_y
			
		end
		
		# Uhh yeah this was necessarily ineffective....
		@connecting_timer = [0, @connecting_timer-1].max
		if @connecting_timer == 0 and @connecting_in_progress == true
			self.begin_connecting
		end
		
		# send queued packets and receive incoming ones (0 = non-blocking)
		if @socket
			@socket.update(0)
		end
		
		# show our client FPS
		self.caption = "Gosu & ENet Test  -  [FPS: #{Gosu::fps.to_s}]"
		
		# Well leave this for now...
		$particles.each  { |inst|  inst.update }
		$portals.each    { |inst|  inst.update }
		$sparks.each     { |inst|  inst.update }
		#$undeads.each    { |inst|  inst.update }
		$glowsticks.each { |inst|  inst.update }
	end
	
	def update_playerlight(player, x, y)
		case player
			when 0
				@light_0.set_coords(x, y)
			when 1
				@light_1.set_coords(x, y)
			when 2
				@light_2.set_coords(x, y)
		end
	end
	
	def create_connection(ip)
		# create a new connection object (remote host address, remote host port, channels, download bandwidth, upload bandwidth)
		@socket = ENet::Connection.new("#{ip}", 8000, 33, 0, 0)
		# set the handler for the packets
		@socket.on_packet_receive(method(:on_packet))
		if ip == ""
			@connection_ip = "localhost"
		else
			@connection_ip = ip
		end
	end
    
	def d_connect
		if @socket.online? == true
			@socket.disconnect(2000)
			self.on_packet("You've disconnected from the server", 4)
		end
	end
	
	def send_pack(data, reliable, channel)
		if @socket.online? == true
			@socket.send_packet(data, reliable, channel)
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbQ
				if @address_menu == false and @playing == true and $players[@my_id.to_i].do_action == false
					 
					self.send_pack("#{@my_id} 1", true, 17) # The string: "ID Q?" 
					$players[@my_id.to_i].change_weapon(@my_id.to_i, 1)
					
				end
			when Gosu::KbL
				if @playing == true
					@do_draw_lights = 1 - @do_draw_lights
				end
			when Gosu::KbT  #### TESTING PURPOSES!
				if @playing == true
					p @player_x_array
				end
			when Gosu::KbE
				if @address_menu == false and @playing == true and $players[@my_id.to_i].do_action == false
					
					self.send_pack("#{@my_id} 0", true, 17) # The string: "ID Q?" 
					$players[@my_id.to_i].change_weapon(@my_id.to_i, 0)
					
				end
			when Gosu::KbZ
				if @address_menu == false and @playing == true					
					
					$players[@my_id.to_i].button_z
					
				end
			when Gosu::KbC
				if @address_menu == false
					if @playing == true
						
						$players[@my_id.to_i].button_c
						
					end
					
					if @writing == false and @socket.online? == false
						# only connects if we are not already connected
						@connecting_in_progress = true
						@connecting_timer = 2
					end
					
				end
			when Gosu::KbP
				if @writing == false and @playing == false
					t1 = Time.now.to_f
					self.send_pack("#{t1}", true, 0)
				end
			when Gosu::KbEscape
				# close the window
				if @address_menu == false
					self.d_connect
				end
				close
			when Gosu::KbReturn
				# Address Menu
				if @address_menu == true
					# Address Menu
					self.create_connection(self.text_input.text)
					File.write('default_ip.txt', self.text_input.text)
					self.text_input.text = ""
					self.text_input = nil
					@text_field.update_stuff(@font, 10, @window_height-180)
					@address_menu = false
				else
					# Chat Menu
					if @playing == false
						if @writing == false
							@writing = true
							self.text_input = @text_field
							self.text_input.text = ""
							self.text_input.move_caret(0) unless self.text_input.nil?
						else
							if self.text_input.text != ""
								self.send_pack(self.text_input.text, true, 2)
                                self.text_input.text = ""
                                self.text_input = nil
							end
							@writing = false
						end
					end
				end
			when Gosu::KbD
				if @writing == false and @playing == false
					# Disconnect
					self.d_connect
					@my_id = "undefined"
				end
		end
	end
	
	def draw_background
		draw_quad(
		0,     0,      TOP_COLOR,
		@window_width, 0,      TOP_COLOR,
		0,     @window_height, BOTTOM_COLOR,
		@window_width, @window_height, BOTTOM_COLOR,
		0)
	end
	
	def point_in_rectangle(point_x, point_y, first_x, first_y, second_x, second_y)
		if point_x.between?(first_x, second_x) and point_y.between?(first_y, second_y)
			return true
		end
	end

	def draw
		
		@darkness.clear # Draws the canvas all black. (Can be changed by drawing manually)
		@darkness.render do
			$lights.each { |light| light.draw }
		end
		
		if @address_menu == false
			
			if @playing == true

				$players.each { |p| p.draw }
				
				# Draw all instances
                $blocks.each     { |inst|  inst.draw }
                $crates.each     { |inst|  inst.draw }
                $particles.each  { |inst|  inst.draw }
                $portals.each    { |inst|  inst.draw }
                $sparks.each     { |inst|  inst.draw }
                $undeads.each    { |inst|  inst.draw }
				# $glowsticks.each { |inst|  inst.draw }
				
				if !@room_data.empty?
					
					@room_data.each_index do  |i|
						
                        tile_x = @gen_x+480*(i % 6) + @window_width/2-@player_x
                        tile_y = @gen_y-(480*(i/6).ceil) + @window_height/2-@player_y
                        if point_in_rectangle(tile_x, tile_y, -480, -480, @window_width+480, @window_height+480) # optimization
                            @tile.draw_rot(tile_x, tile_y, 2, 0)
                        end
						
						if !@torchlights.empty?
                            for n in 0..@torchlights.length/3-1
                                torch_x = @torchlights[n*3] + @window_width/2-@player_x
                                torch_y = @torchlights[n*3+1] + @window_height/2-@player_y
                                if point_in_rectangle(torch_x, torch_y, -480, -480, @window_width+480, @window_height+480) # optimization
                                    @torch.draw_rot( torch_x, torch_y, 3.1, @torchlights[n*3+2]-135, 0, 0)
                                end
                            end
						end
						
						case @room_data[i][1]
							when 1
                                door_x = @gen_x+480*(i % 6)+@window_width/2-@player_x
                                door_y = @gen_y-(480*(i/6).ceil)-240+@window_height/2-@player_y
                                if point_in_rectangle(door_x, door_y, -480, -480, @window_width+480, @window_height+480) # optimization
                                    @door1.draw_rot( door_x, door_y, 3, 0)
                                end
						end
						case @room_data[i][2]
							when 1
                                door_x = @gen_x+480*(i % 6)+240+@window_width/2-@player_x
                                door_y = @gen_y-(480*(i/6).ceil)+@window_height/2-@player_y
                                if point_in_rectangle(door_x, door_y, -480, -480, @window_width+480, @window_height+480) # optimization
                                    @door2.draw_rot( door_x, door_y, 3, 0)
                                end
						end
						
					end
				
                    @biggestfont.draw("S", 
                    @gen_x+480*((@spawn_tile-1) % 6)-15+@window_width/2-@player_x, 
                    @gen_y-480*((@spawn_tile-1) / 6).ceil-21+@window_height/2-@player_y, 
                    4, 1.0, 1.0, 0xFF686868)
                    
                    @boxes.each_index do |i|
                        box_x = @gen_x+480*((@boxes[i]) % 6)+@window_width/2-@player_x
                        box_y = @gen_y-(480*((@boxes[i])/6).ceil)+@window_height/2-@player_y
                        if point_in_rectangle(box_x, box_y, -480, -480, @window_width+480, @window_height+480) # optimization
                            @box.draw_rot( box_x, box_y, 4, 0)
                        end
                    end
				
				end

			else
				
				# show if we are connected to the server or not (@socket.connected? is valid too)
				if @connecting_in_progress == true
					@font.draw("[CONNECTING...]", 10, 10, 0, 1.0, 1.0, 0xffffff00)
				else
					@font.draw("Connected: #{@socket.online?}", 10, 10, 0, 1.0, 1.0, 0xffffff00)
				end
				
				# Draw your own ID:
				@font.draw("ID: #{@my_id}", 200, 10, 0, 1.0, 1.0, 0xffffff00)
				
				# show the controls
				if @socket.online? == false
					@font.draw("Press C to connect", 10, @window_height-118, 0, 1.0, 1.0, 0xffffff00)
				else
					@font.draw("Press D to disconnect", 10, @window_height-118, 0, 1.0, 1.0, 0xffffff00)
				end
				
				@font.draw("Press ENTER to send a message", 10, @window_height-96, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("Type '<start' to start the game", 10, @window_height-74, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("Press P to check latency", 10, @window_height-52, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("* this estimates the time it takes the data to reach the server, and back again", 10, @window_height-30, 0, 1.0, 1.0, 0xffffff00)
					
				# Show the socket information
				@font.draw("Packets Sent: #{@socket.total_sent_packets}", @window_width-190, @window_height-100, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("Packets Recv: #{@socket.total_received_packets}", @window_width-190, @window_height-80, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("Bytes Sent: #{@socket.total_sent_data}", @window_width-190, @window_height-60, 0, 1.0, 1.0, 0xffffff00)
				@font.draw("Bytes Recv: #{@socket.total_received_data}", @window_width-190, @window_height-40, 0, 1.0, 1.0, 0xffffff00)
				
				# show the storaged packets
				if !@packets.empty?
					@packets.each_index do |i|
                        msg = @packets[i][0].chomp("\u0000").chomp("\u0000")
						case @packets[i][1]
							when 0
								@font.draw("Ping*: #{msg}", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
							when 1
								@font.draw("ID #{msg}", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
							when 2
								@font.draw("Message - #{msg}", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
							when 3
								@font.draw("You've connected to the server", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
							when 4
								@font.draw("#{msg}", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
							when 5
								@font.draw("ID #{msg} has connected", 10, 10+24*(i+1), 0, 1.0, 1.0, @packets[i][2])
						end
					end
				end
			end
		else
			# Draw the address menu text
			@bigfont.draw("Input Server Address with port 8000*", @window_width/2-120, @window_height/2-65, 0, 1.0, 1.0, 0xffffff00)
			@bigfont.draw("Press ENTER to continue", @window_width/2-85, @window_height/2+5, 0, 1.0, 1.0, 0xffffff00)
			@font.draw("*leave blank to join localhost", @window_width/2-85, @window_height/2+160, 0, 1.0, 1.0, 0xffffff00)
		end
		
		# Draw textfield...
		if @writing == true or @address_menu == true
			@text_field.draw
		end
		
		if @address_menu == false and @playing == true
			
			if @do_draw_lights == 1
				@darkness.draw(0, 0, 10, :mode=>:multiply) # The actual "lighting-mask"
			end
			
			# THE COLOR OF THE LIGHTS WILL ONLY MATCH THE COLOR OF THE DRAWN OBJECT THAT HAS THE HIGHEST Z VALUE!!!!!
			# And the z value has to be lower than the darkness z value
			
			@font.draw("Playing: #{@playing}", @window_width-120, 30, 11, 1.0, 1.0, 0xffff0000)
			@font.draw("room_num: #{@room_num}", @window_width-120, 50, 11, 1.0, 1.0, 0xffff0000)
			
			$glowsticks.each { |inst|  inst.draw } # Glowsticks are not affected by lighting
			
		end
		
		# ESC
		@font.draw("Press Esc to quit", @window_width-120, 10, 11, 1.0, 1.0, 0xffff0000)
		
		
		
		
	end
	
	def start_room(room)
		
		@room_data.clear
		@room_num = room
		
		case @room_num
			when "0"
				File.open('room0data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
			when "1"
				File.open('room1data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
			when "2"
				File.open('room2data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
		end
		
		$players[0] = Player.new(self, 220, 480, 0, 0xFF6464FF) # 0xFF6464FF
		@light_0 = Light.new(self, @window_width/2, @window_height/2, 2.5, 0xffeeeeee, 1, true)
		$lights.push(@light_0)
		
		$players[1] = Player.new(self, 260, 460, 1, 0xFF41CC41)
		@light_1 = Light.new(self, @window_width/2, @window_height/2, 2.5, 0xffeeeeee, 1, true)
		$lights.push(@light_1)
		
		$players[2] = Player.new(self, 260, 500, 2, 0xFFFF6464)
		@light_2 = Light.new(self, @window_width/2, @window_height/2, 2.5, 0xffeeeeee, 1, true)
		$lights.push(@light_2)
		
		@anti_mega_lag_compensator = true
		
		@players_ingame[0] = @players_online[0]
		@players_ingame[1] = @players_online[1]
		@players_ingame[2] = @players_online[2]
		@players_alive = [1, 1, 1]
		
		self.create_room
		@playing = true
		
	end
	
	def create_light(x, y, scale, color, blur, follow_camera)
		light = Light.new(self, x, y, scale, color, blur, follow_camera)
		$lights.push(light)
		return light
	end
	
	def create_portals(tiles)
		for i in 0..3
			
			# i = 0, means the portal is in the bottom 
			# i = 1, means the portal is in the top
			# i = 2, means the portal is to the left
			# i = 3, means the portal is to the right
			
			room_edge_x = 130 * (((i%2)*2-1) * (i/2).floor)
			room_edge_y = 130 * ((1 - (i%2))*2 - 1) * (1 - i/2).floor
			
			temp1 = 480 * 5 * (i/3).floor # The right-most portal (otherwise = 0)
			temp2 = 480 * 5 * (1-((i+1)/3).floor) * (i%2) # The top-most portal (otherwise = 0)
			
			x = @gen_x + 480 * (tiles[i]-1) * (1-(i/2).floor) + room_edge_x + temp1
			y = @gen_y - 480 * (tiles[i]-1) * (i/2).floor + room_edge_y - temp2
			
			portal = Portal.new(self, x, y, 0xff7575ff, 90 - 90*(i/2).floor, i)
			$portals[i] = portal
		end
	end
	
	def create_room
		
		# Each one of the four edges on the map
		create_block(  @gen_x-330, @gen_y-480*5-330,  180, 3060) # Right - relative to tile 30
		create_block(  @gen_x-330, @gen_y-480*5-330,  3060, 180) # Top - relative to tile 30
		create_block(  @gen_x+480*5+150, @gen_y-480*5-330,  180, 3060) # Left - relative to tile 35
		create_block(  @gen_x-330, @gen_y+150,  3060, 180) # Bottom - relative to tile 0
		
		# Check each and every room, and create "phantom walls"
		@room_data.each_index do  |i|
			
			room_center_x = @gen_x+480*((@room_data[i][0]-1) % 6)
			room_center_y = @gen_y-(480*((@room_data[i][0]-1)/6).ceil)
			
			if @room_data[i][0].between?(31, 36) and @room_data[i][2] == 1 # Top row of rooms
				create_block(room_center_x+150, room_center_y-150, 180, 75)
			end
			
			if (@room_data[i][0]-1) % 6 == 0 and @room_data[i][1] == 1 # Left row of rooms
				create_block(room_center_x-150, room_center_y-330, 75, 180)
			end
			
			if @room_data[i][1] == 1 # Top doorway
				create_block(  room_center_x+75, room_center_y-330, 330, 180) # Right doorway block
			else
				create_block(  room_center_x-150, room_center_y-330, 555, 180) # Top wall
			end
			
			if @room_data[i][2] == 1 # Right doorway
				create_block(  room_center_x+150, room_center_y+75, 180, 330) # Bottom doorway block
			else
				create_block(  room_center_x+150, room_center_y-150, 180, 555) # Right wall
			end
		end
		
	end
	
	def create_block(x, y, width, height)
		$blocks.push(Block.new(self, x, y, width, height))
	end
	
	def create_crates(crate_count)
		bx = @gen_x + 480*(@boxes[crate_count-1] % 6)
		by = @gen_y - 480*(@boxes[crate_count-1] / 6).ceil
		for i in 0..@crates.length/2-1
			$crates.push(crate(bx+@crates[i*2], by+@crates[i*2+1]))
		end
	end
	
	def create_torches
		if !@torchlights.empty?
			for i in 0..@torchlights.length/3-1
				@flickerlights[i] = self.create_light(@torchlights[i*3] + Gosu::offset_x(@torchlights[i*3+2], 13), @torchlights[i*3+1] + Gosu::offset_y(@torchlights[i*3+2], 13), @torchscale, @torchcolor, 2, false)
			end
		end
	end
	
	def manage_players # This was also necessary for some reason...
		
		if @players_online[0] == 1
			$players[0].create
		else
			$players[0].remove
			$lights.delete(@light_0)
		end
		if @players_online[1] == 1
			$players[1].create
		else
			$players[1].remove
			$lights.delete(@light_1)
		end
		if @players_online[2] == 1
			$players[2].create
		else
			$players[2].remove
			$lights.delete(@light_2)
		end
	end
	
	def destroy_light(light)
		$lights.delete(light)
	end
	
	def crateCheckCollisionWeapon(x, y, collision_radius, angle1, angle2, type)
        $crates.each_with_index { |inst, i|
            if inst.checkCollisionWeapon(x, y, collision_radius, angle1, angle2, type)
                $crates[i] = nil
            end
        }
		$crates.delete(nil)
	end
	
	def portalCheckCollision(x, y, r, meth)
        $portals.each { |inst|
            if inst.checkCollision(x, y, r)
                meth.call(inst)
            end
        }
	end
	
	def blockCheckCollision(x, y, r, meth)
        $blocks.each { |inst|
            if inst.checkCollision(x, y, r)
                meth.call(inst)
            end
        }
	end
	
	def crateCheckCollision(x, y, r, meth)
        $crates.each { |inst|
            if inst.checkCollision(x, y, r)
                meth.call(inst)
            end
        }
	end
	
	def undeadCheckCollision(x, y, r, id, meth)
        $undeads.each { |inst|
            if inst.checkCollision(x, y, r, id)
                meth.call(inst)
            end
        }
	end
	
	def inst_coord_x(id)
		return $portals[id].x
	end
	
	def inst_coord_y(id)
		return $portals[id].y
	end
	
	def portal_color(id)
		return $portals[id].color
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
	
	# define a custom handler to manage the packets
	def on_packet(data, channel)
		
		if channel < 6 # These channels are reserved for text messages
			
			# delete the old packets if we get more than 10
			@packets.slice!(0) if @packets.size >= 11
			
			if channel == 0
				t2 = Time.now.to_f
				@delta_t = t2 - data.to_f
				@delta_t = @delta_t * 1000
				puts "ms: #{@delta_t.round(3)}"
				steps = (@delta_t / 16.667).round
				puts "steps: #{steps}"
				data = "#{@delta_t.to_i} ms , #{(@delta_t / 16.667).round} tick(s)"
			end
			
			if channel == 3
				if data == @my_id
					# Send "You've connected to the server"
					@packets << [data, 3, Gosu::Color.argb(255, rand(100)+155, rand(100)+155, rand(100)+155)]
				else
					# Send at channel 5
					@packets << [data, 5, Gosu::Color.argb(255, rand(100)+155, rand(100)+155, rand(100)+155)]
				end
			else
				# Send at channel
				@packets << [data, channel, Gosu::Color.argb(255, rand(100)+155, rand(100)+155, rand(100)+155)]
			end
		else # The rest is actual data
			case channel
				when 6
					@my_id = data.chomp("\u0000")
			
				when 7
					self.start_room(data.chomp("\u0000"))
					puts 'Room Starting...'

				when 8
					@boxes = data.split.map(&:to_i)

				when 9
					if @playing == true
						@players_online = data.split.map(&:to_i)
						self.manage_players
					end

				when 10
					if @my_id != "0" and @playing == true
						@pack = data.split.map(&:to_f)
						if @pack[0] == 1
							$players[0].accelerate
						end
						if @pack[1] > 0
							$players[0].turn_right(@pack[1])
						end
						if @pack[2] == 1
							$players[0].decelerate
						end
						if @pack[3] > 0
							$players[0].turn_left(@pack[3])
						end
					end

				when 11
					if @my_id != "1" and @playing == true
						@pack = data.split.map(&:to_f)
						if @pack[0] == 1
							$players[1].accelerate
						end
						if @pack[1] > 0
							$players[1].turn_right(@pack[1])
						end
						if @pack[2] == 1
							$players[1].decelerate
						end
						if @pack[3] > 0
							$players[1].turn_left(@pack[3])
						end
					end

				when 12
					if @my_id != "2" and @playing == true
						@pack = data.split.map(&:to_f)
						if @pack[0] == 1
							$players[2].accelerate
						end
						if @pack[1] > 0
							$players[2].turn_right(@pack[1])
						end
						if @pack[2] == 1
							$players[2].decelerate
						end
						if @pack[3] > 0
							$players[2].turn_left(@pack[3])
						end
					end

				when 13
					@counter = 30
					@counting = true

				when 14
					@crate_count += 1
					@crates = data.split.map(&:to_i)
					create_crates(@crate_count)

				when 15
					@coords = data.split.map(&:to_f)
					if @my_id.to_i != @coords[0] and @playing == true
						
						case @coords[0]
							when 0
								$players[0].warp(@coords[1], @coords[2], @coords[3], @coords[4], @coords[5])
							when 1
								$players[1].warp(@coords[1], @coords[2], @coords[3], @coords[4], @coords[5])
							when 2
								$players[2].warp(@coords[1], @coords[2], @coords[3], @coords[4], @coords[5])
						end
						
						# coords --- ID --------- X ---------- Y -------- ANGLE ----- VEL_X ----- VEL_Y

					end	

				when 16
					@dash = data.split.map(&:to_i)
					if @my_id.to_i != @dash[0] and @playing == true
						$players[0].dash(@dash[0], @dash[1])
						$players[1].dash(@dash[0], @dash[1])
						$players[2].dash(@dash[0], @dash[1])
					end

				when 17
					temp = data.split.map(&:to_i)
					if @my_id.to_i != temp[0] and @playing == true
						$players[0].change_weapon(temp[0], temp[1])
						$players[1].change_weapon(temp[0], temp[1])
						$players[2].change_weapon(temp[0], temp[1])
					end

				when 18 # Attack / use item
					temp = data.split.map(&:to_i)
					if @my_id.to_i != temp[0] and @playing == true
						$players[0].action(temp[0])
						$players[1].action(temp[0])
						$players[2].action(temp[0])
					end

				when 19 # Create torches
					@torchlights = data.split.map(&:to_i)
					self.create_torches

				when 20 # Update phantom coords
					if @playing == true
						temp = data.split.map(&:to_f)
						if @phantom != nil
							@phantom.set_coords(temp[0], temp[1])
						end
					end

				when 21 # Create portals
					temp = data.split.map(&:to_i)
					self.create_portals(temp)

				when 22 # Portal teleport
					temp = data.split.map(&:to_i)
					if @my_id.to_i != temp[1] and @playing == true
						$players[0].teleport(temp[0], temp[1])
						$players[1].teleport(temp[0], temp[1])
						$players[2].teleport(temp[0], temp[1])
					end

				when 23 # Create undead
					temp = data.split.map(&:to_i)
					for i in 0..temp.length/3-1
						create_undead(temp[i*3], temp[i*3+1], temp[i*3+2], i)
					end

				when 24 # Move undead target pos
					temp = data.split.map(&:to_i)
					$undeads.each { |u| u.update_target_pos(temp[0], temp[1], temp[2], temp[3], temp[4]) }

				when 25 # Crate destroyed by other client
					temp = data.split
					if temp[2] != @my_id
                        $crates.each_with_index { |inst, i|
							if inst.destroy_at_position(temp[0], temp[1])
                                $crates[i] = nil
                            end
                        }
                        $crates.delete(nil)
					end
				when 26 # Update undead coords
					temp = data.split.map(&:to_i)
					$undeads.each { |u| u.update_coords(temp[0], temp[1], temp[2], temp[3], temp[4]) }
				when 27 # Make the undead attack (for some reason this is checked server-side)
					id = data.to_i
					$undeads.each { |u| u.animate_attack(id) }
				when 28 # Make the undead take damage
					temp = data.split
					if @my_id != temp[0]
						$undeads.each { |u| u.take_damage(temp[1].to_i, temp[2].to_i) }
					end
				when 29
					temp = data.split
					if @my_id != temp[0]
						$players.each { |p| p.take_damage(temp[1].to_i, temp[2].to_i) }
					end
				when 31
					temp = data.split
					if @my_id != temp[0]
						$players.each { |p| p.change_glowstickcolor(temp[1].to_i, temp[2].to_i, temp[3].to_i, temp[4].to_i, temp[5].to_i) }
					end
				when 32
					temp = data.split
					$undeads.each { |u| u.set_player_target(temp[0].to_i, temp[1])} 
					
			end
		end
	end
end

# show the window
window = GameWindow.new
window.show
