--------------------------------------------------------
-- X-TRIS FOR X-LITE V1.0
--------------------------------------------------------
-- (c)2018 by Mike Dogan (mike-vom-mars.com)
--------------------------------------------------------

local screenW = math.floor( LCD_W )
local screenH = math.floor( LCD_H )

local key
local KEY_SHIFT = 96

local brickSize = 6
local cols      = 10
local rows      = 9
local gridW     = cols * (brickSize+1)+3
local gridH     = rows * (brickSize+1)+3
local gridX     = -1
local gridY     = -1
local previewX = 76
local previewY = 12

local Map = {}
local c,r
for c = 1, cols do 
	Map[c] = {} 
	for r = 1, rows do 
			Map[c][r] =
				{
				x		 = gridX+2+(c-1)*(brickSize+1),
				y		 = gridY+2+(r-1)*(brickSize+1),
				filled = false,
				}
	end 
end

NextBrick = {}
Brick     = {}

local interval 	   = 250	-- AUTO-MOVE INTERVAL
local lastAutoMove
local moveInterval  = 15	-- STICK-MOVE DELAY
local lastMove
local rotInterval   = 35   -- STICK-ROTATE DELAY
local lastRot

local now
local oldTime
local newTime
local sound = true
local start = getTime()

local state        = 1
local SCR_SPLASH   = 1
local SCR_GAME     = 2
local SCR_GAMEOVER = 3

local stats =
	{
	lines = 0,
	left  = 15,
	score = 0,
	stage = 1,
	start = 0,
	}

local brickData  = 
	{
	{0,1,2,3, 0,0,0,0, 2}, --  XXXX  

	{0,1,2,2, 0,0,0,1, 2}, --  XXX
						   	  --    X 
	
	{0,1,2,0, 0,0,0,1, 2}, --  XXX
					           --  X  

	{0,1,1,2, 0,0,1,1, 3}, -- XX
					       	  --  XX 

	{1,2,0,1, 0,0,1,1, 4}, --  XX 
					 	        -- XX   

	{0,1,0,1, 0,0,1,1, 1}, --  XX
					  	   	  --  XX  

	{0,1,2,1, 0,0,0,1, 2}, -- XXX
					  	   	  --  X  
	}

---------------------------------------------

local getBrickData = function(num)
	local i
	local cols = {}
	local rows = {}
	
	for i = 1,4 do
		cols[i] = brickData[num][i]
		rows[i] = brickData[num][i+4]
	end
	-- RETURN BRICK DATA
	return 
		{ 
		typ    = num,						-- BRICK TYPE ARRAY INDEX 
		c      = 0,							-- CURR. COL OF BRICK ON MAP 
		r      = 0,							-- CURR. ROW OF BRICK ON MAP 
		cs     = cols,						-- X-STEPS OF THE BRICK SQUARES 
		rs     = rows,						-- Y-STEPS OF THE BRICK SQUARES 
		rot    = brickData[num][9], 	-- PIECE NUM (1-..) TO USE AS ROTATION CENTER 
		}
end

---------------------------------------------

local function isBlocked(c,r,cs,rs)
	cs = cs or Brick.cs
	rs = rs or Brick.rs
	for i = 1,4 do
		if Map[c+cs[i]] ~= nil then
			local Tile = Map[c+cs[i]][r+rs[i]]
				if Tile ~= nil and Tile.filled == true then return true end
		end
	end
	return nil
end

---------------------------------------------

local function outsideGrid(c,r,cs,rs)
	cs = cs or Brick.cs
	rs = rs or Brick.rs
	for i = 1,4 do
		if Map[c+cs[i]] == nil then return true end
		if Map[c+cs[i]][r+rs[i]] == nil then return true end
	end
	return nil
end

---------------------------------------------

local function lineCheck()
	local i,c,r
	-- FIND COMPLETED LINES
	local fullRows = {}
	for r = rows,1, -1 do
		for c = 1,cols do
			if Map[c][r].filled == false then break end
			-- LINE COMPLETELY FILLED?
			if c == cols then
				fullRows[#fullRows+1] = r
				for c = 1, cols do 
					Map[c][r].filled = false 
				end
			end
		end
	end
	-- SHIFT LINES
	for i = #fullRows, 1, -1 do
		for r = fullRows[i], 1, -1 do
			for c = 1, cols do
				print("col: "..c.." row: "..r)
				Map[c][r].filled = Map[c][r-1] ~= nil and Map[c][r-1].filled or false
			end
		end
		-- INSERT "EMPTY" ROW ON TOP
		for c = 1, cols do Map[c][1].filled = false  end
	end
	
	-- LINES FOUND?
	if #fullRows > 0 then
		stats.lines = stats.lines + #fullRows
		stats.score = stats.score + #fullRows*5
		stats.left  = stats.left  - #fullRows
		if stats.left < 0 then
			stats.left = 15
			stats.stage = stats.stage + 1
			playFile("/SCRIPTS/TOOLS/X-TRIS/snd/levelup.wav")
		else
			    if #fullRows == 1 then playFile("/SCRIPTS/TOOLS/X-TRIS/snd/filled1.wav")
			elseif #fullRows == 2 then playFile("/SCRIPTS/TOOLS/X-TRIS/snd/filled2.wav"); stats.score = stats.score + 10
			elseif #fullRows >= 3 then playFile("/SCRIPTS/TOOLS/X-TRIS/snd/filled3.wav"); stats.score = stats.score + 20 end
		end
	end
end

---------------------------------------------

local function rotateBrick(dir)
	if Brick.typ == 6 then return end -- DON'T ROTATE SQUARE BRICK

	local i	
	local csNew = {}
	local rsNew = {}
	-- ROTATE RIGHT
	if dir > 0 then
		for i = 1,4 do
			csNew[#csNew+1] = Brick.cs[Brick.rot]+Brick.rs[Brick.rot]-Brick.rs[i]
			rsNew[#rsNew+1] = -Brick.cs[Brick.rot]+Brick.rs[Brick.rot]+Brick.cs[i]
		end
	-- ROTATE LEFT
	else
		for i = 1,4 do
			csNew[#csNew+1] = Brick.cs[Brick.rot]-Brick.rs[Brick.rot]+Brick.rs[i]
			rsNew[#rsNew+1] = Brick.cs[Brick.rot]+Brick.rs[Brick.rot]-Brick.cs[i]
		end
	end

	-- BLOCKED?
	if not isBlocked(Brick.c,Brick.r,csNew,rsNew) and not outsideGrid(Brick.c,Brick.r,csNew,rsNew) then 
		Brick.cs = csNew; 
		Brick.rs = rsNew; 
		playFile("/SCRIPTS/TOOLS/X-TRIS/snd/rot.wav")
		return true
	end

	return false
end

---------------------------------------------

local function newPreviewBrick()
	NextBrick = getBrickData( math.random(1,#brickData) )
end

---------------------------------------------

local function newBrick()
	Brick   = getBrickData( NextBrick.typ or math.random(1,#brickData) )
	Brick.c	= math.floor(cols/2)-1
	Brick.r	= 1
	
	-- NEW PREVIEW BRICK
	newPreviewBrick()

	-- TILES OCCUPIED? GAME OVER!
	if isBlocked(Brick.c,Brick.r) then
		playFile("/SCRIPTS/TOOLS/X-TRIS/snd/gover.wav")
		state = SCR_GAMEOVER
	end
end

---------------------------------------------

function secsToClock(seconds)
  seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

---------------------------------------------

local function updateGame()
	local i,x,y,c,r
	
	-- STICK-MOVE
	if now-lastMove >= moveInterval then
		lastMove    = now
		-- RIGHT?
		if getValue('ail') > 300 then
			if not outsideGrid(Brick.c+1,Brick.r) and not isBlocked(Brick.c+1,Brick.r) then
				playFile("/SCRIPTS/TOOLS/X-TRIS/snd/move.wav")
				Brick.c = Brick.c + 1
			end
		-- LEFT
		elseif getValue('ail') < -300 then
			if not outsideGrid(Brick.c-1,Brick.r) and not isBlocked(Brick.c-1,Brick.r) then
				playFile("/SCRIPTS/TOOLS/X-TRIS/snd/move.wav")
				Brick.c = Brick.c - 1
			end
		-- DOWN
		elseif getValue('ele') < -300 then
			if not outsideGrid(Brick.c,Brick.r+1) and not isBlocked(Brick.c,Brick.r+1) then
				Brick.r = Brick.r + 1
				playFile("/SCRIPTS/TOOLS/X-TRIS/snd/move.wav")
			end
			-- PLACE HERE?
			if outsideGrid(Brick.c,Brick.r+1) == true or isBlocked(Brick.c,Brick.r+1) then
				lastAutoMove = now-interval
			end
		end
	end

	-- STICK-ROTATE
	if now-lastRot >= rotInterval then
		lastRot    = now
		-- RIGHT?
		if getValue('rud') > 300 or getValue('ele') > 300 then
			rotateBrick(1)
		-- LEFT
		elseif getValue('rud') < -300 then
			rotateBrick(-1)
		end
	end
	
	-- AUTO-MOVE BRICK?
	if now-lastAutoMove >= interval then
		lastAutoMove = now
		-- CAN MOVE DOWN?
		if not isBlocked(Brick.c,Brick.r+1) and not outsideGrid(Brick.c,Brick.r+1) then
			playFile("/SCRIPTS/TOOLS/X-TRIS/snd/shift.wav")
			Brick.r = Brick.r + 1
		-- PLACE HERE!
		else
			playFile("/SCRIPTS/TOOLS/X-TRIS/snd/set.wav")
			for i = 1,4 do
				Map[Brick.c+Brick.cs[i]][Brick.r+Brick.rs[i]].filled = true
			end
			lineCheck()
			newBrick()
		end
	end

	-- DRAW ----------------------------------
	
	local x1 = gridX+gridW+4
	local x2 = x1+28
	lcd.drawText(x1,2, "NEXT", SMLSIZE)
	lcd.drawText(x1,34, "SCORE:", SMLSIZE)
	lcd.drawText(x1,44, "STAGE:", SMLSIZE)
	lcd.drawText(x1,54, "LEFT:", SMLSIZE)
	lcd.drawText(x2,34, stats.score, SMLSIZE)
	lcd.drawText(x2,44, stats.stage, SMLSIZE)
	lcd.drawText(x2,54, stats.left, SMLSIZE)
	lcd.drawFilledRectangle(gridX+gridW-1,0, 1,screenH)
	lcd.drawFilledRectangle(x1-3,0,54,30)
	lcd.drawFilledRectangle(x1-3,31,54,45)
	
	-- PREVIEW BRICK
	for i = 1,4 do
		lcd.drawFilledRectangle(previewX+NextBrick.cs[i]*(brickSize+1),previewY+NextBrick.rs[i]*(brickSize+1),brickSize,brickSize)
	end
	-- CURR BRICK
	for i = 1,4 do
		local Tile = Map[Brick.c+Brick.cs[i]][Brick.r+Brick.rs[i]]
		if Tile ~= nil then lcd.drawFilledRectangle(Tile.x,Tile.y,brickSize,brickSize) end
	end
	-- FILLED SQUARES
	for c = 1, cols do 
		for r = 1, rows do
			if Map[c][r].filled == true then
				lcd.drawFilledRectangle(Map[c][r].x,Map[c][r].y,brickSize,brickSize)
			end
		end 
	end
	
end

---------------------------------------------

local function newGame()
	local c,r
	playFile("/SCRIPTS/TOOLS/X-TRIS/snd/ready.wav")
	lastAutoMove = getTime()
	lastMove     = getTime()
	lastRot      = getTime()
	
	for c = 1,cols do
		for r = 1,rows do
			Map[c][r].filled = false
		end
	end
	
	stats.lines = 0
	stats.score = 0
	stats.stage = 1
	stats.start = getTime()

	newBrick()
end

---------------------------------------------

local function update(deltaTime)
	-- SPLASH SCREEN?
	if state == SCR_SPLASH then
		if sound == true then print("SOUND!"); playFile("/SCRIPTS/TOOLS/X-TRIS/snd/splash.wav"); sound = false end
		lcd.drawPixmap(0,0, "/SCRIPTS/TOOLS/X-TRIS/gfx/splash1.bmp")
		lcd.drawPixmap(64,0, "/SCRIPTS/TOOLS/X-TRIS/gfx/splash2.bmp")
		if now-start >= 200 then
			state = SCR_GAME
			newGame()
		end
	
	-- GAME
	elseif state == SCR_GAME then
		updateGame()
	
	-- GAME OVER
	elseif state == SCR_GAMEOVER then
		local x1 = 28
		local x2 = 70
		lcd.drawText(7,2, "    GAME OVER    ", MIDSIZE+INVERS )
		lcd.drawText(x1,20, "SCORE:", SMLSIZE )
		lcd.drawText(x1,30, "STAGE:", SMLSIZE )
		lcd.drawText(x1,40, "LINES:", SMLSIZE )
		lcd.drawText(x2,20, stats.score, SMLSIZE )
		lcd.drawText(x2,30, stats.stage, SMLSIZE )
		lcd.drawText(x2,40, stats.lines, SMLSIZE )

		lcd.drawText(6,screenH-9, "   -STICK UP TO CONTINUE-   ", SMLSIZE )
		lcd.drawRectangle(5,1,screenW-10,screenH-2)
		if getValue("ele") > 500 then
			sound = true
			start = getTime()
			state = SCR_SPLASH
		end
	
	end
end

---------------------------------------------

local function init()
	lcd.clear()
	oldTime = getTime()
end

---------------------------------------------

local function run(event)
	if event == nil then return 2 end
	if event == EVT_EXIT_BREAK then return 2 end
	
	--key = event; if key ~= 0 then print(key) end

	now = getTime()
	local deltaTime = now - oldTime

	lcd.clear()
	update(deltaTime)

	oldTime = now
	return 0
end

return {init=init, run=run}
