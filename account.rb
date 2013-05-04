class Account
  @@all_accounts=[]
  attr_accessor :login_name,:password,:cart
  def initialize(login_name,password)
    @login_name=login_name
    @password=password
    @@all_accounts<<self
    @cart=Cart.new
  end  

  def self.all_accounts
    @@all_accounts
  end

end  