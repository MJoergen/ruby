class A
    def initialize(controller,x,y)
        @controller = controller
        @x = x
        @y = y
    end
    def show
        print "A",@x,@y
    end
    def update
        show
        print "\n"
    end
    def checkCollisionA(x,y)
        return (@x == x and @y == y)
    end
end

class B
    def initialize(controller,x,y)
        @controller = controller
        @x = x
        @y = y
    end
    def collisionAB(inst)
        print "Collision: "
        self.show
        print " "
        inst.show
        print "\n"
    end
    def show
        print "B",@x,@y
    end
    def update
        show
        print "\n"
        @controller.checkCollisionA(@x,@y, self.method(:collisionAB))
    end
end

class C
    def initialize(controller,x,y)
        @controller = controller
        @x = x
        @y = y
    end
    def show
        print "C",@x,@y
    end
    def update
        show
        print "\n"
    end
end

class Controller
    def initialize
        @insts = []
        @insts.push(A.new(self,0,4))
        @insts.push(A.new(self,1,3))
        @insts.push(B.new(self,2,2))
        @insts.push(B.new(self,3,1))
        @insts.push(B.new(self,0,4))
        @insts.push(C.new(self,0,4))
        @insts.push(C.new(self,6,3))

        @insts.each     { |inst|  inst.update }
    end

    def checkCollisionA(x,y,meth)
        @insts.each     { |inst|  
            if inst.respond_to?(:checkCollisionA)
                if inst.checkCollisionA(x,y)
                    meth.call(inst)
                end
            end
        }
    end

end

Controller.new
