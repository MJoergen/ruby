require 'matrix'

class Ball
	
	attr_reader :x, :y, :dir, :radius, :id, :mass, :vel_x, :vel_y
	
	def initialize(window, x, y, dir, vel, rad, id, mass)
		
		@window, @x, @y, @dir, @radius, @id, @mass = window, x, y, dir, rad, id, mass
		
		## Initial values.
		@vel_x = Gosu::offset_x(@dir, vel)
		@vel_y = Gosu::offset_y(@dir, vel)
		
		@colliding = false
		@collision_point = false
		
		@collisionPointX = @x
		@collisionPointY = @y
		
		@circle_img = Gosu::Image.new("media/filled_circle.png")
	end
	
	def update
		@colliding = false
		@collision_point = false

		### Move the ball
		@x = @x + @vel_x
		@y = @y + @vel_y
		
		### Check collision with walls
        if @x > (@window.universe_width - @radius) and @vel_x > 0
			@vel_x = -@vel_x
		end
		if @x < @radius and @vel_x < 0
			@vel_x = -@vel_x
		end
		
        if @y > (@window.universe_height - @radius) and @vel_y > 0
			@vel_y = -@vel_y
		end
		
		if @y < @radius and @vel_y < 0
			@vel_y = -@vel_y
		end
	end
	
	def checkCollision(inst)  ### This method is only called once for each pair of balls
		
        sum_radius = @radius + inst.radius
		if @x + sum_radius > inst.x and
		   @x < inst.x + sum_radius and
		   @y + sum_radius > inst.y and
		   @y < inst.y + sum_radius
			
			dist = Gosu::distance(inst.x, inst.y, @x, @y)
			if dist < sum_radius
				
				@collisionPointX = (@x*inst.radius + inst.x*@radius)/sum_radius
				@collisionPointY = (@y*inst.radius + inst.y*@radius)/sum_radius
				
				@collision_point = true
				
				new_vel_self = new_velocity(@mass, inst.mass,
                                            Vector[@vel_x, @vel_y], Vector[inst.vel_x, inst.vel_y],
                                            Vector[@x, @y], Vector[inst.x, inst.y])
				new_vel_inst = new_velocity(inst.mass, @mass,
                                            Vector[inst.vel_x, inst.vel_y], Vector[@vel_x, @vel_y],
                                            Vector[inst.x, inst.y], Vector[@x, @y])
				
				self.collision_ball(new_vel_self)
				inst.collision_ball(new_vel_inst)
				
			end
		end
	end
	
	def collision_ball(new_vel)
		@colliding = true
		
		@vel_x = new_vel[0]
		@vel_y = new_vel[1]
		
		# @x = @x + @vel_x
		# @y = @y + @vel_y
		
	end
	
	def new_velocity(m1, m2, v1, v2, c1, c2)
		f = (2*m2)/(m1+m2)  ## Number
		
		dv = v1 - v2
		dc = c1 - c2
		
		v_new = v1 - f * (dv.inner_product(dc))/(dc.inner_product(dc)) * dc  ### Vector
		
        # Hvis vi allerede er på vej væk fra hinanden, så lad være med at opdatere hastigheden.
        if dv.inner_product(dc) > 0
			return v1
		else
			return v_new
		end
	end

    def draw_rot(image, x, y, color, scale=1.0, z=0)
        image.draw_rot(x + @window.width/2  - @window.camera_x,
                       y + @window.height/2 - @window.camera_y,
                       z, 0, 0.5, 0.5, scale*(@radius/50.0), scale*(@radius/50.0), color)
    end

	def draw
		if @id == 0
            # Den første bold er hvid
            draw_rot(@circle_img, @x, @y, Gosu::Color::WHITE)
		else
            # Alle andre bolde er røde!
            draw_rot(@circle_img, @x, @y, Gosu::Color::RED)
        end

        # Hvis de støder sammen, så er de grønne :-)
        if @colliding == true
            draw_rot(@circle_img, @x, @y, Gosu::Color::GREEN)
        end
        if @collision_point == true
            draw_rot(@circle_img, @collisionPointX, @collisionPointY, Gosu::Color::BLUE, 0.3, 1)
        end
	end
	
end

