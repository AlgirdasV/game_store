class Order
  attr_accessor :games, :created_on
  def initialize(games)
    @games=[]
    games.each do |game|
      @games<<game
    end  
    @created_on=Time.now
  end

end  