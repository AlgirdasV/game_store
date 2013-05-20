begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  puts 'Coverage disabled'
end

require_relative 'interface'

describe Interface do

  describe ".load" do

    before :each do
      @interface=Interface.new
      @interface.load('games_test.yml','user_test.yml','accounts_test.yml')
    end  

    it "should load games from file" do
      @games=["Gta","Skyrim","Deus ex","Fifa","Minecraft","Nfs","Assassins Creed","Call of Duty","Crysis","LFS"]#games in games.yml file
      @interface.games.each do |game|
        @games.include?(game.name).should == true
      end  
    end

   it "should load user" do
      @user_in_file=User.new
      @user_in_file.stub(:cart).and_return(Cart.new)
      @user_in_file.stub(:logged_in).and_return(true)
      @interface.user.same_as(@user_in_file).should==true
   end

   it "should load accounts" do
     @first_acc=Account.new("","")
     @first_acc.stub(:login_name).and_return("jonas")
     @first_acc.stub(:password).and_return("12345678")
     @first_acc.stub(:cart).and_return(Cart.new)
     @first_acc.stub(:logged_in).and_return(false)
     Account.all_accounts[0].same_as(@first_acc).should==true
   end

  end

  describe ".store"do

  before :each do
    @interface=Interface.new
    @interface.load('games_test.yml','user_test.yml','accounts_test.yml')
    @interface.store('games_store_test.yml','user_store_test.yml','accounts_store_test.yml')
  end  
  
    it "should games data to file" do
      FileUtils.compare_file('games_test.yml', 'games_store_test.yml').should==true
    end
    it "should store user data to file" do
      FileUtils.compare_file('user_test.yml', 'user_store_test.yml').should==true  
    end

    it "should store accounts data to file" do
      FileUtils.compare_file('accounts_test.yml', 'accounts_store_test.yml').should==true    
    end
    
    
  end  

end
