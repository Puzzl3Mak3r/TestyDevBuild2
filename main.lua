--[[ Main core stuff ]]-- =========================================================

physics = require "physics"
physics.start()
system.activate( "multitouch" )


--[[ To read the CSV file(s) ]]-- =========================================================

io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

require "extensions.string"
require "extensions.io"
require "extensions.table"
require "extensions.math"
require "extensions.display"



--[[ Parameters ]]-- =========================================================

local fullw                        = display.actualContentWidth
local fullh                        = display.actualContentHeight
local cx                           = display.contentCenterX
local cy                           = display.contentCenterY
local left, right                  = false, false
local screenX                      = display.contentWidth
local screenY                      = display.contentHeight
local leftMove, rightMove          = false, false
local holdingLeft, holdingRight    = false, false
local doubleJump                   = false
local levelchosen                  = ""
local platform                     = ""
local spawnX, spawnY               = cx, cy
local TestyBackground              = display.newRect( cx, cy, 3*screenX, 3*screenY)
local velocity                     = 0
TestyBackground.fill               = {0.5,0.7,1}
playingStatus                      = false
physics.setGravity                   (0,10)


--[[ Choose Level ]]-- =========================================================

local function removeLevels()
    display.remove(levela)
    display.remove(levelb)
    display.remove(levelaLabel)
    display.remove(levelbLabel)
end

local function levelSelected(event)
    if (event.phase == "began") then
        levelchosen = event.target.name
        removeLevels()
        PreBuild()
        StartPlaying()
        BuildTheLevel()
        levelchosen = "Loader"
        playingStatus = true
    end
end



--[[ PreBuild ]]-- =========================================================

function PreBuild()

    --[[ DevGround ]]-- =========================================================

    local ground = display.newRect( cx, screenY-30, 2000, 60 )
    physics.addBody( ground, "static", { density=1.0, friction=100, bounce=0} )

    local groundTwo =display.newRect( cx, screenY-80, 500, 180 )
    physics.addBody( groundTwo, "static", { density=1.0, friction=10000, bounce=-300000} )



    --[[ Last Stuff Overlays ]]-- =========================================================

    
    if platform == "mobile" then
        leftArrow =display.newImageRect( 'Assets/UI/arrowLeft.png', 150, 100 )
        rightArrow =display.newImageRect( 'Assets/UI/arrowRight.png', 150, 100 )
        leftArrow.x, leftArrow.y = cx+650,screenY-(cy/2.5)
        rightArrow.x, rightArrow.y = cx-650,screenY-(cy/2.5)
        leftArrow.name,rightArrow.name = "left","right"
    end
end



--[[ Game Code ]]-- =========================================================

function StartPlaying()



    --[[ Player ]]-- =========================================================

    -- Load the sheets

    player = display.newRect( cx, cy, 100, 70)
    player.name = "real"
    player.fill = {1,1,0}
    playerVx, playerVy = 0, 0
    physics.addBody( player )
    player.isFixedRotation=true
    player.postCollision = nil
    

    --[[ Testy Animation ]]-- =========================================

    local TestyFrameSize =
    {
        width = 605,
        height = 344,
        numFrames = 143
    }

    local TestySheet = graphics.newImageSheet( "Assets/Sprites/Testy.png", TestyFrameSize )

    -- sequences table
    local TestySequences = {
        {
            name="idle",
            frames= { 1 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="hit",
            frames= { 131, 131 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="blink",
            frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="startrun",
            frames= { 12, 13, 14, 15, 16, 17, 18 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="run",
            frames= { 27, 28, 29 }, -- frame indexes of animation, in image sheet
            time = 300,
            loopCount = 999        -- Optional ; default is 0
        },
        {
            name="dash",
            frames= { 40, 41, 42, 43, 44, 45, 46, 47, 48 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="jump",
            frames= { 53, 54 }, -- frame indexes of animation,   in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0 
        },
        {
            name="startJump",
            frames= { 66, 67, 68, 69, 70 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="fall",
            frames= { 79, 80 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1     -- Optional ; default is 0
        },
        {
            name="startFall",
            frames= { 92, 93, 94, 95 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        },
        {
            name="highjump",
            frames= { 105, 106 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 0        -- Optional ; default is 0
        },
        {
            name="startHighjump",
            frames= { 54, 105, 106 }, -- frame indexes of animation, in image sheet
            time = 100,
            loopCount = 1        -- Optional ; default is 0
        }
    }

    local newPlayer = display.newSprite( TestySheet, TestySequences )

    
    newPlayer:setSequence("idle")
    newPlayer:play()
    newPlayer.xScale, newPlayer.yScale = 0.3,0.3
    player.alpha = 0


    --[[ Main Level Functions ]]-- =========================================================

    --[[ Jumping ]]--

        if doubleJump then
            jumps = 2
        else
            jumps = 1
        end

        local shouldPlayerJump = false

        local function jumpAgain()
            if playingStatus and playerVy == 0 then
                if doubleJump then
                    jumps = 2
                else
                    jumps = 1
                end
                print ("reset Jump")
            end
        end

        local function Jump( event )
            if playingStatus then
                if jumps ~= 0 then
                    if (not doubleJump) and (playerVy == 0) then
                        shouldPlayerJump = true
                        jumps = jumps - 1
                    else
                        if doubleJump and jumps <= 1 then
                            shouldPlayerJump = true
                            jumps = 0
                        else
                            shouldPlayerJump = false
                        end
                    end

                    if platform == "mobile" then
                        if(event.phase == "began") then
                            if ((holdingLeft or holdingRight)== false) then
                                player:setLinearVelocity(0,-300)
                                newPlayer:setSequence("jump")
                                newPlayer:play("jump")
                                jumps = jumps - 1
                            end
                        end
                    end

                    if platform == "pc" then
                        if shouldPlayerJump then
                            player:setLinearVelocity(0,-300)
                            newPlayer:setSequence("jump")
                            newPlayer:play("jump")
                        end
                    end
                else
                    jumpAgain()
                end
            end
        end


    --[[ Moving Left & Right ]]--
        -- Moving left and right with dynamic velocity

        -- Velocity 1 through to 3, 3 "accelerations"
        local v3, v2, v1 = false, false, false

        local function MovingRight()
            if playingStatus then
                player.x = player.x - (2 * velocity) -- - (velocity)
                print("moveRight")
            end
        end

        local function MovingLeft()
            if playingStatus then
                player.x = player.x + (2 * velocity) -- + (velocity)
                print("moveLeft")
            end
        end

        local function RunAnim()
            if playingStatus then
                local count = 0
                newPlayer:setSequence("run")
                newPlayer:play("run")
                while not (count == 999) do
                    if (pressedKeys["a"] == false) or (pressedKeys["w"] == false) then break end
                    count = count + 1
                end
            end
        end

        local function delayAcceleration()
            if playingStatus then
                if not v2 then
                    v3 = true
                elseif not v1 then
                    v2 = true
                else
                    v1 = true
                end
            end
        end

        local function turnOffVelocity()
            velocity   = 0
            v1, v2, v3 = false, false, false
        end

        local function turnOnVelocity()
            timer.performWithDelay( 1500, delayAcceleration )
            if v3 and velocity >= 10 then
                velocity = 1.8
            elseif v2 and velocity >= 7 then
                velocity = 1.5
            elseif v1 and velocity >= 4 then
                velocity = 1.3
            end
        end

    local function falling()
        if playingStatus then
            -- Falling animation
            if (velocity == 0) then
                if (playerVy >= 0) then
                    newPlayer:setSequence("fall")
                    newPlayer:play("fall")
                end
                if (playerVy <= 0) then
                    newPlayer:setSequence("jump")
                    newPlayer:play("jump")
                end
                if (playerVy == 0) then
                    newPlayer:setSequence("idle")
                    newPlayer:play("idle")
                end
            end
        end
    end

    -- Make the animated player constantly follow the physical player
    local function WhenPlaying()
        if playingStatus then
            newPlayer.x,newPlayer.y=player.x,(player.y - 8 )
            playerVx, playerVy = player:getLinearVelocity()
            -- 
            if (playerVx == 0) then
                timer.performWithDelay( 200, falling )
            end
        end
    end


    -- [[ PC controls ]] -- =========================================================
    pressedKeys = {}
    function onKeyEvent(event)
        if event.phase == "down" then
            pressedKeys[event.keyName] = true
        else
            pressedKeys[event.keyName] = false
        end
        if event.phase == "up" then
            pressedKeys[event.keyName] = false
        end
    end

    local function onEnterFrame(event)
        if pressedKeys["w"] then
            Jump()            
            jumps = jumps - 1
        end
        if pressedKeys["a"] then
            MovingRight()
            RunAnim()
            newPlayer.xScale=-0.3
            velocity = 1
            Runtime:addEventListener("enterFrame", turnOffVelocity )
        elseif pressedKeys["d"] then
            MovingLeft()
            RunAnim()
            newPlayer.xScale=0.3
            velocity = 1
        end
    end



    --[[ Delays And Listeners ]]-- =========================================================
    
    timer.performWithDelay( 300, RunAnim )
    Runtime:addEventListener("enterFrame", WhenPlaying )
    if platform == "mobile" then
        TestyBackground:addEventListener("touch", Jump)
        -- Runtime:addEventListener("enterFrame", PressAndHold)
    end
    if platform == "pc" then
        Runtime:addEventListener( "enterFrame", onEnterFrame )
        Runtime:addEventListener( "key", onKeyEvent )
        -- Runtime:addEventListener( "enterFrame", PressAndHoldPC)
    end
end



--[[ Level Builder ]]-- =========================================================

function BuildTheLevel()
        
    --[[ Level Loader ]]-- =========================================================

    -- Load CSV file as table of tables, where each sub-table is a row
    local lines = io.readFileTable( "OldDebugTest.csv", system.ResourceDirectory )

    local rows = {}

    for i=1, #lines do	
        rows[#rows+1] = string.fromCSV(lines[i])
    end

    -- Debug step to see what we extracted from the CSV file
    table.print_r(rows)

    -- Top of your code:
    local curRow = 0
    local forLooper = 0
    local id = 0
    local rectTable = {} -- for keeping references on created rectangles

    -- Triangle parameters
    local upL   = { 0,25, 0,75, 50,25,  }
    local downL = { 0,0, 0,50, 50,50, }
    local upR   = { 0,0, 0,50, -50,0, }
    local downR = { 0,-50, 0,50, -50,50, }
    local vert  = {}

    -- [[ Actual Loader Function ]]-- =========================================================

    function buildLevel()
        curRow = 0
        forLooper = 1
        curRow = curRow + 1

        if( curRow <= #rows ) then
            table.print_r(rows[curRow])
            forLooper = tonumber((rows[1][1]))
            spawnX, spawnY = tonumber((rows[1][2])), tonumber((rows[1][3]))
            
            while (forLooper>=1) do

                -- In your loop:

                -- Create 'id' to make array assortment easier
                id=forLooper+1
                if not rows[id] then break end -- this new line will stop the loop if index is nil
                                            
                -- Make the Blocks
                    rectID = rows[id][1]
                    xOffset = (tonumber(rows[id][2]))*50
                    yOffset = (tonumber(rows[id][3]))*50
                

                -- Select type of triangle orientation
                if( (tostring(rows[id][7])) == "upL" ) then
                    vert = upL
                end
                if( (tostring(rows[id][7])) == "downL" ) then
                    vert = downL
                end
                if( (tostring(rows[id][7])) == "upR" ) then
                    vert = upR
                end
                if( (tostring(rows[id][7])) == "downR" ) then
                    vert = downR
                end

                -- If the blocks are triangles
                if( (tostring(rows[id][6])) == "triangle") then
                    -- rectTable[rectID] = display.newImage( "images/Tiles/triangleDownLeft.png" )
                    rectTable[rectID] = display.newPolygon( xOffset, yOffset, vert )
                    rectTable[rectID]:setFillColor(rows[id][4], 0, 0)
                    if ((tostring(rows[id][5])) == "1") then
                        physics.addBody( rectTable[rectID], "static", { density=1.0, friction=100, bounce=-10, shape=vert } )
                        rectTable[rectID].anchorX, rectTable[rectID].anchorY = 0,0
                        rectTable[rectID].x, rectTable[rectID].y = rectTable[rectID].x - 25, rectTable[rectID].y - 25
                    end
                end
                
                -- If the blocks are squares
                if( (tostring(rows[id][6])) == "square") then
                    rectTable[rectID] = display.newRect(xOffset, yOffset, 50, 50)
                    rectTable[rectID]:setFillColor(rows[id][4], 0, 0)
                    if ((tostring(rows[id][5])) == "1") then
                        physics.addBody( (rectTable[rectID]), "static", { density=1.0, friction=100, bounce=-10} )
                    end
                end
                -- Repeat until finished CSV
                forLooper = forLooper-1
            end
        end
    end
    player.x, player.y = spawnX, spawnY -- Move player to set spawn position
end



--[[ Load Start Screen ]]-- =========================================================

-- Overlay
local flatOverlay = display.newRect( 2*screenX, 2.5*screenY, 5*screenX, 5*screenY )
flatOverlay.fill, flatOverlay.alpha = {0,0,0},1

-- PC
local pcOption = display.newRect( cx-100, cy-100, 200, 200 )
pcOption.fill, pcOption.alpha = {1,0,0},1
local pcOptionLabel = display.newText( "PC", pcOption.x, pcOption.y, native.systemFont, 16 )

-- Mobile
local mbOption = display.newRect( cx+100, cy-100, 200, 200 )
mbOption.fill, mbOption.alpha = {1,0.5,0.5},1
local mbOptionLabel = display.newText( "Mobile", mbOption.x, mbOption.y, native.systemFont, 16 )


-- Detects if a level is being played

local function LevelSelect()
    levela = display.newRect( cx - 75, cy, 40, 40 )
    levelb = display.newRect( cx + 75, cy, 40, 40 )
    levela.fill = {0}
    levelb.fill = {0}
    levelaLabel = display.newText( "level1", levela.x, levela.y,  native.systemFont, 13 )
    levelbLabel = display.newText( "level2", levelb.x, levelb.y,  native.systemFont, 13 )
    levelaLabel.name,levelbLabel.name = "1","2"
    
    -- physics.addBody( levela, "static" )
    -- physics.addBody( levelaLabel, "static" )

    levela:addEventListener("touch", levelSelected)
end


-- Choosing the platform
local function ChoosePC(event)
    if (event.phase == "began") then
        platform = "pc"
        display.remove( mbOption )
        display.remove( pcOption )
        display.remove( mbOptionLabel )
        display.remove( pcOptionLabel )
        display.remove( flatOverlay )
        LevelSelect()
    end
end

local function ChooseMobile(event)
    if (event.phase == "began") then
        platform = "mobile"
        display.remove( mbOption )
        display.remove( pcOption )
        display.remove( mbOptionLabel )
        display.remove( pcOptionLabel )
        display.remove( flatOverlay )
        LevelSelect()
    end
end

--[[ Listeners ]]-- =========================================================

mbOption:addEventListener("touch", ChooseMobile)
pcOption:addEventListener("touch", ChoosePC)
-- button:addEventListener( "touch" , buildLevel)