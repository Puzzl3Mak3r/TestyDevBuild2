--[[ Main core stuff ]]--        =========================================================

physics = require "physics"
physics.start()
system.activate( "multitouch" )

-- Extended Luas
local LevelSelectWorld  = require("CoreCode.LevelSelectWorld")
local PlayLevel         = require("CoreCode.MovementAndAnim")


--[[ To read the CSV file(s) ]]-- =========================================================

io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

require "extensions.string"
require "extensions.io"
require "extensions.table"
require "extensions.math"
require "extensions.display"



--[[ Local Parameters ]]--         =========================================================

local cx                                     = display.contentCenterX
local cy                                     = display.contentCenterY
local screenX                                = display.contentWidth
local screenY                                = display.contentHeight
local platform                               = ""
local BackGround                             = display.newRect( cx, cy, 3*screenX, 3*screenY)
BackGround.fill                              = {0.5,0.7,1}
playingStatus                                = false
physics.setGravity                             (0,10)



--[[ Choose Level ]]--             =========================================================

local function removeLevels()
    display.remove(level1)
    display.remove(level2)
    display.remove(level1Label)
    display.remove(level2Label)
end

local function levelSelected(event)
    if (event.phase == "began") then
        levelchosen = event.target.name --    Doens't work
        print( "level chosen" )
        removeLevels()
        levelchosen = "Loader"
        removeLevels()
       LevelSelectWorld.unLoadWorld()
    end
end

--[[ Load Start Screen ]]--    =========================================================


-- PC
local pcOption                       = display.newRect( cx-100, cy-100, 200, 200 )
    pcOption.fill, pcOption.alpha    = {1,0,0},1
local pcOptionLabel                  = display.newText( "PC", pcOption.x, pcOption.y, native.systemFont, 16 )

-- Mobile
local mbOption                       = display.newRect( cx+100, cy-100, 200, 200 )
    mbOption.fill, mbOption.alpha    = {1,0.5,0.5},1
local mbOptionLabel                  = display.newText( "Mobile", mbOption.x, mbOption.y, native.systemFont, 16 )


-- Detects if a level is being played

local function LevelSelect()
    level1 = display.newRect( cx - 75, cy, 40, 40 )
    level2 = display.newRect( cx + 75, cy, 40, 40 )
    level1.fill,level2.fill = {0},{0}
    level1Label = display.newText( "level1", level1.x, level1.y, native.systemFont, 13 )
    level2Label = display.newText( "level2", level2.x, level2.y, native.systemFont, 13 )
    level1Label.name,level2Label.name = "1","2"

    level1:addEventListener( "touch", levelSelected )
    level2:addEventListener( "touch", levelSelected )
end


-- Choosing the platform
local function removeOptions()
    display.remove( mbOption )
    display.remove( pcOption )
    display.remove( mbOptionLabel )
    display.remove( pcOptionLabel )
    -- display.remove( flatOverlay )
end


local function ChoosePC(event)
    if (event.phase == "began") then
        platform = "pc"
        print("pc built")
        PlayLevel.PC()
        removeOptions()
        LevelSelect()
        LevelSelectWorld.option("pc")
        print( "PC platform selected" )
        LevelSelectWorld.LoadWorld()
    end
end

local function ChooseMobile(event)
    if (event.phase == "began") then
        platform = "mobile"
        print("mobile built")
        PlayLevel.MOBILE()
        removeOptions()
        LevelSelect()
        LevelSelectWorld.option("mobile")
        print( "Mobile platform selected" )
        LevelSelectWorld.LoadWorld()
    end
end

--[[ Listeners ]]-- =========================================================

mbOption:addEventListener("touch", ChooseMobile)
pcOption:addEventListener("touch", ChoosePC)