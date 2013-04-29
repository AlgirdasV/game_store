require_relative 'user'
require_relative 'order'
require_relative 'cart'
require_relative 'game'

class String
  def is_int?    
    self =~ /^-?[0-9]+$/
  end
end

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
    else puts "#{yield} list is empty" 
    end  
  end

  def get_valid_integer
    while not((input=gets.chop).is_int?)
      puts "\'#{input}\' is not a number." 
      print yield     
    end
    input
  end
    
  def buy_game()
    print "Buy game Nr.:"
    game_number = Integer(get_valid_integer {"Buy game Nr.:"})
    while not (game_number.between?(1,@games.size))
      puts "Wrong game number. Try again."  
      print "Buy game Nr.:"
      game_number = Integer(get_valid_integer {"Buy game Nr.:"})
    end
    @current_user.buy(@games[game_number-1])
    puts "Game \"#{@games[game_number-1].name}\" was bought successfully."
  end  

  def add_game_to_cart()
    print "Add game to cart Nr.:"
    game_number = Integer(get_valid_integer {"Add game to cart Nr.:"})
    while not (game_number.between?(1,@games.size))
      puts "Wrong game number. Try again."  
      print "Add game to cart Nr.:"
      game_number = Integer(get_valid_integer {"Add game to cart Nr.:"})
    end
    @current_user.add_game_to_cart(@games[game_number-1])
    puts "Game \"#{@games[game_number-1].name}\" was successfully added to cart."
  end 

  def remove_game_from_cart ()
    print "Remove game from cart Nr.:"
    game_number = Integer(get_valid_integer {"Remove game from cart Nr.:"})
    while not (game_number.between?(1,@current_user.cart.games.size))
      puts "Wrong game number. Try again."  
      print "Remove game from cart Nr.:"
      game_number = Integer(get_valid_integer {"Remove game from cart Nr.:"})
    end
    @current_user.remove_game_from_cart(@games[game_number-1])
    puts "Game \"#{@games[game_number-1].name}\" was successfully removed from cart."
  end  

  def order_games()
    if not(@current_user.cart.games.empty?)
      @current_user.order
      puts "Games in cart were successfully ordered."
    else
      puts "Cart is empty."
    end  
  end  

  def create_account
    print "choose a new login name:"
    login_name=gets.chop
    print "choose a new password:"
    password=gets.chop
    @current_user.create_account(login_name,password)
    if (@current_user.valid?)
      puts "Successfully created new account. Login name: #{@current_user.login_name}"
    else
      puts "Password too short or login name is taken.Try again."
      create_account
    end  
  end

  def main_loop
    puts "Welcome to the online game store!"
    puts "Available actions:"
    puts "(B)uy a game"
    puts "(A)dd a game to cart"
    puts "(R)emove a game from cart"
    puts "(O)rder all the games in your cart"
    puts "(L)ist bought games"
    puts "List games in (C)art"
    puts "(E)xit"
    puts "(LOG) in"
    puts "Create (ACC)ount"
    while (true)
      print "Select your action:"
      action = gets.chomp.upcase
      case action
        when "A" then add_game_to_cart
        when "B" then buy_game()
        when "C" then list_games(@current_user.cart.games) {"Cart"}
        when "L" then list_games(@current_user.bought_games ) {"Bought games"}
        #when "LOG" then @current_user. 
        when "ACC" then create_account
        when "R" then remove_game_from_cart
        when "O" then order_games 
        when "E" then break; 
        else puts"Unrecognized action. Please try again"  
      end
      
    end  
  end  
end

interface = Interface.new()
interface.list_games(interface.games) {"Available games"}
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
