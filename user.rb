require 'yaml'
require_relative 'cart.rb'
require_relative 'game.rb'


class GameNotFound < Exception

end

class RatingOutOfRange < Exception

end

class NoOnlineMode < Exception

end

class User
  attr_accessor :bought_games, :cart, :orders, :login_name, :password, :login_names, :valid, :logged_in
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
    if @@login_names.include?(login_name) || password.length<8
      @valid=false
    else
      @valid=true
    end  
    if @valid
      @@login_names<<login_name

      @login_name=login_name
      @password=password
    end
  end

  def login(name,password)
    if login_valid(name,password)
      @logged_in=true
    else
      @logged_in=false
    end
  end

  def login_valid(name,password)
    if name==@login_name && password==@password
      true
    else
      false
    end  
  end  

  def valid?
    @valid
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

#yml = YAML::load(File.open('users.yml'))
