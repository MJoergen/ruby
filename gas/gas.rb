require 'gosu'
require_relative 'ball'

class GameWindow < Gosu::Window
	
	def initialize
		
		super(860, 540, false)
		self.caption = "Gas"
		
		## The size of the "universe"
		$universe_width = width - 60
		$universe_height = height - 140
		
		## Camera coordinates
		$camera_x = $universe_width/2
		$camera_y = $universe_height/2
		
		## Default font
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		## Game is paused by default. Unpause by pressing W
		@update_balls = false

		## Creates the objects
		self.restart
	end
	
	def restart  #### When you press Z, this method gets called
		
		$balls = []     ### Array containing every ball object.
		@ball_ids = []  ### Array used to manage the ball ids. Each ball has a unique number in "@id".
		
		for i in 0..39  ### Repeat 40 times
			## Create a ball
			self.create_ball(11.0+rand($universe_width-2*11.0), 11.0+rand($universe_height-2*11.0),
                             rand(360), rand(5), 11.0, 3.14*(11.0**2))
		end
		
	end
	
	def update
		
		self.caption = "Elastic Collision  -  [FPS: #{Gosu::fps.to_s}]"
		
		if @update_balls == true
			$balls.each     { |inst|  inst.update }
			## CHECK FOR BALL COLLISION. THIS IS DONE BY THE WINDOW, NOT BY EACH BALL. THE REASON IS OPTIMISATION.
			self.check_ball_collision
		end
		
		### MOVE THE CAMERA
		if button_down? Gosu::KbLeft
			$camera_x += -4
		end
		if button_down? Gosu::KbRight
			$camera_x += 4
		end
		if button_down? Gosu::KbUp
			$camera_y += -4
		end
		if button_down? Gosu::KbDown
			$camera_y += 4
		end
		
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbZ
				self.restart
			when Gosu::KbQ       ### When the game is paused, you can manually run each "step" of the simulation by pressing Q.
				$balls.each     { |inst|  inst.update }
				self.check_ball_collision
			when Gosu::KbW
				@update_balls = !@update_balls
		end
	end
	
	def create_ball(x, y, dir, vel, rad, mass)
		
		### Maximum of 200 balls when giving them a unique id. 200 is an abitrary number... change it to whatever you like. 
		for i in 0..199
			if !@ball_ids.include? i
				id = i
				@ball_ids << id
				inst = Ball.new(self, x, y, dir, vel, rad, id, mass) ### Create the ball
				$balls << inst  ### And remember the ball in the $balls array
				break
			end
		end
	end
	
	def check_ball_collision  
		
		### This method has been optimised to only check each collision ONCE. Therefore the entire collision check is 2x faster.
		### Thats also the reason why the method is run by the window, not by each ball.
		
		second_index = 1
		
		for i in 0..$balls.length-2  ## Ignore the last ball, since we have all the collisions checked by then
			
			for q in second_index..$balls.length-1  ### Check every ball from second_index
				$balls[i].checkCollision($balls[q])
			end
			
			second_index += 1
			
		end
		
	end
	
	def needs_cursor?
		true
	end
	
	def warp_camera(x, y)
		$camera_x = x
		$camera_y = y
	end
	
	def draw
		## Draw the balls
		$balls.each     { |inst|  inst.draw }
		
		## Display the amount of balls
		@font.draw("Balls : #{$balls.length}", 10, 10, 1, 1.0, 1.0, 0xffffffff)
		
		### Draw the universe borders
        draw_line(0+width/2-$camera_x, 0+height/2-$camera_y, 0xffffffff,
                  $universe_width+width/2-$camera_x, 0+height/2-$camera_y, 0xffffffff, 0)
		draw_line(0+width/2-$camera_x, $universe_height+height/2-$camera_y, 0xffffffff,
                  $universe_width+width/2-$camera_x, $universe_height+height/2-$camera_y, 0xffffffff, 0)
		
		draw_line(0+width/2-$camera_x, 0+height/2-$camera_y, 0xffffffff,
                  0+width/2-$camera_x, $universe_height+height/2-$camera_y, 0xffffffff, 0)
		draw_line($universe_width+width/2-$camera_x, 0+height/2-$camera_y, 0xffffffff,
                  $universe_width+width/2-$camera_x, $universe_height+height/2-$camera_y, 0xffffffff, 0)
		
		### Draw the instructions
		@font.draw("Press W to Unpause/Pause", width/2-50, 10, 2)
		@font.draw("Press Q to single-step", width/2-50, 30, 2)
		@font.draw("Press Arrow Keys to Move camera", width/2-50, 50, 2)
	end
	
end

# show the window
window = GameWindow.new
window.show
