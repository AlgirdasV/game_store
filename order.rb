class Order
  attr_accessor :games
  def initialize(games)
    @games=Array.new
    @games=Marshal.load( Marshal.dump(games) )
  end

end  