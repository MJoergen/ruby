require 'rubygems'
require 'gosu'
require 'matrix'
require_relative 'Ball'

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

        @point_img = Gosu::Image.new("media/Point2.png")
        @pocket_corner_img = Gosu::Image.new("media/pocket_corner.png")
        @pocket_middle_img = Gosu::Image.new("media/pocket_middle.png")
        @circle_img = Gosu::Image.new("media/filled_circle.png")
        @stripe_img = Gosu::Image.new("media/billiard_circle.png")

        $hit_sound = Gosu::Sample.new("media/hit_sound.wav")

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

        $walls_array_path = [[26, 11, $universe_width/2-21, 11],   #### Top left wall
                             [$universe_width/2+21, 11, $universe_width-26, 11],   #### Top Right
                             [26, $universe_height-11, $universe_width/2-21, $universe_height-11],   ### Bottom left
                             [$universe_width/2+21, $universe_height-11, $universe_width-26, $universe_height-11],  ### Bottom right
                             [11, 26, 11, $universe_height-26],   ### Left
                             [$universe_width-11, 26, $universe_width-11, $universe_height-26]] ### Right

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

        # for i in 0..$walls_array_path.length-1
        # draw_line($walls_array_path[i][0]+$window_width/2-$camera_x, $walls_array_path[i][1]+$window_height/2-$camera_y, 0xffffffff, $walls_array_path[i][2]+$window_width/2-$camera_x, $walls_array_path[i][3]+$window_height/2-$camera_y, 0xffffffff, 3)
        # end
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
            $balls.each     { |inst|  inst.collision_wall_path($walls_array_path[i][0], $walls_array_path[i][1], $walls_array_path[i][2], $walls_array_path[i][3], i)}
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

# show the window
window = GameWindow.new
window.show

