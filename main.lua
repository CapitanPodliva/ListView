--set orientation
stage:setOrientation(Stage.LANDSCAPE_LEFT)

local texture = Texture.new("images/The plashka.png")
local bl = Bitmap.new(Texture.new("images/Bottom lane.png"))

textFields = {}
for i = 1,2 do 
	textFields[i] = TextField.new(nil, i)
end

local list = ListView.new(application:getContentWidth(),480,
0,0,texture,textFields)
stage:addChild(list,1)
bl:setPosition(0,600)
stage:addChild(bl)