require 'yaml'
require_relative 'cart.rb'
require_relative 'game.rb'


class GameNotFound < Exception

end

class RatingOutOfRange < Exception

end

class NoOnlineMode < Exception

end

class AlreadyLoggedIn < Exception

end

class InvalidLogin < Exception

end

class IncorrectPassword < Exception

end

class NotUniqueName < Exception

end

class PasswordTooShort < Exception

end


class User
  attr_accessor :bought_games, :cart, :orders, :login_name, :password, :login_names, :logged_in

  def initialize
    @bought_games=Array.new
    @cart=Cart.new
    @orders=Array.new
    @@total_price=0
    @@login_names=[]
    @valid=true
    @logged_in=false
  end  

  def create_account(login_name,password)
    if @@login_names.include?(login_name)
      raise NotUniqueName
    end  

    if password.length<8
      raise PasswordTooShort
    end  

    @@login_names<<login_name
    account=Account.new(login_name,password)
    account
  end

  def log_in(name,password)

    Account.all_accounts.each do |account|
          if account.login_name==name
            @found_account=account
          end
    end
    
    if @found_account==nil 
      raise InvalidLogin
    end

    if @found_account.password==password
      concatenated=@found_account.cart.games.concat(@cart.games)
      @found_account.cart.games=concatenated.flatten
      @logged_in=true
      @found_account
    else
      raise IncorrectPassword
    end  
  end

  def log_out
    if @logged_in
      @logged_in=false
    else
      raise AlreadyLoggedIn
    end    
  end  

  def login_names
    @login_names=@@login_names
  end  

  def buy(game)
    @bought_games << game
  end  

  def most_bought_genre
    genres=[]
    bought_games.each do |game|
        genres<<game.genre
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

  def play_online(game)
    if not(game.multiplayer?)
      raise NoOnlineMode, "Game has no multiplayer option"
    end  
    game.online_player_count+=1
  end  

  def bought_games
    @bought_games  
  end

  def add_game_to_cart(game)
    if (game==nil) 
      raise GameNotFound, "Game was not found"
    end

    @cart.add_game(game)
  end  

  def remove_game_from_cart(game)
    if (game==nil) 
      raise GameNotFound, "Game was not found"
    end

    @cart.remove_game(game)     
  end 

  def order()
    order=Order.new(cart.games)
    @orders<<order
    @cart.games.clear
  end  

  def rate(game,rating)
    if (rating<1 || rating>10)
      raise RatingOutOfRange, "Rating out of range (1..10)"
    end  
    game.total_ratings_count=game.total_ratings_count+1
    game.total_ratings+=rating
    game.rating=game.total_ratings/game.total_ratings_count
  end 

end    

