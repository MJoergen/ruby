
require 'rubygems'
require 'gosu'

#require_relative 'TextClass.rb'

class GameWindow < Gosu::Window
	
	attr_reader :player, :wizard
	
	def initialize
		
		@window_width = 640
		@window_height = 480
		
		super(@window_width, @window_height, false)
		
		self.caption = "ShadowWizard"
		
		@tile = Gosu::Image.new(self, "media/tile.png", true)
		@door = Gosu::Image.new(self, "media/door.png", true)
		@point = Gosu::Image.new(self, "media/Point.png", true)
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		@room_data = []
		@room_num = "undefined"
		
		@gen_x, @gen_y = 60, 400
		@route = []
		
		#self.generate_map
	
	end

    # This implements the path finding algorithm described
    # in http://en.wikipedia.org/wiki/Pathfinding
    #
    # room_data contains tuples of the form
    # [square, open_up, open_right]
    # The function returns a list of squares
    # containing the path.
    def make_path(room_data, from_sq, to_sq)
		
        # Stage 1
        main_list = []
        main_list << [to_sq, 0]
        while true # Repeat forever
            new_list = [].concat(main_list) # Make a copy
            upd = false
            main_list.each do |e|
                sq = e[0]
                count = e[1] + 1
                if (((sq%6) > 0) and room_data[sq-1][2]==1) # go left
                    if !new_list.find_index {|elem| elem[0] == sq-1}
                        new_list << [sq-1, count]
                    end
                end
                if (((sq%6) < 5) and room_data[sq][2]==1) # go right
                    if !new_list.find_index {|elem| elem[0] == sq+1}
                        new_list << [sq+1, count]
                    end
                end
                if (((sq/6) > 0) and room_data[sq-6][1]==1) # go down
                    if !new_list.find_index {|elem| elem[0] == sq-6}
                        new_list << [sq-6, count]
                    end
                end
                if (((sq/6) < 5) and room_data[sq][1]==1) # go up
                    if !new_list.find_index {|elem| elem[0] == sq+6}
                        new_list << [sq+6, count]
                    end
                end

            end

            # If no new items appear in list, then stop.
            if new_list.count == main_list.count
                break
            end
            main_list = [].concat(new_list)
			
        end  # stage 1

        # Stage 2 - find the number of steps needed
        idx = main_list.find_index {|elem| elem[0] == from_sq}
        count = main_list[idx][1] # Number of steps needed

        # Stage 3
        sq = from_sq
        @route = [from_sq]
        while count >= 0
            count -= 1
            main_list.each do |e|
                if (((sq%6) > 0) and room_data[sq-1][2]==1) # go left
                    if main_list.find_index {|elem| elem[0] == sq-1 and elem[1] == count}
                        sq = sq-1
                        @route << sq
                        next
                    end
                end
                if (((sq%6) < 5) and room_data[sq][2]==1) # go right
                    if main_list.find_index {|elem| elem[0] == sq+1 and elem[1] == count}
                        sq = sq+1
                        @route << sq
                        next
                    end
                end
                if (((sq/6) > 0) and room_data[sq-6][1]==1) # go down
                    if main_list.find_index {|elem| elem[0] == sq-6 and elem[1] == count}
                        sq = sq-6
                        @route << sq
                        next
                    end
                end
                if (((sq/6) < 5) and room_data[sq][1]==1) # go up
                    if main_list.find_index {|elem| elem[0] == sq+6 and elem[1] == count}
                        sq = sq+6
                        @route << sq
                        next
                    end
                end
            end
        end # stage 3
        puts "route=#{@route}"
    end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbZ
				@room_data.clear
				@room_num = "undefined"
			when Gosu::Kb1
				@room_data.clear
				File.open('room0data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
				@room_num = 0
                make_path(@room_data, 5, 5)
			
			when Gosu::Kb2
				@room_data.clear
				File.open('room1data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
				@room_num = 1
                make_path(@room_data, 16, 7)
			
			when Gosu::Kb3
				@room_data.clear
				File.open('room2data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
				@room_num = 2
                make_path(@room_data, 28, 18)
			
		end
	end
	
	def draw
		
		# Text
		@font.draw("Press 'Z' to clear", 10, 10, 2, 1.0, 1.0, 0xffff0000)
		@font.draw("Room_num: #{@room_num}", 150, 10, 2, 1.0, 1.0, 0xffff0000)
		
		if !@room_data.empty?
			
            @font.draw("S", @gen_x-4, @gen_y-6, 4, 1.0, 1.0, 0xffff0000)
				
			@room_data.each_index do |i|

			    if i>0
                    #@font.draw("#{i}", @gen_x-4+32*((@room_data[i][0]-1) % 6),
                    #           @gen_y-6-(32*((@room_data[i][0]-1)/6).ceil),
                    #           4, 1.0, 1.0, 0xffff0000)
                end
					
				@tile.draw_rot(@gen_x+32*((@room_data[i][0]-1) % 6), @gen_y-(32*((@room_data[i][0]-1)/6).ceil), 2, 0)
				
				case @room_data[i][1]
					when 1
						@door.draw_rot(@gen_x+32*((@room_data[i][0]-1) % 6), @gen_y-(32*((@room_data[i][0]-1)/6).ceil)-16, 3, 0)
				end
				case @room_data[i][2]
					when 1
						@door.draw_rot(@gen_x+32*((@room_data[i][0]-1) % 6)+16, @gen_y-(32*((@room_data[i][0]-1)/6).ceil), 3, 0)
				end

			end
		end
		
		if !@route.empty?
			@route.each_index do |i|
				@point.draw_rot(@gen_x+32*((@route[i]) % 6), @gen_y-(32*((@route[i])/6).ceil), 2, 0)
			end
		end
	end
end

window = GameWindow.new
window.show
