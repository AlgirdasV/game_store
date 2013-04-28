require_relative 'user'
require_relative 'order'
require_relative 'cart'
require_relative 'game'

user1 = User.new()
game1 = Game.new("gta",20.3,"action")
game2 = Game.new("skyrim",30.2,"rpg")
game3 = Game.new("deus ex",20.5,["action","rpg"] )
game4 = Game.new("",23.78,"")
game5 = Game.new("minecraft",15.99,"sandbox")
game6 = Game.new("nfs",29.99,"driving")

