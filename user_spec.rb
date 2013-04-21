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
				@game = Game.new("gta",15.13)
		end	

		it "should be able to buy a game" do 
				@user.buy(@game)
				@user.bought_games.should include(@game)
		end

		it "should have an empty shopping cart" do
			@user.cart.should be_empty
		end	

		it "should be able to add a game to cart" do
				@user.add_game_to_cart(@game)
				@user.cart.should include(@game)
		end

		it "should have an empty list of previous orders" do
			@user.orders.should be_empty
		end

	end

	context "after adding at least 1 game to cart" do

		before (:each) do
				@user =	User.new
				@game = Game.new("gta",15.13)
				@user.add_game_to_cart(@game)
		end

		it "should have a non empty cart"do
			@user.cart.should_not be_empty
		end

		it "should have the games in the cart" do
			@user.cart.games[0].should==@game
		end

		it "should have the total price of games in the cart" do
			@user.total_price.should ==@user.cart.games[0].price
		end

		it "should be able to remove a game from the cart" do
			@user.remove_game_from_cart(@game)
			@user.cart.games.include?(@game) == true	
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

		it "should have a name" do
				@game = Game.new("gta",15.13)
				@game.name.should eq("gta")
				
		end

		it "should have a price" do
				@game = Game.new("gta",15.13)
				@game.price.should==15.13
				
		end

end	