---@beginFile PrecomputedHeightMap
do
    --[[
    ===============================================================================================================================================================
                                                                    Precomputed Height Map
                                                                        by Antares
    ===============================================================================================================================================================
    
    GetLocZ(x, y)                               Returns the same value as GetLocationZ(x, y).
    GetTerrainZ(x, y)                           Returns the exact height of the terrain geometry.
    GetUnitZ(whichUnit)                         Returns the same value as BlzGetUnitZ(whichUnit).
    GetUnitCoordinates(whichUnit)               Returns x, y, and z-coordinates of a unit.

    ===============================================================================================================================================================

    Computes the terrain height of your map on map initialization for later use. The function GetLocZ replaces the traditional GetLocZ, defined as:

    function GetLocZ(x, y)
        MoveLocation(moveableLoc, x, y)
        return GetLocationZ(moveableLoc)
    end

    The function provided in this library cannot cause desyncs and is approximately twice as fast. GetTerrainZ is a variation of GetLocZ that returns the exact height
    of the terrain geometry (around cliffs, it has to approximate).

    Note: PrecomputedHeightMap initializes OnitInit.final, because otherwise walkable doodads would not be registered.

    ===============================================================================================================================================================

    You have the option to save the height map to a file on map initialization. You can then reimport the data into the map to load the height map from that data.
    This will make the use of Z-coordinates completely safe, as all clients are guaranteed to use exactly the same data. It is recommended to do this once for the
    release version of your map.

    To do this, set the flag for WRITE_HEIGHT_MAP and launch your map. The terrain height map will be generated on map initialization and saved to a file in your
    Warcraft III\CustomMapData\ folder. Open that file in a text editor, then remove all occurances of

    	call Preload( "
    " )
    
    with find and replace (including the quotation marks and tab space). Then, remove

    function PreloadFiles takes nothing returns nothing
	    call PreloadStart()

    at the beginning of the file and

        call PreloadEnd( 0.0 )
    endfunction

    at the end of the file. Finally, remove all line breaks by removing \n and \r. The result should be something like

    HeightMapCode = "|pk44mM-b+b1-dr|krjdhWcy1aa1|eWcyaa"

    except much longer.

    Copy the entire string and paste it anywhere into the Lua root in your map, for example into the Config section of this library. Now, every time your map is
    launched, the height map will be read from the string instead of being generated, making it guaranteed to be synced.

    To check if the code has been generated correctly, launch your map one more time in single-player. The height map generated from the code will be checked against
    one generated in the traditional way.

    --=============================================================================================================================================================
                                                                          C O N F I G
    --=============================================================================================================================================================
    ]]

    --Where to store data when exporting height map.
    local SUBFOLDER                         = "PrecomputedHeightMap"

    --If set to false, GetTerrainZ will be less accurate around cliffs, but slightly faster.
    local STORE_CLIFF_DATA                  = true

    --Set to true if you have water cliffs and have STORE_CLIFF_DATA enabled.
    local STORE_WATER_DATA                  = true

    --Write height map to file?
    local WRITE_HEIGHT_MAP                  = false

    --Check if height map read from string is accurate.
    local VALIDATE_HEIGHT_MAP               = true

    --Create a special effect at each grid point to double-check if the height map is correct.
    local VISUALIZE_HEIGHT_MAP              = false

    --=============================================================================================================================================================

    local heightMap                         = {}        ---@type table[]
    local terrainHasCliffs                  = {}        ---@type table[]
    local terrainCliffLevel                 = {}        ---@type table[]
    local terrainHasWater                   = {}        ---@type table[]
    local moveableLoc                       = nil       ---@type location

    local MINIMUM_Z                         = -2048     ---@type number
    local CLIFF_HEIGHT                      = 128       ---@type number

    local worldMinX
    local worldMinY
    local worldMaxX
    local worldMaxY

    local iMax
    local jMax

    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$&()[]=?:;,._#*~/{}<>^"

    local NUMBER_OF_CHARS = string.len(chars)

    ---@param x number
    ---@param y number
    ---@return number
    function GetLocZ(x, y)
        MoveLocation(moveableLoc, x, y)
        return GetLocationZ(moveableLoc)
    end
	
	GetTerrainZ = GetLocZ

    ---@param whichUnit unit
    ---@return number
    function GetUnitZ(whichUnit)
        return GetLocZ(GetUnitX(whichUnit), GetUnitY(whichUnit)) + GetUnitFlyHeight(whichUnit)
    end

    ---@param whichUnit unit
    ---@return number, number, number
    function GetUnitCoordinates(whichUnit)
        local x = GetUnitX(whichUnit)
        local y = GetUnitY(whichUnit)
        return x, y, GetLocZ(x, y) + GetUnitFlyHeight(whichUnit)
    end

    local function OverwriteHeightFunctions()
    	---@param x number
		---@param y number
		---@return number
        GetLocZ = function(x, y)
            local rx = (x - worldMinX)*0.0078125 + 1
            local ry = (y - worldMinY)*0.0078125 + 1
            local i = rx // 1
            local j = ry // 1
            rx = rx - i
            ry = ry - j
            if i < 1 then
                i = 1
                rx = 0
            elseif i > iMax then
                i = iMax
                rx = 1
            end
            if j < 1 then
                j = 1
                ry = 0
            elseif j > jMax then
                j = jMax
                ry = 1
            end

            local heightMapI = heightMap[i]
            local heightMapIplus1 = heightMap[i+1]
            return (1 - ry)*((1 - rx)*heightMapI[j] + rx*heightMapIplus1[j]) + ry*((1 - rx)*heightMapI[j+1] + rx*heightMapIplus1[j+1])
        end

        if STORE_CLIFF_DATA then
            ---@param x number
            ---@param y number
            ---@return number
            GetTerrainZ = function(x, y)
                local rx = (x - worldMinX)*0.0078125 + 1
                local ry = (y - worldMinY)*0.0078125 + 1
                local i = rx // 1
                local j = ry // 1
                rx = rx - i
                ry = ry - j
                if i < 1 then
                    i = 1
                    rx = 0
                elseif i > iMax then
                    i = iMax
                    rx = 1
                end
                if j < 1 then
                    j = 1
                    ry = 0
                elseif j > jMax then
                    j = jMax
                    ry = 1
                end

                if terrainHasCliffs[i][j] then
                    if rx < 0.5 then
                        if ry < 0.5 then
                            if STORE_WATER_DATA and terrainHasWater[i][j] then
                                return heightMap[i][j]
                            else
                                return (1 - rx - ry)*heightMap[i][j] + (rx*(heightMap[i+1][j] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j] - terrainCliffLevel[i][j])) + ry*(heightMap[i][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i][j+1] - terrainCliffLevel[i][j])))
                            end
                        elseif STORE_WATER_DATA and terrainHasWater[i][j] then
                            return heightMap[i][j+1]
                        elseif rx + ry > 1 then
                            return (rx + ry - 1)*(heightMap[i+1][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j+1] - terrainCliffLevel[i][j+1])) + ((1 - rx)*heightMap[i][j+1] + (1 - ry)*(heightMap[i+1][j] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j] - terrainCliffLevel[i][j+1])))
                        else
                            return (1 - rx - ry)*(heightMap[i][j] - CLIFF_HEIGHT*(terrainCliffLevel[i][j] - terrainCliffLevel[i][j+1])) + (rx*(heightMap[i+1][j] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j] - terrainCliffLevel[i][j+1])) + ry*heightMap[i][j+1])
                        end
                    elseif ry < 0.5 then
                        if STORE_WATER_DATA and terrainHasWater[i][j] then
                            return heightMap[i+1][j]
                        elseif rx + ry > 1 then
                            return (rx + ry - 1)*(heightMap[i+1][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j+1] - terrainCliffLevel[i+1][j])) + ((1 - rx)*(heightMap[i][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i][j+1] - terrainCliffLevel[i+1][j])) + (1 - ry)*heightMap[i+1][j])
                        else
                            return (1 - rx - ry)*(heightMap[i][j] - CLIFF_HEIGHT*(terrainCliffLevel[i][j] - terrainCliffLevel[i+1][j])) + (rx*heightMap[i+1][j] + ry*(heightMap[i][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i][j+1] - terrainCliffLevel[i+1][j])))
                        end
                    elseif STORE_WATER_DATA and terrainHasWater[i][j] then
                        return heightMap[i+1][j+1]
                    else
                        return (rx + ry - 1)*heightMap[i+1][j+1] + ((1 - rx)*(heightMap[i][j+1] - CLIFF_HEIGHT*(terrainCliffLevel[i][j+1] - terrainCliffLevel[i+1][j+1])) + (1 - ry)*(heightMap[i+1][j] - CLIFF_HEIGHT*(terrainCliffLevel[i+1][j] - terrainCliffLevel[i+1][j+1])))
                    end
                else
                    if rx + ry > 1 then --In top-right triangle
                        local heightMapIplus1 = heightMap[i+1]
                        return (rx + ry - 1)*heightMapIplus1[j+1] + ((1 - rx)*heightMap[i][j+1] + (1 - ry)*heightMapIplus1[j])
                    else
                        local heightMapI = heightMap[i]
                        return (1 - rx - ry)*heightMapI[j] + (rx*heightMap[i+1][j] + ry*heightMapI[j+1])
                    end
                end
            end
        else
            ---@param x number
            ---@param y number
            ---@return number
            GetTerrainZ = function(x, y)
                local rx = (x - worldMinX)*0.0078125 + 1
                local ry = (y - worldMinY)*0.0078125 + 1
                local i = rx // 1
                local j = ry // 1
                rx = rx - i
                ry = ry - j
                if i < 1 then
                    i = 1
                    rx = 0
                elseif i > iMax then
                    i = iMax
                    rx = 1
                end
                if j < 1 then
                    j = 1
                    ry = 0
                elseif j > jMax then
                    j = jMax
                    ry = 1
                end

                if rx + ry > 1 then --In top-right triangle
                    local heightMapIplus1 = heightMap[i+1]
                    return (rx + ry - 1)*heightMapIplus1[j+1] + ((1 - rx)*heightMap[i][j+1] + (1 - ry)*heightMapIplus1[j])
                else
                    local heightMapI = heightMap[i]
                    return (1 - rx - ry)*heightMapI[j] + (rx*heightMap[i+1][j] + ry*heightMapI[j+1])
                end
            end
        end
    end

    local function CreateHeightMap()
        local xMin = (worldMinX // 128)*128
        local yMin = (worldMinY // 128)*128
        local xMax = (worldMaxX // 128)*128 + 1
        local yMax = (worldMaxY // 128)*128 + 1

        local x = xMin
        local y
        local i = 1
        local j
        while x <= xMax do
            heightMap[i] = {}
            if STORE_CLIFF_DATA then
                terrainHasCliffs[i] = {}
                terrainCliffLevel[i] = {}
                if STORE_WATER_DATA then
                    terrainHasWater[i] = {}
                end
            end
            y = yMin
            j = 1
            while y <= yMax do
                heightMap[i][j] = GetLocZ(x,y)
                if VISUALIZE_HEIGHT_MAP then
                    BlzSetSpecialEffectZ(AddSpecialEffect("Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0", x, y), heightMap[i][j] - 40)
                end
                if STORE_CLIFF_DATA then
                    local level1 = GetTerrainCliffLevel(x, y)
                    local level2 = GetTerrainCliffLevel(x, y + 128)
                    local level3 = GetTerrainCliffLevel(x + 128, y)
                    local level4 = GetTerrainCliffLevel(x + 128, y + 128)
                    if level1 ~= level2 or level1 ~= level3 or level1 ~= level4 then
                        terrainHasCliffs[i][j] = true
                    end
                    terrainCliffLevel[i][j] = level1
                    if STORE_WATER_DATA then
                        terrainHasWater[i][j] = not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x, y + 128, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x + 128, y, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x + 128, y + 128, PATHING_TYPE_FLOATABILITY)
                    end
                end
                j = j + 1
                y = y + 128
            end
            i = i + 1
            x = x + 128
        end

        iMax = i - 2
        jMax = j - 2
    end

    local function ValidateHeightMap()
        local xMin = (worldMinX // 128)*128
        local yMin = (worldMinY // 128)*128
        local xMax = (worldMaxX // 128)*128 + 1
        local yMax = (worldMaxY // 128)*128 + 1

        local numOutdated = 0

        local x = xMin
        local y
        local i = 1
        local j
        while x <= xMax do
            y = yMin
            j = 1
            while y <= yMax do
                if heightMap[i][j] then
                    if VISUALIZE_HEIGHT_MAP then
                        BlzSetSpecialEffectZ(AddSpecialEffect("Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0", x, y), heightMap[i][j] - 40)
                    end
                    if bj_isSinglePlayer and math.abs(heightMap[i][j] - GetLocZ(x, y)) > 1 then
                        numOutdated = numOutdated + 1
                    end
                else
                    print("Height Map nil at x = " .. x .. ", y = " .. y)
                end
                j = j + 1
                y = y + 128
            end
            i = i + 1
            x = x + 128
        end
        
        if numOutdated > 0 then
            print("|cffff0000Warning:|r Height Map is outdated at " .. numOutdated .. " locations...")
        end
    end

    local function ReadHeightMap()
        local charPos = 0
        local numRepetitions = 0
        local charValues = {}

        for i = 1, NUMBER_OF_CHARS do
            charValues[string.sub(chars, i, i)] = i - 1
        end

        local firstChar = nil

        local PLUS = 0
        local MINUS = 1
        local ABS = 2
        local segmentType = ABS

        for i = 1, #heightMap do
            for j = 1, #heightMap[i] do
                if numRepetitions > 0 then
                    heightMap[i][j] = heightMap[i][j-1]
                    numRepetitions = numRepetitions - 1
                else
                    local valueDetermined = false
                    while not valueDetermined do
                        charPos = charPos + 1
                        local char = string.sub(HeightMapCode, charPos, charPos)
                        if char == "+" then
                            segmentType = PLUS
                            charPos = charPos + 1
                            char = string.sub(HeightMapCode, charPos, charPos)
                        elseif char == "-" then
                            segmentType = MINUS
                            charPos = charPos + 1
                            char = string.sub(HeightMapCode, charPos, charPos)
                        elseif char == "|" then
                            segmentType = ABS
                            charPos = charPos + 1
                            char = string.sub(HeightMapCode, charPos, charPos)
                        end
                        if tonumber(char) then
                            local k = 0
                            while tonumber(string.sub(HeightMapCode, charPos + k + 1, charPos + k + 1)) do
                                k = k + 1
                            end
                            numRepetitions = tonumber(string.sub(HeightMapCode, charPos, charPos + k)) - 1
                            charPos = charPos + k
                            valueDetermined = true
                            heightMap[i][j] = heightMap[i][j-1]
                        else
                            if segmentType == PLUS then
                                heightMap[i][j] = heightMap[i][j-1] + charValues[char]
                                valueDetermined = true
                            elseif segmentType == MINUS then
                                heightMap[i][j] = heightMap[i][j-1] - charValues[char]
                                valueDetermined = true
                            elseif firstChar then
                                if charValues[firstChar] and charValues[char] then
                                    heightMap[i][j] = charValues[firstChar]*NUMBER_OF_CHARS + charValues[char] + MINIMUM_Z
                                else
                                    heightMap[i][j] = 0
                                end
                                firstChar = nil
                                valueDetermined = true
                            else
                                firstChar = char
                            end
                        end
                    end
                end
            end
        end
        HeightMapCode = nil
    end

    local function WriteHeightMap(subfolder)
        PreloadGenClear()
        PreloadGenStart()
    
        local numRepetitions = 0
        local firstChar
        local secondChar
        local stringLength = 0
        local lastValue = 0
    
        local PLUS = 0
        local MINUS = 1
        local ABS = 2
        local segmentType = ABS
        local preloadString = {'HeightMapCode = "'}

        for i = 1, #heightMap do
            for j = 1, #heightMap[i] do
                if j > 1 then
                    local diff = (heightMap[i][j] - lastValue)//1
                    if diff == 0 then
                        numRepetitions = numRepetitions + 1
                    else
                        if numRepetitions > 0 then
                            table.insert(preloadString, numRepetitions)
                        end
                        numRepetitions = 0

                        if diff > 0 and diff < NUMBER_OF_CHARS then
                            if segmentType ~= PLUS then
                                segmentType = PLUS
                                table.insert(preloadString, "+")
                            end
                        elseif diff < 0 and diff > -NUMBER_OF_CHARS then
                            if segmentType ~= MINUS then
                                segmentType = MINUS
                                table.insert(preloadString, "-")
                            end
                        else
                            if segmentType ~= ABS then
                                segmentType = ABS
                                table.insert(preloadString, "|")
                            end
                        end
    
                        if segmentType == ABS then
                            firstChar = (heightMap[i][j] - MINIMUM_Z) // NUMBER_OF_CHARS + 1
                            secondChar = heightMap[i][j]//1 - MINIMUM_Z - (heightMap[i][j]//1 - MINIMUM_Z)//NUMBER_OF_CHARS*NUMBER_OF_CHARS + 1
                            table.insert(preloadString, string.sub(chars, firstChar, firstChar) .. string.sub(chars, secondChar, secondChar))
                        elseif segmentType == PLUS then
                            firstChar = diff//1 + 1
                            table.insert(preloadString, string.sub(chars, firstChar, firstChar))
                        elseif segmentType == MINUS then
                            firstChar = -diff//1 + 1
                            table.insert(preloadString, string.sub(chars, firstChar, firstChar))
                        end
                    end
                else
                    if numRepetitions > 0 then
                        table.insert(preloadString, numRepetitions)
                    end
                    segmentType = ABS
                    table.insert(preloadString, "|")
                    numRepetitions = 0
                    firstChar = (heightMap[i][j] - MINIMUM_Z) // NUMBER_OF_CHARS + 1
                    secondChar = heightMap[i][j]//1 - MINIMUM_Z - (heightMap[i][j]//1 - MINIMUM_Z)//NUMBER_OF_CHARS*NUMBER_OF_CHARS + 1
                    table.insert(preloadString, string.sub(chars, firstChar, firstChar) .. string.sub(chars, secondChar, secondChar))
                end
    
                lastValue = heightMap[i][j]//1
    
                stringLength = stringLength + 1
                if stringLength == 100 then
                    Preload(table.concat(preloadString))
                    stringLength = 0
                    for k, __ in ipairs(preloadString) do
                        preloadString[k] = nil
                    end
                end
            end
        end
    
        if numRepetitions > 0 then
            table.insert(preloadString, numRepetitions)
        end
    
        table.insert(preloadString, '"')
        Preload(table.concat(preloadString))
    
        PreloadGenEnd(subfolder .. "\\heightMap.txt")
    
        print("Written Height Map to CustomMapData\\" .. subfolder .. "\\heightMap.txt")
    end

    local function InitHeightMap()
        local xMin = (worldMinX // 128)*128
        local yMin = (worldMinY // 128)*128
        local xMax = (worldMaxX // 128)*128 + 1
        local yMax = (worldMaxY // 128)*128 + 1

        local x = xMin
        local y
        local i = 1
        local j
        while x <= xMax do
            heightMap[i] = {}
            if STORE_CLIFF_DATA then
                terrainHasCliffs[i] = {}
                terrainCliffLevel[i] = {}
                if STORE_WATER_DATA then
                    terrainHasWater[i] = {}
                end
            end
            y = yMin
            j = 1
            while y <= yMax do
                heightMap[i][j] = 0
                if STORE_CLIFF_DATA then
                    local level1 = GetTerrainCliffLevel(x, y)
                    local level2 = GetTerrainCliffLevel(x, y + 128)
                    local level3 = GetTerrainCliffLevel(x + 128, y)
                    local level4 = GetTerrainCliffLevel(x + 128, y + 128)
                    if level1 ~= level2 or level1 ~= level3 or level1 ~= level4 then
                        terrainHasCliffs[i][j] = true
                    end
                    terrainCliffLevel[i][j] = level1
                    if STORE_WATER_DATA then
                        terrainHasWater[i][j] = not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x, y + 128, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x + 128, y, PATHING_TYPE_FLOATABILITY)
                        or not IsTerrainPathable(x + 128, y + 128, PATHING_TYPE_FLOATABILITY)
                    end
                end
                j = j + 1
                y = y + 128
            end
            i = i + 1
            x = x + 128
        end

        iMax = i - 2
        jMax = j - 2
    end

	WSCode.InitEssential(function()
        local worldBounds = GetWorldBounds()
        worldMinX = GetRectMinX(worldBounds)
        worldMinY = GetRectMinY(worldBounds)
        worldMaxX = GetRectMaxX(worldBounds)
        worldMaxY = GetRectMaxY(worldBounds)

        moveableLoc = Location(0, 0)

        if HeightMapCode then
            InitHeightMap()
			ReadHeightMap()
            if bj_isSinglePlayer and VALIDATE_HEIGHT_MAP then
                ValidateHeightMap()
            end
        else
            CreateHeightMap()
            if WRITE_HEIGHT_MAP then
                WriteHeightMap(SUBFOLDER)
            end
        end
        OverwriteHeightFunctions()
    end)
end