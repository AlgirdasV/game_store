class Order
  attr_accessor :games, :created_on
  def initialize(games)
    @games=Array.new
    @games=Marshal.load( Marshal.dump(games) )
    @created_on=Time.now
  end

end  