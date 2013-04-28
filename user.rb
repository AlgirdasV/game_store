require 'yaml'
require_relative 'cart.rb'
require_relative 'game.rb'


class GameNotFound < Exception

end

class User
  attr_accessor :bought_games, :cart, :orders
  def initialize
    @bought_games=Array.new
    @cart=Cart.new
    @orders=Array.new
    @@total_price=0
  end  

  def buy(game)
    @bought_games << game
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
    game.rating=rating 
    game.total_ratings_count=game.total_ratings_count+1
  end 

end    

#yml = YAML::load(File.open('users.yml'))
