require 'gosu'
require_relative 'ball'

class GameWindow < Gosu::Window
    attr_reader :universe_width, :universe_height
    attr_reader :camera_x, :camera_y
	
	def initialize
		
		super(860, 540, false)
		self.caption = "Gas"
		
		## The size of the "universe"
		@universe_width = width - 60
		@universe_height = height - 140
		
		## Camera coordinates
		@camera_x = @universe_width/2
		@camera_y = @universe_height/2
        @follow = false
		
		## Default font
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		## Game is paused by default. Unpause by pressing W
		@update_balls = false

		## Creates the objects
		self.restart
	end
	
	def restart  #### When you press Z, this method gets called
        radius = 11.0
		
		@balls = []     ### Array containing every ball object.
		for i in 0..39
            x = radius + rand(@universe_width-2*radius)
            y = radius + rand(@universe_height-2*radius)
            dir = rand(360)
            vel = rand(5)
            mass = 3.14*(radius**2)
            @balls << Ball.new(self, x, y, dir, vel, radius, i, mass) ### Create the ball
		end
	end

	def update
		self.caption = "Gas  -  [FPS: #{Gosu::fps.to_s}]"
		
		if @update_balls == true
			@balls.each     { |inst|  inst.update }
			self.check_ball_collision
		end

        if @follow == true
            @camera_x = @balls[0].x
            @camera_y = @balls[0].y
        end

        ### MOVE THE CAMERA
        if button_down? Gosu::KbLeft
			@camera_x += -4
		end
		if button_down? Gosu::KbRight
			@camera_x += 4
		end
		if button_down? Gosu::KbUp
			@camera_y += -4
		end
		if button_down? Gosu::KbDown
			@camera_y += 4
		end
	end
	
	def check_ball_collision  
		### This method has been optimised to only check each collision ONCE. Therefore the entire collision check is 2x faster.
		### Thats also the reason why the method is run by the window, not by each ball.
		
		for i in 0..@balls.length-2  ## Ignore the last ball, since we have all the collisions checked by then
			for q in (i+1)..@balls.length-1  ### Check every ball from second_index
				@balls[i].checkCollision(@balls[q])
			end
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbZ
				self.restart
			when Gosu::KbQ       ### When the game is paused, you can manually run each "step" of the simulation by pressing Q.
				@balls.each     { |inst|  inst.update }
				self.check_ball_collision
			when Gosu::KbW
				@update_balls = !@update_balls
			when Gosu::KbF
                @follow = !@follow
		end
	end
	
	def needs_cursor?
		true
	end

    def draw_universe_line(x1, y1, x2, y2, color)
        draw_line(x1 + width/2-@camera_x, y1 + height/2-@camera_y, color,
                  x2 + width/2-@camera_x, y2 + height/2-@camera_y, color)
    end
	
	def draw
		## Draw the balls
		@balls.each     { |inst|  inst.draw }
		
		### Draw the universe borders
        draw_universe_line(0,               0,
                           @universe_width, 0,                Gosu::Color::WHITE)
        draw_universe_line(0,               @universe_height,
                           @universe_width, @universe_height, Gosu::Color::WHITE)
        draw_universe_line(0,               0,
                           0,               @universe_height, Gosu::Color::WHITE)
        draw_universe_line(@universe_width, 0,
                           @universe_width, @universe_height, Gosu::Color::WHITE)

		### Draw the instructions
		@font.draw("Press W to Unpause/Pause",        width/2-50, 5, 2)
		@font.draw("Press Q to single-step",          width/2-50, 20, 2)
		@font.draw("Press Z to reset",                width/2-50, 35, 2)
		@font.draw("Press F to follow white ball",    width/2-50, 50, 2)
		@font.draw("Press Arrow Keys to Move camera", width/2-50, 75, 2)
	end
end

# show the window
GameWindow.new.show

