require_relative 'geom.rb'

class Crate

	attr_reader :x, :y, :width, :height

	def initialize(window, x, y)
		@window = window
		@x = x
		@y = y
		@width = 34
		@height = 34
		#@light = @window.create_light(@x+@width/2, @y+@height/2, 1, 0xff909000, 1, false)
	end
	
	def update
		
	end
	
	def particle(x, y, color, img, scale)
		i = Particle.new(@window, x, y, color, img, scale)
		return i
	end
	
	def destroy_at_position(x, y)
		if @x == x.to_i and @y == y.to_i
			self.destroy
			return true
		end
	end
	
	def destroy
		for i in 0..8
			$particles.push(particle(@x+(@width/3)*(i%3 + 1) - @width/6, @y+(@height/3)*(((i+0.9)/3).ceil) - @height/6, 0xffffffff, @window.crate_tilearray[i], 1))
		end
		#@window.destroy_light(@light)
	end
	
	def point_direction(x1, y1, x2, y2)
		return (((Math::atan2(y2-y1, x2-x1)* (180/Math::PI))) + 450) % 360;
	end
	
	def get_dir_dif(dir1,dir2)
		# Only works with directions between 0 - 360
		
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
	
	def draw
		@window.crate_img.draw(@x-1+@window.width/2-@window.player_x, @y-1+@window.height/2-@window.player_y, 5.8)
	end
	
	def checkCollisionWeapon(cx, cy, radius, angle_start, angle_end, type) # This is basically one big cone-collision-check.
		
		cone_center_angle = (angle_start + angle_end)/2 # The center angle of the cone
		cone_angle_radius = cone_center_angle - angle_start # Always positive
		cone_center_angle = cone_center_angle % 360 # Sync the angle between 0 - 360
		
		
		if (Gosu::distance(@x, @y, cx, cy) < radius and 
			   (get_dir_dif(point_direction(cx, cy, @x, @y), cone_center_angle).abs < cone_angle_radius or 
			    point_in_rectangle(cx + Gosu::offset_x(angle_start, radius), cy + Gosu::offset_y(angle_start, radius), @x, @y, @x+@width+radius, @y+@height+radius) or 
				point_in_rectangle(cx + Gosu::offset_x(angle_end, radius), cy + Gosu::offset_y(angle_end, radius), @x, @y, @x+@width+radius, @y+@height+radius))) or # Four corners
		   (Gosu::distance(@x+@width, @y, cx, cy) < radius and 
		       (get_dir_dif(point_direction(cx, cy, @x+@width, @y), cone_center_angle).abs < cone_angle_radius or 
			    point_in_rectangle(cx + Gosu::offset_x(angle_start, radius), cy + Gosu::offset_y(angle_start, radius), @x-radius, @y, @x+@width, @y+@height+radius) or 
				point_in_rectangle(cx + Gosu::offset_x(angle_end, radius), cy + Gosu::offset_y(angle_end, radius), @x-radius, @y, @x+@width, @y+@height+radius))) or # -||-
		   (Gosu::distance(@x+@width, @y+@height, cx, cy) < radius and 
		       (get_dir_dif(point_direction(cx, cy, @x+@width, @y+@height), cone_center_angle).abs < cone_angle_radius or 
			    point_in_rectangle(cx + Gosu::offset_x(angle_start, radius), cy + Gosu::offset_y(angle_start, radius), @x-radius, @y-radius, @x+@width, @y+@height) or 
				point_in_rectangle(cx + Gosu::offset_x(angle_end, radius), cy + Gosu::offset_y(angle_end, radius), @x-radius, @y-radius, @x+@width, @y+@height))) or # -||-
		   (Gosu::distance(@x, @y+@height, cx, cy) < radius and 
		       (get_dir_dif(point_direction(cx, cy, @x, @y+@height), cone_center_angle).abs < cone_angle_radius or 
			    point_in_rectangle(cx + Gosu::offset_x(angle_start, radius), cy + Gosu::offset_y(angle_start, radius), @x, @y-radius, @x+@width+radius, @y-radius) or 
				point_in_rectangle(cx + Gosu::offset_x(angle_end, radius), cy + Gosu::offset_y(angle_end, radius), @x, @y-radius, @x+@width+radius, @y-radius))) or # -||-
		    
			cone_in_rectangle_sides(cx, cy, radius, angle_start, angle_end, @x, @y, @width, @height)
				
				coords = [@x, @y, @window.my_id]
				@window.send_pack(coords.join(' '), true, 25) # These coords are used to destroy the crate on other clients aswell
				self.destroy # Sadly that means, that two crates on the same coords will be destroyed no matter what.
				return true
		end
	end
	
	def cone_in_rectangle_sides(cone_x, cone_y, radius, angle_start, angle_end, rec_x, rec_y, rec_width, rec_height) # This checks the collision on the sides only (excl. corners).
		cone_point_start_x = cone_x + Gosu::offset_x(angle_start, radius)
		cone_point_start_y = cone_y + Gosu::offset_y(angle_start, radius)
		cone_point_end_x = cone_x + Gosu::offset_x(angle_end, radius)
		cone_point_end_y = cone_y + Gosu::offset_y(angle_end, radius)
		
		# These statements extend the given rectangle (horizontally or vertically) with the radius of the cone 
		# and checks if the center on the cone is within the extended rectangles to see if the cone is within range of the rectangle sides.
		if cone_x.between?(rec_x-radius, rec_x+rec_width+radius) and cone_y.between?(rec_y, rec_y+rec_height) # Horizontally extended rectangle
			if cone_x < rec_x + rec_width/2
				side_angle = 0 # the angle from the center of the cone, to the side
				if side_angle.between?(angle_start, angle_end) or
				   point_in_rectangle(cone_point_start_x, cone_point_start_y, rec_x, rec_y-radius, rec_x+rec_width+radius, rec_y+rec_height+radius) or
				   point_in_rectangle(cone_point_end_x, cone_point_end_y, rec_x, rec_y-radius, rec_x+rec_width+radius, rec_y+rec_height+radius)
						return true
				end
			else
				side_angle = 180 # the angle from the center of the cone, to the side
				if side_angle.between?(angle_start, angle_end)
				   point_in_rectangle(cone_point_start_x, cone_point_start_y, rec_x-radius, rec_y-radius, rec_x+rec_width, rec_y+rec_height+radius) or
				   point_in_rectangle(cone_point_end_x, cone_point_end_y, rec_x-radius, rec_y-radius, rec_x+rec_width, rec_y+rec_height+radius)
						return true
				end
			end
		end
		if cone_x.between?(rec_x, rec_x+rec_width) and cone_y.between?(rec_y-radius, rec_y+rec_height+radius) # Vertically extended rectangle
			if cone_y < rec_y + rec_height/2
				side_angle = 90 # the angle from the center of the cone, to the side
				if side_angle.between?(angle_start, angle_end)
				   point_in_rectangle(cone_point_start_x, cone_point_start_y, rec_x-radius, rec_y, rec_x+rec_width+radius, rec_y+rec_height+radius) or
				   point_in_rectangle(cone_point_end_x, cone_point_end_y, rec_x-radius, rec_y, rec_x+rec_width+radius, rec_y+rec_height+radius)
						return true
				end
			else
				side_angle = 270 # the angle from the center of the cone, to the side
				if side_angle.between?(angle_start, angle_end)
				   point_in_rectangle(cone_point_start_x, cone_point_start_y, rec_x-radius, rec_y-radius, rec_x+rec_width+radius, rec_y+rec_height) or
				   point_in_rectangle(cone_point_end_x, cone_point_end_y, rec_x-radius, rec_y-radius, rec_x+rec_width+radius, rec_y+rec_height)
						return true
				end
			end
		end
	end
	
    def checkCollision(cx, cy, radius) # This is a collision detection between a circle and a rectangle.
        if Geom.collision_circle_box(cx, cy, radius, @x, @y, @width, @height) != 0
			return true
		end
    end
	
	def point_in_rectangle(point_x, point_y, first_x, first_y, second_x, second_y)
		if Geom.point_in_rectangle(point_x, point_y, first_x, first_y, second_x, second_y) != 0
			return true
		end
	end
	
end
