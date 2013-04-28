require_relative 'user'
require_relative 'order'
require_relative 'cart'
require_relative 'game'

class Interface
  attr_accessor :games,:users,:current_user

  def initialize
    @users=[user1 = User.new()]
    @current_user=users[0]
    @games=[game1 = Game.new("Gta",20.3,"Action"),
    game2 = Game.new("Skyrim",30.2,"Rpg"),
    game3 = Game.new("Deus ex",20.5,"Action, Rpg"),
    game4 = Game.new("Fifa",23.78,"Sport"),
    game5 = Game.new("Minecraft",15.99,"Sandbox"),
    game6 = Game.new("Nfs",29.99,"Driving")
    ]  
  end  

  def list_games(games)
    if not(games.empty?)
      numlen=8
      namelen=20
      genrelen=25
      pricelen=5  
      printf("%-#{numlen}s%-#{namelen}s%-#{genrelen}s%-#{pricelen}s\n","Number:","Name:","Genre:","Price:")
      games.each_with_index do |game,index|
        printf("%-#{numlen}d%-#{namelen}s%-#{genrelen}s%-#{pricelen}s\n",index+1,game.name,game.genre,game.price)
      end  
    else puts"No games to list" 
    end  
  end

  def buy_game()
    print "Buy game Nr.:"
    game_number = Integer(gets.chop)
    while not (game_number.between?(1,@games.size))
      puts "Wrong game number. Try again."  
      print "Buy game Nr.:"
      game_number = Integer(gets.chop)
    end
    @current_user.buy(@games[game_number-1])
    puts "Game \"#{@games[game_number-1].name}\" was bought successfully."
  end  

  def add_game_to_cart(game_number)
    @current_user.add_game_to_cart(@games[game_number-1])
  end  

  def order_games()
    @current_user.order
  end  

  def main_loop
    puts "Welcome to the online game store!"
    puts "Available actions:"
    puts "(B)uy a game"
    puts "(A)dd a game to cart"
    puts "(O)rder all the games in your cart"
    puts "(L)ist bought games"
    puts "(E)xit"
    while (true)
      print "Select your action:"
      action = gets.chomp
      case action
        when "B" then buy_game()
        when "L" then list_games(@current_user.bought_games) 
        when "E" then break;  
        else puts"Unrecognized action. Please try again"  
      end
      
    end  
  end  
end

interface = Interface.new()
interface.list_games(interface.games)
interface.main_loop
#interface.buy_game(1)
#interface.buy_game(3)
#puts
#interface.list_games(interface.current_user.bought_games)
#interface.add_game_to_cart(4)
#interface.list_games(interface.current_user.cart.games)
#interface.order_games
#interface.list_games(interface.current_user.orders[0].games)
#interface.list_games(interface.current_user.cart.games)
