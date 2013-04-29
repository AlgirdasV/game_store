class Game
  attr_accessor :name, :price, :genre,:rating,:total_ratings,:multiplayer_option,:online_player_count
  def initialize(name,price,genre,multiplayer_option)
    @name=name    
    @price=price 
    @genre=genre
    @rating=0
    @@total_ratings_count=0
    @online_player_count=0
    @total_ratings=0
    if multiplayer_option=="single"
      @multiplayer_option=false
    else
      @multiplayer_option=true
    end
  end 

  def total_ratings_count
    @@total_ratings_count
  end  

  def total_ratings_count=(total_ratings_count)
    @@total_ratings_count=total_ratings_count
  end  

  def multiplayer?
    @multiplayer_option
  end  

  def rating=(rating)
    @rating=rating
  end  
 
end