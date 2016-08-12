require 'rubygems'
require 'gosu'
require 'matrix'

include Gosu


class GameWindow < Gosu::Window
	
	WIDTH = 1000
	HEIGHT = 650
	TITLE = "Just another ruby project"
	
	attr_reader :circle_img, :pocket_corner_img, :balls_in_hole, :font_small, :stripe_img, :pocket_middle_img
	
	def initialize
		
		super(WIDTH, HEIGHT, false)
		self.caption = TITLE
		
		$window_width = 1000.0
		$window_height = 650.0
		
		$universe_width = 800.0
		$universe_height = 400.0
		
		@point_img = Gosu::Image.new(self, "media/Point2.png", true)
		@pocket_corner_img = Gosu::Image.new(self, "media/pocket_corner.png", true)
		@pocket_middle_img = Gosu::Image.new(self, "media/pocket_middle.png", true)
		@circle_img = Gosu::Image.new(self, "media/filled_circle.png", true)
		@stripe_img = Gosu::Image.new(self, "media/billiard_circle.png", true)
		
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		@font_small = Gosu::Font.new(self, Gosu::default_font_name, 12)
		
		$camera_x = $universe_width/2
		$camera_y = $universe_height/2
		
		@update_balls = true
		
		### Used to determine the path that the cue ball will take after being shot
		$path_blockers = []
		
		$pocket_coords = [[0, 26], 
						  [26, 0], 
						  [$universe_width-26, 0], 
						  [$universe_width, 26], 
						  [$universe_width, $universe_height-26], 
						  [$universe_width-26, $universe_height], 
						  [26, $universe_height], 
						  [0, $universe_height-26], 
						  [$universe_width/2-21, 0], 
						  [$universe_width/2+21, 0], 
						  [$universe_width/2-21, $universe_height], 
						  [$universe_width/2+21, $universe_height]]
		
		$lines_array = [[26, 0, 0, -26], 
						[0, 26, -26, 0], 
						[$universe_width-26, 0, $universe_width, -26], 
						[$universe_width, 26, $universe_width+26, 0], 
						[$universe_width, $universe_height-26, $universe_width+26, $universe_height], 
						[$universe_width-26, $universe_height, $universe_width, $universe_height+26], 
						[26, $universe_height, 0, $universe_height+26], 
						[0, $universe_height-26, -26, $universe_height], 
						[$universe_width/2-21, 0, $universe_width/2-21+5, -25], 
						[$universe_width/2+21, 0, $universe_width/2+21-5, -25], 
						[$universe_width/2-21, $universe_height, $universe_width/2-21+5, $universe_height+25], 
						[$universe_width/2+21, $universe_height, $universe_width/2+21-5, $universe_height+25]]
		
		$walls_array_path = [[26, 11, $universe_width/2-21, 11], 
							 [$universe_width/2+21, 11, $universe_width-26, 11], 
							 [26, $universe_height-11, $universe_width/2-21, $universe_height-11], 
							 [$universe_width/2+21, $universe_height-11, $universe_width-26, $universe_height-11],
							 [11, 26, 11, $universe_height-26], 
							 [$universe_width-11, 26, $universe_width-11, $universe_height-26]]
		
		$pocket_holes = [[-4, -4], [$universe_width+4, -4], [$universe_width+4, $universe_height+4], [-4, $universe_height+4], [$universe_width/2, -17], [$universe_width/2, $universe_height+17]]
		
		$pocket_radius = 17.0
		
		@id_colors = [0xffFFDDAE, 
					  0xffFECC15, 
					  0xff375CB5, 
					  0xffEE1122, 
					  0xff513D9C, 
					  0xffFD5413, 
					  0xff2E5F32, 
					  0xff79282E, 
					  0xff191919, 
					  0xffFECC15, 
					  0xff375CB5, 
					  0xffEE1122, 
					  0xff513D9C, 
					  0xffFD5413, 
					  0xff2E5F32, 
					  0xff79282E]
		
		self.restart
		
	end
	
	def restart
		$balls = []  ## lol
		@ball_ids = []
		
		@balls_in_hole = 0
		
		### The cue
		self.create_ball($universe_width*3/4, $universe_height/2, 271, 0, 11.0)
		
		### The triangle
		for i in 0..4
			self.create_ball(110, $universe_height/2-44+i*22, 0, 0, 11.0)
		end
		for i in 0..3
			self.create_ball(110+19.10, $universe_height/2-33+i*22, 0, 0, 11.0)
		end
		for i in 0..2
			self.create_ball(110+19.10*2, $universe_height/2-22+i*22, 0, 0, 11.0)
		end
		for i in 0..1
			self.create_ball(110+19.10*3, $universe_height/2-11+i*22, 0, 0, 11.0)
		end
		self.create_ball(110+19.10*4, $universe_height/2, 0, 0, 11.0)
		
		
		
	end
	
	def update
		
		$path_blockers = []
		
		self.caption = "Billiard  -  [FPS: #{Gosu::fps.to_s}]"
		
		if @update_balls == true
			
			#### Called twice for 120 physics updates per second
			$balls.each     { |inst|  inst.update }
			self.check_ball_collision
			
			$balls.each     { |inst|  inst.update }
			self.check_ball_collision
		
		end
		
		if button_down? Gosu::KbA
			$camera_x = [$camera_x-5, $universe_width/2-400].max
		end
		if button_down? Gosu::KbD
			$camera_x = [$camera_x+5, $universe_width/2+400].min
		end
		if button_down? Gosu::KbW
			$camera_y = [$camera_y-5, $universe_height/2-400].max
		end
		if button_down? Gosu::KbS
			$camera_y = [$camera_y+5, $universe_height/2+400].min
		end
		
	end
	
	def button_up(id)
		case id
			when Gosu::MsLeft
				$balls.each     { |inst|  inst.release }
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbZ
				self.restart
			when Gosu::KbQ
				$balls.each     { |inst|  inst.update }
				self.check_ball_collision
			when Gosu::KbP
				@update_balls = !@update_balls
			when Gosu::MsLeft
				$balls.each     { |inst|  inst.checkMouseClick }
		end
	end
	
	def draw
		
		draw_quad(0, 0, 0xffffffff,
				  $window_width, 0, 0xffffffff,
				  $window_width, $window_height, 0xffffffff, 
				  0, $window_height, 0xffffffff, 0)
		
		brown_wall_size = 40
		
		draw_quad(0-brown_wall_size+$window_width/2-$camera_x, 0-brown_wall_size+$window_height/2-$camera_y, 0xff773E2F,
				  $universe_width+brown_wall_size+$window_width/2-$camera_x, 0-brown_wall_size+$window_height/2-$camera_y, 0xff773E2F,
				  $universe_width+brown_wall_size+$window_width/2-$camera_x, $universe_height+brown_wall_size+$window_height/2-$camera_y, 0xff773E2F, 
				  0-brown_wall_size+$window_width/2-$camera_x, $universe_height+brown_wall_size+$window_height/2-$camera_y, 0xff773E2F, 0)
		
		green_wall_size = 21
		
		draw_quad(0-green_wall_size+$window_width/2-$camera_x, 0-green_wall_size+$window_height/2-$camera_y, 0xff144429,
				  $universe_width+green_wall_size+$window_width/2-$camera_x, 0-green_wall_size+$window_height/2-$camera_y, 0xff144429,
				  $universe_width+green_wall_size+$window_width/2-$camera_x, $universe_height+green_wall_size+$window_height/2-$camera_y, 0xff144429, 
				  0-green_wall_size+$window_width/2-$camera_x, $universe_height+green_wall_size+$window_height/2-$camera_y, 0xff144429, 0)
		
		### Corner Pockets
		## Clockwise order
		@pocket_corner_img.draw_rot(0-brown_wall_size+$window_width/2-$camera_x, 0-brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.0, 0.0)
		@pocket_corner_img.draw_rot($universe_width+brown_wall_size+$window_width/2-$camera_x, 0-brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.0, 0.0, -1.0, 1.0)
		@pocket_corner_img.draw_rot($universe_width+brown_wall_size+$window_width/2-$camera_x, $universe_height+brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.0, 0.0, -1.0, -1.0)
		@pocket_corner_img.draw_rot(0-brown_wall_size+$window_width/2-$camera_x, $universe_height+brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.0, 0.0, 1.0, -1.0)
		
		### Middle Pockets
		@pocket_middle_img.draw_rot($universe_width/2+$window_width/2-$camera_x, 0-brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.5, 0.0, 1.0, 1.0)
		@pocket_middle_img.draw_rot($universe_width/2+$window_width/2-$camera_x, $universe_height+brown_wall_size+$window_height/2-$camera_y, 1, 0, 0.5, 0.0, 1.0, -1.0)
		
		draw_quad(0+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xff38BC73,
				  $universe_width+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xff38BC73,
				  $universe_width+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xff38BC73, 
				  0+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xff38BC73, 0)
		
		$balls.each     { |inst|  inst.draw }
		
		# ### Draw the collision hitbox for the pocket holes (white circles)
		# for i in 0..$pocket_holes.length-1
			# @circle_img.draw_rot($pocket_holes[i][0]+$window_width/2-$camera_x, $pocket_holes[i][1]+$window_height/2-$camera_y, 2, 0, 0.5, 0.5, 1.0*($pocket_radius/50.0), 1.0*($pocket_radius/50.0))
		# end
		
		for i in 0..$walls_array_path.length-1
			draw_line($walls_array_path[i][0]+$window_width/2-$camera_x, $walls_array_path[i][1]+$window_height/2-$camera_y, 0xffffffff, $walls_array_path[i][2]+$window_width/2-$camera_x, $walls_array_path[i][3]+$window_height/2-$camera_y, 0xffffffff, 3)
		end
		

	end
	
	def create_ball(x, y, dir, vel, rad)
		
		for i in 0..199
			if !@ball_ids.include? i
				id = i
				@ball_ids << id
				inst = Ball.new(self, x, y, dir, vel, rad, id, @id_colors[i])
				$balls << inst
				break
			end
		end
	end
	
	def check_ball_collision
		
		second_index = 1
		
		for i in 0..$balls.length-2  ## Ignore the last ball, since we have all the collisions checked by then
			
			for q in second_index..$balls.length-1  ### Check every ball from second_index
				$balls[i].checkCollision($balls[q])
			end
			
			second_index += 1
			
		end
		
	end
	
	def checkPathCollision(x1, y1, x2, y2)
		$balls.each     { |inst|  inst.collision_path(x1, y1, x2, y2)}
		
		for i in 0..$walls_array_path.length-1
			$balls.each     { |inst|  inst.collision_wall_path($walls_array_path[i][0], $walls_array_path[i][1], $walls_array_path[i][2], $walls_array_path[i][3])}
		end
		
	end
	
	def needs_cursor?
		true
	end
	
	def warp_camera(x, y)
		$camera_x = x
		$camera_y = y
	end
	
	def destroy_ball(inst)
		@ball_ids.delete(inst.id)
		$balls.delete(inst)
	end
	
	def ball_in_hole
		@balls_in_hole += 1
	end
	
end

class Ball
	
	attr_reader :x, :y, :dir, :radius, :id, :mass, :vel_x, :vel_y
	
	def initialize(window, x, y, dir, vel, rad, id, color)
		
		@window, @x, @y, @dir, @radius, @id, @color = window, x, y, dir, rad, id, color
		
		@mass = 3.14*(@radius**2)  ### This is the area of the ball
		
		@vel_x = Gosu::offset_x(@dir, vel)
		@vel_y = Gosu::offset_y(@dir, vel)
		
		@colliding = false
		@collision_point = false  ### True if you should draw the collision point
		
		@collisionPointX = @x
		@collisionPointY = @y
		
		@resistance = Math::sqrt(0.995)
		@resistance_strong = Math::sqrt(0.96)
		
		@release_force = 0.02
		
		## Is the ball out of the game? (AKA did the ball reach the pocket yet?)
		@out = false
		
	end
	
	def update
		@colliding = false
		@collision_point = false
		self.move
		
		## Direction from mouse to cue ball
		dir = point_direction(@window.mouse_x, @window.mouse_y, @x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y)
		
		if @pulled == true and @color == 0xffFFDDAE
			@window.checkPathCollision(@x, @y, @x+Gosu::offset_x(dir, 900), @y+Gosu::offset_y(dir, 900))
			# p $path_blockers
		end
	end
	
	def draw
		
		## Shadow
		@window.circle_img.draw_rot(@x-3+$window_width/2-$camera_x, @y+9+$window_height/2-$camera_y, 1, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0x44000000)
		
		## The ball itself
		if @colliding == false
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), @color)
		else
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xff00FF00)
			if @collision_point == true
				@window.circle_img.draw_rot(@collisionPointX+$window_width/2-$camera_x, @collisionPointY+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(5.0/50.0), 1.0*(5.0/50.0), 0xff0000FF)
			end
		end
		
		## Light reflection
		@window.circle_img.draw_rot(@x+1+$window_width/2-$camera_x, @y-5+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(4.0/50.0), 1.0*(4.0/50.0), 0x66ffffff)
		
		## Numbers
		if @color != 0xffFFDDAE
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(6.3/50.0), 1.0*(6.3/50.0), 0xffffffff)
			if @id > 9
				@window.font_small.draw("#{@id}", @x-6+$window_width/2-$camera_x, @y-6+$window_height/2-$camera_y, 3, 1.0, 1.0, 0xff000000)
			else
				@window.font_small.draw("#{@id}", @x-3+$window_width/2-$camera_x, @y-6+$window_height/2-$camera_y, 3, 1.0, 1.0, 0xff000000)
			end
			if @id > 8
				@window.stripe_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 2, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xffffffff)
			end
		end
		
		## The release line
		if @pulled == true
			
			## Direction from mouse to cue ball
			dir = point_direction(@window.mouse_x, @window.mouse_y, @x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y)
			
			## Red line to the mouse
			if Gosu::distance(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, @window.mouse_x, @window.mouse_y) < 300
				@window.draw_line(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0xffff0000, @window.mouse_x, @window.mouse_y, 0xffff0000, 2)
			else
				@window.draw_line(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0xffff0000, @x+$window_width/2-$camera_x+Gosu::offset_x(dir-180, 300), @y+$window_height/2-$camera_y+Gosu::offset_y(dir-180, 300), 0xffff0000, 2)
			end
			
			### Find the nearest collision point in $path_blockers
			d = 10000
			for i in 0..$path_blockers.length-1
				dist = Gosu::distance(@x, @y, $path_blockers[i][0], $path_blockers[i][1])
				if dist < d
					closest_int = [$path_blockers[i][0], $path_blockers[i][1], $path_blockers[i][2], $path_blockers[i][3]]
					d = dist
				end
			end
			
			if closest_int != nil
				@window.draw_line(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0xffffffff, closest_int[0]+$window_width/2-$camera_x, closest_int[1]+$window_height/2-$camera_y, 0xffffffff, 2)
				@window.circle_img.draw_rot(closest_int[2]+$window_width/2-$camera_x, closest_int[3]+$window_height/2-$camera_y, 3, @dir, 0.5, 0.5, 1.0*(3.5/50.0), 1.0*(3.5/50.0), 0xff0000FF)
				
				vel_vec = new_velocity(10, 10, Vector[closest_int[0]-@x, closest_int[1]-@y], Vector[0, 0], Vector[closest_int[0], closest_int[1]], Vector[closest_int[2], closest_int[3]])
				
				predicted_response_x = closest_int[0] + vel_vec[0]
				predicted_response_y = closest_int[1] + vel_vec[1]
				
				dir = point_direction(closest_int[0], closest_int[1], predicted_response_x, predicted_response_y)
				
				@window.draw_line(closest_int[0]+$window_width/2-$camera_x, closest_int[1]+$window_height/2-$camera_y, 0xffffffff, closest_int[0]+Gosu::offset_x(dir, 40)+$window_width/2-$camera_x, closest_int[1]+Gosu::offset_y(dir, 40)+$window_height/2-$camera_y, 0xffffffff, 2)
				
			else
				## White line showing the path
				@window.draw_line(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0xffffffff, @x+$window_width/2-$camera_x+Gosu::offset_x(dir, 900), @y+$window_height/2-$camera_y+Gosu::offset_y(dir, 900), 0xffffffff, 2)
			end
			
			
		end
		
	end
	
	def move
		
		
		### Move the ball
		@x = @x + @vel_x
		@y = @y + @vel_y
		
		
		### Check collision with walls
		## Wall to the right
		if @x > ($universe_width-@radius) and @vel_x > 0 and 26 < @y and @y < $universe_height-26
			@vel_x = -@vel_x
		end
		
		## Wall to the left
		if @x < @radius and @vel_x < 0 and 26 < @y and @y < $universe_height-26
			@vel_x = -@vel_x
		end
		
		## Wall at the bottom
		if @y > ($universe_height-@radius) and @vel_y > 0
			if (26 < @x and @x < $universe_width/2-22) or ($universe_width/2+22 < @x and @x < $universe_width-26)
				@vel_y = -@vel_y
			end
		end
		
		## Wall at the top
		if @y < @radius and @vel_y < 0
			if (26 < @x and @x < $universe_width/2-22) or ($universe_width/2+22 < @x and @x < $universe_width-26)
				@vel_y = -@vel_y
			end
		end
		
		### Check collision with lines
		for i in 0..$lines_array.length-1
			self.check_collision_line($lines_array[i][0], $lines_array[i][1], $lines_array[i][2], $lines_array[i][3])
		end
		
		### Check collision with corners
		for i in 0..$pocket_coords.length-1
			self.check_collision_point($pocket_coords[i][0], $pocket_coords[i][1])
		end
		
		### Check collision with pockets
		for i in 0..$pocket_holes.length-1
			self.check_collision_pocket($pocket_holes[i][0], $pocket_holes[i][1])
		end
		
		### Resistance
		if (@vel_x**2+@vel_y**2) > 0.5**2
			@vel_x = @vel_x * @resistance
			@vel_y = @vel_y * @resistance
		else
			@vel_x = @vel_x * @resistance_strong
			@vel_y = @vel_y * @resistance_strong
		end
		
	end
	
	def check_collision_pocket(x, y)
		
		dist2 = (x - @x)**2+(y - @y)**2  ## Optimisation
		if dist2 < $pocket_radius**2  ## Optimisation
			### Collision!
			if @color == 0xffFFDDAE
				@x = $universe_width*3/4
				@y = $universe_height/2
				@vel_x = 0.0
				@vel_y = 0.0
			else
				self.in_hole
			end
		end
		
	end
	
	def check_collision_line(x1, y1, x2, y2)
		
		vector_x = x2 - x1
		vector_y = y2 - y1
		
		point_to_vector_x = @x - x1
		point_to_vector_y = @y - y1
		
		vector_product = vector_x * point_to_vector_x + vector_y * point_to_vector_y
		
		vec_length_squared = vector_x**2 + vector_y**2
		
		projection_factor = vector_product / vec_length_squared
		
		if projection_factor > 0 and projection_factor < 1 ### If the projected point is on the line. Projection factor is between 0 and 1.
			
			projected_point_x = projection_factor * vector_x + x1
			projected_point_y = projection_factor * vector_y + y1
			
			dist_to_player = Gosu::distance(@x, @y, projected_point_x, projected_point_y)
			
			if dist_to_player < radius
				
				## Collision with projected point!
				vec = new_velocity(0, 10, Vector[@vel_x, @vel_y], Vector[0, 0], Vector[@x, @y], Vector[projected_point_x, projected_point_y])
				self.collision_response(vec)
				
			end
			
		end
		
	end
	
	def check_collision_point(x, y)
		dist2 = (x - @x)**2 + (y - @y)**2
		if dist2 < @radius**2
			## Collision!
			vec = new_velocity(0, 10, Vector[@vel_x, @vel_y], Vector[0, 0], Vector[@x, @y], Vector[x, y])
			self.collision_response(vec)
		end
	end
	
	def checkMouseClick
		dist = Gosu::distance(@window.mouse_x-$window_width/2+$camera_x, @window.mouse_y-$window_height/2+$camera_y, @x, @y)
		if dist < @radius
			if @color == 0xffFFDDAE
				@pulled = true
			end
		end
	end
	
	def release
		if @pulled == true
			
			## Direction from ball to mouse
			dir = point_direction(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, @window.mouse_x, @window.mouse_y)
			
			## If the distance from mouse to ball is less than 300 pixels
			if Gosu::distance(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, @window.mouse_x, @window.mouse_y) < 300
				## The distance from ball to mouse is proportional to the force
				@vel_x += -(@window.mouse_x-$window_width/2+$camera_x - @x) * @release_force
				@vel_y += -(@window.mouse_y-$window_height/2+$camera_y - @y) * @release_force
			else
				## The ball gets pushed by a force asif the mouse was 300 pixels away.
				@vel_x += -(Gosu::offset_x(dir, 300)) * @release_force
				@vel_y += -(Gosu::offset_y(dir, 300)) * @release_force         
			end
			
			@pulled = false
		end
	end
	
	### Basically the same as "check_collison_line" except the radius is different 
	### and there is no collision response
	def collision_path(x1, y1, x2, y2)  
		
		if @color != 0xffFFDDAE and @out == false
			
			vector_x = x2 - x1
			vector_y = y2 - y1
			
			point_to_vector_x = @x - x1
			point_to_vector_y = @y - y1
			
			vector_product = vector_x * point_to_vector_x + vector_y * point_to_vector_y
			
			vec_length_squared = vector_x**2 + vector_y**2
			
			projection_factor = vector_product / vec_length_squared
			
			if projection_factor > 0 and projection_factor < 1 ### If the projected point is on the line. Projection factor is between 0 and 1.
				
				projected_point_x = projection_factor * vector_x + x1
				projected_point_y = projection_factor * vector_y + y1
				
				dist_to_player = Gosu::distance(@x, @y, projected_point_x, projected_point_y)
				
				if dist_to_player < radius*2  ### this balls radius, and the cue balls radius. They are the same.
					
					@colliding = true
					
					dt = Math::sqrt((radius*2)**2 - dist_to_player**2)/Math::sqrt(vec_length_squared)
					
					## Intersection point nearest to A
					t1 = projection_factor - dt
					int_x = x1 + t1 * vector_x
					int_y = y1 + t1 * vector_y
					col_x = (@x + int_x)/2
					col_y = (@y + int_y)/2
					
					$path_blockers << [int_x, int_y, col_x, col_y]
					
				end
				
			end
		end
	end
	
	def collision_wall_path(x1, y1, x2, y2)
		
		if @pulled == true  ### Only called for the cue-ball
			
			##### COLLISION BETWEEN TWO LINE SEGMENTS
			##### Credits goes to this guy : http://stackoverflow.com/a/1968345
			x3 = @x
			y3 = @y
			
			dir = self.point_direction(@window.mouse_x, @window.mouse_y, @x, @y)
			
			x4 = @x + Gosu::offset_x(dir, 900)
			y4 = @y + Gosu::offset_y(dir, 900)
			
			s1_x = x2 - x1
			s1_y = y2 - y1
			
			s2_x = x4 - x3
			s2_y = y4 - y3
			
			s = (-s1_y * (x1 - x3) + s1_x * (y1 - y3)) / (-s2_x * s1_y + s1_x * s2_y)
			t = ( s2_x * (y1 - y3) - s2_y * (x1 - x3)) / (-s2_x * s1_y + s1_x * s2_y)
			
			if s >= 0 and s <= 1 and t >= 0 and t <= 1
				### Collision Detected
				int_x = x1 + (t * s1_x)
				int_y = y1 + (t * s1_y)
				
				$path_blockers << [int_x, int_y, 0, 0]
				
			else
				### No collison :(
			end
			
		end
		
	end
	
	def checkCollision(inst)  ### This method is only called once for each pair of balls
		
		if @x + @radius + inst.radius > inst.x and
		   @x < inst.x + @radius + inst.radius and
		   @y + @radius + inst.radius > inst.y and
		   @y < inst.y + @radius + inst.radius
			
			dist = Gosu::distance(inst.x, inst.y, @x, @y)
			if dist < (@radius + inst.radius)
				
				@collisionPointX = ((@x * inst.radius) + (inst.x * @radius))/(@radius + inst.radius)
				@collisionPointY = ((@y * inst.radius) + (inst.y * @radius))/(@radius + inst.radius)
				
				@collision_point = true
				
				new_vel_self = new_velocity(@mass, inst.mass, Vector[@vel_x, @vel_y], Vector[inst.vel_x, inst.vel_y], Vector[@x, @y], Vector[inst.x, inst.y])
				new_vel_inst = new_velocity(inst.mass, @mass, Vector[inst.vel_x, inst.vel_y], Vector[@vel_x, @vel_y], Vector[inst.x, inst.y], Vector[@x, @y])
				
				
				self.collision_response(new_vel_self)
				inst.collision_response(new_vel_inst)
				
			end
		end
	end
	
	def collision_response(new_vel)
		# @colliding = true
		
		@vel_x = new_vel[0]
		@vel_y = new_vel[1]
		
	end
	
	def new_velocity(m1, m2, v1, v2, c1, c2)
		
		f = (2*m2)/(m1+m2)  ## Number
		
		dv = v1 - v2  ### Vector
		dc = c1 - c2  ### Vector
		
		v_new = v1 - f * (dv.inner_product(dc))/(dc.inner_product(dc)) * dc  ### Vector
		
		if dv.inner_product(dc) > 0
			return v1     ### Vector
		else
			return v_new  ### Vector
		end
		
	end
	
	def get_kin
		return (@mass * (@vel_x**2+@vel_y**2))
	end
	
	def point_direction(x1, y1, x2, y2)
		return ((Math::atan2(y2-y1, x2-x1) * (180/Math::PI)) + 450) % 360;
	end
	
	def in_hole
		@x = 10 + @window.balls_in_hole*22.5
		@y = -100
		@vel_x = 0.0
		@vel_y = 0.0
		@out = true
		@window.ball_in_hole
	end
	
	def destroy
		@window.destroy_ball(self)
	end
	
end

# show the window
window = GameWindow.new
window.show