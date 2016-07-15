class Score

    attr_reader :player, :bot

    def initialize(window)
        @window = window
        @font   = Gosu::Font.new(@window, Gosu::default_font_name, 24)
        @dead   = Gosu::Sample.new("media/dead.wav")
        @player = 5
        @bot    = 5
    end

    def dead_player
        @player -= 1
        @dead.play
    end

    def dead_bot
        @bot -= 1
        @dead.play
    end

    def draw
        @font.draw("#{@player}", 100, 100, 2)
        @font.draw("#{@bot}",    400, 100, 2)
    end

end
