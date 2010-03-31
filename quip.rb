bm = false
module Shuffle
private
  @array
  @mixed
  def mix()
    @array.each {|a|
      r = rand(@array.nitems)
      if @mixed[r]==nil
        @mixed[r] = a
      else
        redo
      end
    }
    @mixed.compact!
  end
  def init()
    @array = self.to_a
    raise Exception.new("must define to_a!") unless @array
    @mixed = Array.new
  end
public
  def shuffle()
    init
    mix
    return @mixed
  end
  def shuffle!()
    init
    mix
    @array = @mixed
  end
end

class Switch2
private
  def initialize(to, from)

    if to.class != Array && from.class != Array
      raise Exception.new("Switch#initialize - Args must be arrays")
    end
    if to.size != from.size
      raise Exception.new("Switch@initialize - Args must be of equal size")
    end
    @to, @from = to, from
    @content = String.new
    @mixedContent = String.new
  end
  def getTo(from)
    lwrCh = from.downcase
    i = 0
    lwr = true if from == lwrCh #this is ghetto, I need to make my own string class
    @from.each {|a|
      if lwrCh == a
        if lwr
          return @to[i]
        else
          return @to[i].upcase
        end
      else
        i+=1
      end
    }
    return from
  end
  

public
  def <<(string)
    if string.class != String
      raise Exception.new("Switch#<<(arg) -- arg must be a string")
    end
    @content<<string
    trade
  end
  def trade()
    @content.split(//).each {|a|
      @mixedContent<<getTo(a)
    }
  end
  def to_s
    return @mixedContent
  end
end

class Switch
private
  #I need to make a translation class
  def initialize(to, from)

    if to.class != Array && from.class != Array
      raise Exception.new("Switch#initialize - Args must be arrays")
    end
    if to.size != from.size
      raise Exception.new("Switch#initialize - Args must be of equal size")
    end
    print "\n", from.inspect, "\n", to.inspect, "\n"
    @theHash = Hash.new
    to.size.times {|x|
      @theHash[from[x]] = to[x]
    }
    
    @content = String.new
    @mixedContent = String.new
  end
  def getTo(from)
  #puts from
    lwrCh = from.downcase
    lwr = true if from == lwrCh #this is ghetto, I need to make my own string class
    begin
      raise Exception.new(from, " not in hash") unless @theHash.has_key?(lwrCh)
      if lwr
        return @theHash[lwrCh]
      else
        return @theHash[lwrCh].upcase
      end
    rescue
      return from
    end
  end
public
  def <<(string)
    if string.class != String
      raise Exception.new("Switch#<<(arg) -- arg must be a string")
    end
    @content<<string
    trade
  end
  def []=(key,value)
    
    @theHash[key]=value
    trade
  end
  def trade()
    @content.split(//).each {|a|
      @mixedContent<<getTo(a)
    }
  end
  def to_s
    return @mixedContent
  end
end

class Quip
  include Shuffle
  def initialize()
    @inContents = String.new
    @fileIn = File.new("inTest.txt", "r")
    @fileOut = File.new("outTest.txt", "w")
    @alphabet = Array.new
    @mixed = Array.new
    ('a'..'z').each {|a| @alphabet<<a}
    @mixed = shuffle
    @switcher = Switch.new(@mixed,@alphabet)
    
    quipFile

    finalize
  end
  def finalize
    @fileIn.close
    @fileOut.close
  end
  def quipFile
    @inContents<<@fileIn.gets(nil) #add some error handling here
    @switcher<<@inContents
    @fileOut<<@switcher.to_s       #and here
  end
  def to_a
    return @alphabet
  end
end

class Tally
  def initialize
    @tally = Hash.new
  end
  def <<(str)
    if @tally[str].nil?
      @tally[str] = 1
    else
      @tally[str] +=1 
    end
  end
  def init(str)
    @tally[str] = 0 
  end
  def to_a
    tallyTo = Array.new
    tallyArray = Array.new(@tally.sort {|a,b| a[1]<=>b[1]} )
    tallyArray.reverse.each {|x| tallyTo<<x[0]}
    return tallyTo
  end
end


class Dequip
  def initialize()
    @inContents = String.new
    @fileIn = File.new("outTest.txt", "r")
    @fileOut = File.new("deOutTest.txt", "w")

    # @to     this represents letter frequency as they appear in written english
    # @from   this represents letter frequency as they appear in @fileIn
    @to= ['e', 't', 'a', 'o', 'i', 'n', 's', 'r', 'h', 'l', 'd', 'c', 'u', 'm', 'f', 'p', 'g', 'w', 'y', 'b', 'v', 'k', 'x', 'j', 'q', 'z']
    @from = Array.new
    
    @alphaTally = Tally.new 

    ('a'..'z').each {|x| 
      @alphaTally.init(x)
    }
    
    getLFreqy #load @from with the data
    #get2LWFreq
    
    @switcher = Switch.new(@to,@from)
    @switcher<<@inContents              #


    @fileOut<<@switcher.to_s   
    @fileIn.close
    @fileOut.close
  end
  def get2LWFreq
    twoWordArray = ['of', 'to', 'in', 'it', 'is', 'be', 'as', 'at', 'so', 'we', 'he', 'by', 'or', 'on', 'do', 'if', 'me', 'my', 'up', 'an', 'go', 'no', 'us', 'am']
    tally = Tally.new
    #puts @inContents
    @inContents.scan(/\b\w\w\b/) {|x|
      dwn = x.downcase
      tally<<dwn
    }
    #puts tally.to_a.inspect
  
  end
  
  def getLFreqy    
    @fileIn.each {|x|    #add some error handling here
      x.split(//).each {|d|   
       dwn = d.downcase
       @alphaTally<<dwn if dwn =~ /[a-z]/
       @inContents<<d
      }
    }
    @from = @alphaTally.to_a
  end
end

require "benchmark"
Benchmark.bm(10) { |r|
  r.report("Quip: ") {Quip.new}
  r.report("Dequip: ") {Dequip.new}
}
