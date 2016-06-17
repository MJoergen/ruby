# This adds the "gosu" library to the game, which enables various extra features!
require 'gosu'
# These are nessecary for THIS code/file to cooperate with the other files/codes
require_relative 'timer.rb'
require_relative 'player.rb'
require_relative 'nimph.rb'
require_relative 'fighter.rb'
require_relative 'bomb.rb'
require_relative 'whale.rb'
require_relative 'bigbomb.rb'
require_relative 'bigwhale.rb'
require_relative 'supnimph.rb'
require_relative 'attackspeed.rb'
require_relative 'minion.rb'
require_relative 'spark.rb'
require_relative 'tail.rb'
# This adds the actual "object" to the game, which in this case works as a controler!	
class GameWindow < Gosu::Window
  # This is the event that occurs when you start the game, like when the object is "created"
  attr_reader :player, :energy, :fighter, :menu, :slot1, :slot2, :slot3, :menuwaiting, :graphics
  
  def initialize
	super(640, 400, false)
    self.caption = "Gosu Tutorial Game"
    
	@background_image = Gosu::Image.new(self, "media/Psuedo.png", true)
	@menutext = Gosu::Image.new(self, "media/Text.png", true)
	@graphic = Gosu::Image.new(self, "media/Graphic1.png", true)
	@box1 = Gosu::Image.new(self, "media/Square.png", true)
	@box2 = Gosu::Image.new(self, "media/Square_Lime.png", true)
	@box3 = Gosu::Image.new(self, "media/Square_Cyan.png", true)
	@transparentbox1 = Gosu::Image.new(self, "media/Transparentbox1.png", true)
	@transparentbox2 = Gosu::Image.new(self, "media/Transparentbox2.png", true)
	@transparentbox3 = Gosu::Image.new(self, "media/Transparentbox3.png", true)
	@graphic2 = Gosu::Image.new(self, "media/Graphic2.png", true)
	@graphic2_lime = Gosu::Image.new(self, "media/Graphic2_Lime.png", true)
	@graphic2_cyan = Gosu::Image.new(self, "media/Graphic2_Cyan.png", true)
	@text_x = Gosu::Image.new(self, "media/Press_X.png", true)
	@text_z = Gosu::Image.new(self, "media/Press_Z.png", true)
	@blackbox = Gosu::Image.new(self, "media/BlackBox.png", true)
    @insts = []
	@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
	@bufftimer = rand(1500)
    @timers = []
	@menu = true
	@room = 0
	@level = 1
	@selectslot = 1
	@slot1 = 1 #Primary
	@slot2 = 1 #Secondary
	@slot3 = 1 #Ability
	@fighter = Fighter.new(self)
	@player = Player.new(self)
	@ary = [1, 2, 3, 5, 7, 7, 5, 5] #<-------- Used for testing
	@sendback = false
	@menutimer = 0
	@menuwaiting = false
	@graphics = 0
  end

  def startTimer(delay, meth, arg)
	timer = Timer.new(delay, meth, arg)
    @timers.push(timer)
	return timer
  end
  
  def startmenu
	@menu = true
	@room = 1
	self.killfighter
	@menutimer = 0
	@menuwaiting = false
  end
  
  def killfighter
	@fighter.kill
  end
  
  def startroom1
	@player.create
	@fighter.create
	@room = 2
	@menu = false
  end
  
  def startroom2
    @menu = false
	self.spawn_minions(2)
	@room = 3
	@player.create
  end
  
  def startroom3
    @menu = false
	@player.create
	self.spawn_minions(5)
	@room = 4
  end
  
  def draw_bar(x1,y1,x2,y2,value,color1,color2,color3,border)
	# Draw some certain bar for certain stuff!
	self.draw_quad(x1,y1,color1,x1+(x2-x1)*value,y1,color1,x1,y2,color1,x1+(x2-x1)*value,y2,color1,4)
	self.draw_quad(x1,y1,color2,x2,y1,color2,x1,y2,color2,x2,y2,color2,3)
	if border == true
		self.draw_quad(x1-1,y1-1,color3,x2+1,y1-1,color3,x1-1,y2+1,color3,x2+1,y2+1,color3,2)
	end
  end
  
  def makebuff
	
	@type = "SEH"[rand(3)]
	@attackspeed = Attackspeed.new(self ,@type)
	@attackspeed.warp(rand(640), rand(400))
	
	return @attackspeed
  end
  
  def spawn_minions(amount)
	for i in 1..(amount)
		create_instance(minion)
	end
  end
  
  def minion
	@minion = Minion.new(self)
    @minion.warp(rand(440)+100, rand(200)+100)
	return @minion
  end
  
  def tail
	@tail = Tail.new(self, 300+rand(40), 180+rand(40))
	return @tail
  end
  
  def player_pos_x
	return @player.x
  end
  
  def player_pos_y
	return @player.y
  end
  
  def fighterexist
	if @fighter.dead == false and @menu == false
		return true
	end
  end
  
  def playerexist #this is basically only "true" when you play the first challenge against this enemy. 
                  #It controls the update and draw methods for fighter.
	if @player.dead == false and @menu == false
		return true
	end
	
  end

  def create_instance(inst)
    @insts.push(inst)
  end
  def destroy_instance(inst)
    @insts.delete(inst)
  end
  
  def collisionminion(x, y)
	@insts.each { |inst|  inst.update }
	return Gosu::distance(@fighter.x, @fighter.y, x, y) < 17
  end

  def collisionfighter(x, y)
    return Gosu::distance(@fighter.x, @fighter.y, x, y) < 17
  end

  def collisionplayer(x, y, dist)
	return Gosu::distance(@player.x, @player.y, x, y) < dist
  end
  
  def menutimer(amount)
	@menutimer = amount
	@menuwaiting = true
  end

  # This event is checked 60 times per second.
  def update
	
	if @menu == false
		if @level == 2 or @level == 3
			if !minion_exist and @menuwaiting == false
				self.menutimer(60)
			end
		end
		
		@menutimer = [0, @menutimer-1].max #Controls the menutimer which delays the "startmenu" method
		
		if @menuwaiting == true and @menutimer == 0
			self.startmenu
			@menuwaiting = false
		end
		
		@timers.reject! { |timer| timer.update }
		@bufftimer = [@bufftimer - 1 ,0].max
		if @bufftimer <= 0
			create_instance(makebuff)
			@bufftimer = rand(1500)
		end
		
		if playerexist
			@player.update
		end
		
		if fighterexist
			@fighter.update
		end
	end
	
	@insts.each     { |inst|  inst.update }
  end
  
  # This controls the graphics in the game. Also checks around 60 times per second...
  def draw
	
	if @menu == false
		if playerexist
			@player.draw
			@font.draw("Energy: #{@player.energy.round}/#{@player.energymax}", 10, 5, 2, 1.0, 1.0, 0xffffff00)
		end
		if fighterexist
			@fighter.draw
		end
	end
	
	#@font.draw("fighter dead: #{@fighter.dead}", 450, 30, 3, 1.0, 1.0, 0xffffff00)
	#font.draw("room #{@room}", 450, 24, 3, 1.0, 1.0, 0xffffff00)
	
	if @menu == true
		if @room == 1
			
			@text_z.draw(460, 340, 1)
			@text_x.draw(460, 310, 1)
			@menutext.draw(235, 30, 1)
			@graphic.draw(170, 3, 1);
			@graphic2.draw(@level*60-40, 200, 1)
			
			@box1.draw(20, 200, 2)
			@font.draw("1", 36, 213, 3, 1.0, 1.0, 0xffffdc96)
			
			@box1.draw(80, 200, 2)
			@font.draw("2", 96, 213, 3, 1.0, 1.0, 0xffffdc96)
			
			@box1.draw(140, 200, 2)
			@font.draw("3", 156, 213, 3, 1.0, 1.0, 0xffffdc96)
			
			@box1.draw(200, 200, 2)
			@font.draw("4", 216, 213, 3, 1.0, 1.0, 0xffffdc96)
			
			@box1.draw(260, 200, 2)
			@font.draw("5", 276, 213, 3, 1.0, 1.0, 0xffffdc96)
		end
		if @room == 0
			
			@font.draw("Move your selection with WASD", 410, 10, 3, 1.0, 1.0, 0xffffff00)
			@text_z.draw(460, 340, 1)
			@graphic2.draw((@slot1-1)*60+50, 75, 1)
			@graphic2_lime.draw((@slot2-1)*60+50, 175, 1)
			@graphic2_cyan.draw((@slot3-1)*60+50, 275, 1)
			@blackbox.draw(340, 100, 3)
			
			case(@selectslot)
			when 1
				@transparentbox1.draw(20, 60, 3)
				case(@slot1)
				when 1
				@font.draw("This laser weapon", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("shoots rapidly with", 397, 144, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("average to low damage...", 397, 160, 3, 1.0, 1.0, 0xffffffff)
				when 2
				@font.draw("This weapon causes", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("electricity to burst", 397, 144, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("from the player", 397, 160, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("and deal damage", 397, 176, 3, 1.0, 1.0, 0xffffffff)
				when 3
				@font.draw("Nothing here...", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				end
			when 2
				@transparentbox2.draw(20, 160, 3)
				case(@slot2)
				when 1
				@font.draw("This ultimate shoots out", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("a big heatseeking missile", 397, 144, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("that deals big damage", 397, 160, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("and slows the enemy.", 397, 176, 3, 1.0, 1.0, 0xffffffff)
				when 2
				@font.draw("Nothing here...", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				when 3
				@font.draw("Nothing here...", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				end
			when 3
				@transparentbox3.draw(20, 260, 3)
				case(@slot3)
				when 1
				@font.draw("I still haven't added", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				@font.draw("an ability...", 397, 144, 3, 1.0, 1.0, 0xffffffff)
				when 2
				@font.draw("Nothing here...", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				when 3
				@font.draw("Nothing here...", 397, 128, 3, 1.0, 1.0, 0xffffffff)
				end
			end
			
			@box1.draw(50, 75, 2)
			@font.draw("1", 66, 88, 3, 1.0, 1.0, 0xffffdc96)
			@box1.draw(110, 75, 2)
			@font.draw("2", 126, 88, 3, 1.0, 1.0, 0xffffdc96)			
			@box1.draw(170, 75, 2)
			@font.draw("3", 186, 88, 3, 1.0, 1.0, 0xffffdc96)
			
			@box2.draw(50, 175, 2)
			@font.draw("1", 66, 188, 3, 1.0, 1.0, 0xff22B14C)
			@box2.draw(110, 175, 2)
			@font.draw("2", 126, 188, 3, 1.0, 1.0, 0xff22B14C)
			@box2.draw(170, 175, 2)
			@font.draw("3", 186, 188, 3, 1.0, 1.0, 0xff22B14C)
			
			@box3.draw(50, 275, 2)
			@font.draw("1", 66, 288, 3, 1.0, 1.0, 0xff00A2E8)
			@box3.draw(110, 275, 2)
			@font.draw("2", 126, 288, 3, 1.0, 1.0, 0xff00A2E8)
			@box3.draw(170, 275, 2)
			@font.draw("3", 186, 288, 3, 1.0, 1.0, 0xff00A2E8)
		end
	else
		#@insts.each { |inst| inst.draw } # Draw all instances
	end
	
	@insts.each { |inst| inst.draw } # Draw all instances
	@background_image.draw(0, 0, 0);
  end

  # This checks when you press ESC
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
	
	if id == Gosu::KbG then
		if @graphics == 1
			@graphics = 0
		else
			@graphics = 1
		end
	end
	
	if @menu == true
		if id == Gosu::KbC
		self.create_instance(tail)
		end
		if id == Gosu::KbA
			if @room == 1
				@level = [@level - 1 ,1].max
			end
			if @room == 0
				case(@selectslot)
				when 1
					@slot1 = [@slot1 - 1 ,1].max
				when 2
					@slot2 = [@slot2 - 1 ,1].max
				when 3
					@slot3 = [@slot3 - 1 ,1].max
				end
			end
		end
		if id == Gosu::KbD
			if @room == 1
				@level = [@level + 1 ,5].min
			end
			if @room == 0
				case(@selectslot)
				when 1
					@slot1 = [@slot1 + 1 ,3].min
				when 2
					@slot2 = [@slot2 + 1 ,3].min
				when 3
					@slot3 = [@slot3 + 1 ,3].min
				end
			end
		end
		if id == Gosu::KbZ
			if @room == 1
				self.levelstart(@level)
			end
			if @room == 0
				@room = 1
			end
		end
		if id == Gosu::KbS
			if @room == 0
				@selectslot = [@selectslot + 1 ,3].min
			end
		end
		if id == Gosu::KbW
			if @room == 0
				@selectslot = [@selectslot - 1 ,1].max
			end
		end
		if id == Gosu::KbX
			if @room == 1
				@room = 0
			end
		end
	end
  end
  
  def levelstart(level)
	
	case(level)
	when 1
		self.startroom1
	
	when 2
		self.startroom2
		
	when 3
		self.startroom3
		
	end

  end
  
  def minion_exist
	 count=0
     @insts.each     { |inst|  
        if inst.respond_to?(:minion)
			count += 1
        end
    }
	return count >= 1
  end
  
  def checkCollision(x,y,meth,collision)
	@insts.each     { |inst|  
        if inst.respond_to?(collision)
            if inst.send collision,x,y
                meth.call(inst)
            end
        end
    }
  end
  
  def find_target
	@targets = []
	if fighterexist
		@targets.push(fighter) # Fighter is always a target
	end
	@insts.each     { |inst|  
        if inst.respond_to?(:targetable) # Could be minion
			@targets.push(inst)
			#inst.targetable(sender)
			#inst.send meth,sender
			#meth.call(sender)
        end
    }
	return @targets
  end
  
  
end

window = GameWindow.new
window.show
