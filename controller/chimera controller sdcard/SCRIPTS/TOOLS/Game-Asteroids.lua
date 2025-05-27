--------------------------------------------------------
-- ASTEROIDS FOR X-LITE V1.0
--------------------------------------------------------
-- (c)2018 by Mike Dogan (mike-vom-mars.com)
--------------------------------------------------------

local screenW = math.floor( LCD_W )
local screenH = math.floor( LCD_H )

local now
local frame       = 1
local oldTime
local deltaTime

local SPLASH      = 0
local GAME        = 1
local STATS       = 2
local state       = SPLASH
local splashStart = getTime()
local level 		= 0

local Shots        = {}
local shotInterval = 65
local lastShot     = getTime()
local shotSpeed    = .9

local Comets       = {}
local cometSize    = 12
local minCometSize = 3
local cometDots    = 5
local cometSpeed   = .1

local i

local Particles    = {}

local numStars     = 0
local Stars        = {}
for i = 1,numStars do
	Stars[#Stars+1] =
		{
		x = math.random(0,screenW),
		y = math.random(0,screenH),
		}
end

local Player =
	{
	x          = math.floor(screenW/2),
	y          = math.floor(screenH/2),
	accel      = .005,
	maxSpeed   = .65,
	lastThrust = getTime(),
	fuel       = 100,
	energy     = 100,
	lastEnergy = getTime(),
	rot        = 0,
	vx         = 0,
	vy         = 0,
	size       = 8,
	level      = 0,
	score      = 0,
	kills      = 0,
	}

--------------------------------------------

local function cleanTable(T)
	local j = 0
	local n = #T
	for i = 1,n do 
		if T[i] ~= nil then
			j = j + 1
			T[j] = T[i]
		end
	end
	for i = j+1,n do T[i] = nil end
end

--------------------------------------------

local function newExplosion(x,y,size,steps)
	local i
	local s = size == nil and 10 and size
	local steps = steps == nil and 20 or steps
	for i = 1,360, steps do
		Particles[#Particles+1] =
			{
			x        = x + math.random(-size, size),
			y        = y + math.random(-size, size),
			vx       = math.cos( math.rad(i) ) * (math.random(1,2)/5),
			vy       = math.sin( math.rad(i) ) * (math.random(1,2)/5),
			killTime = now + 150,
			}
	end
end

local function newThrust()
	local i,r,v
	for i = 1,2 do
		r = Player.rot + 180 + math.random(-5,5)
		Particles[#Particles+1] =
			{
			x        = Player.x,
			y        = Player.y,
			vx       = math.cos( math.rad(r) ) * (math.random(1,2)/5),
			vy       = math.sin( math.rad(r) ) * (math.random(1,2)/5),
			killTime = now + 50,
			}
	end
end

local function updateParticles()
	local i
	local n = #Particles
	for i = 1,n do
		if Particles[i] ~= nil then
			Particles[i].x   = Particles[i].x   + Particles[i].vx*deltaTime
			Particles[i].y   = Particles[i].y   + Particles[i].vy*deltaTime
				 if Particles[i].x < 1 or Particles[i].x > screenW-1 then Particles[i] = nil 
			elseif Particles[i].y < 1 or Particles[i].y > screenH-1 then Particles[i] = nil 
			elseif Particles[i].killTime <= now then Particles[i] = nil end
		end
	end
	cleanTable(Particles)
end

--------------------------------------------

local function updatePlayer()
	local i
	local P = Player
	
	-- PLAYER KILLED?
	if Player.energy <= 0 then return end
	
	-- INVISIBILITY
	if Player.invisible > 0 and Player.invisible + 200 <= now then Player.invisible = 0 end

	-- ROTATE SHIP
	P.rot = P.rot + (getValue("ail")/400)*deltaTime; 
	
	P.x1 = P.x  + math.cos( math.rad(  0 + P.rot) )*P.size
	P.y1 = P.y  + math.sin( math.rad(  0 + P.rot) )*P.size
	P.x2 = P.x  + math.cos( math.rad(120 + P.rot) )*P.size
	P.y2 = P.y  + math.sin( math.rad(120 + P.rot) )*P.size
	P.x3 = P.x  + math.cos( math.rad(180 + P.rot) )*P.size*.2
	P.y3 = P.y  + math.sin( math.rad(180 + P.rot) )*P.size*.2
	P.x4 = P.x  + math.cos( math.rad(240 + P.rot) )*P.size
	P.y4 = P.y  + math.sin( math.rad(240 + P.rot) )*P.size
	
	-- ACCELERATE
	local thr   = ((getValue("thr")+1024)/2048)
	local accel = P.accel * thr
	if accel > 0 and P.fuel > 0 then 
		newThrust()
		if P.lastThrust + 50 <= now then
			P.lastThrust = now
			P.fuel = P.fuel - thr*3
			if P.fuel <= 0 then
				P.fuel  = 0
				playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/empty.wav") 
			else
				playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/thrust.wav") 
			end
		end

		P.vx = P.vx + math.cos( math.rad(P.rot) ) * accel * deltaTime
		P.vy = P.vy + math.sin( math.rad(P.rot) ) * accel * deltaTime
	end

	-- PLAYER MAX SPEED
	local totalvel = math.sqrt( (P.vx*P.vx) + (P.vy*P.vy) )
	if totalvel >= P.maxSpeed then
		P.vx = P.vx * P.maxSpeed / totalvel
		P.vy = P.vy * P.maxSpeed / totalvel
	end
	
	-- MOVE SHIP
	P.x = P.x + P.vx*deltaTime
	P.y = P.y + P.vy*deltaTime
	if P.x < 0 then P.x = screenW elseif P.x > screenW then P.x = 0 end
	if P.y < 0 then P.y = screenH elseif P.y > screenH then P.y = 0 end

	-- MOVE STARS
	--local S
	--for i = 1,numStars do
	--	S = Stars[i]
	--	S.x = S.x - P.vx*deltaTime 
	--	S.y = S.y - P.vy*deltaTime 
	--	if S.x < 0 then S.x = screenW elseif S.x > screenW then S.x = 0 end
	--	if S.y < 0 then S.y = screenH elseif S.y > screenH then S.y = 0 end
	--end
end

local function updateShots()
	local i,j,n
	local now = getTime()
	
	-- ADD SHOT?
	if Player.energy > 0 and lastShot + shotInterval <= now then
		lastShot = now
		playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/shot.wav") 
		Shots[#Shots+1] =
			{
			x  = Player.x1,
			y  = Player.y1,
			vx = math.cos( math.rad(Player.rot) ) * shotSpeed,
			vy = math.sin( math.rad(Player.rot) ) * shotSpeed,
			}
	end
	
	-- MOVE SHOTS
	n = #Shots
	for i = 1,n do 
		Shots[i].x = Shots[i].x + Shots[i].vx*deltaTime
		Shots[i].y = Shots[i].y + Shots[i].vy*deltaTime
		    if Shots[i].x < 2 or Shots[i].x > screenW-2 then Shots[i] = nil 
		elseif Shots[i].y < 2 or Shots[i].y > screenH-2 then Shots[i] = nil end
	end
	
	-- REMOVE SHOTS
	cleanTable(Shots)
end

--------------------------------------------

local function pointInsideCircle(x,y,a,b,r)
	return (x - a)*(x - a) + (y - b)*(y - b) < r*r
end

local function circlesIntersect(x1,y1,r1, x2,y2,r2)
	local  distSq   = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
	local  radSumSq = (r1 + r2) * (r1 + r2)
	return (distSq <= radSumSq) 
end
--------------------------------------------

local function newComet(x,y,vx,vy,size)
	local rot = math.random(1,360)
	Comets[#Comets+1] =
		{
		px   = {},
		py   = {},
		size = size == nil and cometSize or size,
		x    = x    == nil and cometSize or x,
		y    = y    == nil and math.random(cometSize,screenH-cometSize) or y,
		rot  = rot,
		vr   = math.random(1,2)/5, -- ROT SPEED
		vx   = vx   == nil and math.cos( math.rad(rot) ) * cometSpeed or vx,
		vy   = vy   == nil and math.sin( math.rad(rot) ) * cometSpeed or vy,
		}
end

local function updateComets()
	local i,j, C,S
	local n = #Comets
	for i = 1,n do
		C     = Comets[i]
		C.x   = C.x   + C.vx*deltaTime
		C.y   = C.y   + C.vy*deltaTime
		C.rot = C.rot + C.vr*deltaTime
		if C.x < 0 then C.x = screenW elseif C.x > screenW then C.x = 0 end
		if C.y < 0 then C.y = screenH elseif C.y > screenH then C.y = 0 end
	
		for j = 1, #Shots do
			if Shots[j] ~= nil and C ~= nil then
				-- HIT BULLET?
				if pointInsideCircle(Shots[j].x,Shots[j].y,C.x,C.y,C.size) then
					playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/explos.wav") 
					Shots [j]    = nil
					Comets[i].px = nil
					Comets[i].py = nil
					Comets[i]    = nil
					Player.score = Player.score + 20
					newExplosion(C.x,C.y,C.size)
					if C.size > minCometSize then
						newComet(C.x+C.vx,C.y+C.vy,C.vx,C.vy,C.size/2)
						newComet(C.x-C.vx,C.y-C.vy,-C.vx,-C.vy,C.size/2)
					else
						Player.kills = Player.kills + 1
					end
					break
				end
			end
		end

		-- HIT PLAYER?
		if Comets[i] ~= nil and Player.energy > 0 and Player.invisible == 0 and circlesIntersect(Player.x,Player.y,Player.size, C.x,C.y,C.size) then
			Player.energy     = Player.energy - 20
			Player.lastEnergy = now
			if Player.energy <= 0 then
				playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/gover.wav") 
				Player.energy   = 0
				Player.killTime = now
				newExplosion(Player.x,Player.y,Player.size,5)
			else
				playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/damage.wav") 
				Player.invisible = now
				local vx  = Player.vx
				local vy  = Player.vy
				if vx == 0 and vy == 0 then
 					vx = -C.vx
 					vy = -C.vy
 				end
				Player.vx = C.vx*1.3
				Player.vy = C.vy*1.3
				C.vx      = vx*1.3
				C.vy      = vy*1.3
				newExplosion(Player.x,Player.y,Player.size)
				--newExplosion(C.x,C.y,C.size)
			end
		end
	end
	
	cleanTable(Comets)
	cleanTable(Shots )
end

--------------------------------------------

local function newLevel()
	--CLEAN UP
	local i
	for i = #Comets,1,-1 do 
		Comets[i].px = nil
		Comets[i].py = nil
		Comets[i]    = nil
	end
	for i = #Shots,1,-1 do Shots[i] = nil end
	for i = #Particles,1,-1 do Particles[i] = nil end
	-- RESET PLAYER
	Player.x          = math.floor(screenW/2)
	Player.y          = math.floor(screenH/2)
	Player.invisible  = getTime()
	Player.lastThrust = getTime()
	Player.fuel       = 100
	Player.energy     = Player.energy + 40; if Player.energy > 100 then Player.energy = 100 end
	Player.rot        = -90
	Player.vx         = 0
	Player.vy         = 0
	Player.level      = Player.level + 1,
	-- GIVE COMETS	
	newComet(0)
	newComet(screenW)
	if Player.level > 2 then newComet(0) end
	if Player.level > 4 then newComet(screenW) end

	playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/ready.wav") 
	state = GAME

end

--------------------------------------------

local function update()
	local i,j,n

	updatePlayer()
	updateShots ()
	updateComets()
	updateParticles()

	-- NEXT LEVEL?
	if #Comets < 1 and Player.energy > 0 then
		newLevel()
	end

	-- DRAW ------------------------------------

	-- SHIP
	if Player.energy > 0 then
		if Player.invisible == 0 or frame%2 == 0 then 
			lcd.drawLine(Player.x1,Player.y1, Player.x2,Player.y2, SOLID,0)
			lcd.drawLine(Player.x2,Player.y2, Player.x3,Player.y3, SOLID,0)
			lcd.drawLine(Player.x3,Player.y3, Player.x4,Player.y4, SOLID,0)
			lcd.drawLine(Player.x4,Player.y4, Player.x1,Player.y1, SOLID,0)
		end
	end
	
	-- COMETS
	local step = math.floor(360/cometDots)
	local C
	for i = 1, #Comets do
		n = 1
		C = Comets[i]
		for j = 1,360, step do
			C.px[n] = C.x  + math.cos( math.rad(C.rot+j) )*C.size
			C.py[n] = C.y  + math.sin( math.rad(C.rot+j) )*C.size
			n = n + 1
		end
		for j = 1, #C.px-1 do
			lcd.drawLine(C.px[j],C.py[j],C.px[j+1],C.py[j+1], SOLID,0)
		end
		lcd.drawLine(C.px[#C.px],C.py[#C.py],C.px[1],C.py[1], SOLID,0)
	end
	
	-- SHOTS
	for i = 1, #Shots do
		lcd.drawFilledRectangle(Shots[i].x-1,Shots[i].y-1, 3,3)
	end

	-- PARTICLES
	for i = 1, #Particles do
		lcd.drawPoint(Particles[i].x,Particles[i].y)
	end

	-- STARS
	for i = 1, #Stars do
		lcd.drawPoint(Stars[i].x,Stars[i].y)
	end
	
	-- FUEL BAR
	lcd.drawRectangle(1,1,3,screenH-2)
	if Player.fuel > 0 then lcd.drawLine(2,screenH-2-((screenH-4)/100)*Player.fuel,2,screenH-3, SOLID,0) end
	lcd.drawText(5,1, "F", SMLSIZE)

	-- ENERGY BAR
	if Player.lastEnergy < now-150 or frame%2 == 0 then 
		lcd.drawRectangle(screenW-4,1,3,screenH-2)
		if Player.energy > 0 then lcd.drawLine(screenW-3,screenH-2-((screenH-4)/100)*Player.energy,screenW-3,screenH-3, SOLID,0) end
	end
	lcd.drawText(screenW-9,1, "E", SMLSIZE)

	-- GAME OVER?
	if Player.energy <= 0 then
		lcd.drawText(26,screenH/2-7,"GAME OVER", MIDSIZE)
		if Player.killTime < now-500 then
			playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/stats.wav") 
			state = STATS
		end
	end

	--lcd.drawFilledRectangle(0,0,screenW,screenH)
end

--------------------------------------------

local function init()
	-- lcd.lock()
	lcd.clear()
	oldTime = getTime()
	playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/splash.wav") 
end

--------------------------------------------

local function run(event)
	if event == nil then end
	if event == EVT_EXIT_BREAK then return 2 end

	lcd.clear()

	frame     = frame + 1
	now       = getTime()
	deltaTime = now - oldTime

	-- SPLASH SCREEN
	if state == SPLASH then
		lcd.drawPixmap(0,0, "/SCRIPTS/TOOLS/ASTEROIDS/gfx/splash1.bmp")
		lcd.drawPixmap(64,0, "/SCRIPTS/TOOLS/ASTEROIDS/gfx/splash2.bmp")
		if now > splashStart + 300 then
			newLevel()
		end
	-- IN GAME
	elseif state == GAME then
		update()
	-- STATS SCREEN
	elseif state == STATS then
		local x1 = 28
		local x2 = 70
		lcd.drawText(7,2, "    GAME OVER    ", MIDSIZE+INVERS )
		lcd.drawText(x1,20, "SCORE:", SMLSIZE )
		lcd.drawText(x1,30, "STAGE:", SMLSIZE )
		lcd.drawText(x1,40, "KILLS:", SMLSIZE )
		lcd.drawText(x2,20, Player.score, SMLSIZE )
		lcd.drawText(x2,30, Player.level, SMLSIZE )
		lcd.drawText(x2,40, Player.kills, SMLSIZE )

		lcd.drawText(6,screenH-9, "   -STICK UP TO CONTINUE-   ", SMLSIZE )
		lcd.drawRectangle(5,1,screenW-10,screenH-2)
		--lcd.drawFilledRectangle(0,0,screenW,screenH)

		if getValue("ele") > 500 then
			playFile("/SCRIPTS/TOOLS/ASTEROIDS/snd/splash.wav") 
			Player.level = 0
			Player.score = 0
			Player.kills = 0
			splashStart  = now
			state        = SPLASH
		end
	end


	oldTime = now
	return 0
end

return {init=init, run=run}
