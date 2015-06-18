require_relative 'geom.rb'

class Server_Phantom
	
	attr_reader :x, :y
	
	def initialize(x, y)
		@x = x
		@y = y
		@player_target_x = @x
		@player_target_y = @y
		@moving_speed = 2
		@my_tile = find_tile(@x, @y)
		@target_tile = @my_tile
		@route = [@my_tile, @target_tile]
		@portal_timer = 0
		@target_update_timer = 0
		@target_update_timer_max = 600
		@target = 0
	end
	
	def update(player_x_array, player_y_array, players_ingame)
		
		self.update_target_pos(player_x_array, player_y_array, players_ingame) 
		# Updates the values @player_target_x and @player_target_y
		# If there are no players, the values will be nil
		
		if @player_target_x != nil and @player_target_y != nil
			
			old_target_tile = @target_tile # Remember the current target tile
			old_my_tile = @my_tile
			
			
			self.get_tiles # Update the values @target_tile and @my_tile
			
			if @target_tile != old_target_tile or @my_tile != old_my_tile # Check to see if my or target tile has changed
				self.make_path($room_data, $portals, @my_tile, @target_tile) # If it has, then update your path
			end
			
			if !$path_blockers.empty?
				if $path_blockers.find_index { |sq|
                    Geom.collision_box_line_with_radius(sq.x, sq.y, sq.width, sq.height, @x, @y,
                                                      @player_target_x - Gosu::offset_x(point_direction(@x, @y, @player_target_x, @player_target_y), 16),
                                                      @player_target_y - Gosu::offset_y(point_direction(@x, @y, @player_target_x, @player_target_y), 16),
                                                      16) != 0 }
                    # OK, our direct path is blocked.

                    # Lets go to the next tile instead.
                    target_x = find_tile_x(@route[1][0])
                    target_y = find_tile_y(@route[1][0])
                    # If we are going through a portal, we must change our target
                    if @route[1][1] > 0
                        target_x = find_tile_x(@route[0])
                        target_y = find_tile_y(@route[0])
                        case @route[1][1]
                            when 1 # right
                                target_x += (130-17)
                            when 2 # left
                                target_x -= (130-17)
                            when 3 # up
                                target_y -= (130-17)
                            when 4 # down
                                target_y += (130-17)
                        end
                    end

					if $path_blockers.find_index { |sq| Geom.collision_box_line_with_radius(sq.x, sq.y, sq.width, sq.height, @x, @y,
                                                                                          target_x, target_y, 16) != 0}
						self.pathfind_towards_target(@x, @y, find_tile_x(@route[0]), find_tile_y(@route[0]))
					else
						self.pathfind_towards_target(@x, @y, target_x, target_y)
					end
				else
					self.pathfind_towards_target(@x, @y,
                                                 @player_target_x - Gosu::offset_x(point_direction(@x, @y, @player_target_x, @player_target_y), 16), 
                                                 @player_target_y - Gosu::offset_y(point_direction(@x, @y, @player_target_x, @player_target_y), 16))
				end
			end
		end
		
	end
	
	def find_tile_x(tile)
		return $gen_x + 480 * (tile % 6)
	end
	
	def find_tile_y(tile)
		return $gen_y - 480 * (((tile)/6 + 0.1).ceil - 1) # "+ 0.1" is there because 30/6 = 5, and 5.ceil is still 5, but it should be 6
	end
	
	def update_target_pos(player_x_array, player_y_array, players_ingame)
		# All players
		player_array = []
		player_array << [player_x_array[0], player_y_array[0], 0, players_ingame[0]]
		player_array << [player_x_array[1], player_y_array[1], 1, players_ingame[1]]
		player_array << [player_x_array[2], player_y_array[2], 2, players_ingame[2]]
		
		# Only active players
		ingame_array = player_array.select { |a| a.last == 1 }
		
		if !ingame_array.empty?
			# Distances to each active player
			distance_array = ingame_array.map { |a| Gosu::distance(@x, @y, a[0], a[1]) }
			
			# Find nearest player
			target_index = distance_array.each_with_index.min.last
			
			@target_update_timer = [0, @target_update_timer - 1].max
			if @target_update_timer == 0
				@target = ingame_array[target_index][2]
				@target_update_timer = @target_update_timer_max
			end
			
			@player_target_x = player_x_array[@target]
			@player_target_y = player_y_array[@target]
			
			
		else
			@player_target_x = nil
			@player_target_y = nil
		end
	end
	
	def get_tiles
		
		target_x = @player_target_x
		target_y = @player_target_y
		
		my_x = @x
		my_y = @y
		
		@my_tile = find_tile(my_x, my_y)
		@target_tile = find_tile(target_x, target_y) 
		
	end
	
	def find_tile(x, y) # Find the tile from two coordinates
		#puts "FIND TILE - X: #{x}"
		array = []
		for i in 0..5
			array[i] = (i+1)*6 - 1 + ((x - $gen_x)/480).round # Array of the tiles in the column of the x value
		end
		#puts "RESULT TILE: #{array[((y - $gen_y) / (-480)).round] - 5}"
		return array[((y - $gen_y) / (-480)).round] - 5 # Final tile
	end
	
	def pathfind_towards_target(x, y, tx, ty)
		
		
		dir = point_direction(x, y, tx, ty)
		if Gosu::distance(x, y, tx, ty) > @moving_speed*$time_diff_ms*60/1000
			self.move_direction(dir, @moving_speed*$time_diff_ms*60/1000)
		end
	end
	
    # The four portals are numbered from 1 to 6.
    # i = 0, means the portal is in the bottom 
    # i = 1, means the portal is in the top
    # i = 2, means the portal is to the left
    # i = 3, means the portal is to the right
    
	def make_path(room_data, portals, from_sq, to_sq)
		puts "from_sq: #{from_sq}"
		puts "to_sq: #{to_sq}"
        # Stage 1
        main_list = []
        main_list << [to_sq%36, 0, to_sq%36]
        while true # Repeat forever
            new_list = [].concat(main_list) # Make a copy
            main_list.each do |e|
                sq = e[0]
                count = e[1] + 1
                if (((sq%6) > 0) and room_data[sq-1][2]==1) # go left
                    new_sq = sq-1
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 0]]
                    end
                end
                if (((sq%6) < 5) and room_data[sq][2]==1) # go right
                    new_sq = sq+1
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 0]]
                    end
                end
                if (((sq/6) > 0) and room_data[sq-6][1]==1) # go down
                    new_sq = sq-6
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 0]]
                    end
                end
                if (((sq/6) < 5) and room_data[sq][1]==1) # go up
                    new_sq = sq+6
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 0]]
                    end
                end
                if (((sq%6) == 0) and sq/6 == portals[2]-1) # go left through portal
                    new_sq = (portals[3]-1)*6 + 5
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 1]]
                    end
                end
                if (((sq%6) == 5) and sq/6 == portals[3]-1) # go right through portal
                    new_sq = (portals[2]-1)*6 + 0
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 2]]
                    end
                end
                if (((sq/6) == 0) and sq%6 == portals[0]-1) # go down through portal
                    new_sq = portals[1]-1 + 5*6
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 3]]
                    end
                end
                if (((sq/6) == 5) and sq%6 == portals[1]-1) # go up through portal
                    new_sq = portals[0]-1 + 0*6
                    if !new_list.find_index {|elem| elem[0] == new_sq}
                        new_list << [new_sq, count, [sq, 4]]
                    end
                end
            end # main_list.each do |e|

            # If no new items appear in list, then stop.
            if new_list.count == main_list.count
                break
            end
            main_list = [].concat(new_list)
			
        end  # stage 1

        # Stage 2 - find the number of steps needed
        idx = main_list.find_index {|elem| elem[0] == from_sq}
        #puts "main_list: "
		#p main_list
		count = main_list[idx][1] # Number of steps needed

        # Stage 3
        sq = from_sq
        @route = [from_sq]
        while count >= 0 and sq != to_sq
            main_list.each do |e|
                if idx = main_list.find_index {|elem| elem[0] == sq and elem[1] == count}
                    r = main_list[idx][2]
                    @route << r
                    sq = r[0]
                    break
                end
            end
            count -= 1
        end # stage 3
		if @route.length == 1
			@route << @route[0]
		end
        puts "route=#{@route}"
    end
	
	def move_direction(dir, speed)
		@x = @x + Gosu::offset_x(dir, speed)
		@y = @y + Gosu::offset_y(dir, speed)
		
		
		@portal_timer = [0, @portal_timer-1].max
		
		portal_collision = check_collision_portal
		
		if portal_collision > 0
			if @portal_timer == 0
				portal_collision += -1
				case portal_collision
				when 0
					@x = $portal_pos_x[1] # change position
					@y = $portal_pos_y[1]
				when 1
					@x = $portal_pos_x[0]
					@y = $portal_pos_y[0]
				when 2
					@x = $portal_pos_x[3]
					@y = $portal_pos_y[3]
				when 3
					@x = $portal_pos_x[2]
					@y = $portal_pos_y[2]
			end
			end
			@portal_timer = 5
		end
		
		
	end
	
	def check_collision_portal
		x = @x
		y = @y
		for i in 0..3
			if Gosu::distance(x, y, $portal_pos_x[i], $portal_pos_y[i]) < 22
				return i+1
			end
		end
		return 0
	end
	
	def point_direction(x1, y1, x2, y2)
		return (((Math::atan2(y2-y1, x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
end
