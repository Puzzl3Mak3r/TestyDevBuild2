-- OVERWORLD CODE!!!!!
io.output():setvbuf("no")
display.setStatusBar  (display.HiddenStatusBar)
local physics = require "physics"
physics.start()
physics.setGravity(0, 0)
require "extensions.string"
require "extensions.io"
require "extensions.table"
require "extensions.math"
require "extensions.display"
local platform        = ""
local fullw           = display.actualContentWidth
local fullh           = display.actualContentHeight
local cx              = display.contentCenterX
local cy              = display.contentCenterY
local spawnX, spanwnY = cx, cy
local Speed           = 4 -- Changes speed of player movement
local pressedKeys     = {}



-- [[ Player Movement ]]

-- [[ PC controls ]]

function onEnterFrame(event)
    -- Up and Down
    if pressedKeys["w"] and pressedKeys["s"] then
    elseif pressedKeys["w"]then
        LevelPlayer.y = LevelPlayer.y - Speed
    elseif pressedKeys["s"]then
        LevelPlayer.y = LevelPlayer.y + Speed
    end

    -- Left and Right
    if pressedKeys["a"] and pressedKeys["d"] then
    elseif pressedKeys["a"]then
        LevelPlayer.x = LevelPlayer.x - Speed
    elseif pressedKeys["d"]then
        LevelPlayer.x = LevelPlayer.x + Speed
    end

    -- Enter Level
    -- if pressedKeys["return"] then
end
function onKeyEvent(event)
    if event.phase == "down" then
        pressedKeys[event.keyName] = true
    elseif event.phase == "up" then
        pressedKeys[event.keyName] = false
    else
        pressedKeys[event.keyName] = false
    end
end





-- Load CSV file as table of tables, where each sub-table is a row
-- [[ Whole World Generation Code ]]
local lines = io.readFileTable( --[["To be sorted out"]] "Overworld/Area_0.csv" , system.ResourceDirectory )

local rows = {}

for i=1, #lines do	
    rows[#rows+1] = string.fromCSV(lines[i])
end

-- Note that I made it green to skip "print" so it doesn't annoy you
-- table.print_r(rows)

-- Top of your code:
local curRow    = 1
local forLooper
local id        = 0
local rectTable = {}  -- for keeping references on created rectangles
local filename

local function buildLevel(build)

    -- [[ Actual Loader Function ]]-- =========================================================

    if( curRow <= #rows ) then
        table.print_r(rows[curRow])
        local forLooper = tonumber((rows[1][1]))
        -- spawnX, spawnY = tonumber((rows[1][2])), tonumber((rows[1][3]))

        while (forLooper>=1) do

            -- In your loop:

            -- Create 'id' to make array assortment easier
            id = forLooper + 1

            if not rows[id] then
                break
            end -- this new line will stop the loop if index is nil

            -- Make the Blocks
            local rectID  = tostring(id)
            local xOffset = cx + tonumber(rows[id][1]) * 100
            local yOffset = cy + tonumber(rows[id][2]) * 100

            if tostring(build) == "YES" then
                if ((tostring(rows[id][3])) == ".7") then
                    rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles1.png", 100, 100 )
                elseif ((tostring(rows[id][3])) == ".3") then
                    rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles2.png", 100, 100 )
                else
                    rectTable[rectID] = display.newImageRect( "Assets/OLD_tiles1.png", 100, 100 )
                end
                rectTable[rectID].x, rectTable[rectID].y = xOffset, yOffset

                if ((tostring(rows[id][4])) == "Y") then
                    physics.addBody( (rectTable[rectID]), "static", { density=1.0, friction=100, bounce=-10} )
                end

            elseif tostring(build) == "NO" then
                display.remove( rectTable[rectID] )
            end
            -- Repeat until finished CSV
            forLooper = forLooper - 1
        end
    end
end



-- [[ Code for Creating the Player ]]
function LoadWorldSelectPlayer(option)
    if option == "Load" then
        LevelPlayer = display.newRect( spawnX, spanwnY, 70, 70 )
        LevelPlayer.fill = {1,1,0.5}
        if platform == "pc" then
            print("QWERTYUIOP{}")
            Runtime:addEventListener( "enterFrame", onEnterFrame )
            Runtime:addEventListener( "key", onKeyEvent )
        end
    elseif option == "unLoad" then
        display.remove( LevelPlayer )
        if platform == "pc" then
            Runtime:removeEventListener( onEnterFrame )
            Runtime:removeEventListener( onKeyEvent )
        end
    end
end


-- [[ Lua File Functions ]]

local M = {}

function M.option(option)
    if option == "pc" then
        platform = "pc"
    elseif option == "mobile" then
        platform = "mobile"
    end
end

function M.LoadWorld()
    buildLevel("YES")
    LoadWorldSelectPlayer("Load")
end

function M.unLoadWorld()
    buildLevel("NO")
    LoadWorldSelectPlayer("unLoad")
end


--Has to be pu last
return M