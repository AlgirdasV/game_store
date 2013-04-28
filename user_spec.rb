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
				expect{@user.rate(@game,5)}.to change{@game.total_ratings_count}.from(0).to(1)
			end	
			it "should change games rating by ..." do

			end	
			#expect{@user.rate(@game,5)}.to change{@game.rating}.to((@game.rating+5)/@game.total_ratings_count+1)
		end	

		#it "should be able rate only from 1 to 10"
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

		it "should have a count of total users who rated it" do
			@game.total_ratings_count.should==0
		end	

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