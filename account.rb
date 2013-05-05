class Account
  @@all_accounts=[]
  attr_accessor :login_name,:password,:cart,:logged_in
  def initialize(login_name,password)
    @login_name=login_name
    @password=password
    @@all_accounts<<self
    @cart=Cart.new
    @logged_in=false
  end  

  def self.all_accounts
    @@all_accounts
  end

  def log_out

  end  

  def add_game_to_cart(game)
    @cart.games<<game
  end  

  def remove_game_from_cart(game)
    @cart.games.delete(game)
  end 

end  