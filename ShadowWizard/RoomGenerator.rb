
require 'rubygems'
require 'gosu'

require_relative 'TextClass.rb'

class GameWindow < Gosu::Window
	
	attr_reader :player, :wizard
	
	def initialize
		
		@window_width = 640
		@window_height = 480
		
		super(@window_width, @window_height, false)
		
		self.caption = "ShadowWizard"
		
		@tile = Gosu::Image.new(self, "media/tile.png", true)
		@door = Gosu::Image.new(self, "media/door.png", true)
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		@room_data = []
		@room_num = "undefined"
		
		@gen_x, @gen_y = 60, 400
		
		#self.generate_map
	
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
			when Gosu::Kb2
				@room_data.clear
				File.open('room1data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
				@room_num = 1
			when Gosu::Kb3
				@room_data.clear
				File.open('room2data.txt') do |f|
					f.lines.each do |line|
						@room_data << line.split.map(&:to_i)
					end
				end
				@room_num = 2
		end
	end
	
	def draw
		
		# Text
		@font.draw("Press 'Z' to clear", 10, 10, 2, 1.0, 1.0, 0xffff0000)
		@font.draw("Room_num: #{@room_num}", 150, 10, 2, 1.0, 1.0, 0xffff0000)
		
		if !@room_data.empty?
			
			@font.draw("S", @gen_x-4, @gen_y-6, 4, 1.0, 1.0, 0xffff0000)
				
			@room_data.each_index do |i|
					
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
	end
end

window = GameWindow.new
window.show
