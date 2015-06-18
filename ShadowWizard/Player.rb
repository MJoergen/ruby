class Player

	attr_reader :x, :y, :exist, :do_action, :dead

	def initialize(window, x, y, id, color)
		@window = window
		@x = x
		@y = y
		@colorr = color
		@exist = false
		@angle = 0
		@a_speed = 0.21
		@vel_x = 0
		@vel_y = 0
		@collision_radius = 14
		@id = id
		
		@update_pos_timer = @update_pos_timer_max = 5
		@portal_jump_timer = 12
		
		@spark_timer = 0
		@spark_timer_max = 3
		@spark_amount = 0
		
		@index = 3
		
		@leftie = false
		@rightie = false
		@hood_off_timer = 0
		@hood_delay = false
		@hood_twitch_timer = 4
		@hood_dir = 1
		@hood_twitch = false
		
		@weapon_slot = 0 # This number represents the actual ID of the weapon. Eg 0 = nothing, 1 = stick, 2 = rod, 3 = wand, and so on...
		@weapon_array_num = 0 # This number provides the position of the weapon ID in the @weapon_array
		@weapon_array = [0, 1, 2, 3] # This array contains all the available weapons for each individual player.
		
		@glowstick_colour = self.generate_random_color
		
		if @window.my_id == @id.to_s
			data = [@window.my_id, @id, (@glowstick_colour/16777216)%256, (@glowstick_colour/65536)%256, (@glowstick_colour/256)%256, @glowstick_colour%256]
			@window.send_pack(data.join(' '), true, 31)
		end
		
		## Weapons ---- vvvv ----
		
		@staff_index = 0
		@staff_change_img = false
		@staff_timer = 0
		@staff_timer_max = 5
		
		@blow_index = 0
		@blow_change_img = false
		@blow_timer = 0
		@blow_timer_max = 5
		
		@halberd_index = 0
		@halberd_change_img = false
		@halberd_timer = 0
		@halberd_timer_max = 5
		
		## ---------------------
		
		@do_action = false
		@action_toggle = 0
		
		@dash_speed = 2
		@dash_dir_left = 0
		@dash_cd = 0
		@dash_cd_max = 60
		
		@maxhealth = 100
		@health = @maxhealth
		@dead = false
		
		@taking_damage = false
		@taking_damage_timer = 0
	end
	
	def generate_random_color
		
		side = rand(6) # A number thats either 0, 1, 2, 3, 4 or 5
		
		color = 0xffffffff
		
		blue = color%256
		green = (color/256)%256
		red = (color/65536)%256
		alpha = (color/16777216)%256
		
		case side
			when 0
				temp_color = alpha*16777216 + 255*65536 + [[102 + rand(255-102), 102].max, 255].min*256 + 102
			when 1
				temp_color = alpha*16777216 + [[102 + rand(255-102), 102].max, 255].min*65536 + 255*256 + 102
			when 2
				temp_color = alpha*16777216 + 102*65536 + 255*256 + [[102 + rand(255-102), 102].max, 255].min
			when 3
				temp_color = alpha*16777216 + 102*65536 + [[102 + rand(255-102), 102].max, 255].min*256 + 255
			when 4
				temp_color = alpha*16777216 + [[102 + rand(255-102), 102].max, 255].min*65536 + 102*256 + 255
			when 5
				temp_color = alpha*16777216 + 255*65536 + 102*256 + [[102 + rand(255-102), 102].max, 255].min
		end
		
		return temp_color
		
	end
	
	def change_glowstickcolor(id, alpha, red, green, blue)
		if @id == id
			@glowstick_colour = alpha*16777216 + red*65536 + green*256 + blue
		end
	end
	
	def create
		@exist = true
	end
	
	def remove
		@exist = false
	end
	
	def warp(x, y, angle, vel_x, vel_y)
		@x = x
		@y = y
		
		@angle = angle
		
		@vel_x = vel_x
		@vel_y = vel_y
	end
	
	def move
		
		@x = @x + @vel_x * $time_diff_ms*60/1000
		@x = [@x, 0].max
		@x = [@x, 2880].min
		
		@y = @y + @vel_y * $time_diff_ms*60/1000
		@y = [@y, @window.height-2880].max
		@y = [@y, 720].min
		
		@window.undeadCheckCollision( @x, @y, @collision_radius, nil, method(:collision_undead)) # Undead
		@window.blockCheckCollision( @x, @y, @collision_radius, method(:collision_block)) # Block
		@window.crateCheckCollision( @x, @y, @collision_radius, method(:collision_block)) # Crate
		@window.portalCheckCollision( @x, @y, @collision_radius, method(:collision_portal)) # Portal
		
		@vel_x -= 0.08 * @vel_x * $time_diff_ms*60/1000
		@vel_y -= 0.08 * @vel_y * $time_diff_ms*60/1000
		
		@window.set_player_array(@id, @x.to_i, @y.to_i)
		
	end
	
	def spark(x, y, color)
		spark = Spark.new(@window, x, y, color)
		return spark
	end
	
	def particle(x, y, color, img, scale)
		temp = Particle.new(@window, x, y, color, img, scale)
		return temp
	end
	
	def glowstick(x, y, vel_x, vel_y, color, angle)
		temp = Glowstick.new(@window, x, y, vel_x, vel_y, color, angle)
		return temp
	end
	
	def dash(id, left)
		if id == @id # Only dash if its your ID provided.
			@spark_amount = 3
			@hood_off_timer = 11
			@spark_timer = @spark_timer_max
			$sparks.push(spark(@x, @y, @colorr))
			@dash_dir_left = left
			if @dash_dir_left == 1 # Dash Left
				@vel_x += Gosu::offset_x(@angle-90, @dash_speed)
				@vel_y += Gosu::offset_y(@angle-90, @dash_speed)
				@index = 6
			else # Dash Right
				@vel_x += Gosu::offset_x(@angle+90, @dash_speed)
				@vel_y += Gosu::offset_y(@angle+90, @dash_speed)
				@index = 0
			end
		end
	end
	
	def change_weapon(id, button_q)
		if id == @id # Only change weapon if its your ID provided.
			if button_q == 1
				@weapon_array_num = [0, @weapon_array_num-1].max
				@weapon_slot = @weapon_array[@weapon_array_num]
			else
				@weapon_array_num = [@weapon_array.length-1, @weapon_array_num+1].min
				@weapon_slot = @weapon_array[@weapon_array_num]
			end
		end
	end
	
	def action(id)
		if id == @id
			case @weapon_slot
				when 0
					if @do_action == false
						@do_action = true
						@blow_change_img = true
						@blow_timer = @blow_timer_max
					end
				when 1
					if @do_action == false
						@do_action = true
						@staff_change_img = true
						@staff_timer = @staff_timer_max
					end
				when 2
					if @action_toggle == 0 and @do_action == false
						
						randy = rand(20) 
						vx = Gosu::offset_x(@angle, 8.6 + randy.to_f/10)
						vy = Gosu::offset_y(@angle, 8.6 + randy.to_f/10)
						
						$glowsticks.push(glowstick(@x, @y, vx, vy, @glowstick_colour, @angle-90))
						
						if @window.my_id == @id.to_s
							@glowstick_colour = self.generate_random_color # Generate a new random color
							data = [@window.my_id, @id, (@glowstick_colour/16777216)%256, (@glowstick_colour/65536)%256, (@glowstick_colour/256)%256, @glowstick_colour%256]
							@window.send_pack(data.join(' '), true, 31)
						end
						
					end
				when 3
					if @do_action == false
						@do_action = true
						@halberd_change_img = true
						@halberd_timer = @halberd_timer_max
					end
			end
		end
	end
	
	def checkCollisionUndeadAttack(ux, uy, x, y)
		if Gosu::distance(@x, @y, x, y) < @collision_radius + 4 # Are you within attack range?
			
			# Knockback
			dir = point_direction(ux, uy, @x, @y)
			@vel_x += Gosu::offset_x(dir, 1)
			@vel_y += Gosu::offset_y(dir, 1)
			
			if @window.my_id == @id.to_s # Only the client-player shall take damage
				
				# Damage
				damage = 10
				
				# Run the actual take_damage method
				self.take_damage(@id, damage)
				
				# Send data
				data = [@window.my_id, @id, damage]
				@window.send_pack(data.join(' '), true, 29)
			end
		end
	end
	
	def take_damage(id, damage)
		if @id == id
			# Take damage
			@health = [0, @health-damage].max
					
			# Flash
			@taking_damage = true
			@taking_damage_timer = 5
		end
	end
	
	def update_light_pos
		if @window.my_id == @id.to_s
			@window.update_playerlight(@id, @window.width/2, @window.height/2)
		else
			@window.update_playerlight(@id, @x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y)
		end
	end
	
	def update
		if @exist == true
			if @window.playing == true and @window.my_id == @id.to_s
				@packet = [0, 0, 0, 0]
				
				if @window.button_down? Gosu::KbUp and @dead == false
					accelerate
					@packet[0] = 1
				end
				if @window.button_down? Gosu::KbRight and @dead == false
					turn_right(3.0*$time_diff_ms*60/1000)
					@packet[1] = 3.0*$time_diff_ms*60/1000
				end
				if @window.button_down? Gosu::KbDown and @dead == false
					decelerate
					@packet[2] = 1
				end
				if @window.button_down? Gosu::KbLeft and @dead == false
					turn_left(3.0*$time_diff_ms*60/1000)
					@packet[3] = 3.0*$time_diff_ms*60/1000
				end
				if @window.button_down? Gosu::KbW and @dead == false
					if @do_action == false
						
						@window.send_pack(@window.my_id, true, 18) # Sends: "Im attacking! And my ID is @my_id"
					end
					self.action(@id) # Attack with your own player
				end
				
				@window.send_pack(@packet.join(' '), true, 10+@id) # The player will update its keyboard input every frame
				
			end
			
			if @dead == false
				
				if @taking_damage == true
					@taking_damage_timer = @taking_damage_timer-1.0*$time_diff_ms*60/1000
					if @taking_damage_timer <= 0
						@taking_damage = false
					end
				end
				
				
				self.move
				self.update_light_pos
				
				@portal_jump_timer = [@portal_jump_timer - 1.0 * $time_diff_ms*60/1000, 0].max
				
				@dash_cd = [@dash_cd - 1.0 * $time_diff_ms*60/1000, 0].max
				
				if @window.playing == true and @window.my_id == @id.to_s
					
					@update_pos_timer = @update_pos_timer-1.0*$time_diff_ms*60/1000
					
					if @update_pos_timer <= 0 # Update position after moving!!
						@coords = [@id, @x.to_i, @y.to_i, @angle.to_i, @vel_x, @vel_y]
						@window.send_pack(@coords.join(' '), true, 15)
						@update_pos_timer += @update_pos_timer_max # The player will update its actual position and angle 3 times a second
						
						## Wait what?!?! 3 times a second is like nothing...
						##
						## Okay it's because the player position is already being updated by the "inputs" from the other client.
						## Search: @window.send_pack(@packet.join(' '), true, 10+@id)
						##
						## But wouldn't that fix the problem on its own?
					end
					
				end
				
				if @health <= 0
					
					@dead = true
					
					if @window.my_id == @id.to_s
						
						if $player_alive == true
							temp = [@id, "died"]
							@window.send_pack(temp.join(' '), true, 30) # Tell the server you just died
						end
						
						$player_alive = false
					end
				end
				
				if @do_action == true
					
					# Glowstick
					if @weapon_slot == 2
						@action_toggle = [0, @action_toggle-1].max
						if @action_toggle == 0
							@do_action = false
						end
					end
					
					# Blowkiss
					if @blow_change_img == true
						@blow_timer = @blow_timer-1.0*$time_diff_ms*60/1000
						if @blow_timer <= 0
							
							@blow_timer += @blow_timer_max
							@blow_index += 1
							
							# End the animation
							if @blow_index == 9
								@blow_timer = 0
								@blow_index = 0
								@do_action = false
								@blow_change_img = false
							end
							
						end
					end
					
					# Staff
					if @staff_change_img == true
						@staff_timer = @staff_timer-1.0*$time_diff_ms*60/1000
						if @staff_timer <= 0
							
							@staff_timer += @staff_timer_max
							@staff_index += 1
							
							# Attack
							if @staff_index == 3
								getx = Gosu::offset_x(@angle+60, 17.88) # This gets the point where the staff begins.
								gety = Gosu::offset_y(@angle+60, 17.88)
								angle_start = @angle-62
								angle_end = @angle+42
								# Crates
								if @window.my_id == @id.to_s
									@window.crateCheckCollisionWeapon(@x + getx, @y + gety, 40, angle_start, angle_end, "staff")
								end
								# Undeads
								$undeads.each { |u|  u.checkCollisionWeapon(@x + getx, @y + gety, 40, angle_start, angle_end, @id, "staff") }
							end
							
							# End the animation
							if @staff_index == 7
								@staff_timer = 0
								@staff_index = 0
								@do_action = false
								@staff_change_img = false
							end
						end
					end
					
					# Halberd
					if @halberd_change_img == true
						@halberd_timer = @halberd_timer-1.0*$time_diff_ms*60/1000
						if @halberd_timer <= 0
							
							@halberd_timer += @halberd_timer_max
							@halberd_index += 1
							
							# Attack
							if @halberd_index == 4
								getx = Gosu::offset_x(@angle+60, 17.88) # This gets the point where the halberd begins.
								gety = Gosu::offset_y(@angle+60, 17.88)
								angle_start = @angle-62
								angle_end = @angle+42
								# Crates
								if @window.my_id == @id.to_s
									@window.crateCheckCollisionWeapon(@x + getx, @y + gety, 65, angle_start, angle_end, "halberd")
								end
								# Undeads
								$undeads.each { |u|  u.checkCollisionWeapon(@x + getx, @y + gety, 65, angle_start, angle_end, @id, "halberd") }
								
							end
							
							# End the animation
							if @halberd_index == 9
								@halberd_timer = 0
								@halberd_index = 0
								@do_action = false
								@halberd_change_img = false
							end
						end
					end
					
				end
				
				if @hood_off_timer > 0 # Hoodie stuff :3
					@hood_off_timer = [0, @hood_off_timer-1].max
				else
					if @leftie == true and @rightie == false
						@index = [0, @index-1].max
					end
					if @rightie == true and @leftie == false
						@index = [6, @index+1].min
					end
					if @leftie == true and @rightie == true
						if @index > 3
							@index = [3, @index-1].max
						end
						if @index < 3
							@index = [3, @index+1].min
						end
					end
					if @leftie == false and @rightie == false
						
						if @hood_twitch == true
							
							@hood_twitch_timer = [0, @hood_twitch_timer-1].max
							
							if @hood_twitch_timer == 0
								
								@hood_twitch_timer = 4
								
								if @index < 2
									@hood_dir = 1
								end
								if @index > 4
									@hood_dir = 0
								end
								if @hood_dir == 1
									@index = [5, @index+1].min
								else
									@index = [1, @index-1].max
								end
							end
						else
							if @hood_delay == false
								if @index > 3
									@index = [3, @index-1].max
								end
								if @index < 3
									@index = [3, @index+1].min
								end
							else
								@hood_delay = false
							end
						end
					end	
				end
				
				if @spark_amount > 0
					@spark_timer = @spark_timer-1.0*$time_diff_ms*60/1000
					if @spark_timer <= 0
						@spark_timer += @spark_timer_max
						@spark_amount += -1
						$sparks.push(spark(@x, @y, @colorr))
						if @dash_dir_left == 1
							@vel_x += Gosu::offset_x(@angle-90, @dash_speed)
							@vel_y += Gosu::offset_y(@angle-90, @dash_speed)
						else
							@vel_x += Gosu::offset_x(@angle+90, @dash_speed)
							@vel_y += Gosu::offset_y(@angle+90, @dash_speed)
						end
					end
				end
				
				@leftie = false
				@rightie = false
				@hood_twitch = false
			end
		end
	end
	
	def button_z
		if @dash_cd == 0
			self.dash(@id, 1)
			@dash_cd = @dash_cd_max
			@window.send_pack("#{@id} 1", true, 16) # The string: "ID Left?"
		end
	end
	
	def button_c
		if @dash_cd == 0
			self.dash(@id, 0)
			@dash_cd = @dash_cd_max
			@window.send_pack("#{@id} 0", true, 16) # The string: "ID Left?"
		end
	end
	
	def accelerate
		@vel_x += Gosu::offset_x(@angle, @a_speed * $time_diff_ms*60/1000)
		@vel_y += Gosu::offset_y(@angle, @a_speed * $time_diff_ms*60/1000)
		@hood_twitch = true
		@hood_delay = true
	end
  
	def decelerate
		@vel_x += Gosu::offset_x(@angle, -@a_speed*0.6 * $time_diff_ms*60/1000)
		@vel_y += Gosu::offset_y(@angle, -@a_speed*0.6 * $time_diff_ms*60/1000)
	end
	
    def turn_left(amount)
		@angle -= amount
		@angle = @angle % 360
		@leftie = true
		@hood_delay = true
    end
  
    def turn_right(amount)
		@angle += amount
		@angle = @angle % 360
		@rightie = true
		@hood_delay = true
    end
	
	def collision_portal(inst)
		if @window.my_id == @id.to_s
			if @portal_jump_timer <= 0
				
				self.teleport(inst.id, @id)
				temp = [inst.id, @id]
				@window.send_pack(temp.join(' '), true, 22)
				
			end
			@portal_jump_timer = 12 # Set delay for the next teleport (this happens even without teleporting)
		end
	end
	
	def teleport(portalid, playerid)
		if playerid == @id
			
			color = @window.portal_color(portalid)
			
			blue = (color%256 / 2).round
			green = ((color/256)%256 / 2).round
			red = ((color/65536)%256 / 2).round
			alpha = (color/16777216)%256
			
			new_color = alpha*16777216 + [[red, 0].max, 255].min*65536 + [[green, 0].max, 255].min*256 + [[blue, 0].max, 255].min
			
			
			# teleport
			16.times do
				$particles.push(particle(@x - 15 + rand(30), @y - 15 + rand(30), new_color, @window.particle_img, 1.5))
			end
			case portalid
				when 0
					@x = @window.inst_coord_x(1) # change position
					@y = @window.inst_coord_y(1)
				when 1
					@x = @window.inst_coord_x(0)
					@y = @window.inst_coord_y(0)
				when 2
					@x = @window.inst_coord_x(3)
					@y = @window.inst_coord_y(3)
				when 3
					@x = @window.inst_coord_x(2)
					@y = @window.inst_coord_y(2)
			end
			
			16.times do
				$particles.push(particle(@x - 15 + rand(30), @y - 15 + rand(30), new_color, @window.particle_img, 1.5))
			end	
		end
	end
	
	def collision_block(inst)
		
		# All this code basically checks which side/corner you are colliding with
		
		if @x < inst.x # Are you to the left of the block?
			if @y < inst.y
				bounce_point(inst.x, inst.y) # uppper-left corner
			end
			if @y.between?(inst.y, inst.y + inst.height) 
				bounce_point(inst.x, @y) # left side
			end
			if @y > inst.y + inst.height
				bounce_point(inst.x, inst.y + inst.height) # lower-left corner
			end
		end
		if @x.between?(inst.x, inst.x + inst.width) # Are you directly above or below the block?
			if @y < inst.y
				bounce_point(@x, inst.y) # top side
			end
			if @y > inst.y + inst.height
				bounce_point(@x, inst.y + inst.height) # bottom side
			end
		end
		if @x > inst.x + inst.width # Are you to the right of the block?
			if @y < inst.y
				bounce_point(inst.x + inst.width, inst.y) # upper-right corner
			end
			if @y.between?(inst.y, inst.y + inst.height)
				bounce_point(inst.x + inst.width, @y) # right side
			end
			if @y > inst.y + inst.height
				bounce_point(inst.x + inst.width, inst.y + inst.height) # lower-right corner
			end
		end
	end
	
	def collision_undead(inst)
		bounce_point(inst.x, inst.y)
	end
	
	def bounce_point(bx, by)
		@move_angle = point_direction(bx, by, @x, @y)
		
		@dir_orb_pos1 = point_direction(bx, by, @x, @y)
		@dir_orb_pos2 = point_direction(bx, by, @x-@vel_x, @y-@vel_y)
		
		@angle_Comp_21p        = @window.get_dir_dif(@dir_orb_pos2, @dir_orb_pos1).abs
		@angle_player_orb_rad  = @angle_Comp_21p * Math::PI / 180
		
		@some_value = Gosu::distance(bx, by, @x-@vel_x, @y-@vel_y) * Math.cos(@angle_player_orb_rad)
		@move_speed = ( @some_value - Gosu::distance(bx, by, @x, @y) ) * 2 * 1
		
		@vel_x += Gosu::offset_x(@move_angle, [@move_speed, 1].max)
		@vel_y += Gosu::offset_y(@move_angle, [@move_speed, 1].max)
	end
	
	def point_direction(x1,y1,x2,y2)
		return (((Math::atan2(y2-y1,x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
	def draw
		if @exist == true 
			
			@window.draw_bar(0, 0, 0, 0, 9.2, 1, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, true)
			
			if @window.my_id == @id.to_s
				if @dead == false
					
					blue = @glowstick_colour%256
					green = (@glowstick_colour/256)%256
					red = (@glowstick_colour/65536)%256
					alpha = (@glowstick_colour/16777216)%256
					
					temp = alpha*16777216 + (255 - ((255 - red) / 3)).round*65536 + (255 - ((255 - green) / 3)).round*256 + (255 - ((255 - blue) / 3)).round
					
					@window.smallfont.draw("#{@health} / #{@maxhealth}", @window.width/2-24, @window.height-40, 10.1, 1.0, 1.0, 0xffffff00)
					
					@window.smallfont.draw("#{@glowstick_colour}", @window.width/2-24, @window.height-60, 10.1, 1.0, 1.0, 0xffffff00)
					
					@window.draw_bar(@window.width/2-40, @window.height-24, @window.width/2+40, @window.height-15, 10.1, @health*1.0/@maxhealth, 0xAAFF4545, 0xAAFFFFFF, 0x77000000, true)
					
					case @weapon_slot
						when 0
							if @do_action == true
								@window.blow_array[@blow_index+10].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							end
						when 1
							@window.staff_array[@staff_index+7].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.staff_array[@staff_index].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1)
						when 2
							@window.staff_array[7].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.glowstick_img.draw_rot(@window.width/2, @window.height/2, 6, @angle-90, 0.5, 0.5, 1, 1, temp)
						when 3
							@window.halberd_array[@halberd_index+9].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.halberd_array[@halberd_index].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1)
					end
					
					if @taking_damage == true
						@window.hood_array[@index+7].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, 0xffffffff)
					else
						@window.hood_array[@index].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
					end
					
					if @weapon_slot == 0 # This is because the "blushing" needs to be above the player image
						@window.blow_array[@blow_index].draw_rot(@window.width/2, @window.height/2, 5.9, @angle-90, 0.5, 0.5, 1, 1)
					end
					
					if @dash_cd != 0
						value = @dash_cd*1.0/@dash_cd_max
						@window.draw_bar(20, 560, 120, 580, 10.1, value, 0xFFD1783C, 0xFFFFFFFF, 0xFF000000, true)
					end
					
				else
					@window.cross_img.draw_rot(@window.width/2, @window.height/2, 5.9, 0, 0.5, 0.5, 1, 1, @colorr)
				end
			else
				
				if @dead == false
					
					blue = @glowstick_colour%256
					green = (@glowstick_colour/256)%256
					red = (@glowstick_colour/65536)%256
					alpha = (@glowstick_colour/16777216)%256
					
					temp = alpha*16777216 + (255 - ((255 - red) / 3)).round*65536 + (255 - ((255 - green) / 3)).round*256 + (255 - ((255 - blue) / 3)).round
					
					@window.smallfont.draw("#{@glowstick_colour}", @x-17+@window.width/2-@window.player_x, @y-38+@window.height/2-@window.player_y, 10.1, 1.0, 1.0, 0xffffff00)
					
					@window.draw_bar(@x-17+@window.width/2-@window.player_x, @y-18+@window.height/2-@window.player_y, @x+17+@window.width/2-@window.player_x, @y-15+@window.height/2-@window.player_y, 5.95, @health*1.0/@maxhealth, 0xAAFF5154, 0xAAFFFFFF, 0x99000000, true)
					
					case @weapon_slot
						when 0
							if @do_action == true
								@window.blow_array[@blow_index+10].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							end
						when 1
							@window.staff_array[@staff_index+7].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.staff_array[@staff_index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1)
						when 2
							@window.staff_array[7].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.glowstick_img.draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 6, @angle-90, 0.5, 0.5, 1, 1, temp)
						when 3
							@window.halberd_array[@halberd_index+9].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
							@window.halberd_array[@halberd_index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1)
					end
					
					if @taking_damage == true
						@window.hood_array[@index+7].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, 0xffffffff)
					else
						@window.hood_array[@index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1, @colorr)
					end
					
					if @weapon_slot == 0 # This is because the "blushing" needs to be above the player image
						@window.blow_array[@blow_index].draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, @angle-90, 0.5, 0.5, 1, 1)
					end
				else
					@window.cross_img.draw_rot(@x+@window.width/2-@window.player_x, @y+@window.height/2-@window.player_y, 5.9, 0, 0.5, 0.5, 1, 1, @colorr)
				end
			end
		end
	end
end
