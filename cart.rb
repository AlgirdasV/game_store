class Cart
  attr_accessor :games
  def initialize()
    @games=Array.new
  end  

  def add_game(game)
    @games<<game  
  end  

  def remove_game(game)
    @games.delete(game)  
  end 

  def empty?()
    if @games.empty? 
      true  
    else
      false
    end  
  end 

  def include?(game)
    if @games.include?(game)
      true
    end  
  end  

end  
