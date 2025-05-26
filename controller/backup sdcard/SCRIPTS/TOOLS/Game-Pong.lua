----------------------
local xVel = 0
local yVel = 0

local xPos = 0
local yPos = 0

local ballSize = LCD_W / 50

local scoreA = 0
local scoreB = 0

local aPadPos = 0
local bPadPos = 0

local function startBall()
    xPos = LCD_W/2 - ballSize/2
    yPos = LCD_H/2 - ballSize/2
    yVel = math.random(0, 6) - 3
    xVel = (math.random() > 0.5) and 2 or -2
end

local function init()
    startBall()
end

local function run()

    lcd.clear()

    aPadPos = (getValue("thr") - 1024) / 2048 * -(LCD_H - ballSize*4)
    bPadPos = (getValue("ele") - 1024) / 2048 * -(LCD_H - ballSize*4)

    if xPos < ballSize and (yPos + ballSize) >= aPadPos and yPos <= (aPadPos + ballSize * 4) then
        xVel = -xVel
        xPos = ballSize + 1
        yVel = math.random(0, 6) - 3
    elseif xPos > (LCD_W - ballSize*2) and (yPos + ballSize) >= bPadPos and yPos <= (bPadPos + ballSize * 4) then
        xVel = -xVel
        xPos = LCD_W - ballSize*2 - 1
        yVel = math.random(0, 6) - 3
    end

    if xPos >= LCD_W - ballSize then
        scoreA = scoreA + 1
        startBall()
    elseif xPos <= 0 then
        scoreB = scoreB + 1
        startBall()
    elseif yPos >= LCD_H - ballSize or yPos <= 0 then
        yVel = -yVel
    end

    xPos = xPos + xVel
    yPos = yPos + yVel

    lcd.drawFilledRectangle(xPos,yPos,ballSize,ballSize)

    lcd.drawFilledRectangle(0, aPadPos, ballSize, ballSize*4)
    lcd.drawFilledRectangle(LCD_W - ballSize, bPadPos, ballSize, ballSize*4)

    lcd.drawLine(LCD_W/2, 0, LCD_W/2, LCD_H, DOTTED, 0)
    lcd.drawNumber(LCD_W * 0.25, ballSize, scoreA, 0)
    lcd.drawNumber(LCD_W * 0.75, ballSize, scoreB, 0)

    lcd.refresh()

    return 0

end

return {init=init, run=run}
