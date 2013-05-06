class Cart
  attr_accessor :games,:total_price

  def initialize()
    @games=Array.new
    @total_price=0
  end  

  def add_game(game)
    @games<<game 
    @total_price=@total_price+game.price 
  end  

  def remove_game(game)
    @games.delete(game)  
    @total_price=@total_price-game.price
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

  def clear
    @games.clear
    @total_price=0
  end 

  def recalculate_price
    @total_price=0
    @games.each do |game|
      @total_price+=game.price
    end 
  end 

end  
