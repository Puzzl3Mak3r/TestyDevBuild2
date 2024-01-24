-- OVERWORLD CODE!!!!!
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )
require "extensions.string"
require "extensions.io"
require "extensions.table"
require "extensions.math"
require "extensions.display"
fullw                        = display.actualContentWidth
fullh                        = display.actualContentHeight
cx                           = display.contentCenterX
cy                           = display.contentCenterY

-- Load CSV file as table of tables, where each sub-table is a row
lines = io.readFileTable( --[["To be sorted out"]] "Overworld/Area_0.csv" , system.ResourceDirectory )

local rows = {}

for i=1, #lines do	
  rows[#rows+1] = string.fromCSV(lines[i])
end

-- Debug step to see what we extracted from the CSV file; Note that I made it green to skip "print"
-- table.print_r(rows)

-- Top of your code:
local curRow = 1
local forLooper
local id = 0
local rectTable = {} -- for keeping references on created rectangles
local filename

local function buildLevel(build)
  --[[ Core Stuff ]]-- =========================================================
  


  

  -- [[ Actual Loader Function ]]-- =========================================================

  if( curRow <= #rows ) then
    table.print_r(rows[curRow])
    local forLooper = tonumber((rows[1][1]))
    local spawnX, spawnY = tonumber((rows[1][2])), tonumber((rows[1][3]))
    
    while (forLooper>=1) do

      -- In your loop:

      -- Create 'id' to make array assortment easier
      id = forLooper + 1

      if not rows[id] then
        break
      end -- this new line will stop the loop if index is nil
                                  
      -- Make the Blocks
      local rectID = tostring( id )
      local xOffset = cx + (tonumber(rows[id][1])) * 50
      local yOffset = cy + (tonumber(rows[id][2])) * 50

      if tostring(build) == "YES" then
        if ((tostring(rows[id][3])) == ".7") then
          rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles1.png", 50, 50 )
        elseif ((tostring(rows[id][3])) == ".3") then
          rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles2.png", 50, 50 )
        else
          rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles1.png", 50, 50 )
        end
        rectTable[rectID].x, rectTable[rectID].y = xOffset, yOffset

        if ((tostring(rows[id][4])) == "Y") then
          physics.addBody( (rectTable[rectID]), "static", { density=1.0, friction=100, bounce=-10} )
        end
        
      elseif tostring(build) == "NO" then
        display.remove( rectTable[rectID] )
      end
      -- Repeat until finished CSV
      forLooper = forLooper-1
    end
  end
end


local M = {}

function M.LoadWorld()
  buildLevel("YES")
end

function M.unLoadWorld()
  buildLevel("NO")
end

return M

--[[ Main core stuff ]]--    =========================================================

physics = require "physics"
physics.start()
system.activate( "multitouch" )
local Test = require("load_world")


--[[ To read the CSV file(s) ]]-- =========================================================

io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

require "extensions.string"
require "extensions.io"
require "extensions.table"
require "extensions.math"
require "extensions.display"



--[[ Parameters ]]--         =========================================================

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
local BackGround                   = display.newRect( cx, cy, 3*screenX, 3*screenY)
local velocity                     = 1
local playerMoving                 = false
BackGround.fill                    = {0.5,0.7,1}
playingStatus                      = false
physics.setGravity                   (0,10)


--[[ Choose Level ]]--       =========================================================

local function removeLevels()
  display.remove(levela)
  display.remove(levelb)
  display.remove(levelaLabel)
  display.remove(levelbLabel)
end

local function levelSelected(event)
  if (event.phase == "began") then
    levelchosen = event.target.name --  Doens't work
    print( "level chosen" )
    removeLevels()
    PreBuild()
    StartPlayingPlatformer()
    BuildTheLevel()
    levelchosen = "Loader"
    removeLevels()
    Test.unLoadWorld()
  end
end



--[[ PreBuild ]]--           =========================================================

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



--[[ Game Code ]]--          =========================================================

function StartPlayingPlatformer()
--[[ Player ]]--         =========================================================

-- Load the sheets
player = display.newRect( cx, cy, 100, 70)
player.name = "real"
player.fill = {1,1,0}
playerVx, playerVy = 0, 0
physics.addBody( player )
player.isFixedRotation=true
player.postCollision = nil
  

--[[ Testy Animation ]]-- ========================================================

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
      loopCount = 7        -- Optional ; default is 0
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


  --[[ Main Level Functions ]]-- ===================================================

  -- Make the player jump
    local jumps = 0

    local function ResetJumps()
      if playerVy == 0 then
        jumps = 1
        print( "Jump has been reset" )
      end
    end

    local function Jump( event )
      if platform == "mobile" then
        if(event.phase == "began") then
          if ((holdingLeft or holdingRight)== false) then
            if jumps == 1 then
              player:setLinearVelocity(0,-270)
              print( "Player Jumped" )
              jumps = jumps - 1
            else
              ResetJumps()
            end
          end
        end
      else
        if jumps == 1 then
          player:setLinearVelocity(0,-270)
          print( "Player Jumped" )
          jumps = jumps - 1
        else
          ResetJumps()
        end
      end
    end

  -- Moving left & right
    local function moveLeft()
      player.x = player.x - 2
      newPlayer.xScale = -0.3
      print( "moved left" )
    end
    local function moveRight()
      player.x = player.x + 2
      newPlayer.xScale = 0.3
      print( "moved right" )
    end

  -- Animations!!!!!
    local function AnimateMoving()
      if playerMoving == true then
        newPlayer:setSequence("run")
        newPlayer:play()
        print( "runAnimation" )
      end
    end

    local function falling()
      -- Falling animation
      if ( velocity == 1 ) then
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

    local function moveTesty()
      if holdingLeft and holdingRight then
      elseif holdingLeft then
        moveLeft()
      elseif holdingRight then
        moveRight()
      end
    end

  local function ConfirmTouch(event)
    if(event.phase == "moved" or event.phase == "began")then
      if event.target.name == "left" and event.target.name == "right" then
      elseif (event.target.name == "left") then
        holdingLeft = true
      elseif (event.target.name == "right") then
        holdingRight = true
      end
      print("touched")
    end
    if(event.phase == "ended")then
      holdingLeft, holdingRight = false, false
      newPlayer:setSequence("idle")
      newPlayer:play()
    end
  end

  -- [[ PC controls ]] --  =========================================================
    pressedKeys = {}
    local function onKeyEvent(event)
      if event.phase == "down" then
        pressedKeys[event.keyName] = true
      elseif event.phase == "up" then
        pressedKeys[event.keyName] = false
      else
        pressedKeys[event.keyName] = false
      end
    end

    local function onEnterFrame(event)
      if pressedKeys["w"] then
        Jump()
      end
      if pressedKeys["a"] and pressedKeys["d"] then
        playerMoving = false
      elseif pressedKeys["a"] then
        moveLeft()
        playerMoving = true
      elseif pressedKeys["d"] then
        moveRight()
        playerMoving = true
      elseif not pressedKeys["a"] and not pressedKeys["d"] then
        playerMoving = false
      end
    end

  -- [[ Set variables for player velocities ]] -- ==================================
  local function WhenPlaying()
    newPlayer.x,newPlayer.y=player.x,(player.y - 8 )
    playerVx, playerVy = player:getLinearVelocity()
  end

  --[[ Delays And Listeners ]]-- ===================================================
    Runtime:addEventListener("enterFrame", WhenPlaying )
    Runtime:addEventListener("enterFrame", falling )
      

    if platform == "mobile" then
      BackGround:addEventListener( "touch", Jump )
      rightArrow:addEventListener( "touch", ConfirmTouch )
      leftArrow:addEventListener( "touch", ConfirmTouch )
      Runtime:addEventListener( "enterFrame", moveTesty )

      -- rightArrow:addEventListener("touch", ConfirmTouch)
      -- leftArrow:addEventListener("touch", ConfirmTouch)
    end
    if platform == "pc" then
      Runtime:addEventListener( "enterFrame", onEnterFrame )
      Runtime:addEventListener( "key", onKeyEvent )
    end
end



--[[ Level Builder ]]--      =========================================================

function BuildTheLevel()
      
  --[[ Level Loader ]]-- =========================================================

  -- Load CSV file as table of tables, where each sub-table is a row
  local lines = io.readFileTable( "OldDebugTest.csv", system.ResourceDirectory )

  local rows = {}

  for i=1, #lines do	
    rows[#rows+1] = string.fromCSV(lines[i])
  end

  -- Debug step to see what we extracted from the CSV file; Note that I made it green to skip "print"
  -- table.print_r(rows)

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



--[[ Load Start Screen ]]--  =========================================================

local testVideo = native.newVideo( cx, cy, 320, 480 )
testVideo:load( "testVid.mp4", system.DocumentsDirectory )
testVideo:play()


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
  levelaLabel = display.newText( "level1", levela.x, levela.y, native.systemFont, 13 )
  levelbLabel = display.newText( "level2", levelb.x, levelb.y, native.systemFont, 13 )
  levelaLabel.name,levelbLabel.name = "1","2"
  
  -- physics.addBody( levela, "static" )
  -- physics.addBody( levelaLabel, "static" )

  levela:addEventListener( "touch", levelSelected )
  levelb:addEventListener( "touch", levelSelected )
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
    print( "PC platform selected" )
    Test.LoadWorld()
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
    print( "Mobile platform selected" )
  end
end

--[[ Listeners ]]-- =========================================================

mbOption:addEventListener("touch", ChooseMobile)
pcOption:addEventListener("touch", ChoosePC)