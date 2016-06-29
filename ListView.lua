ListView = Core.class(Sprite)

function ListView:init(width, height, posX, posY, texture, ...)
	--main sprite
	sprite = Sprite.new()
	--fields
	self.width = width
	self.height = height
	self.posY = posY
	self.posX = posX
	self.texture = texture
	self.texts = ...
	
	self.MAX_PATH_LENGTH = 20
	self.DISTANCE_FROM_TEXT = 40
	self.SPEED_FACTOR = 0.05
	self.nRemovedTopSprites = 0
	self.passedPath = 0
	--positioning
	self:setPosition(posX, posY)
	--sprite:setPosition(posX,posY)
	--creating main sprite
	for i = 1,table.getn(self.texts),1 do
		if i == 1 then 
			self:_addTopSprite(i)
		else 
			self:_addBottomSprite(i)
		end
		if sprite:getHeight() >= self.height + self.posY then
			break
		end 
	end
	
	self:addChild(sprite)
	--adding events
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

--SPRITES MAGIC
function ListView:_makeSprite()
	local bmp = Bitmap.new(self.texture)
	bmp:setScale(1,1)
	bmp:setScale(self.width/bmp:getWidth(), 1)
	return bmp
end

function ListView:_addBottomSprite(textIndex)
	local prevSpriteIndex = sprite:getNumChildren() - 1
	sprite:addChild(self:_makeSprite())
	
	local lastSpriteIndex = sprite:getNumChildren() 
	
	sprite:getChildAt(lastSpriteIndex):setPosition(sprite:getChildAt(prevSpriteIndex):getX(), 
	sprite:getChildAt(prevSpriteIndex):getY() + sprite:getChildAt(prevSpriteIndex):getHeight())
	
	local textfield = TextField.new(nil, self.texts[textIndex]:getText())
	textfield:setPosition(sprite:getChildAt(lastSpriteIndex):getX() + 20,
	sprite:getChildAt(lastSpriteIndex):getY() + 20)
	sprite:addChild(textfield)
end

function ListView:_addTopSprite(textIndex)
	
	sprite:addChildAt(self:_makeSprite(),1)
	if sprite:getNumChildren() ~= 1 then
		sprite:getChildAt(1):setPosition(sprite:getChildAt(2):getX(), 
		sprite:getChildAt(2):getY() - sprite:getChildAt(1):getHeight())
	else 
		sprite:getChildAt(1):setPosition(0 - self.posX, 0 - self.posY)
	end
	
	local textfield = TextField.new(nil, self.texts[textIndex]:getText())
	textfield:setPosition(sprite:getChildAt(1):getX() + 20,
	sprite:getChildAt(1):getY() + 20)
	sprite:addChildAt(textfield,2)
end

--EVENTS
function ListView:onMouseDown(event)
	print("DOWN")
	if self:hitTestPoint(event.x, event.y) then
		event:stopPropagation()
		self.startY = event.y
		self.topY = self:getY()
	end
end

function ListView:onMouseUp(event)
	print("UP")
	if self:hitTestPoint(event.x, event.y) then
	self.passedPath = 0
		event:stopPropagation()
	end
end

function ListView:onMouseMove(event)
	if self:hitTestPoint(event.x, event.y) then
		event:stopPropagation()
		if sprite:getHeight() < self.height + self.posY then 
			do return end 
		end 
		self.endY = event.y
		local pathY = self.endY - self.startY
		pathY = self.SPEED_FACTOR * pathY
		local newY = self:getY() - pathY

		if pathY < 0 then 
			
			self.passedPath = self.nRemovedTopSprites*sprite:getChildAt(1):getHeight()
			
			sprite:setPosition(self.posX, (sprite:getY() + pathY - sprite:getChildAt(1):getHeight() < -1*(self.passedPath)  
			and self.nRemovedTopSprites + sprite:getNumChildren()/2 == table.getn(self.texts) )
			and (-1*(self.passedPath) - sprite:getChildAt(1):getHeight() + 5) or sprite:getY() + pathY)
			
			if self.nRemovedTopSprites == 0 then 
				if sprite:getChildAt(1):getHeight() <= math.abs(sprite:getY()) then 
				sprite:removeChildAt(1)
				sprite:removeChildAt(1)
				self.nRemovedTopSprites = self.nRemovedTopSprites + 1
				end
			else 
				if math.abs(sprite:getY()) - self.passedPath >= sprite:getChildAt(1):getHeight() then 
					sprite:removeChildAt(1)
					sprite:removeChildAt(1)
					self.nRemovedTopSprites = self.nRemovedTopSprites + 1
				end
			end
			
			if self.nRemovedTopSprites + sprite:getNumChildren()/2 < table.getn(self.texts) then 
				while (sprite:getHeight() < self.height + sprite:getChildAt(1):getHeight()) do 
					self:_addBottomSprite(self.nRemovedTopSprites + sprite:getNumChildren()/2 + 1)
				end 
			end
			
		elseif pathY > 0 then 
			self.passedPath = self.nRemovedTopSprites*sprite:getChildAt(1):getHeight()
			
			sprite:setPosition(self.posX,(sprite:getY() + pathY > self.posY and self.nRemovedTopSprites == 0 ) 
			and 0 - self.posY or sprite:getY() + pathY)
			
			if self.nRemovedTopSprites ~= 0 then 
				
				if math.abs(sprite:getY() - sprite:getChildAt(1):getHeight()) - sprite:getChildAt(1):getHeight() < self.passedPath  then 
					self:_addTopSprite(self.nRemovedTopSprites)
					self.nRemovedTopSprites = self.nRemovedTopSprites - 1
				end
				 
					while (sprite:getHeight() > self.height + 2*sprite:getChildAt(1):getHeight() + self.posY) do 
						sprite:removeChildAt(sprite:getNumChildren())
						sprite:removeChildAt(sprite:getNumChildren())
					end
			end
			
		end 
	end
end