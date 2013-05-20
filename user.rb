require 'yaml'
require_relative 'cart.rb'
require_relative 'game.rb'


class GameNotFound < StandardError

end

class RatingOutOfRange < StandardError

end

class NoOnlineMode < StandardError

end

class AlreadyLoggedOut < StandardError

end

class InvalidLogin < StandardError

end

class IncorrectPassword < StandardError

end

class NotUniqueName < StandardError

end

class PasswordTooShort < StandardError

end


class User
  attr_accessor :bought_games, :cart, :login_names, :logged_in

  def initialize
    @bought_games=[]
    @cart=Cart.new
   
    @@total_price=0
    @@login_names=[]
    @logged_in=false
  end  

  def same_as(another_user)
    self.cart.same_as(another_user.cart) && self.logged_in==another_user.logged_in
      
 
  end  

  def create_account(login_name,password)
    begin
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
  end

  def log_in(name,password)
    found_account=nil
    Account.all_accounts.each do |account|
          if account.login_name==name
            found_account=account
          end
    end
    
    if found_account==nil 
      raise InvalidLogin
    end

    if found_account.password==password
      merged=found_account.cart.games.concat(@cart.games)
      found_account.cart.games=merged.flatten.uniq
      found_account.cart.recalculate_price
      @cart.clear
      @logged_in=true
      found_account.logged_in=true
      found_account
    else
      raise IncorrectPassword
    end  
  end

  def log_out
    if @logged_in
      @logged_in=false
    else
      raise AlreadyLoggedOut
    end    
  end  

  def login_names
    @login_names=@@login_names
  end  

  def buy(game)
    @bought_games << game
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

  def rate(game,rating)
    if (rating<1 || rating>10)
      raise RatingOutOfRange, "Rating out of range (1..10)"
    end  
    game.total_ratings_count=game.total_ratings_count+1
    game.total_ratings+=rating
    game.rating=game.total_ratings/game.total_ratings_count
  end 

end    

