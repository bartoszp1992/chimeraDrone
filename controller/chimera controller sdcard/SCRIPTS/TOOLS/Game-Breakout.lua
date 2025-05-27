--------------------------------------------------------
-- BREAKOUT FOR X-LITE V2.0
--------------------------------------------------------
-- Basic script (c)2016 for Taranis by 'travir'
-- Rewritten and enhanced for the X-Lite  
-- (c)2018 by Mike Dogan (mike-vom-mars.com)
--------------------------------------------------------

local screenWidth  = math.floor( LCD_W )
local screenHeight = math.floor( LCD_H )

local score = 0
local lives = 5
local level = 1
local map   = 1
local bricks = {}
local brickWidth = 8
local brickHeight = 6
local brickGapWidth = 2
local brickGapHeight = 2
local visibleBricks = 0

local showSplash = getTime()
local playSplash = true
local showGameOver = 0
local showLevelUp  = 0
local showStats    = false
local playStats    = false

local paddle = {}
paddle.width = 24
paddle.height = 4
paddle.x = screenWidth / 2 - paddle.width / 2
paddle.y = screenHeight - paddle.height
paddle.dx = 1

local ball = {}
ball.width = 4
ball.height = 4
ball.x = 0
ball.y = 0
ball.dx = 0
ball.dy = 0
local lx = ball.x
local ly = ball.y

local oldTime

local stats =
	{
	begin  = 0,
	finish = 0,
	kills  = 0,
	score  = 0,
	level  = 0,
	}

local maps =
	{
		{
		1,1,1,1,1,0,0,1,1,1,1,1,
		1,1,1,1,1,0,0,1,1,1,1,1,
		1,1,1,1,1,0,0,1,1,1,1,1,
		0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		1,0,1,0,1,0,1,0,1,0,1,0,
		0,1,0,1,0,1,0,1,0,1,0,1,
		1,0,1,0,1,0,1,0,1,0,1,0,
		0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		2,2,2,2,2,0,0,2,2,2,2,2,
		2,2,2,2,2,0,0,2,2,2,2,2,
		1,1,1,1,1,0,0,1,1,1,1,1,
		0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		2,2,2,0,2,0,2,0,0,2,2,2,
		2,1,2,0,2,0,2,0,0,2,1,2,
		2,1,2,0,2,0,2,0,0,2,1,2,
		2,2,2,0,2,0,2,0,0,2,2,2,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		3,3,3,3,3,0,0,3,3,3,3,3,
		2,2,2,2,2,0,0,2,2,2,2,2,
		2,2,2,2,2,0,0,2,2,2,2,2,
		3,3,3,3,3,0,0,3,3,3,3,3,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		1,2,3,1,2,3,1,2,3,1,2,3,
		2,3,1,2,3,1,2,3,1,2,3,1,
		3,1,2,3,1,2,3,1,2,3,1,2,
		1,2,3,1,2,3,1,2,3,1,2,3,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		3,1,3,1,3,1,1,3,1,3,1,3,
		3,1,3,1,3,1,1,3,1,3,1,3,
		3,1,3,1,3,1,1,3,1,3,1,3,
		3,1,3,1,3,1,1,3,1,3,1,3,
		0,0,0,0,0,0,0,0,0,0,0,0,
		},
		{
		0,3,2,3,2,3,3,2,3,2,3,0,
		0,0,3,2,3,2,2,3,2,3,0,0,
		0,0,0,3,2,3,3,2,3,0,0,0,
		0,0,0,0,3,2,2,3,0,0,0,0,
		0,0,0,0,0,3,3,0,0,0,0,0,
		},
		{
		3,2,0,3,2,0,3,2,0,3,2,0,
		3,2,0,3,2,0,3,2,0,3,2,0,
		3,2,0,3,2,0,3,2,0,3,2,0,
		3,2,0,3,2,0,3,2,0,3,2,0,
		3,2,0,3,2,0,3,2,0,3,2,0,
		},
		{
		1,1,1,1,1,1,1,1,1,1,1,1,
		2,2,2,2,2,2,2,2,2,2,2,2,
		1,1,1,1,1,1,1,1,1,1,1,1,
		2,2,2,2,2,2,2,2,2,2,2,2,
		3,3,3,3,3,3,3,3,3,3,3,3,
		},
		{
		3,3,3,0,3,3,3,3,0,3,3,3,
		3,2,3,0,0,0,0,0,0,3,2,3,
		3,3,3,0,3,3,3,3,0,3,3,3,
		0,0,0,0,3,2,2,3,0,0,0,0,
		3,3,3,0,3,3,3,3,0,3,3,3,
		},
		{
		3,3,3,3,3,3,3,3,3,3,3,3,
		3,1,1,1,1,1,1,1,1,1,1,1,
		3,3,3,3,3,3,3,3,3,3,3,3,
		1,1,1,1,1,1,1,1,1,1,1,3,
		3,3,3,3,3,3,3,3,3,3,3,3,
		},
		{
		3,3,3,1,3,3,3,1,3,3,3,1,
		3,1,3,1,3,1,3,1,3,1,3,1,
		3,1,3,1,3,1,3,1,3,1,3,1,
		3,1,3,1,3,1,3,1,3,1,3,1,
		3,1,3,3,3,1,3,3,3,1,3,3,
		},
	}


---------------------------------------

local function createBricks()
	local k
	local i   = 1
	local col = 1
	local row = 1
	visibleBricks = 0
	
	for k in pairs (bricks) do bricks[k] = nil end
	bricks = {}
	
	for row = 1,5 do
		for col = 1,12 do
			local p = (row-1)*12 + col
			if maps[map][p] > 0 then
				bricks[i] = {}
				bricks[i].x = 5 + (col-1) * (brickWidth +brickGapWidth)
				bricks[i].y = 9 + (row-1) * (brickHeight+brickGapHeight)
				bricks[i].lives = maps[map][p]
				i = i + 1
				visibleBricks = visibleBricks + 1
			end
		end
	end
end

---------------------------------------

local function resetBall()
	ball.dx = 0
	ball.dy = 0
end

---------------------------------------

local function reset(won)
	-- NEW GAME?
	if won == nil then
		stats.begin = getTime()
		stats.score = 0
		stats.kills = 0
		stats.level = 1
	-- GAME OVER?
	elseif won == false then
		stats.level  = level
		stats.finish = getTime()
		showGameOver = getTime()
		playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/gover.wav") 
	end

	-- RESET VARS
	lives = won == true and lives or 5
	score = won == true and score or 0
	level = won == true and level + 1 or 1
	map   = won == true and map   + 1 or 1; if map > #maps then map = 1 end
	-- PLACE PADDLE
   paddle.x = screenWidth / 2 - paddle.width / 2
   paddle.y = screenHeight - paddle.height

	resetBall()
	createBricks()
end

---------------------------------------

local function drawAll()
	-- BRICKS
	for i, brick in pairs(bricks) do
		if brick.lives == 1 then
			lcd.drawRectangle(brick.x, brick.y, brickWidth, brickHeight)
		elseif brick.lives == 2 then
			lcd.drawRectangle(brick.x, brick.y, brickWidth, brickHeight)
			lcd.drawFilledRectangle(brick.x+2, brick.y+2, brickWidth-4, brickHeight-4, 0)
		elseif brick.lives == 3 then
			lcd.drawFilledRectangle(brick.x, brick.y, brickWidth, brickHeight, 0)
		end
	end
	-- BALL & BAT
	lcd.drawRectangle(paddle.x, paddle.y, paddle.width, paddle.height, 0)
	lcd.drawFilledRectangle(paddle.x+3, paddle.y+1, paddle.width-6, paddle.height-2, 0)
	lcd.drawFilledRectangle(ball.x, ball.y, ball.width, ball.height, 0)
	-- TEXTS
	if ball.dx == 0 and ball.dy == 0 then
		lcd.drawText(7, 1, "         PULL STICK UP!         ", SMLSIZE + INVERS + BLINK)
	else
		--lcd.drawText(100, 0, visibleBricks, 0)
		lcd.drawText(5, 1, "LIVES: " .. lives, SMLSIZE + (lives == 0 and BLINK or 0) )
		lcd.drawText(55, 1, "SCORE: " .. score, SMLSIZE)
	end
end

---------------------------------------

local function collisionDetection(aX, aY, aW, aH, bX, bY, bW, bH)
   if aY + aH < bY then
      return false
   elseif aY > bY + bH then
      return false
   elseif aX + aW < bX  then
      return false
   elseif aX > bX + bW then
      return false
   else
      return true;
   end
end

---------------------------------------

local function update(deltaTime)
   if collisionDetection(ball.x, ball.y, ball.width, ball.height,
                         paddle.x, paddle.y, paddle.width, paddle.height) then

		-- RANDOMIZE A BIT
		local xr = math.random(90,110)/100
		local yr = math.random(90,110)/100

      if ball.y > paddle.y - paddle.height then
         ball.y = ball.y + paddle.y - ball.y - ball.height
      end
      
      if ball.dx > 0 then -- BALL MOVING TO RIGHT?
      	if ball.x < paddle.x + ball.width then 
      		ball.dx = -ball.dx * xr
      	end
      elseif ball.dx < 0 then -- BALL MOVING TO LEFT?
      	if ball.x > paddle.x + paddle.width - ball.width then 
      		ball.dx = -ball.dx * xr
      	end
      end

      ball.dy = -ball.dy * yr

      playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/bat.wav")
   end

	for i, brick in pairs(bricks) do
		if brick.lives > 0 then
			if collisionDetection(ball.x, ball.y, ball.width, ball.height,
							 brick.x, brick.y, brickWidth, brickHeight) then

				if ball.y < brick.y + brickHeight then -- Hit was below the brick
					ball.dy = -ball.dy
				elseif ball.y + ball.height > brick.y then -- Hit was above the brick
					ball.dy = -ball.dy
				end

				if ball.x < brick.x + brickWidth then -- Brick hit on right
					ball.dx = -ball.dx
				elseif ball.x + ball.width > brick.x then -- Brick hit on left
					ball.dx = -ball.dx
				end
				
				ball.x = lx
				ball.y = ly
				
				brick.lives = brick.lives - 1
				if brick.lives == 0 then
					stats.kills = stats.kills + 1
					visibleBricks = visibleBricks - 1 
					playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/brick.wav")
				else
					playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/brick.wav")
				end
				score = score + 10; stats.score = score
				if visibleBricks == 0 then
					playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/up.wav")
					reset(true)
					showLevelUp = getTime()
				end
			end
		end
	end


   -- BALL STICKS TO BAT?
   if ball.dx == 0 and ball.dy == 0 then
		ball.x  = paddle.x + paddle.width/2
		ball.y  = paddle.y - paddle.height - 2
		-- THROW BALL!
		if getValue("ele") > 500 then
			playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/throw.wav")
			ball.dx = math.random(1,2) == 1 and -0.55 or 0.55
			ball.dy = -0.5
			print(getValue("thr"))
		end
	-- BALL IS MOVING
	else
		lx = ball.x
		ly = ball.y
		ball.x = ball.x + ball.dx * deltaTime
		ball.y = ball.y + ball.dy * deltaTime
	end

   if getValue('ail') > 150 or getValue('rud') > 150 then
      paddle.x = paddle.x + paddle.dx * deltaTime
   end
   if getValue('ail') < -150 or getValue('rud') < -150 then
      paddle.x = paddle.x - paddle.dx * deltaTime
   end
   
	--if getValue('ele') > 999 or getValue('ele') < -999 then
	--	playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/up.wav")
	--	reset(true)
	--	showLevelUp = getTime()
	--end

   if ball.x + ball.width > screenWidth then
      ball.x = screenWidth - ball.width
      ball.dx = -ball.dx
      playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/border.wav")
   elseif ball.x < 0 then
      ball.x = 0
      ball.dx = -ball.dx
      playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/border.wav")
   end
   
	if ball.y < 0 then
		ball.y = 0
		ball.dy = -ball.dy
		playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/border.wav")
	-- LOST BALL?
	elseif ball.y + ball.height > screenHeight then 
		resetBall()
		lives = lives - 1
      
      if lives >= 0 then
      	playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/killed.wav")
		elseif lives < 0 then
	 		reset(false)
      end
   end

	if paddle.x + paddle.width > screenWidth then
		paddle.x = screenWidth - paddle.width
	elseif paddle.x < 0 then
		paddle.x = 0
	end
end

---------------------------------------

function secsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

---------------------------------------

local function init()
   -- lcd.lock()
   lcd.clear()
   createBricks()
   reset()
   drawAll()
   oldTime = getTime()
	
end

---------------------------------------

local function run(event)
   if event == EVT_EXIT_BREAK then return 2 end

   local newTime = getTime()
   local deltaTime = newTime - oldTime
   lcd.clear()

	-- SPLASH SCREEN
	if showSplash > 0 then
		if newTime < (showSplash+250) then
			if playSplash == true then 
				playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/splash.wav") 
				playSplash = false
			end
  			lcd.drawPixmap(0,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/splash1.bmp")
  			lcd.drawPixmap(64,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/splash2.bmp")
			return 0
		else
			showSplash = 0
		end
		
	-- GAME OVER SCREEN
	elseif showGameOver > 0	then
		if newTime < (showGameOver+350) then
  			lcd.drawPixmap(0,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/gover1.bmp")
  			lcd.drawPixmap(64,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/gover2.bmp")
			return 0
		else
			showGameOver = 0
			showStats = true
			playStats = true
			return 0
		end
		
	-- SHOW STATS SCREEN
	elseif showStats == true then
		if playStats == true then 
			playFile("/SCRIPTS/TOOLS/BREAKOUT/snd/stats.wav") 
			playStats = false
		end
		lcd.drawRectangle(2, 2, screenWidth-4, screenHeight-4)
		lcd.drawText(5,6, "Level:", 0)
		lcd.drawText(5,16, "Your score:", 0)
		lcd.drawText(5,26, "Time played:", 0)
		lcd.drawText(5,36, "Bricks killed:", 0)
		lcd.drawText(85,6,  stats.level, 0)
		lcd.drawText(85,16, stats.score, 0)
		lcd.drawText(85,26, secsToClock( (stats.finish-stats.begin)/100 ), 0)
		lcd.drawText(85,36, stats.kills, 0)
		lcd.drawText(6,51, "-STICK UP TO CONTINUE-", INVERS)
		-- DISMISS?
		if getValue("ele") > 500 then
			showStats  = false
			-- SPLASH SCREEN
			showSplash = getTime()
			playSplash = true
			return 0
		end

	-- LEVEL UP SCREEN
	elseif showLevelUp > 0	then
		if newTime < (showLevelUp+250) then
  			lcd.drawPixmap(0,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/up1.bmp")
  			lcd.drawPixmap(64,0, "/SCRIPTS/TOOLS/BREAKOUT/gfx/up2.bmp")
			return 0
		else
			showLevelUp = 0
		end

	-- GAME RUNNING	
	else
		update(deltaTime)
		drawAll()
	end
	-- lcd.lock()

	oldTime = newTime



   return 0
end


return {init=init, run=run}
