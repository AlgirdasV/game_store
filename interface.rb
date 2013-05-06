require 'yaml/store'
require 'yaml'
require_relative 'user'
require_relative 'order'
require_relative 'cart'
require_relative 'game'
require_relative 'account'

class String
  def is_int?    
    self =~ /^-?[0-9]+$/
  end
end

class Interface
  attr_accessor :games,:user,:accounts,:user,:current_account

  def initialize
    @user=User.new()
    @current_account=nil
    @accounts=[]
    @games=[]
  end  


  def list_games(games)
    if not(games.empty?)
      numlen=8
      namelen=20
      genrelen=25
      pricelen=5  
      puts "#{yield}:"
      printf("%-#{numlen}s%-#{namelen}s%-#{genrelen}s%-#{pricelen}s\n","Number:","Name:","Genre:","Price:")
      games.each_with_index do |game,index|
        printf("%-#{numlen}d%-#{namelen}s%-#{genrelen}s%-#{pricelen}s\n",index+1,game.name,game.genre,game.price)
      end  
    else puts "#{yield} is empty" 
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
    if @user.logged_in
      print "Buy game Nr.:"
      game_number = Integer(get_valid_integer {"Buy game Nr.:"})
      while not (game_number.between?(1,@games.size))
        puts "Wrong game number. Try again."  
        print "Buy game Nr.:"
        game_number = Integer(get_valid_integer {"Buy game Nr.:"})
      end
      @user.buy(@games[game_number-1])
      puts "Game \"#{@games[game_number-1].name}\" was bought successfully."
    else
      puts "You must login before buying games"
    end  
  end  

  def add_game_to_cart()
    print "Add game to cart Nr.:"
    game_number = Integer(get_valid_integer {"Add game to cart Nr.:"})
    while not (game_number.between?(1,@games.size))
      puts "Wrong game number. Try again."  
      print "Add game to cart Nr.:"
      game_number = Integer(get_valid_integer {"Add game to cart Nr.:"})
    end

    if !@user.logged_in  
      @user.add_game_to_cart(@games[game_number-1])
      puts "Game \"#{@games[game_number-1].name}\" was successfully added to users cart."
    else
      @current_account.add_game_to_cart(@games[game_number-1])
      puts "Game \"#{@games[game_number-1].name}\" was successfully added to #{@current_account.login_name}'s cart."
    end    
  end 

  def remove_game_from_cart ()
    print "Remove game from cart Nr.:"
    game_number = Integer(get_valid_integer {"Remove game from cart Nr.:"})
    

    if !user.logged_in  
      while not (game_number.between?(1,@user.cart.games.size))
        puts "Wrong game number. Try again."  
        print "Remove game from cart Nr.:"
        game_number = Integer(get_valid_integer {"Remove game from cart Nr.:"})
      end
      removed_game_name=@user.cart.games[game_number-1].name
      @user.remove_game_from_cart(@user.cart.games[game_number-1])
      puts "Game \"#{removed_game_name}\" was successfully removed from cart."  
    else
      while not (game_number.between?(1,@current_account.cart.games.size))
        puts "Wrong game number. Try again."  
        print "Remove game from cart Nr.:"
        game_number = Integer(get_valid_integer {"Remove game from cart Nr.:"})
      end
      removed_game_name=@current_account.cart.games[game_number-1].name
      @current_account.remove_game_from_cart(@current_account.cart.games[game_number-1])
      puts "Game \"#{removed_game_name}\" was successfully removed from cart."
    end  

  end  

  def order_games()
    if @user.logged_in
      if not(@current_account.cart.games.empty?)
        @current_account.order
        puts "Games in cart were successfully ordered."
      else
        puts "Cart is empty."
      end  
    else
      puts "You must login before ordering games"
    end  
  end  

  def create_account

    begin
      print "Choose a new login name or (C)ancel:"
      login_name=gets.chop 
      if (login_name.upcase=="C")
        return
      end
      print "Choose a new password:"
      password=gets.chop
      account=@user.create_account(login_name,password)#Raises NotUniqueName and PasswordTooShort errors
      accounts<<account
      puts "Successfully created new account. Login name: #{account.login_name}"
      rescue NotUniqueName
        puts "Login name is already taken. Try again."
        create_account
      rescue PasswordTooShort
        puts  "Password is too short. Try again."
        create_account
    end

  end

  def log_in
    if @user.logged_in
      puts "Already logged in"
      return
    end 

    print "Enter login name or (C)ancel:"
    login_name=gets.chop
    if (login_name.upcase=="C")
      return
    end 
    print "Enter password:"
    password=gets.chop
    
    account=@user.log_in(login_name,password)#Raises InvalidLogin and IncorrectPassword errors
    @current_account=account
    puts "Successfully logged in"

    rescue InvalidLogin
      puts "Such login name doesn't exist. Try again."
      log_in
    rescue IncorrectPassword
      puts "Password is incorrect. Try again."  
      log_in

  end 

  def log_out

      @user.log_out
      @current_account.log_out
      @current_account=nil
      puts "Successfully logged out"
      rescue AlreadyLoggedOut
        puts "User was already logged out"

  end

  def get_recommendations
    list_games(@user.get_recommendations(@games)) {"Recommendations"}
  end 

  def main_loop
    puts "\nWelcome to the online game store!\n\n"
    puts "Available actions:"
    puts "(B)uy a game"
    puts "(A)dd a game to cart"
    puts "(R)emove a game from cart"
    puts "(O)rder all the games in your cart"
    puts "(L)ist bought games"
    puts "List games in (C)art"
    puts "(E)xit"
    puts "(LOGIN)"
    puts "(LOGOUT)"
    puts "Create (ACC)ount"
    puts "(G)et recommendations"
    puts "List (AV)ailable games"
    puts "(LOAD)"
    puts "(STORE)"
    while (true)
      print "\nSelect your action:"
      action = gets.chomp.upcase
      case action
        when "STORE" then 

          File.open( 'games.yml', 'w+' ) do|f|
            f.print @games.to_yaml
          end  

          File.open( 'user.yml', 'w+' ) do|f|
            f.puts @user.to_yaml
          end  

          File.open( 'accounts.yml', 'w+' ) do|f|
            f.puts @accounts.to_yaml
          end

        when "LOAD" then
          games=YAML::load_file('games.yml')
          games.each do |game|
  
            @games<<game
          end 

          user= YAML::load_file('user.yml')
          if !user.nil?
            @user=user
          end
     

          accounts=YAML::load_file('accounts.yml')
          if !accounts.nil?
            accounts.each do |account|
              Account.all_accounts<<account
              if account.logged_in=true
                @current_account=account
              end  
              @accounts<<account
            
            end
          end  

          if @user.logged_in
            puts "State: logged in to #{@current_account.login_name}'s account"
          else
            puts "State: logged out"
          end

        when "A" then add_game_to_cart
        when "B" then buy_game()
        when "C" then 
          if (!@user.logged_in)
            list_games(@user.cart.games) {"User's cart"}
          else  
            list_games(@current_account.cart.games) {"#{@current_account.login_name}'s cart"}
          end  
        when "L" then list_games(@user.bought_games ) {"Bought games"}
        when "LOGIN" then log_in 
        when "LOGOUT" then log_out 
        when "ACC" then create_account
        when "AV" then list_games(@games) {"Available games"} 
        when "G" then get_recommendations()  
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
