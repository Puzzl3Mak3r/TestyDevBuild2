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