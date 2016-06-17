class Timer
	def initialize(delay, meth, arg)
        @delay = delay
        @meth = meth
        @arg = arg
    end

    def update
        if (@delay > 0) then
            @delay -= 1
            return false
        end

        @meth.call(@arg)
        return true
    end
	
	def getvalue
		return @delay
	end
end
