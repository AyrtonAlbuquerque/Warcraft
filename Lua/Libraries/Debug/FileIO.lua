if Debug then Debug.beginFile "FileIO" end
--[[
    FileIO v2

    Author: Trokkin
    Updated by Antares

    Provides functionality to read and write files, optimized with lua functionality in mind.

    API:

        FileIO.Save(filename, data)
            - Write string data to a file

        FileIO.Load(filename) -> string?
            - Read string data from a file. Returns nil if file doesn't exist.

        FileIO.SaveAsserted(filename, data, onFail?) -> bool
            - Saves the file and checks that it was saved successfully.
              If it fails, passes (filename, data, loadResult) to onFail.

    Optional requirements:
        DebugUtils by Eikonium                          @ https://www.hiveworkshop.com/threads/330758/

    Inspired by:
        - TriggerHappy's Codeless Save and Load         @ https://www.hiveworkshop.com/threads/278664/
        - ScrewTheTrees's Codeless Save/Sync concept    @ https://www.hiveworkshop.com/threads/325749/
        - Luashine's LUA variant of TH's FileIO         @ https://www.hiveworkshop.com/threads/307568/post-3519040
        - HerlySQR's LUA variant of TH's Save/Load      @ https://www.hiveworkshop.com/threads/331536/post-3565884

    Updated: 15 June 2025
--]]
do
    local RAW_PREFIX = ']]i([['
    local RAW_SUFFIX = ']])--[['
    local RAW_SIZE = 255 - #RAW_PREFIX - #RAW_SUFFIX
    local LOAD_ABILITY = FourCC('ANdc')
    local LOAD_EMPTY_KEY = '!@#$, empty data'

    local name

    local function open(filename)
        name = filename
        PreloadGenClear()
        Preload('")\nendfunction\n//!beginusercode\nlocal p={} local i=function(s) table.insert(p,s) end--[[')
    end

    local function write(s)
        --Avoid ]] in string.
        s = s:gsub("\x25]", "!]")
        --Repeated backslash literals are not processed correctly by the Preload natives.
        s = s:gsub("\\", "!\\")
        local i = 1
        local size = #s
        local pos, __, num, str
        repeat
            pos = i + RAW_SIZE - 1
            str = s:sub(i, pos)
            --Escaped characters increase preload string size in file, causing the suffix to get swallowed, which in turn causes a crash.
            __, num = str:gsub("[\\\n\'\"]", "")
            pos = pos - num
            --A ] at the end of a preload string will crash the game. A newline character at the beginning will be swallowed.
            while s:sub(pos, pos) == "]" or s:sub(pos + 1, pos + 1) == "\n" do
                pos = pos - 1
            end
            Preload(RAW_PREFIX .. s:sub(i, pos) .. RAW_SUFFIX)
            i = pos + 1
        until i > size
    end

    local function close()
        Preload(']]BlzSetAbilityTooltip(' ..
            LOAD_ABILITY .. ', table.concat(p), 0)\n//!endusercode\nfunction a takes nothing returns nothing\n//')
        PreloadGenEnd(name)
        name = nil
    end

    ---@param filename string
    ---@param data string
    local function savefile(filename, data)
        open(filename)
        write(data)
        close()
    end

    ---@param filename string
    ---@return string?
    local function loadfile(filename)
        local s = BlzGetAbilityTooltip(LOAD_ABILITY, 0)
        BlzSetAbilityTooltip(LOAD_ABILITY, LOAD_EMPTY_KEY, 0)
        Preloader(filename)
        local loaded = BlzGetAbilityTooltip(LOAD_ABILITY, 0)
        BlzSetAbilityTooltip(LOAD_ABILITY, s, 0)
        if loaded == LOAD_EMPTY_KEY then
            return nil
        end
        ---@diagnostic disable-next-line: redundant-return-value
        return loaded:gsub("!\x25]", "]"):gsub("!\\\\", "\\")
    end

    ---@param filename string
    ---@param data string
    ---@param onFail function?
    ---@return boolean
    local function saveAsserted(filename, data, onFail)
        savefile(filename, data)
        local res = loadfile(filename)
        if res == data then
            return true
        end
        if onFail then
            onFail(filename, data, res)
        end
        return false
    end

    FileIO = {
        Save = savefile,
        Load = loadfile,
        SaveAsserted = saveAsserted
    }
end