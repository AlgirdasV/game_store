class Game
  attr_accessor :name, :price, :genre,:rating,:total_ratings
  def initialize(name,price,genre)
    @name=name    
    @price=price 
    @genre=genre
    @rating=0
    @@total_ratings_count=0
    @total_ratings=0
  end 

  def total_ratings_count() 
    @@total_ratings_count
  end  

  def total_ratings_count=(total_ratings_count)
    @@total_ratings_count=total_ratings_count
  end  

  def rating
    @rating  
  end

  def rating=(rating)
    @rating=rating
  end  
 
end