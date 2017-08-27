require 'rubygems'
require 'gosu'
require 'matrix'

include Gosu

class GameWindow < Gosu::Window
	
	WIDTH = 640
	HEIGHT = 480
	TITLE = "3d"
	
	def initialize
		
		super(WIDTH, HEIGHT, false)
		self.caption = TITLE
		
		@font      = Gosu::Font.new(self, Gosu::default_font_name, 16)
		@smallfont = Gosu::Font.new(self, Gosu::default_font_name, 14)
		@circle    = Gosu::Image.new("circle-100px.png")
		@point     = Gosu::Image.new("Point2.png")
		
		@SIZE = 30           ## Circle size in pixels

        @cube_center = Vector[0, 0, 50]
        @cube_size   = 60

        ## List of points in 3D space.
        @points = [(@cube_center + Vector[ 1, 1, 1]*@cube_size), ## 0
                   (@cube_center + Vector[ 1, 1,-1]*@cube_size), ## 1
                   (@cube_center + Vector[ 1,-1, 1]*@cube_size), ## 2
                   (@cube_center + Vector[ 1,-1,-1]*@cube_size), ## 3
                   (@cube_center + Vector[-1, 1, 1]*@cube_size), ## 4
                   (@cube_center + Vector[-1, 1,-1]*@cube_size), ## 5
                   (@cube_center + Vector[-1,-1, 1]*@cube_size), ## 6
                   (@cube_center + Vector[-1,-1,-1]*@cube_size)] ## 7 

        ## List of sides: four numbers represent corners, one number represents the color
		@sides = [[0, 1, 5, 4, 0xffffffff], ## white
                  [1, 3, 7, 5, 0xffffff00], ## yellow
                  [3, 2, 6, 7, 0xffff0000], ## red
                  [2, 0, 4, 6, 0xff0000ff], ## blue
                  [4, 5, 7, 6, 0xff00ff00], ## green
                  [1, 0, 2, 3, 0xff00ffff]] ## cyan

        ## Defines the location of the camera (view point)
        @camera_type = Struct.new(:position, :angle, :zoom)
        @camera = @camera_type.new(Vector[0, 0, -300],      ## Position of camera
                                   [0, 0, 0],               ## Angles of rotation
                                   0.8/300)                 ## Scale (zoom)
	end
	
	def update
		
        ## Move the camera around
        if button_down? Gosu::KbG then @camera[:position] -= Vector[2, 0, 0] end
        if button_down? Gosu::KbJ then @camera[:position] += Vector[2, 0, 0] end
        if button_down? Gosu::KbY then @camera[:position] -= Vector[0, 2, 0] end
        if button_down? Gosu::KbH then @camera[:position] += Vector[0, 2, 0] end
        if button_down? Gosu::KbT then @camera[:position] -= Vector[0, 0, 2] end
        if button_down? Gosu::KbU then @camera[:position] += Vector[0, 0, 2] end
		
        ## Rotate the camera
		if button_down? Gosu::Kb1 then @camera[:angle][2] -= 0.01 end
		if button_down? Gosu::Kb2 then @camera[:angle][2] += 0.01 end
		if button_down? Gosu::Kb3 then @camera[:angle][1] -= 0.01 end
		if button_down? Gosu::Kb4 then @camera[:angle][1] += 0.01 end
		if button_down? Gosu::Kb5 then @camera[:angle][0] -= 0.01 end
		if button_down? Gosu::Kb6 then @camera[:angle][0] += 0.01 end
		
        ## Change the camera zoom
		if button_down? Gosu::KbO then @camera[:zoom] *= 1.02 end 
		if button_down? Gosu::KbP then @camera[:zoom] /= 1.02 end 
		
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
	end

    def rotate(x, y, angle)
        rx = x * Math.cos(angle) - y * Math.sin(angle) - x
        ry = x * Math.sin(angle) + y * Math.cos(angle) - y 
        return [rx, ry]
    end

    def calc_3d(point, camera)
        ## Calculate position relative to camera
        offset = point - camera[:position]

        ## Rotate position relative to camera angle
        xd = offset[0]
        yd = offset[1]
        zd = offset[2]
        zx, zy = rotate(xd,    yd,    camera[:angle][2])
        yx, yz = rotate(xd+zx, zd,    camera[:angle][1])
        xy, xz = rotate(yd+zy, zd+yz, camera[:angle][0])
        rot_point = offset + Vector[yx+zx, zy+xy, xz+yz] 

        dist = rot_point.norm

        ## Perform 3D -> 2D projection
        z = rot_point[2]
        x = rot_point[0] / z / camera[:zoom]
        y = rot_point[1] / z / camera[:zoom]

        return [x, y, z, dist]
    end
	
	def draw
		
        @square_corners = []

        ## Draw each point
		for n in 1..8

            point = @points[n-1]
            x, y, z, dist = calc_3d(point, @camera)

			# Drawing the circles in each corner
            if z > 0
                factor = (@SIZE / z / @camera[:zoom])/100.0
                @circle.draw_rot(x+320, y+240, -dist,   # x, y, z
                                 0, 0.5, 0.5,           # angle, center_x, center_y
                                 factor, factor)        # factor_x, factor_y
            end

			@square_corners.push([x,y])
		end
		
        ## Draw each side
        for n in 1..6
            p0, p1, p2, p3, color = @sides[n-1]

            ## Find middle of side
            middle = (@points[p0] + @points[p1] + @points[p2] + @points[p3]) / 4

            x, y, z, dist = calc_3d(middle, @camera)
            
            draw_quad(@square_corners[p0][0]+320, @square_corners[p0][1]+240, color, 
                      @square_corners[p1][0]+320, @square_corners[p1][1]+240, color, 
                      @square_corners[p2][0]+320, @square_corners[p2][1]+240, color, 
                      @square_corners[p3][0]+320, @square_corners[p3][1]+240, color,
                      -dist)
                     
            self.draw_line(@square_corners[p0][0]+320, @square_corners[p0][1]+240, 0xff000000, 
                           @square_corners[p1][0]+320, @square_corners[p1][1]+240, 0xff000000, 
                           -dist)
            
            self.draw_line(@square_corners[p1][0]+320, @square_corners[p1][1]+240, 0xff000000, 
                           @square_corners[p2][0]+320, @square_corners[p2][1]+240, 0xff000000, 
                           -dist)
                           
            self.draw_line(@square_corners[p2][0]+320, @square_corners[p2][1]+240, 0xff000000, 
                           @square_corners[p3][0]+320, @square_corners[p3][1]+240, 0xff000000, 
                           -dist)
                           
            self.draw_line(@square_corners[p3][0]+320, @square_corners[p3][1]+240, 0xff000000, 
                           @square_corners[p0][0]+320, @square_corners[p0][1]+240, 0xff000000, 
                           -dist)
        end
		
		@smallfont.draw("@CAMX = #{@camera[:position][0]}", 10, 120, 0, 1, 1, 0xffffffff)
		@smallfont.draw("@CAMY = #{@camera[:position][1]}", 10, 140, 0, 1, 1, 0xffffffff)
		@smallfont.draw("@CAMZ = #{@camera[:position][2]}", 10, 160, 0, 1, 1, 0xffffffff)
		
	end
	
end

# show the window
window = GameWindow.new
window.show
