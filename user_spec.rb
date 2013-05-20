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



RSpec::Matchers.define :match_genre do |expected|
  match do |actual|
    actual.each do |game|
			
			description { "#{game} should match genre #{expected}" }
	    failure_message_for_should { "Game #{game.name} does not match #{expected} genre" }
	    failure_message_for_should_not { "Game #{game.name} matches #{expected} genre"}
	    break false unless game.genre==expected	
		end	

  end
end

RSpec::Matchers.define :filter_orders_by_date do |date_from,date_to|
  match do |actual|
    actual.each_with_index do |order, index|
    	range=date_from..date_to
			description { "#{order}'s date should match date #{range}" }
	    failure_message_for_should { "Order Nr. #{index}, created on #{order.created_on} does not match #{range}" }
	    failure_message_for_should_not {"Order Nr. #{index}, created on #{order.created_on} matches #{range}" }
	    break false unless order.created_on.between?(date_from, date_to)

	  end
  end
end

#Used matchers:
#1 be_empty
#2 include
#3 raise_error
#4 change
#5 match_array


	
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
				expect{@user.rate(@game,5.6)}.to change{@game.rating}.to((3.4+5.6)/2)
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

		it "should have a collection of all login names" do
		  @user.login_names.should == []
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
			  @user.create_account("new","pass1234").should == Account.all_accounts.first
			end

			it "should only accept a unique login name" do
			  @user2=User.new()
			  @user2.create_account("MyName","pass1234")
			  expect{@user2.create_account("MyName","123456")}.to raise_error(NotUniqueName)
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

				it "should change account's state to logged in" do
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
					@account.cart.games.should match_array([@common_game,@acc_game1,@acc_game2,@usr_game])
				end

				it "should merge users total_price with accounts total price" do
				  @account=Account.new("Name","password")
				  @acc_game1=Game.new("1",5,"","")
				  @acc_game2=Game.new("2",10,"","")
				  @usr_game=Game.new("3",15,"","")
				 	@common_game=Game.new("4",10,"","")
				 	@account.cart.games.clear
				 	@user.cart.games.clear
				 	@account.cart.add_game(@acc_game1)
				 	@account.cart.add_game(@acc_game2)
				 	@account.cart.add_game(@common_game)
					@user.cart.add_game(@usr_game)
					@user.cart.add_game(@common_game)
					@user.log_in("Name","password")
					@account.cart.total_price.should ==5+10+15+10
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
				@account=@user.create_account("MyName","pass1234")
				@user.log_in("MyName","pass1234")
			end	

			it "should change users state to logged out" do		
			  expect{@user.log_out}.to change{@user.logged_in}.to(false)
			end


			it "should fail when already logged out" do
				@user.logged_in=false
				expect{@user.log_out}.to raise_error(AlreadyLoggedOut)
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

	it "should have a list of previous orders" do
		@account.orders.should be_empty
	end

	it "should be able to view orders by date" do
		@game1=Game.new("",0,"","")
		@game2=Game.new("",0,"","")
		
		@order1=Order.new([@game1,@game2])
		@order2=Order.new([@game1,@game2])
		@order3=Order.new([@game1,@game2])
		@order4=Order.new([@game1,@game2])
		@order1.stub(:created_on).and_return(Time.new(2013, 1, 25))
		@order2.stub(:created_on).and_return(Time.new(2013, 2, 1))
		@order3.stub(:created_on).and_return(Time.new(2013, 2, 28))
		@order4.stub(:created_on).and_return(Time.new(2013, 3, 1))
		@account.orders<<@order1
		@account.orders<<@order2
		@account.orders<<@order3
		@account.orders<<@order4
		
  	@date_from= Time.new(2013, 1, 30)
  	@date_to= Time.new(2013, 2, 28)

	  @account.orders_by_date(@date_from,@date_to).should filter_orders_by_date(@date_from,@date_to)
	end

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
		it "should change account's state to logged out" do
		  @user=User.new
		  @account.logged_in=true
		  expect{@account.log_out}.to change{@account.logged_in}.to(false)
		end

		it "should raise error if account was already logged out" do
		  @user=User.new
		  @account.logged_in=false
		  expect{@account.log_out}.to raise_error(AlreadyLoggedOut)
		end
	end	

	describe ".add_game_to_cart" do
		it "adds game to games array in account's cart" do
			@game=Game.new("",0,"","")
			@account.add_game_to_cart(@game)
		  @account.cart.games.should include(@game)
		end

		it "increases total price of account's cart" do
		  @game=Game.new("",15.63,"","")
			expect{@account.add_game_to_cart(@game)}.to change{@account.cart.total_price}.to(15.63)
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

	it "should be able to order games that are in the cart" do
			@game=Game.new("",0,"","")
			@account.add_game_to_cart(@game)
			@account.order
			@account.orders[0].games.should include(@game)
	end

	context "ability to get recommendations" do
			before(:each) do
					@available_games=[
			  	  @action_game1=Game.new("action1",0,"action",""),
						@action_game2=Game.new("action2",0,"action",""),
						@action_game3=Game.new("action3",0,"action",""),
						@racing_game1=Game.new("racing1",0,"racing",""),
						@racing_game2=Game.new("racing2",0,"racing",""),
						@racing_game3=Game.new("racing3",0,"racing",""),
						@racing_game4=Game.new("racing4",0,"racing","")
					]
					@user=User.new()
					@account=@user.create_account("Name","password")
					@account.add_game_to_cart(@action_game1)
					@account.add_game_to_cart(@action_game2)
					@account.add_game_to_cart(@racing_game1)
					@account.add_game_to_cart(@racing_game2)
					@account.add_game_to_cart(@racing_game3)
					@account.add_game_to_cart(@racing_game4)
					@account.order
		  	end

		  describe ".most_bought_genre" do
				it "should return users most bought genre" do			
				  @account.most_bought_genre.should == "racing"
				end
			end
		
			describe ".get_recommendations(games_available)" do
				it "should give games according to users most_bought_genre" do
					@account.get_recommendations(@available_games).should match_genre(@account.most_bought_genre)

				end
			end

		end

		context "after ordering games" do
			before (:each) do
				@game=Game.new("",0,"","")
				@account.order
			end

			it "should have an empty shopping cart" do
				 @account.cart.should be_empty
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
			@game.total_ratings.should ==0
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
			@cart.total_price.should == 0
	end

	describe "total_price" do
		before :each do
		  @game=Game.new("",5.63,"","")
		end

		it "should increase after adding games to cart" do
		  expect{@cart.add_game(@game)}.to change{@cart.total_price}.from(0).to(5.63)
		end

		it "should decrease after removing games from cart" do
			@cart.add_game(@game)
		  expect{@cart.remove_game(@game)}.to change{@cart.total_price}.from(5.63).to(0)
		end
	end	

	describe ".recalculate_price" do
		it "should recalculate total price of games in the cart" do
			@game=Game.new("",5.63,"","")
			@game2=Game.new("",17.38,"","")
			@cart.games<<@game
			@cart.games<<@game2
			expect{@cart.recalculate_price}.to change{@cart.total_price}.from(0).to(5.63+17.38)
		end	
	end	

	describe ".clear" do
		before :each do
			@game1=Game.new("",10,"","")
		  @cart.add_game(@game1)
		  
		end  
		it "should remove all games from the cart" do
			@cart.clear
		  @cart.games.should be_empty
		end

		it "should reset total price to zero" do
			expect{@cart.clear}.to change{@cart.total_price}.to(0)
		  
		end
	end	

end

describe Order do
	it "should have a date of creation" do
		@time_now = Time.now
  	Time.stub!(:now).and_return(@time_now)

		@games=[]
		@order=Order.new(@games)
		@order.created_on.should eql(@time_now)
	end

end



