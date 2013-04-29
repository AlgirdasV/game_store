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

describe User do

	context "when using first time" do

		before (:each) do
				@user =	User.new
				@game = Game.new("gta",15.13,"action")
		end	

		it "should be able to buy a game" do 
				@user.buy(@game)
				@user.bought_games.should include(@game)
		end

		it "should have an empty shopping cart" do
			@user.cart.should be_empty
		end	

		

		describe ".add(game)" do
			it "should add a game to cart" do
			  @user.add_game_to_cart(@game)
				@user.cart.should include(@game)
			end

			it "should raise exception when the game cannot be found" do
			  expect{@user.add_game_to_cart(@non_existant_game)}.to raise_error(GameNotFound)
			end
		end	

		it "should have an empty list of previous orders" do
			@user.orders.should be_empty
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
				expect{@user.rate(@game,5.6)}.to change{@game.rating}.from(3.4).to((3.4+5.6)/2)
			end	

			it "should accept rating not higher than 10" do
			  expect{@user.rate(@game,10.1)}.to raise_error(RatingOutOfRange)
			end

			it "should accept rating not lower than 1" do
			  expect{@user.rate(@game,0.9)}.to raise_error(RatingOutOfRange)
			end
		end	

		it "should have valid flag" do
		  @user.valid.should==true
		end

		it "should be either valid or not" do
			@user.should be_valid
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
			before :each do
				@user.create_account("MyName","pass1234")
			end	

			it "should add login name to login_names array" do
			  @user.login_names.should include("MyName")
			end

			it "should assign a login name" do
				@user.login_name.should=="MyName"
			end	

			it "should assign a passowrd" do
				 @user.password.should=="pass1234" 
			end

			it "should only accept a unique login name" do
			  @firstuser=User.new()
			  @seconduser=User.new()
			  @firstuser.create_account("MyName","pass1234")
			  @seconduser.create_account("MyName","123456")
			  @seconduser.should_not be_valid
			end
		end
		
		it "should be able to play online"
		it "should be able to get recommendations"
	end


	context "after adding at least 1 game to cart" do

		before (:each) do
				@user =	User.new
				@game = Game.new("gta",15.13,"action")
				@user.add_game_to_cart(@game)
		end

		it "should have a non empty cart"do
			@user.cart.should_not be_empty
		end

		it "should have the games in the cart" do
			@user.cart.games[0].should==@game
		end

		describe ".remove_game_from_cart" do
			it "should remove a game from the cart" do
				@user.remove_game_from_cart(@game)
				@user.cart.games.include?(@game) == true	
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

describe Game do
	before :each do 
		@game = Game.new("gta",15.13,"action, sandbox")
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

			it "when maximum is reached" 
			  
		end

		it "should have total_ratings" do
			@game.total_ratings=[]
		end	

		it "should have a demo version"
		it "should have online or offline type"
		it "should have a number of online players"
		it "number of online players should increase after user starts playing"



end	

describe Cart do
	before :each do
		@cart=Cart.new()
	end
	it "should have the total price of games in the cart" do
			@cart.total_price.should==0
	end
	describe "total_price" do
		before :each do
		  @game=Game.new("",5.63,"")
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
 it "should have a date of creation"

 it "should have information about games"
end	