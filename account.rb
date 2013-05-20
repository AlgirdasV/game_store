require_relative 'user.rb'
class Account
  @@all_accounts=[]
  attr_accessor :login_name,:password,:cart,:logged_in, :orders
  def initialize(login_name,password)
    @login_name=login_name
    @password=password
    @@all_accounts<<self
    @cart=Cart.new
    @logged_in=false
    @orders=[]
  end  

  def self.all_accounts
    @@all_accounts
  end

  def same_as(another_acc)
    self.login_name==another_acc.login_name && self.password==another_acc.password && self.logged_in==another_acc.logged_in && self.cart.same_as(another_acc.cart)
  end  

  def log_out
    if @logged_in==false
      raise AlreadyLoggedOut
    else
      @logged_in=false
    end    

  end  

  def add_game_to_cart(game)
    @cart.games<<game
    @cart.total_price+=game.price
  end  

  def remove_game_from_cart(game)
    @cart.games.delete(game)
  end 

  def order()
    order=Order.new(@cart.games)
    @orders<<order
    @cart.clear
  end

  def orders_by_date(date_from,date_to)
    list=[]
    orders.each do |order|
      if order.created_on.between?(date_from,date_to)
        list<<order
      end  
    end  
    return list
  end  

  def most_bought_genre
    genres=[]

    @orders.each do |order|
      order.games.each do |game|
        genres<<game.genre
      end
    end

    freq = genres.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    genres.sort_by { |v| freq[v] }.last
  end

  def get_recommendations(available_games)
    recommendations=[]
    available_games.each do |game|
      if game.genre==most_bought_genre
        recommendations<<game
      end  
    end
    recommendations
  end   

end  