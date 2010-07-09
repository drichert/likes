# Dan Richert                                                        
# dan.richert@gmail.com    

class Like
    attr_writer :p, :others
    attr_reader :p, :pl, :s, :ndx, :matchcount, :can_move, :chunk, :recently_mutated
    
    def initialize(text, ndx=0, lookahead=50)
        @ndx = ndx
        @lookahead = lookahead
        @text = text
        @matchcount = 0 
        @mutations = 0
        @s = '' 
        @can_move = false
        @gap = ".*?"
        @recently_mutated = 0
        gen     #only runs gen at initialization
    end
    
    def gen
        specials = /\(|\)|\[|\]|\{|\}|\+|\\|\^|\$|\*|\?/
        ndx = rand(@text.length)
        word = @text[ndx..ndx+3]
        word = word.gsub(specials, '')
        @pl = []
        word.each_byte {|b| @pl.push(b.chr)}
        @pl.insert(rand(@pl.length-2)+1, @gap)  #insert gap
        @p = Regexp.new(@pl.join)
        return @p
    end
    
    def _read
        @chunk = @text[@ndx..@ndx+@lookahead]
        
        if @chunk =~ @p 
            @can_move = true
            @matchcount += 1
            @s = $&
        else 
            @can_move = false
            @s = ''
            mutate 
        end
    end

    def mutate
        @mutations += 1
        @recently_mutated = 3
        
        inprox = []
        
        @others.each do |obj|
            dif = obj.ndx-@ndx
            if dif.abs<@lookahead and obj!=self: inprox.push(obj) end
        end
        
        temp = 0
        winner = nil
        inprox.each do |obj|
            if obj.matchcount>=temp  
                temp = obj.matchcount
                winner = obj
            end
        end
        
        @pl.delete(@gap)   #removes gap
        
        if winner          #won't try if there's no other objects in proximity
            winner_ndx = rand(winner.pl.length) 
            replace_ndx = rand(@pl.length)
            @pl[replace_ndx] = winner.pl[winner_ndx]
            @pl.insert(rand(@pl.length-2)+1, @gap)  #reinsert gap
            @p = Regexp.new(@pl.join)   
        end
    end
             
    def move
        if @can_move
            @ndx += @lookahead
            if @recently_mutated>0: @recently_mutated -= 3 end
            if @ndx == @text.length: @ndx = 0 end
        end
    end

end
                    
