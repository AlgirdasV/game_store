begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  puts 'Coverage disabled'
end

require_relative 'user'
require_relative 'order'
require_relative 'cart'
require_relative 'game'
require_relative 'account'

RSpec::Matchers.define :change_to do |expected|
  match do |actual|
    actual.should ==expected
  end
end

RSpec::Matchers.define :have_been_created_on do |expected|
  match do |actual|
    actual.created_on.should be_within(1).of(expected)
  end
end

RSpec::Matchers.define :have_a_total_price_of do |expected|
  match do |actual|
    actual.total_price.should == expected
  end
end

RSpec::Matchers.define :have_most_bought_genre do |expected|
  match do |actual|
    actual.most_bought_genre.should == expected
  end
end

RSpec::Matchers.define :validate_login do |expected1,expected2|
  match do |actual|
  	actual.login_valid(expected1,expected2).should be_true
  end
end

RSpec::Matchers.define :include_account_with_login_name do |expected|
	match do |actual|
		actual
  end

end



describe User do

	context "when using first time" do

		before (:each) do
				@user =	User.new
				@game = Game.new("gta",15.13,"action","Single")
		end	

		it "should be able to buy a game" do 
				@user.buy(@game)
				@user.bought_games.should include(@game)
		end

		it "should have an empty shopping cart" do
			@user.cart.should be_empty
		end	

		
		it "should have a list of previous orders" do
			@user.orders.should be_empty
		end

		describe ".add_game_to_cart(game)" do

		  it "should add a game to cart" do
			  @user.add_game_to_cart(@game)
				@user.cart.should include(@game)
			end

			it "should raise exception when the game cannot be found" do
			  expect{@user.add_game_to_cart(@non_existant_game)}.to raise_error(GameNotFound)
			end

		end	

		describe ".rate" do
			it "should increment total ratings count" do
				expect{@user.rate(@game,5.6)}.to change{@game.total_ratings_count}.from(0).to(1)
			end	

			it "should add the rating to total_ratings" do
				expect{@user.rate(@game,5.6)}.to change{@game.total_ratings}.from(0).to(5.6)
			end

			it "should change games rating to new average rating." do
				@user.rate(@game,3.4)
				@user.rate(@game,5.6)
				@game.rating.should change_to((3.4+5.6)/2)
			end	

			it "should accept rating not higher than 10" do
			  expect{@user.rate(@game,10.1)}.to raise_error(RatingOutOfRange)
			end

			it "should accept rating not lower than 1" do
			  expect{@user.rate(@game,0.9)}.to raise_error(RatingOutOfRange)
			end
		end	

		it "should be either logged in or not" do
		  @user.logged_in.should==false
		end

		it "should a have a login name" do
			@user.login_name.should be_nil
		end	

		it "should have a collection of all login names" do
		  @user.login_names.should == []
		end


		it "should a have a password" do
			@user.password.should be_nil
		end

		describe ".create_account" do

			it "should add login name to login_names array" do
			  @user.create_account("MyName","pass1234")
			  @user.login_names.should include("MyName")
			end

			it "should create and pass information to new account" do
				Account.should_receive(:new).with("new","pass1234")
				@user.create_account("new","pass1234")
			end

			it "should return the created account" do
				Account.all_accounts.clear
			  @user.create_account("new","pass1234").should ==Account.all_accounts[0]
			end

			it "should only accept a unique login name" do
			  @firstuser=User.new()
			  @seconduser=User.new()
			  @firstuser.create_account("MyName","pass1234")
			  expect{@firstuser.create_account("MyName","123456")}.to raise_error(NotUniqueName)
			end

			it "should only accept password longer than 7 symbols" do
				@user2=User.new()
			  expect{@user2.create_account("Name","pass123")}.to raise_error(PasswordTooShort)
				
			end

		end


		describe ".log_in" do
			before :each do
				Account.all_accounts.clear
				@account1=@user.create_account("MyName","pass1234")
				@account2=@user.create_account("differentName","pass1234")
				
			end	

			context "if valid" do
			  it "should change users state to logged in" do
			  	expect{@user.log_in("differentName","pass1234")}.to change {@user.logged_in}.to(true)
				end

				it "should change users state to logged in" do
			  	expect{@user.log_in("differentName","pass1234")}.to change {@account2.logged_in}.to(true)
				end

				it "should return the account to which user has logged in" do	
					@user.log_in("differentName","pass1234").should ==@account2
				end


				it "should merge users cart with the account cart" do
				  @account=Account.new("Name","password")
				  @acc_game1=Game.new("1",0,"","")
				  @acc_game2=Game.new("2",0,"","")
				  @usr_game=Game.new("3",0,"","")
				 	@common_game=Game.new("4",0,"","")
				 	@account.cart.games.clear
				 	@user.cart.games.clear
				 	@account.cart.games<<[@acc_game1,@acc_game2,@common_game]
					@user.cart.games<<[@usr_game,@common_game]
					@user.log_in("Name","password")
					@account.cart.games.should =~[@acc_game1,@acc_game2,@common_game,@usr_game]

				end
					
				it "should clear users cart after merging" do
				  @account=Account.new("Name","password")
					@usr_game=Game.new("1",0,"","")
					@usr_game2=Game.new("2",0,"","")
					@user.cart.games<<[@usr_game,@usr_game2]
					@user.log_in("Name","password")
					@user.cart.games.should be_empty
				end
			end

			context "if invalid" do

			  it "should raise exception when given a wrong password" do
			    expect{@user.log_in("differentName","invalidPass")}.to raise_error(IncorrectPassword)
			  end

			  it "should raise exception when given a non existant login name" do
			    expect{@user.log_in("nonExistantName","anypassw")}.to raise_error(InvalidLogin)
			  end

			end


		end

		

		describe "log_out" do
			before :each do
				@user.create_account("MyName","pass1234")
				@user.log_in("MyName","pass1234")
			end	

			it "should change users state to logged out" do		
			  expect{@user.log_out}.to change{@user.logged_in}.to(false)
			end

			it "should fail when already logged out" do
				@user.logged_in=false
				expect{@user.log_out}.to raise_error(AlreadyLoggedIn)
			end	


		end	
		
		describe ".play_online" do

		  it "should not raise exceptions if game has an online option" do
			  @multiplayer_game=Game.new("",0,"","Multi")
			  expect{@user.play_online(@multiplayer_game)}.to_not raise_error(NoOnlineMode)
			end

			it "should raise exceptions if game is singleplayer" do
			  @singleplayer_game=Game.new("",0,"","Single")
			  expect{@user.play_online(@singleplayer_game)}.to raise_error(NoOnlineMode)
			end

			it "should increase number of online players by 1" do
				@multiplayer_game=Game.new("",0,"","Multi")
				expect{@user.play_online(@multiplayer_game)}.to change{@multiplayer_game.online_player_count}.from(0).to(1)
				
			end
		end

		context "ability to get recommendations" do
			before(:each) do
					@available_games=[
			  	  @action_game1=Game.new("",0,"action",""),
						@action_game2=Game.new("",0,"action",""),
						@action_game3=Game.new("",0,"action",""),
						@racing_game=Game.new("",0,"racing","")
					]
					@user3=User.new()
					@user3.buy(@action_game1)
					@user3.buy(@action_game2)
					@user3.buy(@racing_game)
		  	end

		  describe ".most_bought_genre" do
				it "should return users most bought genre" do			
				  @user3.should have_most_bought_genre("action")
				end
			end
		
			describe ".get_recommendations(games_available)" do
				it "should give games according to users most_bought_genre" do
					@user3.get_recommendations(@available_games).should==[@action_game1,@action_game2,@action_game3]
				end
			end

		end
		

	end


	context "after adding at least 1 game to cart" do

		before (:each) do
				@user =	User.new
				@game = Game.new("gta",15.13,"action","Single")
				@user.add_game_to_cart(@game)
		end

		it "should have a non empty cart"do
			@user.cart.should_not be_empty
		end

		it "should have the games in the cart" do
			@user.cart.games.should include(@game)
		end

		describe ".remove_game_from_cart" do
			it "should remove a game from the cart" do
				@user.remove_game_from_cart(@game)
				@user.cart.games.should_not include(@game)
			end

			it "should raise exception when the game cannot be found" do
			  expect{@user.remove_game_from_cart(@non_existant_game)}.to raise_error(GameNotFound)
			end
		end

		it "should be able to order games that are in the cart" do
			@user.order
			@user.orders[0].games[0].name.should match(@game.name)
		end

		context "after ordering games" do
			before (:each) do
				@user.order
			end

	
			it "should have an empty shopping cart" do
				 @user.cart.should be_empty
			end

			it "should have information about previously ordered games" do
				@user.orders[0].games[0].name.should eq(@game.name)
				@user.orders[0].games[0].price.should eq(@game.price)
			end

		end	
	end
	
end

describe Account do
	before :each do
		@account=Account.new("name","password")
	end	

	subject {@account}
	it {should respond_to :login_name}
	it {should respond_to :password}
	it {should respond_to :log_out}
	it {should respond_to :add_game_to_cart}
	it {should respond_to :remove_game_from_cart}

	it "should have a login name" do
		@account.login_name.should == "name"
	end	

	it "should have a password" do
	  @account.password.should == "password"
	end

	it "should be stored in a array of all accounts" do
	  Account.all_accounts.should include(@account)
	end

	it "should have a login flag" do
		@new_account=Account.new("name","password")
	  @new_account.logged_in.should==false
	end

	describe ".log_out" do

	end	

	describe ".add_game_to_cart" do
		it "adds game to account's cart's games array" do
			@game=Game.new("",0,"","")
			@account.add_game_to_cart(@game)
		  @account.cart.games.should include(@game)
		end
	end	

	describe ".remove_game_from_cart" do
		it "removes game from account's cart's games array" do
			@game=Game.new("",0,"","")
			@account.cart.games<<@game
			@account.remove_game_from_cart(@game)
		  @account.cart.games.should_not include(@game)
		end
	end	

end	

describe Game do
	before :each do 
		@game = Game.new("gta",15.13,"action, sandbox","Single")
	end
	
		it "should have a name" do
				
				@game.name.should eq("gta")
				
		end

		it "should have a price" do
				
				@game.price.should==15.13
				
		end

		it "should have one or more genres" do
			
			@game.genre.should eq("action, sandbox")
		end	

		it "should have a rating" do
			@game.rating.should==0
		end	

		describe ".total_ratings_count" do
			context "when game is first created" do
			  it "should equal zero" do
					@game.total_ratings_count.should==0
				end
			end
			  
		end

		it "should have total_ratings" do
			@game.total_ratings=[]
		end	

		it "should have multiplayer or singleplayer type" do
			@game.multiplayer?.should==false
		end

		context "if it has a multiplayer option," do
			before :each do
				@multiplayer_game = Game.new("",1,"","multi")
			end
			it "should have a number of online players" do
				@multiplayer_game.online_player_count.should==0
			end
		end	

end	

describe Cart do
	before :each do
		@cart=Cart.new()
	end
	it "should have the total price of games in the cart" do
			@cart.should have_a_total_price_of(0)
	end
	describe "total_price" do
		before :each do
		  @game=Game.new("",5.63,"","")
		end

		it "should increase after adding games to cart" do
		  expect{@cart.add_game(@game)}.to change{@cart.total_price}.from(0).to(5.63)
		end

		it "should increase after removing games from cart" do
			@cart.add_game(@game)
		  expect{@cart.remove_game(@game)}.to change{@cart.total_price}.from(5.63).to(0)
		end
	end	

end

describe Order do
	it "should have a date of creation" do
		@games=[]
		@time_before_create = Time.now
		@order=Order.new(@games)
		@order.should have_been_created_on(@time_before_create)
	end

end	