if Debug then Debug.beginFile "WarcraftStudioCode" end
do
---@diagnostic disable: redundant-return-value

    --[[
    =============================================================================================================================================================
                                                                    Warcraft Studio Code
                                                                         by Antares
                                                                            v3.4

                                                        An in-game Lua editor, compiler, and debugger.
                        
                                Requires:
                                DebugUtils (2.5+)               https://www.hiveworkshop.com/threads/.353720/
                                HandleType                      https://www.hiveworkshop.com/threads/.354436/
                                World2Screen (replaceable)      https://www.hiveworkshop.com/threads/.354017/

                                PrecomputedHeightMap (optional) https://www.hiveworkshop.com/threads/.353477/
                                World2ScreenSynced (optional)   https://www.hiveworkshop.com/threads/.354017/
                                FileIO (optional)				https://www.hiveworkshop.com/threads/.360424/
                                FunctionPreviews (optional)     Included in Test Map.

                                ALICE (optional)                https://www.hiveworkshop.com/threads/.353126/

    =============================================================================================================================================================
                                                                            A P I
    =============================================================================================================================================================

    WSCode.Parse(functionBody)                      Parses the provided code, searching for function definitions to generate function previews, then executes the
                                                    code in chunks delimited by either Debug.be\ginFile or @beginFile tokens, which must be followed by the script
                                                    name. Parsed scripts can be added to the editor with the Pull Script button. A script will automatically be
                                                    transpiled into debug form and added to the editor if a @debug token is found anywhere in the script. Designed
                                                    to read in the entire map script by creating a wrapper starting with WSCode.Parse([===[ and ending with ]===]).
    WSCode.AddBreakPoint(whichTab, lineNumber)      Adds a breakpoint to a line in the specified tab. The tab can be referenced either by its tab index or its name.
    WSCode.BreakHere()                              Halts exeuction of the code when it reaches this line and switches to the tab it is executed in. Script must be
                                                    compiled in debug mode. A breakpoint added this way cannot be disabled.
    WSCode.Show(enable)                             Shows or hides the code editor.
    WSCode.IsEnabled()                              Returns whether the code editor has been created.
    WSCode.IsVisible()                              Returns whether the code editor is visible.
    WSCode.IsExpanded()                             Returns whether the code editor is expanded.



    WSCode initializers execute a function at a specified point in the map loading process, allowing you to initialize your scripts in a safe and ordered way.
    The initialization points take inspiration from TotalInitialization, mapping the same suffixes to the same initialization points.

    Functions are added to the initializer list in the same order as they are encountered by the Parser. Therefore, the @require command governs both the order of
    the script execution in the Lua root as well as the order of the initializer functions. In the rare cases where you need additional control over the order of
    execution, you can add the optional onWhichPass parameter. If a pass is set to N > 1, the initializer list is looped through multiple times and the function
    for which the pass was set is only executed on the Nth iteration.

    WSCode.InitMain(whichFunc, onWhichPass?)        Called before main. The earliest point to initialize outside the Lua root.
    WSCode.InitGlobal(whichFunc, onWhichPass?)      Called after InitGlobals. The standard point to initialize.
    WSCode.InitTrig(whichFunc, onWhichPass?)        Called after InitCustomTriggers. Useful for removing hooks that should only apply to GUI events.
    WSCode.InitMap(whichFunc, onWhichPass?)         Called at the last point in initialization before the loading screen is completed.
    WSCode.InitFinal(whichFunc, onWhichPass?)       Called immediately after the loading screen has disappeared, and the game has started.
    WSCode.InitEssential(whichFunc, onWhichPass?)   Called immediately before InitFinal. Will execute even if initialization was halted.

    =============================================================================================================================================================
                                                                        C O N F I G
    =============================================================================================================================================================
    ]]

    WSCodeConfig = {
        compiler = {
            --Disables the editor and all code alterations. Overwrites all settings below.
            RELEASE_VERSION                         = false

            --If enabled, WSCode will wrap coroutines around everything, allowing it to yield from the parent function on a breakpoint insteayd of just the function that
            --was added to the debugger. This means that if an external function calls a function that is being debugged, the parent function will not continue executing
            --when the function being debugged is halted. In addition, the complete traceback will be available on an error. This feature slows down code execution, even
            --with all WSCode wrappers removed, so set it to false for your release version. WARNING: Will break GUI waits.
            ,WRAP_ALL_LUA_ENTRY_POINTS              = true

            --If a function is wrapped in a caller function, it remains persistent throughout function redefinitions. When recompiling functions, WSCode will only swap
            --out the functions the wrappers call, which means that existing references to the old functions will correctly update to the new ones when you recompile a
            --chunk of code. The wrapped function is referenced by its name. Therefore, anonymous functions cannot be wrapped, and you must not rename functions or have
            --two functions with the same name in any one script. A script must have been originally compiled in debug mode for wrappers to work.
            ,WRAP_IN_CALLER_FUNCTIONS               = true

            --Throw an error when a function returns a framehandle with handle id 0. Requires script to be compiled in debug mode.
            ,VALIDATE_FRAMES                        = true

            --Allows you to save the map script with changes made in-game to a file, then restart the map and load the modified map script. This option necessitates that
            --the map script is suspended until main is called, even when the map is launched regularly, which may have side effects. Only works if map script is wrapped
            --by WSCode.Parse function. Recommended to use WSCode initializers when using this feature.
            ,ENABLE_QUICK_RESTART                   = false

            --Automatically pauses a script that was compiled in debug mode if more than this many lines have been executed during one game tick. Set to nil to disable.
            ,EXECUTION_LIMIT                        = 5e6

            --Always halt the ALICE cycle when stopping at a breakpoint. If disabled, it will only stop if halted within an ALICE function.
            ,ALWAYS_HALT_ALICE_ON_BREAKPOINT        = true

            --Writes the map script to the file WSCodeMapScript.txt if the game is in singleplayer and the player is listed as one of the map's creators, otherwise reads
            --the map script from that file. Enables you to update your map by sharing the preload file instead of the entire map if only changes to the map script have
            --been made. This option necessitates that the map script is suspended until main is called, even when the map is launched regularly, which may have side
            --effects. Only works if map script is wrapped by WSCode.Parse function.
            ,ENABLE_MAP_SCRIPT_SHARING              = false
        },

        diagnostics = {
            --Throw a warning when a WSCode.Init function is called outside of the Parse wrapper. This may happen by accident when scripts or folders are moved around.
            INIT_OUTSIDE_OF_WRAP_WARNING            = true

            --If enabled, writes the name of the last file being parsed by WSCode.Parse into the file WSCodeInitDump.txt, so that you gain information about which script
            --causes a crash on map initialization. Will not catch crashes occuring in TotalInitialization init functions. Only works if map script is wrapped by
            --WSCode.Parse function.
            ,INIT_DUMP                              = false

            ,PROFILE_INIT                           = false

            --Writes the transpiled scripts of files in debug mode into the file WSCodeTranspiled<FileName>.txt, so that you can check what the transpiler is actually
            --doing.
            ,DUMP_TRANSPILED_SCRIPTS                = false
        },

        editor = {
            --Enables the "-wscode" command for the players with these names. Uses substring, therefore #XXXX not required and an empty string enables it for all players.
            MAP_CREATORS = {                                    ---@constant string[]
                ""
            }

            ,NEXT_LINE_HOTKEY                       = "F9"      ---@constant string | nil
            ,CONTINUE_HOTKEY                        = "F5"      ---@constant string | nil
            ,TOGGLE_HIDE_EDITOR_HOTKEY              = "F12"      ---@constant string | nil
            --0 = None, 1 = Shift, 2 = Ctrl, 3 = Shift + Ctrl
            ,NEXT_LINE_METAKEY                      = 0         ---@constant integer
            ,CONTINUE_METAKEY                       = 0         ---@constant integer
            ,TOGGLE_HIDE_EDITOR_METAKEY             = 2         ---@constant integer

            --Replaces the standard Friz Quadrata font with Consolas. This will ensure that all currentTab spaces remain aligned. Requires Consolas.ttf.
            ,USE_MONOSPACE_FONT                     = true

            --Enable automatic export of script files into text files to be saved or imported again on a later session.
            ,ENABLE_SAVE_AND_LOAD                   = true

            --The folder to which all text files are exported. The complete path is Warcraft III\CustomMapData\Subfolder\
            ,EXPORT_SUBFOLDER                       = "WSCode"

            --Automatically initialize the editor on map start so that it can be pulled up with the TOGGLE_HIDE_EDITOR_HOTKEY without having to type -wscode.
            ,AUTO_INITIALIZE                        = true

            --Automatically loads into the editor scripts that have been parsed by WSCode.Parse, but are not currently being debugged, when they produce an error.
            ,LOAD_EXTERNAL_SCRIPTS_ON_ERROR         = true

            --Since hotkeys do not work because all inputs are intercepted by the editbox frame, you can set characters here that, when entered, will emulate the
            --function of those hotkeys.
            ,LEFT_ARROW_REPLACEMENT_CHAR            = "ö"
            ,RIGHT_ARROW_REPLACEMENT_CHAR           = "ä"
            ,TAB_REPLACEMENT_CHAR                   = "°"
            ,DELETE_REPLACEMENT_CHAR                = "ü"

            --Automatically close (, {, [, ", and ' when typed.
            ,AUTO_CLOSE_BRACKETS_AND_QUOTES         = true

            --This function is called when the editor is shown or enabled.
            ,ON_ENABLE                              = function()
                --Uncomment this to hide the default UI when the editor is opened, giving you more space to work with.
                --[[BlzHideOriginFrames(true)
                for i = 0, 11 do
                    BlzFrameSetVisible(BlzGetFrameByName("CommandButton_" .. i, 0), false)
                end]]
            end

            --This function is called when the editor is hidden.
            ,ON_DISABLE                             = function()
                --[[BlzHideOriginFrames(false)
                for i = 0, 11 do
                    BlzFrameSetVisible(BlzGetFrameByName("CommandButton_" .. i, 0), true)
                end]]
            end

            --This function is called when the editor is expanded.
            ,ON_EXPAND                              = function()
                ClearTextMessages()
            end

            --This function is called when the editor is collapsed.
            ,ON_COLLAPSE                            = function()
            end

            --This function is called when the script execution halts at a breakpoint.
            ,ON_BREAK                               = function(scriptName)
            end

            --This function is called when the script execution resumes from a breakpoint.
            ,ON_RESUME                              = function(scriptName)
            end

            --This function is called when a script encounters an error.
            ,ON_ERROR                               = function(scriptName)
            end

            --Setting a list of legal characters protects you from messing up your code by accidently pressing the key of a character that cannot be displayed,
            --leading to compile errors from seemingly valid code. This list contains all utf8 1-byte characters except the grave accents. Set to nil to disable.
            ,LEGAL_CHARACTERS                       = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$&()[]=?:;,._#*~/{}<>^+-|'\"\\@\x25 1234567890\t"

            --If the user presses no key for this long, a new undo step is created.
            ,MIN_TIME_BETWEEN_UNDO_STEPS            = 1.0

            ,GET_PARENT                             = function()
                --This makes the editor appear above the Console UI
                --[[CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, "title")
                local parent = BlzGetFrameByName("Leaderboard", 0)
                BlzFrameSetSize(parent, 0, 0)
                BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
                BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)
                return parent]]
                return BlzGetFrameByName("ConsoleUIBackdrop", 0)
                --This makes the editor appear below the Console UI
            end

            --These parameter control the layout of the code editor.
            ,COLLAPSED_X                            = 0.567
            ,Y_TOP                                  = 0.555
            ,EXPANDED_X                             = 0.187
            ,LINE_SPACING                           = 0.0085
            ,MAX_LINES_ON_SCREEN                    = 39
            ,COLLAPSED_WIDTH                        = 0.353
            ,EXPANDED_WIDTH                         = 0.733
            ,CODE_LEFT_INSET                        = 0.045
            ,CODE_RIGHT_INSET                       = 0.025
            ,CODE_TOP_INSET                         = 0.025
            ,CODE_BOTTOM_INSET                      = 0.013
            ,LINE_NUMBER_HORIZONTAL_INSET           = 0.006
            ,STOP_BUTTON_HORIZONTAL_INSET           = 0.023
            ,LINE_HIGHLIGHT_HORIZONTAL_INSET        = 0.034
            ,CODE_SCROLLER_HORIZONTAL_INSET         = 0.013
            ,BOTTOM_BUTTON_SIZE                     = 0.024
            ,BOTTOM_BUTTON_VERTICAL_SHIFT           = -0.022
            ,CHECKBOX_HORIZONTAL_INSET              = 0.032
            ,CHECKBOX_VERTICAL_SHIFT                = -0.007
            ,CHECKBOX_TEXT_VERTICAL_SHIFT           = -0.0015
            ,CHECKBOX_TEXT_SPACING                  = 0.002
            ,TEXT_CHECKBOX_SPACING                  = 0.008
            ,DELETE_BUTTON_HORIZONTAL_INSET         = 0.007
            ,DELETE_BUTTON_HIGHLIGHT_INSET          = 0.002
            ,CLOSE_BUTTON_INSET                     = 0.005
            ,CLOSE_BUTTON_SIZE                      = 0.017
            ,TITLE_VERTICAL_SHIFT                   = -0.0085
            ,LINE_NUMBER_SCALE                      = 0.9

            --0-255
            ,BLACK_BACKDROP_ALPHA                   = 150
            --The colors of syntax highlighting.
            ,KEYWORD_COLOR                          = "|cffff9d98"
            ,FUNCTION_NAME_COLOR                    = "|cff9aaaee"
            ,NATIVE_COLOR                           = "|cfff0a77e"
            ,COMMENT_COLOR                          = "|cff8a8a92"
            ,STRING_COLOR                           = "|cff77b9c3"
            ,VALUE_COLOR                            = "|cff8bbaf7"
            --The colors of currentTab navigators.
            ,TAB_NAVIGATOR_SELECTED_COLOR           = "|cffffffff"
            ,TAB_NAVIGATOR_UNSELECTED_COLOR         = "|cffaaaaaa"
            ,TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR  = "|cffaaaaff"
            ,TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR= "|cff7171aa"
            ,TAB_NAVIGATOR_UNSAVED_COLOR            = "|cffff0000"
            --The colors of line numbers.
            ,LINE_NUMBER_COLOR                      = "|cffaaaaaa"
            ,IDLE_LINE_NUMBER_COLOR                 = "|cff777777"
        },

        --Links the name of a destructor function with the name of a creator function that is used to clean up objects created
        --by previous compilations of the code chunk when "Clean Handles" is enabled.
        CREATOR_DESTRUCTOR_PAIRS = {                  ---@constant table<string, string>
            CreateTimer = "DestroyTimer",
            CreateGroup = "DestroyGroup",
            CreateForce = "DestroyForce",
            CreateRegion = "RemoveRegion",
            CreateTrigger = "DestroyTrigger",
            CreateDestructable = "RemoveDestructable",
            CreateDestructableZ = "RemoveDestructable",
            CreateDeadDestructable = "RemoveDestructable",
            CreateDeadDestructableZ = "RemoveDestructable",
            CreateItem = "RemoveItem",
            CreateUnit = "RemoveUnit",
            CreateUnitByName = "RemoveUnit",
            CreateUnitAtLoc = "RemoveUnit",
            CreateUnitAtLocByName = "RemoveUnit",
            CreateCorpse = "RemoveUnit",
            CreateFogModifierRect = "DestroyFogModifier",
            CreateFogModifierRadius = "DestroyFogModifier",
            CreateFogModifierRadiusLoc = "DestroyFogModifier",
            DialogCreate = "DialogDestroy",
            CreateUnitPool = "DestroyUnitPool",
            CreateItemPool = "DestroyItemPool",
            CreateMinimapIconOnUnit = "DestroyMinimapIcon",
            CreateMinimapIconAtLoc = "DestroyMinimapIcon",
            CreateMinimapIcon = "DestroyMinimapIcon",
            CreateTextTag = "DestroyTextTag",
            CreateQuest = "DestroyQuest",
            CreateDefeatCondition = "DestroyDefeatCondition",
            CreateTimerDialog = "DestroyTimerDialog",
            CreateLeaderboard = "DestroyLeaderboard",
            CreateMultiboard = "DestroyMultiboard",
            CreateImage = "DestroyImage",
            CreateUbersplat = "DestroyUbersplat",
            BlzCreateFrame = "BlzDestroyFrame",
            BlzCreateSimpleFrame = "BlzDestroyFrame",
            BlzCreateFrameByType = "BlzDestroyFrame",
            CreateCommandButtonEffect = "DestroyCommandButtonEffect",
            CreateUpgradeCommandButtonEffect = "DestroyCommandButtonEffect",
            CreateLearnCommandButtonEffect = "DestroyCommandButtonEffect",
            BlzCreateItemWithSkin = "RemoveItem",
            BlzCreateUnitWithSkin = "RemoveUnit",
            BlzCreateDestructableWithSkin = "RemoveDestructable",
            BlzCreateDestructableZWithSkin = "RemoveDestructable",
            BlzCreateDeadDestructableWithSkin = "RemoveDestructable",
            BlzCreateDeadDestructableZWithSkin = "RemoveDestructable",
            AddSpecialEffect = "DestroyEffect",
            AddSpecialEffectTarget = "DestroyEffect",
            AddSpecialEffect3D = "DestroyEffect",
            EnableWeatherEffect = "RemoveWeatherEffect",
            ALICE_Create = "ALICE_Destroy",
            ALICE_CallPeriodic = "ALICE_DisableCallback",
            ALICE_CallRepeated = "ALICE_DisableCallback",
            ALICE_CallDelayed = "ALICE_DisableCallback",
            ALICE_PairCallDelayed = "ALICE_DisableCallback"
        },

        --Use this function to define automatic replacements within the Code Editor. The function takes the current line being edited and returns
        --the line with the replacements added.
        handleTextMacros = function(line)
            if line:find("!COORDS") then
                if line:find("!COORDS!") then
                    return line:gsub("!COORDS!", math.floor(WSDebug.Mouse.x) .. ", " .. math.floor(WSDebug.Mouse.y))
                elseif line:find("!COORDS3D!") then
                    return line:gsub("!COORDS3D!", math.floor(WSDebug.Mouse.x) .. ", " .. math.floor(WSDebug.Mouse.y) .. ", " .. math.floor(GetLocZ(WSDebug.Mouse.x, WSDebug.Mouse.y)))
                end
            elseif line:find("!SCREEN!") then
                local x, y = World2Screen(WSDebug.Mouse.x, WSDebug.Mouse.y, GetTerrainZ(WSDebug.Mouse.x, WSDebug.Mouse.y))
                if x < -0.1333 or x > 0.93333 or y < 0 or y > 0.6 then
                    x, y = WSDebug.MouseTargetFrameX or 0, WSDebug.MouseTargetFrameY or 0
                end
                return line:gsub("!SCREEN!", string.format("\x25.4f", x) .. ", " .. string.format("\x25.4f", y))
            elseif line:find("!UNIT!") then
                ---@diagnostic disable-next-line: lowercase-global
                wsunit = ALICE_GetClosestObject(WSDebug.Mouse.x, WSDebug.Mouse.y, "unit")
                return line:gsub("!UNIT!", "wsunit")
            elseif line:find("!OBJ!") then
                ---@diagnostic disable-next-line: lowercase-global
                wsobject = ALICE_GetClosestObject(WSDebug.Mouse.x, WSDebug.Mouse.y, {MATCHING_TYPE_ALL}, nil, function(whichObject) return not ALICE_HasIdentifier(whichObject, "mouse") and not ALICE_HasIdentifier(whichObject, "camera") end)
                return line:gsub("!OBJ!", "wsobject")
            elseif line:find("!CAM!") then
                return line:gsub("!CAM!",
                "{x = " .. math.floor(GetCameraTargetPositionX()) ..
                ", y = " .. math.floor(GetCameraTargetPositionY()) ..
                ", angleOfAttack = " .. string.format("\x25.3f", bj_RADTODEG*GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)) ..
                ", rotation = " .. string.format("\x25.3f", bj_RADTODEG*GetCameraField(CAMERA_FIELD_ROTATION)) ..
                ", targetDistance = " .. math.floor(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)) ..
                ", z = " .. math.floor(GetCameraTargetPositionZ()) .. "}")
            end
        end,

        tabNavigator = {
            VERTICAL_SHIFT                     = -0.007
            ,WIDTH                              = 0.062
            ,HEIGHT                             = 0.028
            ,OVERLAP                            = 0.007
            ,TEXT_INSET                         = 0.008
            ,CLOSE_BUTTON_INSET                 = 0.003
            ,CLOSE_BUTTON_SIZE                  = 0.01
        },

        variableViewer = {
            WIDTH                              = 0.24
            ,LINE_HORIZONTAL_INSET              = 0.01
            ,LINE_VERTICAL_INSET                = 0.025
            ,BOTTOM_SPACE                       = 0.012
            ,VARIABLE_MAX_STRING_LENGTH         = 25
            ,FUNCTION_CALL_SPACING              = 0.007
            ,FUNCTION_PARAM_MAX_STRING_LENGTH   = 42
            ,TEXT_SCALE                         = 0.9
            ,GLOBAL_COLOR                       = "|cffaaaaff"
            ,LOCAL_COLOR                        = "|cffffffff"
        },

        searchBar = {
            HORIZONTAL_INSET                    = 0.023
            ,VERTICAL_INSET                      = 0.023
            ,WIDTH                               = 0.15
            ,HEIGHT                              = 0.04
            ,SEARCH_FIELD_LEFT_INSET             = 0.0
            ,SEARCH_FIELD_RIGHT_INSET            = 0.0
            ,SEARCH_FIELD_TOP_INSET              = 0.013
            ,SEARCH_FIELD_BOTTOM_INSET           = 0.0
            ,SEARCH_BUTTON_INSET                 = 0.005
            ,BUTTON_SIZE                         = 0.015
            ,NUM_FINDS_LEFT_INSET                = 0.009
            ,NUM_FINDS_TOP_INSET                 = 0.01
        },

        nameDialog = {
            WIDTH                              = 0.16
            ,HEIGHT                             = 0.06
            ,TITLE_VERTICAL_SHIFT               = 0.012
            ,ENTER_BOX_HORIZONTAL_INSET         = 0.01
            ,ENTER_BOX_VERTICAL_SHIFT           = 0.025
            ,ENTER_BOX_HEIGHT                   = 0.027
        },

        flagsMenu = {
            WIDTH                              = 0.094
            ,TEXT_INSET                         = 0.007
        },

        getMouseScreenCoordinates = function(worldX, worldY)
            if GetTerrainZ then
                return World2Screen(worldX, worldY, GetTerrainZ(worldX, worldY))
            else
                return World2Screen(worldX, worldY, GetLocZ(worldX, worldY))
            end
        end
    }

   --[[
    =============================================================================================================================================================
                                                                  E N D   O F   C O N F I G
    =============================================================================================================================================================
    ]]

    local compiler = WSCodeConfig.compiler
    local diagnostics = WSCodeConfig.diagnostics
    local editor = WSCodeConfig.editor
    local CREATOR_DESTRUCTOR_PAIRS = WSCodeConfig.CREATOR_DESTRUCTOR_PAIRS
    local HandleTextMacros = WSCodeConfig.handleTextMacros
    local tabNavigator = WSCodeConfig.tabNavigator
    local variableViewer = WSCodeConfig.variableViewer
    local searchBar = WSCodeConfig.searchBar
    local nameDialog = WSCodeConfig.nameDialog
    local flagsMenu = WSCodeConfig.flagsMenu
    local GetMouseScreenCoordinates = WSCodeConfig.getMouseScreenCoordinates

    if compiler.RELEASE_VERSION then
        compiler.WRAP_ALL_LUA_ENTRY_POINTS = false
        editor.LOAD_EXTERNAL_SCRIPTS_ON_ERROR = false
        diagnostics.INIT_DUMP = false
        diagnostics.INIT_OUTSIDE_OF_WRAP_WARNING = false
        compiler.ENABLE_MAP_SCRIPT_SHARING = false
        compiler.ENABLE_QUICK_RESTART = false
        editor.AUTO_INITIALIZE = false
    end

    local tab2D                         = {__index = function(self, key) self[key] = {} return self[key] end}

    local codeEditorParent
    local enterBox
    local cursorFrame
    local codeLineFrames                = {}
    local lineNumbers                   = {}
    local stopButtons                   = {}
    local indexFromFrame                = {}
    local duplicateHighlightFrames      = {}
    local flagsMenuParent
    local clearMenuParent
    local codeScroller
    local contextMenu                   = {}

    local meta3D                        = {
        __index = function(parent, parentKey)
            parent[parentKey] = setmetatable({}, {
                __index = function(self, key)
                    self[key] = setmetatable({}, {
                        __index = function(child, childKey)
                            child[childKey] = ""
                            return child[childKey]
                        end
                    })
                    return self[key]
                end
            })
            return parent[parentKey]
        end
    }
    local codeLines                     = setmetatable({}, meta3D)
    local coloredCodeLines              = setmetatable({}, meta3D)

    local cursor = {
        pos = nil,
        rawLine = nil,
        adjustedLine = nil,
        x = 0
    }

    variableViewer.frames               = {}
    variableViewer.valueFrames          = {}
    variableViewer.textFrames           = {}
    variableViewer.functionFrames       = {}
    variableViewer.functionParamFrames  = {}
    variableViewer.functionTextFrames   = {}
    variableViewer.nameFromFrame        = {}
    variableViewer.linkedObject         = {}
    variableViewer.viewedGlobals        = {}
    variableViewer.viewedValueTrace     = {}
    variableViewer.viewedVariableTrace  = {}
    variableViewer.lineNumberOffset     = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    variableViewer.isViewingGlobal      = false
    variableViewer.isViewingParams      = false
    variableViewer.isExpanded           = true
    variableViewer.hasNotBeenExpanded   = true

    local isShowingVariableTooltip      = false
    local checkedForVariableDisplay     = false

    local helper                        = {}
    local widthTestFrame

    local buttons                       = {}

    local lastLineNumber                = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local lastViewedLineNumber          = {}
    local errorLineNumber               = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local currentStop                   = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local cursorCounter                 = 0
    local numFunctions                  = 0
    local doNotUpdateVariables          = {}
    local editBoxFocused                = false
    local globalLookupTable             = {}
    local localLookupTable              = {}
    local autoCompleteSuggestions       = {}
    local lastFunctionCall              = {}
    local lastViewedFunctionCall        = {}
    local functionParams                = setmetatable({}, tab2D)
    local viewedFunctionParams          = setmetatable({}, tab2D)
    local concatTable                   = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
    local anchor
    local enterBoxText                  = " "
    local clipboard
    local canJumpToError                = true
    local user
    local lastHaltedCoroutine
    local initialized
    local coroutineWaitingForInit
    local executionCount                = 0
    local lineNumberWasExecuted         = setmetatable({}, tab2D)
    local clearMenu                     = {}
    local doNotCheckStop                = setmetatable({}, {
        __index = function(grandParent, grandParentKey)
            grandParent[grandParentKey] = setmetatable({}, {
                __index = function(parent, parentKey)
                    parent[parentKey] = {}
                    return parent[parentKey]
                end
            })
            return grandParent[grandParentKey]
        end
    })

    local lineByLine                    = false
    local numVisibleVars                = 0
    local highestNonEmptyLine           = setmetatable({}, {
        __index = function(self, key)
            self[key] = setmetatable({}, {
                __index = function()
                    return 0
                end
            })
            return self[key]
        end
    })

    local hookedFuncs = {
        original                        = {},
        hooked                          = {}
    }

    local lines = {
        endsInLongString                = setmetatable({}, tab2D),
        endsInLongComment               = setmetatable({}, tab2D),
        numEqualSigns                   = {},
        debugState                      = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__index = function(child, childKey) child[childKey] = 0 return 0 end}) return self[key] end})
    }

    local flags                         = {
        "debugMode",
        "runInit",
        "cleanHandles",
        "hideGlobals",
        "hideConstants",
        "hideFunctions",
        "smartPersist",
        "quickRestart"
    }
    local handles                       = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__mode = "k"}) return self[key] end})

    local files                         = {}
    local fileNames                     = {}
    local existingFiles                 = {}
    local orderedFileNames              = {}

    local currentTab                    = "Main"
    local step                          = setmetatable({}, {__index = function(self, key) self[key] = 1 return 1 end})
    local maxRedo                       = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local lineNumberOffset              = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local lineNumberOfEdit              = setmetatable({}, tab2D)
    local posOfEdit                     = setmetatable({}, tab2D)
    local lastKeyStroke                 = 0
    local lastFrame                     = 0
    local timeElapsed                   = 0
    local firstDifferentChar            = 0

    local wrapperFunc                   = setmetatable({}, tab2D)
    local wrappedFunc                   = setmetatable({}, tab2D)
    local wrapperGenerationCounter      = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__index = function(child, childKey) child[childKey] = 0 return 0 end}) return self[key] end})

    local dragWindow                    = {
        WIDTH = 0.105,
        TOP_INSET = 0.01
    }

    local tabs = {
        amount                          = 1,
        names                           = {"Main"},
        numbers                         = {Main = 1},
        numberFromFrame                 = {},
        hasError                        = {},
        hasUncompiledChanges            = {},
        hasUnsavedChanges               = {},
        wasNotCompiledInDebugMode       = {},
        disableSyntaxCheck              = {},
        truncatedNames                  = {},
        wasPulledFromDebugToken         = {}
    }
    local executionTab                  = "Main"

    tabNavigator.frames                 = {}
    tabNavigator.titles                 = {}
    tabNavigator.highlights             = {}
    tabNavigator.closeButtons           = {}
    tabNavigator.widths                 = {tabNavigator.WIDTH}

    local varTable                      = setmetatable({}, tab2D)
    local visibleVarsOfLine             = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, tab2D) return self[key] end})
    local varLevelExecution             = setmetatable({}, tab2D)

    local init = {
        main = {},
        global = {},
        trig = {},
        map = {},
        essential = {},
        final = {},
        names = {},
        passes = {},
        highestPass = {
            main = 1,
            global = 1,
            trig = 1,
            map = 1,
            final = 1
        },
        completed = {},
        originalCreators = {},
        profiler = {totalTime = 0}
    }

    local highlights = {
        text                            = {},
        typeFromFrame                   = {},
    }

    local selection                     = {
        lines = {}
    }

    searchBar.text                      = ""
    searchBar.numFinds                  = 0
    searchBar.highlights                = {}
    searchBar.lines                     = {}
    searchBar.startPos                  = {}
    searchBar.endPos                    = {}
    searchBar.current                   = 0

    local hasCodeOnInit                 = false

    local sub                           = string.sub
    local find                          = string.find
    local match                         = string.match
    local clock                         = os.clock
    local running                       = coroutine.running

    local benchmark = {
        results                         = {}
    }

    local brackets = {
        highlights = {},
        lines = {},
        pos = {},
        IS_BRACKET = {
            ["("] = true,
            [")"] = true,
            ["["] = true,
            ["]"] = true,
            ["{"] = true,
            ["}"] = true
        },
        CORRESPONDING_BRACKET = {
            ["("] = ")",
            [")"] = "(",
            ["["] = "]",
            ["]"] = "[",
            ["{"] = "}",
            ["}"] = "{"
        }
    }

    local function DoNothing() end

    local EnableEditor
    local UpdateVariableViewer
    local ToggleExpand
    local ToggleVariableViewerExpand
    local SetSelection
    local HideSelection
    local StoreCode
    local RenderSearchHighlights
    local FindSearchItems
    local Pull
    local JumpToError
    local SwitchToTab
    local Value2String
    local CloseTab
    local SaveSettings
    local SaveTabs
    local AddTab
    local wsdebug

    local LINE_STATE_ICONS = {
        [0] = "transparentmask.blp",
        [1] = "spyGlass.blp",
        [2] = "stopButton.blp",
    }

    local LUA_CONTROL_FLOW_STATEMENTS = {
        ["if"] = true,
        ["then"] = true,
        ["else"] = true,
        ["elseif"] = true,
        ["end"] = true,
        ["for"] = true,
        ["while"] = true,
        ["repeat"] = true,
        ["until"] = true,
        ["return"] = true,
        ["do"] = true,
        ["break"] = true
    }

    local LUA_KEYWORDS = {
        ["if"] = true,
        ["then"] = true,
        ["else"] = true,
        ["elseif"] = true,
        ["end"] = true,
        ["for"] = true,
        ["while"] = true,
        ["repeat"] = true,
        ["until"] = true,
        ["return"] = true,
        ["do"] = true,
        ["break"] = true,
        ["or"] = true,
        ["and"] = true,
        ["not"] = true,
        ["function"] = true,
        ["in"] = true,
        ["local"] = true
    }

    local LUA_OPERATORS = {
        ["+"] = true,
        ["-"] = true,
        ["*"] = true,
        ["/"] = true,
        ["//"] = true,
        ["\x25"] = true,
        ["{"] = true,
        ["}"] = true,
        ["["] = true,
        ["]"] = true,
        ["("] = true,
        [")"] = true,
        [","] = true,
        ["^"] = true,
        ["~="] = true,
        ["<"] = true,
        [">"] = true,
        ["<="] = true,
        [">="] = true,
        ["="] = true,
        ["=="] = true,
        [".."] = true,
        ["and"] = true,
        ["or"] = true,
        ["not"] = true,
        ["&"] = true,
        ["|"] = true,
        ["~"] = true,
        ["<<"] = true,
        [">>"] = true
    }

    local LUA_BINARY_OPERATORS = {
        ["+"] = true,
        ["-"] = true,
        ["*"] = true,
        ["/"] = true,
        ["//"] = true,
        ["\x25"] = true,
        [","] = true,
        ["^"] = true,
        ["<"] = true,
        [">"] = true,
        ["~="] = true,
        ["=="] = true,
        ["<="] = true,
        [">="] = true,
        ["="] = true,
        [".."] = true,
        ["and"] = true,
        ["or"] = true,
        ["not"] = true,
        ["["] = true,
        ["&"] = true,
        ["|"] = true,
        ["~"] = true,
        ["<<"] = true,
        [">>"] = true
    }

    local LUA_ONE_CHAR_OPERATORS = {
        ["+"] = true,
        ["-"] = true,
        ["*"] = true,
        ["/"] = true,
        ["\x25"] = true,
        ["{"] = true,
        ["}"] = true,
        ["["] = true,
        ["]"] = true,
        ["("] = true,
        [")"] = true,
        [","] = true,
        ["^"] = true,
        ["<"] = true,
        [">"] = true,
        ["="] = true,
        ["&"] = true,
        ["|"] = true,
        ["~"] = true,
    }

    local LUA_TWO_CHAR_OPERATORS = {
        ["~="] = true,
        ["<="] = true,
        [">="] = true,
        ["=="] = true,
        [".."] = true,
        ["::"] = true,
        ["//"] = true,
        ["<<"] = true,
        [">>"] = true
    }

    local END_OF_STATEMENT_IGNORED_CHARS = {
        ["."] = true,
        [":"] = true,
        ["'"] = true,
        ['"'] = true
    }

    local INIT_POINTS = {
        root = 1,
        config = 2,
        main = 3,
        global = 4,
        trig = 5,
        map = 6,
        final = 7
    }

    local FRAME_RETURNER_FUNCTIONS = {
        BlzCreateFrame = true,
        BlzCreateSimpleFrame = true,
        BlzCreateFrameByType = true,
        BlzGetFrameByName = true,
        BlzFrameGetParent = true,
        BlzFrameGetChild = true,
        BlzGetTriggerFrame = true
    }

    if Debug then
        ---@diagnostic disable-next-line: duplicate-set-field
        Debug.traceback = function(startDepth, endDepth)
            startDepth = (startDepth or 0) + 2 --The 0-level shall be the level where Debug.traceback is called by the user, so we must add 2 to get out of the pcall/error level below.
            endDepth = (endDepth or 200) + 2 --Same +2 logic. 200 is a level recommended to fetch the whole stack trace, including the final piece of stack overflow errors.
            local trace, separator = "", ""
            local _, currentFile, lastFile, tracePiece, lastTracePiece
            for loopDepth = startDepth, endDepth do --get trace on different depth level
                _, tracePiece = pcall(error, "", loopDepth) ---@type boolean, string
                tracePiece = Debug.getLocalErrorMsg(tracePiece)
                if tracePiece:sub(1, 15) == ('[string "WSCode') then
                    tracePiece = tracePiece:gsub('\x25[string "(.-)"\x25]', "\x251"):gsub("WSCode ", "")
                end
                if #tracePiece > 0 and lastTracePiece ~= tracePiece then --some trace pieces can be empty, but there can still be valid ones beyond that
                    currentFile = tracePiece:match("^.-:")
                    --Hide DebugUtils in the stack trace (except main reference), if settings.INCLUDE_DEBUGUTILS_INTO_TRACE is set to true.
                    if Debug.settings.INCLUDE_DEBUGUTILS_INTO_TRACE or (loopDepth == startDepth) or currentFile ~= "DebugUtils:" then
                        trace = trace .. separator .. ((currentFile == lastFile) and tracePiece:match(":\x25d+"):sub(2,-1) or tracePiece:match("^.-:\x25d+"))
                        lastFile, lastTracePiece, separator = currentFile, tracePiece, " <- "
                    end
                end
            end
            return trace
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        Debug.errorHandler = function(errorMsg, startDepth, returnErrorMsg_yn)
            local fileName = errorMsg:match('"(.-)"\x25]')
            if errorMsg:sub(1, 15) == '[string "WSCode' then
                fileName = fileName:gsub("WSCode ", "")
            end
            local lineNumber = tonumber(errorMsg:match("\x25]:(\x25d+):"))

            startDepth = (startDepth or 0)
            errorMsg = Debug.getLocalErrorMsg(errorMsg)
            --Original error message and stack trace.
            local toPrint = "|cff" .. Debug.settings.colors.error .. "ERROR at " .. errorMsg .. "|r"
            if Debug.settings.SHOW_TRACE_ON_ERROR then
                toPrint = toPrint .. "\n|cff" .. Debug.settings.colors.error .. "Traceback (most recent call first):|r\n|cff" .. Debug.settings.colors.error .. Debug.traceback(startDepth,202) .. "|r"
            end
            --Also print entries from param log, if there are any.
            for location, loggedParams in pairs(Debug.data.paramLog) do
                toPrint = toPrint .. "\n|cff" .. Debug.settings.colors.log .. "Logged at " .. Debug.getLocalErrorMsg(location) .. loggedParams .. "|r"
                Debug.data.paramLog[location] = nil
            end
            toPrint = toPrint:gsub('\x25[string "(.-)"\x25]', "\x251"):gsub("WSCode ", "")
            Debug.data.firstError = Debug.data.firstError or toPrint
            if Debug.data.printErrors_yn then --don't print error, if execution of Debug.firstError() has disabled it.
                print(toPrint)
            end

            errorMsg = toPrint
            if fileName and lineNumber then
                if initialized then
                    JumpToError(fileName, lineNumber)
                    WSDebug.NoStop = true
                    editor.ON_ERROR(fileName)
                    WSDebug.NoStop = false
                else
                    init.error = init.error or {
                        fileName = fileName,
                        lineNumber = lineNumber,
                    }
                end
            end

            return returnErrorMsg_yn and errorMsg
        end
    end

    if compiler.WRAP_ALL_LUA_ENTRY_POINTS then
        local tryWrappers = setmetatable({}, {__mode = 'k'})
        local function getTryWrapper(func)
            if func then
                tryWrappers[func] = tryWrappers[func] or function(...) return select(2, xpcall(func, Debug.errorHandler,...)) end
            end
            return tryWrappers[func]
        end

        local originalCoroutineCreate = Debug and Debug.original.coroutine.create or coroutine.create
        local originalCoroutineWrap = Debug and Debug.original.coroutine.wrap or coroutine.wrap

        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.create = function(whichFunc)
            return originalCoroutineCreate(getTryWrapper(whichFunc))
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.wrap = function(whichFunc)
            return originalCoroutineWrap(getTryWrapper(whichFunc))
        end

        --Thread recycler
        local deadCorots = setmetatable({}, {__index = function(self, key) self[key] = {} return self[key] end})
        local pack = table.pack
        local unpack = table.unpack

        local function getCoroutine(whichFunc)
            local corot
            if #deadCorots[whichFunc] == 0 then
                local wrapper = function(...)
                    local args = pack(...)
                    ::beginning::
                    whichFunc(unpack(args, 1, args.n))
                    deadCorots[whichFunc][#deadCorots[whichFunc] + 1] = corot
                    if corot == lastHaltedCoroutine then
                        lastHaltedCoroutine = nil
                    end
                    args = pack(coroutine.yield())
                    goto beginning
                end
                corot = originalCoroutineCreate(wrapper)
            else
                corot = deadCorots[whichFunc][#deadCorots[whichFunc]]
                deadCorots[whichFunc][#deadCorots[whichFunc]] = nil
            end
            return corot
        end

        local originals = {
            triggerAddAction = Debug and Debug.original.TriggerAddAction or TriggerAddAction,
            condition = Debug and Debug.original.Condition or Condition,
            filter = Debug and Debug.original.Filter or Filter,
            forGroup = Debug and Debug.original.ForGroup or ForGroup,
            forForce = Debug and Debug.original.ForForce or ForForce,
            enumDestructables = Debug and Debug.original.EnumDestructablesInRect or EnumDestructablesInRect,
            enumItems = Debug and Debug.original.EnumItemsInRect or EnumItemsInRect,
            timerStart = Debug and Debug.original.TimerStart or TimerStart
        }

        TriggerAddAction = function(whichTrigger, actionFunc)
            return originals.triggerAddAction(whichTrigger, function()
                coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
            end)
        end

        Condition = function(whichFunction)
            if whichFunction then
                return originals.condition(function()
                    return select(2, coroutine.resume(getCoroutine(getTryWrapper(whichFunction))))
                end)
            else
                return originals.condition(whichFunction)
            end
        end

        Filter = function(whichFunction)
            if whichFunction then
                return originals.filter(function()
                    return select(2, coroutine.resume(getCoroutine(getTryWrapper(whichFunction))))
                end)
            else
                return originals.filter(whichFunction)
            end
        end

        ForGroup = function(whichGroup, actionFunc)
            if actionFunc then
                return originals.forGroup(whichGroup, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.forGroup(whichGroup, actionFunc)
            end
        end

        ForForce = function(whichForce, actionFunc)
            if actionFunc then
                return originals.forForce(whichForce, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.forForce(whichForce, actionFunc)
            end
        end

        EnumDestructablesInRect = function(r, filter, actionFunc)
            if actionFunc then
                return originals.enumDestructables(r, filter, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.enumDestructables(r, filter, actionFunc)
            end
        end

        EnumItemsInRect = function(r, filter, actionFunc)
            if actionFunc then
                return originals.enumItems(r, filter, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.enumItems(r, filter, actionFunc)
            end
        end

        local funcOfTimer = {}
        local function timerStartWrapper()
            local whichTimer = GetExpiredTimer()
            if funcOfTimer[whichTimer] then
                return coroutine.resume(getCoroutine(getTryWrapper(funcOfTimer[whichTimer])))
            end
        end

        TimerStart = function(whichTimer, timeout, periodic, actionFunc)
            if not whichTimer then
                return
            end
            funcOfTimer[whichTimer] = actionFunc
            return originals.timerStart(whichTimer, timeout, periodic, timerStartWrapper)
        end
    end

    --======================================================================================================================
    --Initialization
    --======================================================================================================================

    local function WriteMapScript()
        if not bj_isSinglePlayer then
            return false
        end

        local player
        local name
        for i = 0, 23 do
            player = Player(i)
            name = GetPlayerName(player)
            for j = 1, #editor.MAP_CREATORS do
                if name:find(editor.MAP_CREATORS[j]) then
                    return true
                end
            end
        end
        return false
    end

    local function ExecuteInitList(whichList)
        if init.suspended and whichList ~= "essential" then
            return
        end

        if whichList == "main" then
            if compiler.ENABLE_MAP_SCRIPT_SHARING then
                init.afterMain = true
                init.writeMapScript = true
                if WriteMapScript() then
                    WSCode.Parse(init.mapScript)
                else
                    local script = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt")
                    if script then
                        print("Loading map script from " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt.")
                        WSCode.Parse(script)
                    else
                        print("Could not find " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. Loading regular map script.")
                        WSCode.Parse(init.mapScript)
                    end
                end
            elseif compiler.ENABLE_QUICK_RESTART then
                init.afterMain = true
                local flagsString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt")
                if flagsString then
                    for i = 1, #flags do
                        flags[flags[i]] = flagsString:sub(i, i) == "1"
                    end
                    if flags.quickRestart then
                        flags.quickRestart = false
                        SaveSettings()
                        init.isQuickRestart = true
                        local script = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt")
                        if script then
                            print("Altered map script loaded successfully.")
                            WSCode.Parse(script)
                        else
                            print("Could not find " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. Loading regular map script.")
                            WSCode.Parse(init.mapScript)
                        end
                    else
                        WSCode.Parse(init.mapScript)
                    end
                else
                    flags.debugMode = true
                    WSCode.Parse(init.mapScript)
                end
            elseif FileIO then
                local flagsString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt")
                if flagsString then
                    for i = 1, #flags do
                        flags[flags[i]] = flagsString:sub(i, i) == "1"
                    end
                else
                    flags.debugMode = true
                end
            else
                flags.debugMode = true
            end
        end

        init.completed[whichList] = true

        local startTime
        if diagnostics.PROFILE_INIT then
            startTime = clock()
        end

        local passes = init.passes
        for i = 1, init.highestPass[whichList] or 1 do
            for __, initializer in ipairs(init[whichList]) do
                if passes[initializer] == i then
                    if diagnostics.INIT_DUMP then
                        PreloadGenClear()
                        PreloadGenStart()
                        Preload("WSCode.Init" .. whichList:sub(1, 1):upper() .. whichList:sub(2) .. ": " .. (init.names[initializer] or "Unknown"))
                        PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
                    end
                    if compiler.RELEASE_VERSION then
                        initializer()
                    elseif diagnostics.PROFILE_INIT then
                        local time = clock()
                        initializer()
                        local endTime = clock()
                        if init.names[initializer] then
                            init.profiler[init.names[initializer]] = (init.profiler[init.names[initializer]] or 0) + endTime - time
                        end
                    else
                        ---@diagnostic disable-next-line: param-type-mismatch
                        xpcall(initializer, Debug.errorHandler)
                    end
                end
            end
        end

        if diagnostics.PROFILE_INIT then
            local endTime = clock()
            init.profiler.totalTime = init.profiler.totalTime + endTime - startTime
        end

        if init and init.suspended and whichList ~= "essential" then
            init.suspended = false
            if not init.completed.main then
                ExecuteInitList("main")
            end
            if not init.completed.global then
                ExecuteInitList("global")
            end
            if not init.completed.trig then
                ExecuteInitList("trig")
            end
            if not init.completed.map then
                ExecuteInitList("map")
            end
            if not init.completed.essential then
                ExecuteInitList("essential")
            end
            if not init.completed.final then
                ExecuteInitList("final")
            end
        end
    end

    do
        local gmt = getmetatable(_G) or getmetatable(setmetatable(_G, {}))
        local rawIndex = gmt.__newindex or rawset

        ---@param _G table
        ---@param key string
        ---@param fnOrDiscard unknown
        local function hookMain(_G, key, fnOrDiscard)
            if key == "main" then
                rawIndex(_G, key, function()
                    if gmt.__newindex == hookMain then
                        gmt.__newindex = rawIndex --restore the original __newindex if no further hooks on __newindex exist.
                    end
                    local corot = coroutine.create(ExecuteInitList)
                    coroutine.resume(corot, "main")

                    fnOrDiscard()
                end)
            else
                rawIndex(_G, key, fnOrDiscard)
            end
        end
        gmt.__newindex = hookMain

        local oldGlobals = InitGlobals
        InitGlobals = function()
            oldGlobals()

            local oldTrig = InitCustomTriggers
            InitCustomTriggers = function()
                oldTrig()
                local corot
                corot = coroutine.create(ExecuteInitList)
                coroutine.resume(corot, "trig")
            end

            local oldMap = RunInitializationTriggers
            RunInitializationTriggers = function()
                oldMap()
                local corot
                corot = coroutine.create(ExecuteInitList)
                coroutine.resume(corot, "map")
            end

            local corot
            corot = coroutine.create(ExecuteInitList)
            coroutine.resume(corot, "global")
        end

        local oldMark = MarkGameStarted
        MarkGameStarted = function()
            oldMark()

            local corot = coroutine.create(ExecuteInitList)
            coroutine.resume(corot, "essential")
            corot = coroutine.create(ExecuteInitList)
            coroutine.resume(corot, "final")

            if not compiler.RELEASE_VERSION then
                --Actions to be executed upon typing -exec
                local function ExecCommand()
                    if string.sub(GetEventPlayerChatString(), 1, 6) ~= "-exec " then
                        return
                    end

                    local input = string.sub(GetEventPlayerChatString(), 7, -1)
                    print("Executing input: |cffffff44" .. input .. "|r")
                    --try preceeding the input by a return statement (preparation for printing below)
                    local loadedFunc, errorMsg = load("return ".. input)
                    if not loadedFunc then --if that doesn't produce valid code, try without return statement
                        loadedFunc, errorMsg = load(input)
                    end
                    --execute loaded function in case the string defined a valid function. Otherwise print error.
                    if errorMsg then
                        print("|cffff5555Invalid Lua-statement: " .. Debug.getLocalErrorMsg(errorMsg) .. "|r")
                    else
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local results = table.pack(Debug.try(loadedFunc))
                        if results[1] ~= nil or results.n > 1 then
                            for i = 1, results.n do
                                results[i] = tostring(results[i])
                            end
                            --concatenate all function return values to one colorized string
                            print("|cff00ffff" .. table.concat(results, '    ', 1, results.n) .. "|r")
                        end
                    end
                end

                local player
                local trig = CreateTrigger()
                local name

                local execTrigger = CreateTrigger()
                TriggerAddAction(execTrigger, ExecCommand)

                for i = 0, 23 do
                    player = Player(i)
                    name = GetPlayerName(player)
                    for __, creator in ipairs(editor.MAP_CREATORS) do
                        if find(name, creator) then
                            user = user or player
                            TriggerRegisterPlayerChatEvent(execTrigger, player, "-exec", false)
                            TriggerRegisterPlayerChatEvent(trig, player, "-wscode", true)
                            break
                        end
                    end
                end

                TriggerAddAction(trig, EnableEditor)

                if init.error then
                    JumpToError(init.error.fileName, init.error.lineNumber)
                elseif Debug and Debug.data.firstError then
                    local fileName = Debug.data.firstError:match("ERROR at (.+), line")
                    local lineNumber = tonumber(Debug.data.firstError:match("line (\x25d+):"))
                    if fileName and lineNumber then
                        JumpToError(fileName, lineNumber)
                    end
                elseif editor.AUTO_INITIALIZE and not codeEditorParent then
                    EnableEditor(user)
                    BlzFrameSetVisible(codeEditorParent, false)
                end
                initialized = true
                if coroutineWaitingForInit then
                    coroutine.resume(coroutineWaitingForInit)
                end
                if init.error then
                    SaveTabs()
                end

                if diagnostics.PROFILE_INIT then
                    local totalTime = init.profiler.totalTime
                    local str = "Map script initialization profile complete:\n|cffaaaaffTotal time:|r " .. string.format("\x25.3f", totalTime) .. "s"
                    init.profiler.totalTime = nil
                    local orderedFiles = {}
                    for fileName, duration in pairs(init.profiler) do
                        orderedFiles[#orderedFiles + 1] = fileName
                    end
                    table.sort(orderedFiles, function(a, b)
                        return init.profiler[a] > init.profiler[b]
                    end)
                    local i = 1
                    while i <= math.min(10, #orderedFiles) do
                        local fraction = init.profiler[orderedFiles[i]]/totalTime
                        if fraction < 0.001 then
                            break
                        end
                        str = str .. "\n|cffffcc00" .. orderedFiles[i] .. ":|r " .. string.format("\x25.3f", init.profiler[orderedFiles[i]]) .. "s |cffaaaaaa(" .. string.format("\x25.1f", 100*fraction) .. "\x25)|r"

                        i = i + 1
                    end

                    print(str)
                end
            else
                files = nil
                fileNames = nil
                init = nil
            end
        end
    end

    local function InitTabs()
        local tabString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeTabs.txt")
        init.tabsInitialized = true
        if tabString then
            init.debugTabs = {}
            init.pullTabs = {}
            init.loadTabs = {}
            local commaPos
            local beginning = 1
            local tabName
            local filePulled
            repeat
                commaPos = tabString:find("[,;]", beginning)
                if commaPos then
                    filePulled = tabString:sub(commaPos, commaPos) == ";"
                    tabName = tabString:sub(beginning, commaPos - 1)
                    beginning = commaPos + 1

                    init.debugTabs[tabName] = true
                    if filePulled then
                        init.pullTabs[tabName] = true
                    else
                        init.loadTabs[tabName] = true
                    end
                end
            until not commaPos
        end
    end

    --======================================================================================================================
    --Code Editor
    --======================================================================================================================

    local function PlayError()
        local s = CreateSound("Sound\\Interface\\Error.flac" , false, false, false, 10, 10, "DefaultEAXON")
        if GetLocalPlayer() == user then
            SetSoundVolume(s, 127)
        else
            SetSoundVolume(s, 0)
        end
        StartSound(s)
        KillSoundWhenDone(s)
    end

    PrintForUser = function(str)
        if user == nil or GetLocalPlayer() == user then
            print(str)
        end
    end

    local function WriteToFile(str)
        while #str > 250 do
            for l = 250, 1, -1 do
                if str:sub(l, l) == " " then
                    Preload(str:sub(1, l) .. "ws")
                    str = str:sub(l + 1)
                    break
                end
            end
        end
        Preload(str .. "ws")
    end

    SaveSettings = function()
        if not FileIO then
            return
        end

        local saveString = ""
        for i = 1, #flags do
            saveString = saveString .. (flags[flags[i]] and "1" or "0")
        end

        FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt", saveString)
    end

    SaveTabs = function()
        if not initialized then
            return
        end
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            local saveString = ""
            for j = 1, tabs.amount do
                if not existingFiles[tabs.names[j]] then
                    saveString = saveString .. tabs.names[j] .. ","
                elseif not tabs.wasPulledFromDebugToken[tabs.names[j]] then
                    saveString = saveString .. tabs.names[j] .. ";"
                end
            end
            FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeTabs.txt", saveString)
        end
    end

    local function QuickRestart(toDebugFiles)
        flags.quickRestart = true
        SaveSettings()

        local mapScript = {}

        local fileTable, debugThis, hasDebugToken
        local thisFile
        for i = 1, #fileNames do
            if tabs.numbers[fileNames[i]] then
                thisFile = codeLines[fileNames[i]][step[fileNames[i]]]
            else
                thisFile = files[i]
            end

            fileTable = {"\n", thisFile[1]}
            for k = 2, #thisFile do
                fileTable[#fileTable + 1] = "\n"
                fileTable[#fileTable + 1] = thisFile[k]
            end
            mapScript[#mapScript + 1] = table.concat(fileTable)

            debugThis = toDebugFiles[fileNames[i]]
            if debugThis then
                if not tabs.numbers[fileNames[i]] then
                    tabs.amount = tabs.amount + 1
                    tabs.names[tabs.amount] = fileNames[i]
                end
            end
        end

        SaveTabs()
        FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt", table.concat(mapScript))
        RestartGame(false)
    end

    local function GetTextHighlightFrame(playerIndexString, alpha, type)
        local frame
        if #highlights.text > 0 then
            frame = highlights.text[#highlights.text]
            highlights.text[#highlights.text] = nil
            if highlights.typeFromFrame[frame] ~= type then
                highlights.typeFromFrame[frame] = type
                BlzFrameSetTexture(frame, "ReplaceableTextures\\TeamColor\\TeamColor" .. playerIndexString .. ".blp", 0, true)
                BlzFrameSetAlpha(frame, alpha)
            end
            BlzFrameSetVisible(frame, true)
        else
            frame = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
            BlzFrameSetTexture(frame, "ReplaceableTextures\\TeamColor\\TeamColor" .. playerIndexString .. ".blp", 0, true)
            BlzFrameSetAlpha(frame, alpha)
            BlzFrameSetEnable(frame, false)
            highlights.typeFromFrame[frame] = type
        end
        return frame
    end

    local function ReturnTextHighlightFrame(whichFrame)
        BlzFrameSetVisible(whichFrame, false)
        highlights.text[#highlights.text + 1] = whichFrame
    end

    local function GetTextWidth(str)
        BlzFrameSetText(widthTestFrame, str:gsub("|", "||"))
        BlzFrameSetSize(widthTestFrame, 0, 0)
        return BlzFrameGetWidth(widthTestFrame)
    end

    local function IsQuotationMarkEscaped(code, pos)
        local numBackslashLiterals = 0
        pos = pos - 1
        while pos > 0 and sub(code, pos, pos) == "\\" do
            numBackslashLiterals = numBackslashLiterals + 1
            pos = pos - 1
        end
        return math.fmod(numBackslashLiterals, 2) ~= 0
    end

    local function SearchForClosingBracket()
        if not cursor.pos then
            return
        end
        local line = cursor.adjustedLine
        local currentLines = codeLines[currentTab][step[currentTab]]
        local previousChar = sub(currentLines[line], cursor.pos, cursor.pos)
        local nextChar = sub(currentLines[line], cursor.pos + 1, cursor.pos + 1)
        local whichChar = brackets.IS_BRACKET[previousChar] and previousChar or brackets.IS_BRACKET[nextChar] and nextChar
        if whichChar and not selection.hasSelection then
            local originalPos = brackets.IS_BRACKET[previousChar] and cursor.pos or cursor.pos + 1
            local searchFor = brackets.CORRESPONDING_BRACKET[whichChar]
            local bracketFound = false

            if whichChar == ")" or whichChar == "]" or whichChar == "}" then
                local startPoint = originalPos - 1
                local bracketBalance = -1
                local char
                repeat
                    for i = startPoint, 1, -1 do
                        char = sub(currentLines[line], i, i)
                        if char == searchFor then
                            bracketBalance = bracketBalance + 1
                            if bracketBalance == 0 then
                                bracketFound = true
                                brackets.lines[1] = cursor.adjustedLine
                                brackets.pos[1] = originalPos
                                brackets.lines[2] = line
                                brackets.pos[2] = i
                                break
                            end
                        elseif char == whichChar then
                            bracketBalance = bracketBalance - 1
                        end
                    end
                    line = line - 1
                    startPoint = #currentLines[line]
                until bracketFound or line < 1
            else
                local startPoint = originalPos + 1
                local bracketBalance = 1
                local char
                repeat
                    for i = startPoint, #currentLines[line] do
                        char = sub(currentLines[line], i, i)
                        if char == searchFor then
                            bracketBalance = bracketBalance - 1
                            if bracketBalance == 0 then
                                bracketFound = true
                                brackets.lines[1] = cursor.adjustedLine
                                brackets.pos[1] = originalPos
                                brackets.lines[2] = line
                                brackets.pos[2] = i
                                break
                            end
                        elseif char == whichChar then
                            bracketBalance = bracketBalance + 1
                        end
                    end
                    line = line + 1
                    startPoint = 1
                until bracketFound or line > highestNonEmptyLine[currentTab][step[currentTab]]
            end

            if bracketFound then
                local rawLine = brackets.lines[1] - lineNumberOffset[currentTab]
                if rawLine >= 1 and rawLine <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[1], true)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[1]], 1, brackets.pos[1] - 1)), -editor.CODE_TOP_INSET - rawLine*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[1]], 1, brackets.pos[1])), -editor.CODE_TOP_INSET - (rawLine - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[1], false)
                end
                rawLine = brackets.lines[2] - lineNumberOffset[currentTab]
                if rawLine >= 1 and rawLine <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[2], true)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[2]], 1, brackets.pos[2] - 1)), -editor.CODE_TOP_INSET - rawLine*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[2]], 1, brackets.pos[2])), -editor.CODE_TOP_INSET - (rawLine - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[2], false)
                end
            else
                brackets.lines[1] = nil
                brackets.lines[2] = nil
                BlzFrameSetVisible(brackets.highlights[1], false)
                BlzFrameSetVisible(brackets.highlights[2], false)
            end
        else
            brackets.lines[1] = nil
            brackets.lines[2] = nil
            BlzFrameSetVisible(brackets.highlights[1], false)
            BlzFrameSetVisible(brackets.highlights[2], false)
        end
    end

    local function SetCursorX(str)
        local width = GetTextWidth(str)
        BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + width, -editor.CODE_TOP_INSET - cursor.rawLine*editor.LINE_SPACING)
        cursor.x = width
        cursorCounter = 0
    end

    local function SetCursorPos(whichPos)
        cursor.pos = whichPos
        SearchForClosingBracket()
    end

    local function SetLineOffset(whichOffset)
        BlzFrameSetValue(codeScroller, highestNonEmptyLine[currentTab][step[currentTab]] - whichOffset)
    end

    local function JumpWindow(whichLine, jumpToCenter, forceCenter)
        if forceCenter then
            SetLineOffset(math.max(0, math.min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN + 4)))
            return true
        else
            if lineNumberOffset[currentTab] > whichLine - 4 and lineNumberOffset[currentTab] > 1 then
                if jumpToCenter then
                    SetLineOffset(math.max(0, math.min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN+ 4)))
                else
                    SetLineOffset(math.max(0, whichLine - 4))
                end
                return true
            elseif lineNumberOffset[currentTab] < whichLine - editor.MAX_LINES_ON_SCREEN + 4 then
                if jumpToCenter then
                    SetLineOffset(math.max(0, math.min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN + 4)))
                else
                    SetLineOffset(whichLine - editor.MAX_LINES_ON_SCREEN + 4)
                end
                return true
            else
                return false
            end
        end
    end

    local function ConvertStringToLines(whichString)
        local lines = {}

        local k = 1
        local beginning = 1
        local pos = whichString:find("\n")
        while pos do
            lines[k] = sub(whichString, beginning, pos - 1)
            beginning = pos + 1
            pos = whichString:find("\n", pos + 1)
            k = k + 1
        end

        if beginning <= #whichString then
            lines[#lines + 1] = sub(whichString, beginning)
        end

        return lines
    end

    local function SetCurrentLine()
        if currentStop[currentTab] - lineNumberOffset[currentTab] < 1 then
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET)
            BlzFrameSetTexture(highlights.currentLine, "currentLineUp.blp", 0, true)
        elseif currentStop[currentTab] - lineNumberOffset[currentTab] > editor.MAX_LINES_ON_SCREEN then
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (editor.MAX_LINES_ON_SCREEN - 1)*editor.LINE_SPACING)
            BlzFrameSetTexture(highlights.currentLine, "currentLineDown.blp", 0, true)
        else
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - (currentStop[currentTab] - lineNumberOffset[currentTab])*editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (currentStop[currentTab] - lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)
            BlzFrameSetTexture(highlights.currentLine, "currentLine.blp", 0, true)
        end
    end

    local function SearchForDuplicates()
        local pos, endPos
        local currentLines = codeLines[currentTab][step[currentTab]]
        local start = math.min(selection.startPos, selection.endPos) + 1
        local stop = math.max(selection.startPos, selection.endPos)
        local selectString = sub(currentLines[selection.startLine], start, stop):gsub("([\x25^\x25$\x25(\x25)\x25\x25\x25.\x25[\x25]\x25*\x25+\x25-\x25?])", "\x25\x25\x251") --escape all special characters
        local numDuplicates = 0
        local offset
        if #selectString > 0 and selectString:find("^\x25s*$") == nil then --empty line
            for i = lineNumberOffset[currentTab] + 1, editor.MAX_LINES_ON_SCREEN + lineNumberOffset[currentTab] do
                pos, endPos = find(currentLines[i], selectString)
                while pos do
                    if i ~= selection.startLine or pos ~= start then
                        numDuplicates = numDuplicates + 1
                        duplicateHighlightFrames[numDuplicates] = duplicateHighlightFrames[numDuplicates] or GetTextHighlightFrame("09", 90, "duplicate")
                        BlzFrameSetPoint(duplicateHighlightFrames[numDuplicates], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[i], 1, pos - 1)), -editor.CODE_TOP_INSET - (i - lineNumberOffset[currentTab])*editor.LINE_SPACING)
                        BlzFrameSetPoint(duplicateHighlightFrames[numDuplicates], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[i], 1, endPos)), -editor.CODE_TOP_INSET - (i - 1 - lineNumberOffset[currentTab])*editor.LINE_SPACING)
                    end
                    offset = endPos
                    pos, endPos = find(sub(currentLines[i], endPos + 1), selectString)
                    if pos then
                        pos = pos + offset
                        endPos = endPos + offset
                    end
                end
            end
        end
        for i = numDuplicates + 1, #duplicateHighlightFrames do
            ReturnTextHighlightFrame(duplicateHighlightFrames[i])
            duplicateHighlightFrames[i] = nil
        end
    end

    local function RemoveDuplicates()
        for i = 1, #duplicateHighlightFrames do
            ReturnTextHighlightFrame(duplicateHighlightFrames[i])
            duplicateHighlightFrames[i] = nil
        end
    end

    local function ConvertAndValidateLines(lines, whichTab, duringInit, printError)
        if tabs.disableSyntaxCheck[currentTab] then
            return
        end

        local adjustedCodeLines = {}
        adjustedCodeLines[1] = lines[1]
        for i = 2, #lines do
            adjustedCodeLines[i] = "\n" .. lines[i]
        end

        local code = table.concat(adjustedCodeLines):gsub("Debug.beginFile", "DoNothing"):gsub("Debug.endFile", "DoNothing")

        local func, err
        func, err = load(code, "WSCodeValidation", "t")
        if not func then
            if not duringInit then
                if err then
                    local lineNumber = tonumber(err:match('"\x25]:(\x25d+):')) --"]:NUMBER:
                    if lineNumber then
                        tabs.hasError[currentTab] = true
                        errorLineNumber[currentTab] = lineNumber
                        lastViewedLineNumber[currentTab] = lineNumber
                        BlzFrameSetVisible(highlights.error, errorLineNumber[currentTab] - lineNumberOffset[whichTab] >= 1 and errorLineNumber[currentTab] - lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN)
                        BlzFrameSetAlpha(highlights.error, 128)
                        BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[whichTab]))
                        BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[whichTab] - 1))
                        if printError then
                            PrintForUser("|cffff5555SYNTAX ERROR at " .. (whichTab or "Unknown") .. (err:match('"WSCodeValidation"\x25](.+)') or "") .. "|r")
                        end
                        return false
                    else
                        tabs.hasError[currentTab] = false
                        BlzFrameSetVisible(highlights.error, false)
                        return false
                    end
                else
                    tabs.hasError[currentTab] = false
                    BlzFrameSetVisible(highlights.error, false)
                    return false
                end
            elseif err then
                if printError then
                    PrintForUser("|cffff5555SYNTAX ERROR at " .. (whichTab or "Unknown") .. (err:match('"WSCodeValidation"\x25](.+)') or "") .. "|r")
                end
                if duringInit then
                    init.error = {
                        fileName = whichTab or "Unknown",
                        lineNumber = tonumber(err:match('"\x25]:(\x25d+):')) --"]:NUMBER:
                    }
                end
                return false
            end
        elseif not duringInit then
            tabs.hasError[currentTab] = false
            BlzFrameSetVisible(highlights.error, false)
        end
        return true, code, func
    end

    local function IncrementStep()
        step[currentTab] = step[currentTab] + 1
        local lastLines = codeLines[currentTab][step[currentTab] - 1]
        local currentLines = codeLines[currentTab][step[currentTab]]

        for i = 1, highestNonEmptyLine[currentTab][step[currentTab] - 1] do
            currentLines[i] = lastLines[i]
            coloredCodeLines[currentTab][step[currentTab]][i] = coloredCodeLines[currentTab][step[currentTab] - 1][i]
        end
        for i = highestNonEmptyLine[currentTab][step[currentTab] - 1] + 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            currentLines[i] = ""
            coloredCodeLines[currentTab][step[currentTab]][i] = ""
        end

        highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab] - 1]
        BlzFrameSetVisible(highlights.currentLine, false)
        BlzFrameSetVisible(highlights.error, false)
        if WSDebug.TabIsHalted[currentTab] then
            WSDebug.TabIsHalted[currentTab] = false
            if not tabs.hasError[currentTab] then
                doNotUpdateVariables[currentTab] = false
            end
        end
        lastViewedLineNumber[currentTab] = nil

        BlzFrameSetEnable(buttons.undo, true)
        BlzFrameSetEnable(buttons.redo, false)

        maxRedo[currentTab] = step[currentTab]
        lineNumberOfEdit[currentTab][step[currentTab]] = cursor.adjustedLine or 1
        posOfEdit[currentTab][step[currentTab]] = cursor.pos

        WSDebug.GenerationCounter[currentTab] = WSDebug.GenerationCounter[currentTab] + 1

        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            if lineNumberWasExecuted[currentTab][i] then
                lineNumberWasExecuted[currentTab][i] = nil
                local rawLineNumber = math.tointeger(i - lineNumberOffset[currentTab])
                if rawLineNumber >= 1 and rawLineNumber <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetText(lineNumbers[rawLineNumber], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
                end
            end
        end
    end

    local function RecalculateHighestNonEmptyLineNumber()
        local currentLines = codeLines[currentTab][step[currentTab]]
        for i = highestNonEmptyLine[currentTab][step[currentTab]], 0, -1 do
            if currentLines[i] ~= "" then
                highestNonEmptyLine[currentTab][step[currentTab]] = i
                BlzFrameSetMinMaxValue(codeScroller, 0, i)
                return
            end
        end
        highestNonEmptyLine[currentTab][step[currentTab]] = 0
        BlzFrameSetMinMaxValue(codeScroller, 0, 0)
    end

    local function UpdateAllLines()
        local currentColoredLines = coloredCodeLines[currentTab][step[currentTab]]
        for i = 1, editor.MAX_LINES_ON_SCREEN do
            BlzFrameSetText(codeLineFrames[i], currentColoredLines[i + lineNumberOffset[currentTab]])
        end
        RecalculateHighestNonEmptyLineNumber()
    end

    local function AddColors(prefix, match, suffix)
        if LUA_KEYWORDS[match] then
            return prefix .. editor.KEYWORD_COLOR .. match .. "|r" .. suffix
        elseif match == "false" or match == "true" or match == "nil" or tonumber(match) then
            return prefix .. editor.VALUE_COLOR .. match .. "|r" .. suffix
        elseif FUNCTION_PREVIEW and FUNCTION_PREVIEW[match] then
            return prefix .. editor.NATIVE_COLOR .. match .. "|r" .. suffix
        end
        return prefix .. match .. suffix
    end

    local function ColorFunctions(prefix, funcWord, funcName)
        return prefix .. " " .. editor.FUNCTION_NAME_COLOR .. funcName .. "|r"
    end

    local function GetColoredText(str, lineNumber, whichTab)
        local inSingleQuoteString
        local inDoubleQuoteString
        local inMultilineString
        local endsInLongComment
        local oldEqualSigns

        str = str:gsub("|", "||")

        local lineSegments = {}

        local restStr, commentStr
        if lineNumber > 1 and lines.endsInLongString[whichTab][lineNumber - 1] then
            inMultilineString = true
            lines.numEqualSigns[lineNumber] = lines.numEqualSigns[lineNumber - 1]
            restStr = str
            lineSegments[1] = ""
            commentStr = ""
        elseif lineNumber > 1 and lines.endsInLongComment[whichTab][lineNumber - 1] then
            lines.numEqualSigns[lineNumber] = lines.numEqualSigns[lineNumber - 1]
            restStr = ""
            commentStr = editor.COMMENT_COLOR .. str .. "|r"
            local matchStr = "]"
            for __ = 1, lines.numEqualSigns[lineNumber] do
                matchStr = matchStr .. "="
            end
            matchStr = matchStr .. "]"
            endsInLongComment = find(str, matchStr) == nil
        else
            local commentBegin = find(str, "\x25-\x25-")
            if commentBegin then
                commentStr =  editor.COMMENT_COLOR .. sub(str, commentBegin) .. "|r"
                restStr = sub(str, 1, commentBegin - 1)
                if sub(str, commentBegin):match("^\x25-\x25-\x25[") ~= nil then
                    oldEqualSigns = lines.numEqualSigns[lineNumber]
                    lines.numEqualSigns[lineNumber] = 0
                    local i = commentBegin + 3
                    while sub(str, i, i) == "=" do
                        lines.numEqualSigns[lineNumber] = lines.numEqualSigns[lineNumber] + 1
                        i = i + 1
                    end
                    if sub(str, i, i) == "[" then
                        local matchStr = "]"
                        for __ = 1, lines.numEqualSigns[lineNumber] do
                            matchStr = matchStr .. "="
                        end
                        if find(str, matchStr) == nil then
                            endsInLongComment = true
                        end
                    end
                end
            else
                restStr = str
                commentStr = ""
                endsInLongComment = nil
            end
        end

        local i = 1
        local beginningOfSegment = 1
        while i <= #restStr do
            local char = sub(restStr, i, i)
            if char == "'" then
                if not IsQuotationMarkEscaped(restStr, i) then
                    if not inDoubleQuoteString and not inMultilineString then
                        if inSingleQuoteString then
                            inSingleQuoteString = false
                            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i) .. "|r"
                            beginningOfSegment = i + 1
                        elseif find(sub(restStr, i + 1), "'") then
                            inSingleQuoteString = true
                            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                            beginningOfSegment = i
                        end
                    end
                end
            elseif char == '"' then
                if not IsQuotationMarkEscaped(restStr, i) then
                    if not inSingleQuoteString and not inMultilineString then
                        if inDoubleQuoteString then
                            inDoubleQuoteString = false
                            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i) .. "|r"
                            beginningOfSegment = i + 1
                        elseif find(sub(restStr, i + 1), '"') then
                            inDoubleQuoteString = true
                            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                            beginningOfSegment = i
                        end
                    end
                end
            elseif sub(restStr, i):match("^\x25[=*\x25[") and not inMultilineString then
                local j = i + 1
                lines.numEqualSigns[lineNumber] = 0
                while sub(restStr, j, j) == "=" do
                    lines.numEqualSigns[lineNumber] = lines.numEqualSigns[lineNumber] + 1
                    j = j + 1
                end
                if sub(restStr, j, j) == "[" then
                    inMultilineString = true
                    lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                    beginningOfSegment = i
                end
                i = i + 1 + lines.numEqualSigns[lineNumber]
            elseif inMultilineString and sub(restStr, i, i + 1 + lines.numEqualSigns[lineNumber]):match("^\x25]=*\x25]$") then
                inMultilineString = false
                lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i + 1 + lines.numEqualSigns[lineNumber]) .. "|r"
                beginningOfSegment = i + 2 + lines.numEqualSigns[lineNumber]
                i = i + 1 + lines.numEqualSigns[lineNumber]
            end
            i = i + 1
        end

        if inMultilineString then
            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment) .. "|r"
        else
            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment)
        end

        for i = 1, #lineSegments, 2 do
            lineSegments[i] = lineSegments[i]:gsub("(\x25f[\x25a_]function)(\x25f[\x25A])\x25s+([\x25a_][\x25w_]*)", ColorFunctions)
            lineSegments[i] = lineSegments[i]:gsub("(\x25f[\x25w_.-])([\x25w_.-]+)(\x25f[\x25W])", AddColors)
        end

        if (lines.endsInLongString[whichTab][lineNumber] == true) ~= (inMultilineString == true) then
            lines.endsInLongString[whichTab][lineNumber] = inMultilineString
            if lineNumber + 1 <= highestNonEmptyLine[whichTab][step[whichTab]] then
                coloredCodeLines[whichTab][step[whichTab]][lineNumber + 1] = GetColoredText(codeLines[whichTab][step[whichTab]][lineNumber + 1], lineNumber + 1, whichTab)
                if lineNumber + 1 - lineNumberOffset[whichTab] >= 1 and lineNumber + 1 - lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetText(codeLineFrames[lineNumber + 1 - lineNumberOffset[whichTab]], coloredCodeLines[whichTab][step[whichTab]][lineNumber + 1])
                end
            end
        elseif (lines.endsInLongComment[whichTab][lineNumber] == true) ~= (endsInLongComment == true) or (lines.endsInLongComment[whichTab][lineNumber] and oldEqualSigns ~= lines.numEqualSigns[lineNumber]) then
            lines.endsInLongComment[whichTab][lineNumber] = endsInLongComment
            if lineNumber + 1 <= highestNonEmptyLine[whichTab][step[whichTab]] then
                coloredCodeLines[whichTab][step[whichTab]][lineNumber + 1] = GetColoredText(codeLines[whichTab][step[whichTab]][lineNumber + 1], lineNumber + 1, whichTab)
                if lineNumber + 1 - lineNumberOffset[whichTab] >= 1 and lineNumber + 1 - lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetText(codeLineFrames[lineNumber + 1 - lineNumberOffset[whichTab]], coloredCodeLines[whichTab][step[whichTab]][lineNumber + 1])
                end
            end
        end

        return (table.concat(lineSegments) .. commentStr)
    end

    local function SetLocalList(lineNumber)
        local str, vars, varName
        localLookupTable = {}
        local varDefLevels = {}
        local level = 0
        local isLocal, isAssignment, isFunctionDef
        local lines = codeLines[currentTab][step[currentTab]]

        for i = 1, lineNumber - 1 do
            str = lines[i]:gsub("'([^']+)'", ""):gsub('"([^"]+)"', "") --Remove string literals.

            isFunctionDef = find(str, "\x25f[\x25w_]function\x25f[^\x25w_]")

            if isFunctionDef or find(str, "\x25f[\x25w_]do\x25f[^\x25w_]") or find(str, "\x25f[\x25w_]if\x25f[^\x25w_]") or find(str, "\x25f[\x25w_]for\x25f[^\x25w_]") or find(str, "\x25f[\x25w_]while\x25f[^\x25w_]") or find(str, "\x25f[\x25w_]repeat\x25f[^\x25w_]") then
                level = level + 1
            end

            if isFunctionDef then
                vars = str:match("\x25((.+)\x25)") or "" --Get function arguments.
                vars = vars:gsub(" ", "")

                local pos = find(vars, ",")
                while pos do
                    varName = sub(vars, 1, pos - 1)
                    vars = sub(vars, pos + 1)
                    if not localLookupTable[varName] and not globalLookupTable[varName] then
                        localLookupTable[#localLookupTable + 1] = varName
                        localLookupTable[varName] = true
                        varDefLevels[#varDefLevels + 1] = level
                    end
                    pos = find(vars, ",")
                end
                if not localLookupTable[vars] and not globalLookupTable[vars] then
                    localLookupTable[#localLookupTable + 1] = vars
                    localLookupTable[vars] = true
                    varDefLevels[#varDefLevels + 1] = level
                end

                isLocal = find(str, "^\x25s*local ")
                isAssignment = find(str, "[^=<>~]=[^=<>~]") --single equal sign, not <= etc.
                if isAssignment then
                    vars = str:match("([\x25w_]+)\x25s*=") --name before equal sign
                else
                    vars = str:match("([\x25w_]+)\x25s*\x25(") --name before opening parenthesis
                end
                if vars and not localLookupTable[vars] and not globalLookupTable[vars] then
                    localLookupTable[#localLookupTable + 1] = vars
                    localLookupTable[vars] = true
                    varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                end
            else
                isLocal = find(str, "^\x25s*local ")
                isAssignment = find(str, "[^=<>~]=[^=<>~]") --single equal sign, not <= etc.
                if isLocal or isAssignment then
                    if isLocal then
                        if isAssignment then
                            vars = str:match("local\x25s*(.+)="):gsub(" ", "") --Between local and =
                        else
                            vars = str:match("local\x25s*(.+)"):gsub(" ", "") --everthing after local
                        end
                    else
                        vars = str:match("(.+)="):gsub(" ", "")
                    end

                    if not find(vars, "\x25.") and not find(vars, "\x25[") then --ignore table assignments
                        local pos = find(vars, ",")
                        --Separate variable names by commas
                        while pos do
                            varName = sub(vars, 1, pos - 1)
                            vars = sub(vars, pos + 1)
                            if not localLookupTable[varName] and not globalLookupTable[varName] then
                                localLookupTable[#localLookupTable + 1] = varName
                                localLookupTable[varName] = true
                                varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                            end
                            pos = find(vars, ",")
                        end
                        if not localLookupTable[vars] and not globalLookupTable[vars] then
                            localLookupTable[#localLookupTable + 1] = vars
                            localLookupTable[vars] = true
                            varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                        end
                    end
                end
            end

            if find(str, "\x25f[\x25w_]end\x25f[^\x25w_]") or find(str, "\x25f[\x25w_]until\x25f[^\x25w_]") then
                for j = 1, #varDefLevels do
                    if varDefLevels[j] == level then
                        localLookupTable[localLookupTable[j]] = nil
                        localLookupTable[j] = localLookupTable[#localLookupTable]
                        localLookupTable[#localLookupTable] = nil
                        varDefLevels[j] = varDefLevels[#varDefLevels]
                        varDefLevels[#varDefLevels] = nil
                    end
                end
                level = level - 1
            end
        end

        table.sort(localLookupTable)
    end

    local function PutStop(lineNumber, isSpyGlass)
        local currentLines = codeLines[currentTab][step[currentTab]]
        local hasWarning

        if not lineNumber then
            local button = BlzGetTriggerFrame()
            BlzFrameSetEnable(button, false)
            BlzFrameSetEnable(button, true)
            lineNumber = indexFromFrame[button] + lineNumberOffset[currentTab]
            isSpyGlass = false
        end

        if lineNumber > highestNonEmptyLine[currentTab][step[currentTab]] then
            PlayError()
            return
        end

        if lines.debugState[currentTab][lineNumber] == 0 then
            if find(currentLines[lineNumber], "^\x25s*$") ~= nil or find(currentLines[lineNumber], "^\x25s*do\x25s*$") ~= nil then
                hasWarning = true
            elseif find(currentLines[lineNumber], "\x25f[\x25a_]end\x25f[^\x25w_]") ~= nil then
                --Stop cannot be put on an end token if the previous line contains a return statement.
                if find(currentLines[lineNumber - 1], "\x25f[\x25a_]return\x25f[^\x25w_]") ~= nil then
                    hasWarning = true
                end
            else
                --Check if line is part of multiline function call or table def.
                local i = lineNumber - 1
                local level = 0
                local numRoundBrackets = 0
                local numSquareBrackets = 0
                local numCurlyBrackets = 0
                repeat
                    if find(currentLines[i], "\x25f[\x25a_]for\x25f[^\x25w_]") ~= nil
                    or find(currentLines[i], "\x25f[\x25a_]do\x25f[^\x25w_]") ~= nil
                    or find(currentLines[i], "\x25f[\x25a_]if\x25f[^\x25w_]") ~= nil
                    or find(currentLines[i], "\x25f[\x25a_]function\x25f[^\x25w_]") then
                        level = level - 1
                    end
                    if find(currentLines[i], "\x25f[\x25a_]end\x25f[^\x25w_]") ~= nil
                    or find(currentLines[i], "\x25f[\x25a_]until\x25f[^\x25w_]") ~= nil then
                        level = level + 1
                    end
                    if level < 0 then
                        break
                    end
                    numRoundBrackets = numRoundBrackets + select(2, currentLines[i]:gsub("\x25(", "")) - select(2, currentLines[i]:gsub("\x25)", ""))
                    numSquareBrackets = numSquareBrackets + select(2, currentLines[i]:gsub("\x25[", "")) - select(2, currentLines[i]:gsub("\x25]", ""))
                    numCurlyBrackets = numCurlyBrackets + select(2, currentLines[i]:gsub("{", "")) - select(2, currentLines[i]:gsub("}", ""))
                    if numRoundBrackets > 0 or numSquareBrackets > 0 or numCurlyBrackets > 0 then
                        hasWarning = true
                        break
                    end
                    i = i - 1
                until i <= 0
            end

            if hasWarning then
                PrintForUser("|cffff0000Warning:|r Breakpoint may not be reachable.")
            end
        end

        if lines.debugState[currentTab][lineNumber] ~= 0 then
            lines.debugState[currentTab][lineNumber] = 0
        elseif isSpyGlass then
            lines.debugState[currentTab][lineNumber] = 1
        else
            lines.debugState[currentTab][lineNumber] = 2
        end
        BlzFrameSetTexture(BlzFrameGetChild(stopButtons[lineNumber - lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[lines.debugState[currentTab][lineNumber]], 0, true)
    end

    local function GetCursorPos(x, y)
        local lineNumber = math.floor(((editor.Y_TOP - editor.CODE_TOP_INSET) - y)/editor.LINE_SPACING) + 1

        if lineNumber >= 1 and lineNumber <= editor.MAX_LINES_ON_SCREEN then
            local dx = editor.isExpanded and x - (editor.EXPANDED_X + editor.CODE_LEFT_INSET) or x - (editor.COLLAPSED_X + editor.CODE_LEFT_INSET)

            if dx < 0 then
                return lineNumber, -1, nil
            elseif dx > (editor.isExpanded and editor.EXPANDED_WIDTH - (editor.CODE_LEFT_INSET + editor.CODE_RIGHT_INSET) or editor.COLLAPSED_WIDTH - (editor.CODE_LEFT_INSET + editor.CODE_RIGHT_INSET)) then
                return lineNumber, math.huge, nil
            end

            local text = codeLines[currentTab][step[currentTab]][lineNumber + lineNumberOffset[currentTab]]

            if #text == 0 then
                return lineNumber, 0, 0
            end

            local testPos = math.min(math.floor(dx/0.005), #text)
            local width, over
            over = GetTextWidth(sub(text, 1, testPos)) < dx
            repeat
                testPos = testPos + (over and 1 or - 1)
                width = GetTextWidth(sub(text, 1, testPos))
            until width < dx ~= over or testPos > #text

            if over then
                testPos = testPos - 1
            end
            if #text > testPos then
                local diff1 = math.abs(GetTextWidth(sub(text, 1, testPos)) - dx)
                local diff2 = math.abs(GetTextWidth(sub(text, 1, testPos + 1)) - dx)
                if diff2 < diff1 then
                    testPos = testPos + 1
                end
            end
            width = GetTextWidth(sub(text, 1, testPos))

            return lineNumber, testPos, width
        elseif lineNumber < 1 then
            return -1, nil, nil
        else
            return math.huge, nil, nil
        end
    end

    SetSelection = function(xc)
        local lower = math.max(selection.startLine, selection.endLine) - lineNumberOffset[currentTab]
        local upper = math.min(selection.startLine, selection.endLine) - lineNumberOffset[currentTab]
        local currentLines = codeLines[currentTab][step[currentTab]]

        local j
        for i = 1, editor.MAX_LINES_ON_SCREEN do
            j = i + lineNumberOffset[currentTab]
            if i > lower or i < upper then
                if selection.lines[i] then
                    ReturnTextHighlightFrame(selection.lines[i])
                    selection.lines[i] = nil
                end
            else
                selection.lines[i] = selection.lines[i] or GetTextHighlightFrame("09", 150, "selection")
                if lower == upper then
                    if selection.endPos < selection.startPos then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + xc, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], 1, selection.startPos)), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], 1, selection.startPos)), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + xc, -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                elseif i == lower then
                    if lower == selection.endLine - lineNumberOffset[currentTab] then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + xc, -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], 1, selection.startPos)), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                elseif i == upper then
                    if upper == selection.endLine - lineNumberOffset[currentTab] then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + xc, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(currentLines[j]), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], 1, selection.startPos)), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(currentLines[j]), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                else
                    BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                    BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(currentLines[j]), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                end
            end
        end

        if lower == upper and selection.startPos ~= selection.endPos then
            SearchForDuplicates()
        else
            RemoveDuplicates()
        end
    end

    HideSelection = function()
        if selection.hasSelection then
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                if selection.lines[i] then
                    ReturnTextHighlightFrame(selection.lines[i])
                    selection.lines[i] = nil
                end
            end
            RemoveDuplicates()
        end
    end

    local function OnMouseMove()
        WSDebug.Mouse.lastMove = timeElapsed
        checkedForVariableDisplay = false

        if isShowingVariableTooltip then
            BlzFrameSetVisible(helper.frame, false)
            isShowingVariableTooltip = false
        end

        if not WSDebug.Mouse.leftButtonIsPressed then
            return
        end

        local xw, yw = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
        local x, y = GetMouseScreenCoordinates(xw, yw)
        if x < -0.1333 or x > 0.93333 or y < 0 or y > 0.6 then
            x, y = mouseTargetFrameX or 0, mouseTargetFrameY or 0
        end

        if dragWindow.isDragging then
            local dx = x - dragWindow.mouseX
            local dy = y - dragWindow.mouseY
            dragWindow.mouseX = x
            dragWindow.mouseY = y
            editor.COLLAPSED_X = editor.COLLAPSED_X + dx
            editor.EXPANDED_X = editor.EXPANDED_X + dx
            editor.Y_TOP = editor.Y_TOP + dy
            if editor.isExpanded then
                BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.EXPANDED_X, editor.Y_TOP)
            else
                BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
            end
            return
        end

        local line, pos, xc = GetCursorPos(x, y)
        local currentLines = codeLines[currentTab][step[currentTab]]

        if line == -1 then
            line = 1
            pos = 0
            xc = 0
        elseif line == math.huge then
            line = editor.MAX_LINES_ON_SCREEN
            xc = GetTextWidth(currentLines[editor.MAX_LINES_ON_SCREEN + lineNumberOffset[currentTab]])
            pos = #currentLines[line + lineNumberOffset[currentTab]]
        end
        if pos == -1 then
            pos = 0
            xc = 0
        elseif pos == math.huge then
            pos = #currentLines[line + lineNumberOffset[currentTab]]
            xc = GetTextWidth(currentLines[line + lineNumberOffset[currentTab]])
        end

        if line == (selection.endLine - lineNumberOffset[currentTab]) and pos == selection.endPos then
            return
        end

        selection.endLine = line + lineNumberOffset[currentTab]
        selection.endPos = pos
        selection.hasSelection = true

        cursor.adjustedLine = selection.endLine
        cursor.rawLine = line
        SetCursorPos(pos)
        SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.adjustedLine], 1, pos))

        SetSelection(xc)
    end

    local function OnMouseRelease()
        if WSDebug.Mouse.leftButtonIsPressed and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
            WSDebug.Mouse.leftButtonIsPressed = false
        end
    end

    local function DefocusCodeEditor()
        BlzFrameSetFocus(enterBox, false)
        editBoxFocused = false
        BlzFrameSetVisible(cursorFrame, false)
        BlzFrameSetVisible(brackets.highlights[1], false)
        BlzFrameSetVisible(brackets.highlights[2], false)
        brackets.lines[1] = nil
        brackets.lines[2] = nil
    end

    local function MoveCursor(pos, line, xc)
        cursor.adjustedLine = line + lineNumberOffset[currentTab]
        cursor.rawLine = line
        SetCursorPos(pos)
        cursor.x = xc
        cursorCounter = 0
        editBoxFocused = true
        BlzFrameSetVisible(cursorFrame, true)
        BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + cursor.x, -editor.CODE_TOP_INSET - cursor.rawLine*editor.LINE_SPACING)
        enterBoxText = " "
        BlzFrameSetText(enterBox, " ")
        SetLocalList(cursor.adjustedLine)

        selection.startLine = cursor.adjustedLine
        selection.endLine = cursor.adjustedLine
        selection.startPos = cursor.pos
        selection.endPos = cursor.pos
    end

    local function OnMouseClick()
        if not BlzFrameIsVisible(codeEditorParent) then
            return
        end

        if WSDebug.Mouse.ignoreClickUntil > timeElapsed then
            return
        end

        BlzFrameSetVisible(helper.frame, false)

        local xw, yw = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
        local x, y = GetMouseScreenCoordinates(xw, yw)
        if x < -0.1333 or x > 0.93333 or y < 0 or y > 0.6 then
            x, y = mouseTargetFrameX or 0, mouseTargetFrameY or 0
        end

        if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
            --Check if click is over one of the popup menus.
            if BlzFrameIsVisible(flagsMenuParent) then
                if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + flags.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + flags.minX)
                and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + flags.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + flags.maxX)
                and y < flags.maxY then
                    DefocusCodeEditor()
                    BlzFrameSetFocus(searchBar.textField, false)
                    return
                else
                    BlzFrameSetVisible(flagsMenuParent, false)
                end
            end
            if BlzFrameIsVisible(clearMenuParent) then
                if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + clearMenu.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + clearMenu.minX)
                and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + clearMenu.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + clearMenu.maxX)
                and y < clearMenu.maxY then
                    DefocusCodeEditor()
                    BlzFrameSetFocus(searchBar.textField, false)
                    return
                else
                    BlzFrameSetVisible(clearMenuParent, false)
                end
            end
            if BlzFrameIsVisible(contextMenu.parent) then
                if x > contextMenu.minX and x < contextMenu.maxX and y > contextMenu.minY and y < contextMenu.maxY then
                    DefocusCodeEditor()
                    BlzFrameSetFocus(searchBar.textField, false)
                    return
                else
                    BlzFrameSetVisible(contextMenu.parent, false)
                end
            end
            if BlzFrameIsVisible(searchBar.parent) then
                local dx = x - (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH - searchBar.HORIZONTAL_INSET - searchBar.WIDTH or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - searchBar.HORIZONTAL_INSET - searchBar.WIDTH)
                local dy = y - (editor.Y_TOP - searchBar.VERTICAL_INSET - searchBar.HEIGHT)
                if dx > 0 and dx < searchBar.WIDTH and dy > 0 and dy < searchBar.HEIGHT then
                    if editBoxFocused and selection.hasSelection and selection.startLine == selection.endLine and dx > searchBar.SEARCH_FIELD_LEFT_INSET and dx < searchBar.WIDTH - searchBar.SEARCH_FIELD_RIGHT_INSET and dy > searchBar.SEARCH_FIELD_BOTTOM_INSET and dy < searchBar.HEIGHT - searchBar.SEARCH_FIELD_TOP_INSET then
                        local text = sub(codeLines[currentTab][step[currentTab]][selection.startLine], math.min(selection.startPos, selection.endPos) + 1, math.max(selection.startPos, selection.endPos))
                        BlzFrameSetText(searchBar.textField, text)
                    end
                    DefocusCodeEditor()
                    return
                end
            else
                BlzFrameSetFocus(searchBar.textField, false)
            end

            if x > (editor.isExpanded and (editor.EXPANDED_X + editor.EXPANDED_WIDTH/2) or (editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2)) - dragWindow.WIDTH/2
            and x < (editor.isExpanded and (editor.EXPANDED_X + editor.EXPANDED_WIDTH/2) or (editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2)) + dragWindow.WIDTH/2
            and y < editor.Y_TOP - dragWindow.TOP_INSET and y > editor.Y_TOP - editor.CODE_TOP_INSET then
                dragWindow.isDragging = true
                WSDebug.Mouse.leftButtonIsPressed = true
                dragWindow.mouseX = x
                dragWindow.mouseY = y
            else
                dragWindow.isDragging = false
            end

            local line, pos, xc = GetCursorPos(x, y)
            if xc then
                HideSelection()
                selection.hasSelection = false

                local diff = timeElapsed - WSDebug.Mouse.lastClick
                WSDebug.Mouse.lastClick = timeElapsed

                if diff < 0.35 and cursor.pos == pos and cursor.rawLine == line then
                    --Double click
                    local text = codeLines[currentTab][step[currentTab]][line + lineNumberOffset[currentTab]]
                    local char = sub(text, pos, pos)
                    if char == "" then
                        return
                    end

                    --Get bounds of token being selected
                    local first, last = pos, pos
                    if char:match("[\x25w_]") then
                        while sub(text, first, first):match("[\x25w_]") do
                            first = first - 1
                        end
                        while sub(text, last + 1, last + 1):match("[\x25w_]") do
                            last = last + 1
                        end
                    elseif char == " " then
                        while sub(text, first, first) == " " do
                            first = first - 1
                        end
                        while sub(text, last + 1, last + 1) == " " do
                            last = last + 1
                        end
                    else
                        while sub(text, first, first):match("[\x25w\x25s_]") == nil and first > 0 do
                            first = first - 1
                        end
                        while sub(text, last + 1, last + 1):match("[\x25w\x25s_]") == nil and last < #text do
                            last = last + 1
                        end
                    end

                    selection.startLine = cursor.adjustedLine
                    selection.endLine = cursor.adjustedLine
                    selection.startPos = first
                    selection.endPos = last
                    selection.hasSelection = true
                    selection.lines[cursor.rawLine] = GetTextHighlightFrame("09", 150, "selection")
                    BlzFrameSetPoint(selection.lines[cursor.rawLine], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(text, 1, first)), -editor.CODE_TOP_INSET - cursor.rawLine*editor.LINE_SPACING)
                    BlzFrameSetPoint(selection.lines[cursor.rawLine], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(text, 1, last)), -editor.CODE_TOP_INSET - (cursor.rawLine - 1)*editor.LINE_SPACING)

                    SetCursorPos(last)
                    SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.adjustedLine], 1, cursor.pos))

                    SearchForDuplicates()
                else
                    MoveCursor(pos, line, xc)
                    WSDebug.Mouse.leftButtonIsPressed = true
                end
            else
                if not (((editor.isExpanded and x >= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006
                and x <= editor.EXPANDED_X + editor.COLLAPSED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET + 0.006)
                or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006
                and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET + 0.006))
                and y <= editor.Y_TOP - editor.CODE_TOP_INSET and y >= editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING) then
                    DefocusCodeEditor()
                    BlzFrameSetFocus(searchBar.textField, false)
                end
            end
        else
            --Right-click over stop button.
            if (editor.isExpanded and x >= editor.EXPANDED_X + editor.STOP_BUTTON_HORIZONTAL_INSET
            and x <= editor.EXPANDED_X + editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING)
            or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.STOP_BUTTON_HORIZONTAL_INSET
            and x <= editor.COLLAPSED_X + editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING) then
                local lineNumber = math.floor(((editor.Y_TOP - editor.CODE_TOP_INSET) - y)/editor.LINE_SPACING) + 1

                if lineNumber >= 1 and lineNumber <= editor.MAX_LINES_ON_SCREEN then
                    PutStop(lineNumber + lineNumberOffset[currentTab], true)
                end

            --Right-click to open context menu.
            elseif (editor.isExpanded and x >= editor.EXPANDED_X + editor.CODE_LEFT_INSET
            and x <= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_RIGHT_INSET)
            or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.CODE_LEFT_INSET
            and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_RIGHT_INSET) then

                local line, pos, xc = GetCursorPos(x, y)
                if line >= 1 and line <= editor.MAX_LINES_ON_SCREEN then
                    if not selection.hasSelection then
                        MoveCursor(pos, line, xc)
                    end
                    BlzFrameSetVisible(contextMenu.parent, true)
                    BlzFrameSetEnable(contextMenu.copy, selection.hasSelection)
                    BlzFrameSetEnable(contextMenu.cut, selection.hasSelection)
                    BlzFrameSetEnable(contextMenu.expose, selection.hasSelection)
                    if selection.hasSelection then
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.copy, 0), "Copy")
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.cut, 0), "Cut")
                    else
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.copy, 0), "|cff999999Copy|r")
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.cut, 0), "|cff999999Cut|r")
                    end

                    local selectedText = sub(codeLines[currentTab][step[currentTab]][selection.startLine], math.min(selection.startPos + 1, selection.endPos), math.max(selection.startPos + 1, selection.endPos)):gsub("^\x25s*", ""):gsub("\x25s*$", "")

                    if selection.hasSelection and selection.startLine == selection.endLine then
                        if match(selectedText, "^[\x25w_]+$") ~= nil and match(sub(selectedText, 1, 1), "\x25d") == nil and not LUA_KEYWORDS[selectedText] then
                            BlzFrameSetEnable(contextMenu.gotodef, true)
                            BlzFrameSetText(BlzFrameGetChild(contextMenu.gotodef, 0), "Go to Definition")
                            BlzFrameSetEnable(contextMenu.expose, true)
                            BlzFrameSetText(BlzFrameGetChild(contextMenu.expose, 0), "Expose")
                        else
                            BlzFrameSetEnable(contextMenu.gotodef, false)
                            BlzFrameSetText(BlzFrameGetChild(contextMenu.gotodef, 0), "|cff999999Go to Definition|r")
                            BlzFrameSetEnable(contextMenu.expose, false)
                            BlzFrameSetText(BlzFrameGetChild(contextMenu.expose, 0), "|cff999999Expose|r")
                        end

                        BlzFrameSetEnable(contextMenu.assign, true)
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.assign, 0), "Assign")
                    else
                        BlzFrameSetEnable(contextMenu.assign, false)
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.assign, 0), "|cff999999Assign|r")
                    end

                    BlzFrameSetEnable(contextMenu.paste, clipboard ~= nil)
                    if clipboard ~= nil then
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.paste, 0), "Paste")
                    else
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.paste, 0), "|cff999999Paste|r")
                    end

                    contextMenu.minX = x
                    contextMenu.maxX = x + flagsMenu.WIDTH
                    BlzFrameClearAllPoints(contextMenu.parent)
                    if line < editor.MAX_LINES_ON_SCREEN/2 then
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_TOPLEFT, x, y)
                        BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 8*editor.LINE_SPACING)
                        contextMenu.minY = y - 2*flagsMenu.TEXT_INSET - 8*editor.LINE_SPACING
                        contextMenu.maxY = y
                    else
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_BOTTOMLEFT, x, y)
                        BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 8*editor.LINE_SPACING)
                        contextMenu.minY = y
                        contextMenu.maxY = y + 2*flagsMenu.TEXT_INSET + 8*editor.LINE_SPACING
                    end
                end
            end
        end
    end

    local function CheckForAutoCompleteSuggestions(str, rawLineNumber, showInDialogWindow, searchLocals, searchFileNames, separateByComma)
        local shift = 0

        str = str:gsub("\\", "\\\\")
        if separateByComma then
            local lastCommaPos = match(str, ".*(),")
            if lastCommaPos then
                local firstCharPos = lastCommaPos
                repeat
                    firstCharPos = firstCharPos + 1
                until firstCharPos ~= " "
                str = sub(str, firstCharPos + 1)
            end
        end

        local entered, lookupTable, prefix, hasDot
        if showInDialogWindow then
            entered = str
            if str == "" then
                BlzFrameSetVisible(helper.frame, false)
                return false
            end

            if searchFileNames then
                lookupTable = orderedFileNames
            else
                lookupTable = globalLookupTable
            end
        else
            if cursor.pos < #str then
                local i = cursor.pos
                while sub(str, i, i):match("[\x25w_]") do
                    i = i + 1
                    shift = shift + 1
                end
            end
            entered = match(sub(str, 1, cursor.pos), "([\x25w_\x25.:]+)$") --last word including dot or colon

            if entered == nil or #entered < 2 or find(str, "\x25-\x25-") or find(str, "[\x25w_]") == nil or find(str, "\x25.\x25.") ~= nil then
                BlzFrameSetVisible(helper.frame, false)
                return false
            end

            lookupTable = globalLookupTable
        end

        if lookupTable == globalLookupTable then
            --Check if in string.
            local num = 0
            for __ in str:gmatch("'") do
                num = num + 1
            end
            if math.fmod(num, 2) == 1 then
                BlzFrameSetVisible(helper.frame, false)
                return false
            end
            num = 0
            for __ in str:gmatch('"') do
                num = num + 1
            end
            if math.fmod(num, 2) == 1 then
                BlzFrameSetVisible(helper.frame, false)
                return false
            end

            hasDot = find(entered, "[\x25.:]") ~= nil

            prefix = ""
            for match in entered:gmatch("\x25s*([\x25w_]+)\x25s*[\x25.:]") do
                lookupTable = lookupTable[match]
                if type(lookupTable) ~= "table" then
                    BlzFrameSetVisible(helper.frame, false)
                    return false
                end
                prefix = prefix .. match .. "."
            end

            if hasDot then
                entered = entered:match("[\x25.:]\x25s*([\x25w_]+)\x25s*$") or "" --last table field after dots or colons
            end
        end

        local low, high = 1, #lookupTable
        while low <= high do
            local mid = math.floor((low + high) / 2)
            if sub(lookupTable[mid], 1, #entered) < entered then
                low = mid + 1
            else
                high = mid - 1
            end
        end

        while low <= #lookupTable and sub(lookupTable[low], 1, #entered) == entered do
            autoCompleteSuggestions[#autoCompleteSuggestions + 1] = lookupTable[low]
            low = low + 1
        end

        if searchLocals and not hasDot then
            low, high = 1, #localLookupTable
            while low <= high do
                local mid = math.floor((low + high) / 2)
                if sub(localLookupTable[mid], 1, #entered) < entered then
                    low = mid + 1
                else
                    high = mid - 1
                end
            end

            while low <= #localLookupTable and sub(localLookupTable[low], 1, #entered) == entered do
                autoCompleteSuggestions[#autoCompleteSuggestions + 1] = localLookupTable[low]
                low = low + 1
            end
        end

        if #autoCompleteSuggestions > 0 then
            table.sort(autoCompleteSuggestions)
            BlzFrameSetVisible(helper.frame, true)
            local first = true
            for i = 1, #concatTable do
                concatTable[i] = nil
            end
            for i = 1, #autoCompleteSuggestions do
                if not first then
                    concatTable = concatTable .. "\n"
                else
                    first = false
                end
                concatTable = ((((((((concatTable .. "|cffffcc00") .. prefix) .. "|r") .. "|cffffcc00") .. entered) .. "|r|cffaaaaaa") .. sub(autoCompleteSuggestions[i], #entered + 1)) .. "|r")
            end

            BlzFrameSetText(helper.text, table.concat(concatTable):gsub("\\\\", "\\"))
            BlzFrameSetSize(helper.text, 0, 0)
            BlzFrameSetSize(helper.frame, BlzFrameGetWidth(helper.text) + 0.009, BlzFrameGetHeight(helper.text) + 0.009)

            if showInDialogWindow then
                BlzFrameClearAllPoints(helper.frame)
                BlzFrameSetPoint(helper.frame, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOP, 0, 0)
            else
                local pos = cursor.pos + shift - #entered
                BlzFrameSetText(widthTestFrame, sub(str, 1, pos))
                BlzFrameSetSize(widthTestFrame, 0, 0)

                local x = math.min(editor.CODE_LEFT_INSET + BlzFrameGetWidth(widthTestFrame), (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) - BlzFrameGetWidth(helper.frame))
                if rawLineNumber < editor.MAX_LINES_ON_SCREEN/2 then
                    BlzFrameClearAllPoints(helper.frame)
                    BlzFrameSetPoint(helper.frame, FRAMEPOINT_TOPLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - rawLineNumber*editor.LINE_SPACING)
                else
                    BlzFrameClearAllPoints(helper.frame)
                    BlzFrameSetPoint(helper.frame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - (rawLineNumber-1)*editor.LINE_SPACING)
                end
            end

            for i = 1, #autoCompleteSuggestions do
                autoCompleteSuggestions[i] = nil
            end
            return true
        else
            BlzFrameSetVisible(helper.frame, false)
            return false
        end
    end

    local function CheckForFunctionPreviews(str, rawLineNumber, cursorpos)
        str = sub(str, 1, cursorpos)
        local currentLevel = select(2, str:gsub("\x25(", "")) - select(2, str:gsub("\x25)", "")) --opened parentheses
        local loopLevel = currentLevel
        local char
        if currentLevel > 0 then
            for i = #str, 1, -1 do
                char = sub(str, i, i)
                if char == "(" then
                    loopLevel = loopLevel - 1
                    if loopLevel < currentLevel then
                        local funcName = sub(str, 1, i):match("([\x25w_\x25.:]+)\x25s*\x25($") --var name before (
                        if FUNCTION_PREVIEW[funcName] then
                            BlzFrameSetVisible(helper.frame, true)
                            local numCommas = select(2, sub(str, i):gsub(",", ""))
                            for j = 1, #concatTable do
                                concatTable[j] = nil
                            end
                            local j = 0
                            concatTable = (((concatTable .. "|cffaaaaaafunction|r ") .. funcName) .. "(")
                            for argName in FUNCTION_PREVIEW[funcName]:gmatch("([\x25w_]+)\x25s*,") do
                                if j == numCommas then
                                    if j > 0 then
                                        concatTable = (((concatTable .. ", |cffffcc00") .. argName) .. "|r")
                                    else
                                        concatTable = (((concatTable .. "|cffffcc00") .. argName) .. "|r")
                                    end
                                else
                                    if j > 0 then
                                        concatTable = ((concatTable .. ", ") .. argName)
                                    else
                                        concatTable = concatTable .. argName
                                    end
                                end
                                j = j + 1
                            end

                            BlzFrameSetText(widthTestFrame, sub(str, 1, i))
                            BlzFrameSetSize(widthTestFrame, 0, 0)

                            BlzFrameSetText(helper.text, table.concat(concatTable .. ")"))
                            BlzFrameSetSize(helper.text, 0, 0)
                            BlzFrameSetSize(helper.frame, BlzFrameGetWidth(helper.text) + 0.009, BlzFrameGetHeight(helper.text) + 0.009)
                            local x = math.min(editor.CODE_LEFT_INSET + BlzFrameGetWidth(widthTestFrame), (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) - BlzFrameGetWidth(helper.frame))
                            BlzFrameClearAllPoints(helper.frame)
                            BlzFrameSetPoint(helper.frame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - (rawLineNumber-1)*editor.LINE_SPACING)
                            return true
                        end
                    end
                elseif char == ")" then
                    loopLevel = loopLevel + 1
                end
            end
        else
            BlzFrameSetVisible(helper.frame, false)
            return false
        end
    end

    local function CheckForVariableDisplay(line, pos, executionLine, xs)
        local text = codeLines[currentTab][step[currentTab]][line]
        local char = sub(text, pos, pos)
        if char == "" then
            return
        end

        local stringList = {}
        text = text:gsub('"[^"]*"', function(str)
            stringList[#stringList + 1] = str
            return "__STRING" .. #stringList
        end)
        text = text:gsub("'[^']*'", function(str)
            stringList[#stringList + 1] = str
            return "__STRING" .. #stringList
        end)

        local first, last = pos, pos
        if char:match("[\x25w_\x25.\x25[\x25]]") == nil then
            return
        end

        while sub(text, first, first):match("[\x25w_\x25.\x25[\x25]]") do
            first = first - 1
        end
        while sub(text, last + 1, last + 1):match("[\x25w_\x25.\x25[\x25]]") do
            last = last + 1
        end

        local token = sub(text, first + 1, last)
        local tableTrace = {}
        local beginning = 1
        local tableVar
        repeat
            pos = find(token, "[\x25.\x25[]", beginning)
            if pos then
                tableVar = sub(token, beginning, pos - 1)
            else
                tableVar = sub(token, beginning)
            end

            if beginning == 1 then
                local level = visibleVarsOfLine[currentTab][executionLine][tableVar]
                if level then
                    tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                elseif _G[tableVar] then
                    tableTrace[#tableTrace + 1] = _G[tableVar]
                else
                    return
                end
            elseif sub(tableVar, -1, -1) == "]" then
                tableVar = sub(tableVar, 1, -2)
                if tonumber(tableVar) then
                    tableTrace[#tableTrace + 1] = tonumber(tableVar)
                elseif sub(tableVar, 1, 1) == "'" or sub(tableVar, 1, 1) == '"' then
                    tableTrace[#tableTrace + 1] = sub(tableVar, 2, -2)
                else
                    local level = visibleVarsOfLine[currentTab][executionLine][tableVar]
                    if level then
                        tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                    elseif _G[tableVar] then
                        tableTrace[#tableTrace + 1] = _G[tableVar]
                    else
                        return
                    end
                end
            else
                tableTrace[#tableTrace + 1] = tableVar
            end
            if pos then
                beginning = pos + 1
            end
        until pos == nil

        for i = 1, #stringList do
            for j = 1, #tableTrace do
                if type(tableTrace[j]) == "string" then
                    tableTrace[j] = tableTrace[j]:gsub("__STRING" .. i, sub(stringList[i], 2, -2))
                end
            end
            token = token:gsub("__STRING" .. i, stringList[i])
        end

        local var = tableTrace[1]
        for i = 2, #tableTrace do
            if type(var) ~= "table" then
                return
            end
            var = var[tableTrace[i]]
        end

        local str = Value2String(var, nil, 1000)
        local dx = xs - (editor.isExpanded and editor.EXPANDED_X or editor.COLLAPSED_X)

        BlzFrameSetVisible(helper.frame, true)
        BlzFrameClearAllPoints(helper.frame)
        BlzFrameSetText(helper.text, token .. ": " .. str)
        BlzFrameSetSize(helper.text, 0, 0)
        BlzFrameSetSize(helper.frame, BlzFrameGetWidth(helper.text) + 0.009, BlzFrameGetHeight(helper.text) + 0.009)
        local xEnd = xs + BlzFrameGetWidth(helper.frame)
        if xEnd > 0.9333 then
            dx = dx - xEnd + 0.9333
        end
        BlzFrameSetPoint(helper.frame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, dx, -editor.CODE_TOP_INSET - (line - lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)

        isShowingVariableTooltip = true
    end

    local function LineOpensScope(whichLine)
        return find(whichLine, "\x25f[\x25a_]do\x25f[^\x25w_]")
        or find(whichLine, "\x25f[\x25a_]then\x25f[^\x25w_]")
        or find(whichLine, "\x25f[\x25a_]repeat\x25f[^\x25w_]")
        or find(whichLine, "\x25f[\x25a_]else\x25f[^\x25w_]")
        or find(whichLine, "\x25f[\x25a_]elseif\x25f[^\x25w_]")
        or find(whichLine, "[\x25(\x25[{]\x25s*$")
        or find(whichLine, "\x25f[\x25a_]function\x25f[^\x25w_]")
    end

    local function ConvertSelectionToLines()
        local lower = math.min(math.max(selection.startLine, selection.endLine), highestNonEmptyLine[currentTab][step[currentTab]])
        local upper = math.min(selection.startLine, selection.endLine)

        if lower < upper then
            return {}
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local left, right
        if lower == upper then
            left = math.min(selection.startPos, selection.endPos)
            right = math.max(selection.startPos, selection.endPos)
        else
            left = selection.startLine == upper and selection.startPos or selection.endPos
            right = selection.startLine == lower and selection.startPos or selection.endPos
        end

        local lines = {}

        if lower == upper then
            lines[1] = sub(currentLines[upper], left + 1, right)
        else
            lines[1] = sub(currentLines[upper], left + 1)
        end
        for i = upper + 1, lower do
            if i == lower then
                lines[#lines + 1] = sub(currentLines[lower], 1, right)
            else
                lines[#lines + 1] = currentLines[i]
            end
        end

        return lines
    end

    local function DeleteSelection()
        local lower = math.max(selection.startLine, selection.endLine)
        local upper = math.min(selection.startLine, selection.endLine)

        if not lower or not upper then
            return
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local left, right
        if lower == upper then
            left = math.min(selection.startPos, selection.endPos)
            right = math.max(selection.startPos, selection.endPos)
        else
            left = selection.startLine == upper and selection.startPos or selection.endPos
            right = selection.startLine == lower and selection.startPos or selection.endPos
        end

        currentLines[upper] = sub(currentLines[upper], 1, left) .. sub(currentLines[lower], right + 1)
        coloredCodeLines[currentTab][step[currentTab]][upper] = GetColoredText(currentLines[upper], upper, currentTab)

        local completeDeletes = lower - upper
        if completeDeletes > 0 then
            for i = upper + 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                currentLines[i] = currentLines[i + completeDeletes]
                coloredCodeLines[currentTab][step[currentTab]][i] = coloredCodeLines[currentTab][step[currentTab]][i + completeDeletes]
            end
            highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] - completeDeletes
            BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        end

        cursor.adjustedLine = upper
        cursor.rawLine = upper - lineNumberOffset[currentTab]
        SetCursorPos(upper == lower and left or upper == selection.startLine and selection.startPos or selection.endPos)
        SetCursorX(sub(currentLines[cursor.adjustedLine], 1, cursor.pos))

        lastKeyStroke = timeElapsed
        lineNumberOfEdit[currentTab][step[currentTab]] = upper
        posOfEdit[currentTab][step[currentTab]] = cursor.pos

        HideSelection()
        selection.hasSelection = false
        UpdateAllLines()
    end

    local function GetFirstDifferentCharPos(str1, str2, firstLook)
        local found
        firstLook = math.min(#str2, firstLook)
        for i = firstLook, math.max(#str1, #str2) do
            if sub(str1, i, i) ~= sub(str2, i, i) then
                return i, true
            end
        end
        if not found then
            for i = 1, firstLook - 1 do
                if sub(str1, i, i) ~= sub(str2, i, i) then
                    return i, true
                end
            end
        end
        return firstLook, false
    end

    local function ShiftLines(amount, firstLine)
        local currentLines = codeLines[currentTab][step[currentTab]]
        local currentColoredLines = coloredCodeLines[currentTab][step[currentTab]]

        if amount > 0 then
            for i = highestNonEmptyLine[currentTab][step[currentTab]] + amount, firstLine + amount, -1 do
                currentLines[i] = currentLines[i - amount]
                currentColoredLines[i] = currentColoredLines[i - amount]
                if lines.debugState[currentTab][i] ~= lines.debugState[currentTab][i - amount] then
                    lines.debugState[currentTab][i] = lines.debugState[currentTab][i - amount]
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i]], 0, true)
                end
            end
            for i = firstLine, firstLine + amount do
                lines.debugState[currentTab][i] = 0
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[0], 0, true)
            end
        else
            amount = -amount
            for i = firstLine + amount, highestNonEmptyLine[currentTab][step[currentTab]] + amount do
                currentLines[i - amount] = currentLines[i]
                currentColoredLines[i - amount] = currentColoredLines[i]
                if lines.debugState[currentTab][i - amount] ~= lines.debugState[currentTab][i] then
                    lines.debugState[currentTab][i - amount] = lines.debugState[currentTab][i]
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - amount - lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i - amount]], 0, true)
                end
            end
        end
    end

    local function ChangeCodeLine(text)
        local oldText = enterBoxText
        if text then
            enterBoxText = text
        else
            enterBoxText = BlzFrameGetText(enterBox)
            if oldText == enterBoxText then
                return
            end
        end

        BlzFrameSetEnable(buttons.undo, true)
        BlzFrameSetEnable(buttons.redo, false)
        BlzFrameSetVisible(highlights.currentLine, false)
        BlzFrameSetVisible(highlights.error, false)
        BlzFrameSetVisible(variableViewer.parent, false)
        editBoxFocused = true
        BlzFrameSetVisible(cursorFrame, true)
        lastViewedLineNumber[currentTab] = nil

        local quickImport = find(enterBoxText, "beginFile") ~= nil
        if quickImport then
            local fileName = match(enterBoxText, "Debug\x25.beginFile\x25s*\x25(?\x25s*[\"']([^\"']+)[\"']") or match(enterBoxText, "@beginFile\x25s*\"(.+)\"") or match(enterBoxText, "@beginFile\x25s*'(.+)'") or match(enterBoxText, "@beginFile\x25s*(.-)\x25s*\n")
            if fileName then
                if tabs.numbers[fileName] then
                    SwitchToTab(fileName)
                    IncrementStep()
                    local currentLines = codeLines[fileName][step[fileName]]
                    local currentColoredLines = coloredCodeLines[fileName][step[fileName]]
                    for i = 1, highestNonEmptyLine[fileName][step[fileName]] do
                        currentLines[i] = ""
                        currentColoredLines[i] = ""
                    end
                    highestNonEmptyLine[fileName][step[fileName]] = 0
                    SetLineOffset(0)
                else
                    AddTab(fileName)
                    SwitchToTab(fileName)
                end
                cursor.rawLine = 1
                cursor.adjustedLine = 1
            end
        end

        tabs.hasUncompiledChanges[currentTab] = true
        tabs.hasUnsavedChanges[currentTab] = true
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        else
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        end

        WSDebug.TabIsHalted[currentTab] = false
        tabs.hasError[currentTab] = false
        doNotUpdateVariables[currentTab] = false

        if timeElapsed - lastKeyStroke > editor.MIN_TIME_BETWEEN_UNDO_STEPS or cursor.adjustedLine ~= lastFrame or selection.hasSelection and not quickImport then
            IncrementStep()
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local selectionDeleted
        if selection.hasSelection and not quickImport then
            DeleteSelection()
            selectionDeleted = true
        end

        if #enterBoxText == 0 or #enterBoxText == #oldText - 1 or (editor.LEGAL_CHARACTERS and not editor.LEGAL_CHARACTERS[sub(oldText, -1,-1) or sub(oldText, -2, -1) == "  "] and #enterBoxText == #oldText - 2) then
            --Backspace
            if not selectionDeleted then
                if cursor.pos > 0 then
                    if sub(currentLines[cursor.adjustedLine], 1, cursor.pos):match("^\x25s*$") then
                        local oldCursorPos = cursor.pos
                        SetCursorPos(math.floor((cursor.pos - 1)/4)*4)
                        currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. sub(currentLines[cursor.adjustedLine], oldCursorPos + 1)
                    elseif brackets.lines[1] == cursor.adjustedLine and brackets.pos[1] == cursor.pos and brackets.lines[2] == cursor.adjustedLine and brackets.pos[2] == cursor.pos + 1 then
                        currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos - 1) .. sub(currentLines[cursor.adjustedLine], cursor.pos + 2)
                        SetCursorPos(cursor.pos - 1)
                    else
                        currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos - 1) .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                        SetCursorPos(cursor.pos - 1)
                    end
                --Backspace on empty line
                elseif cursor.adjustedLine > 1 then
                    SetCursorPos(#currentLines[cursor.adjustedLine - 1])
                    currentLines[cursor.adjustedLine - 1] = currentLines[cursor.adjustedLine - 1] .. currentLines[cursor.adjustedLine]
                    coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine - 1] = GetColoredText(currentLines[cursor.adjustedLine - 1], cursor.adjustedLine - 1, currentTab)
                    BlzFrameSetText(codeLineFrames[cursor.rawLine - 1], coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine - 1])
                    ShiftLines(-1, cursor.adjustedLine)

                    UpdateAllLines()

                    cursor.rawLine = cursor.rawLine - 1
                    cursor.adjustedLine = cursor.adjustedLine - 1

                    SetCursorX(sub(currentLines[cursor.adjustedLine], 1, cursor.pos))
                    BlzFrameSetAlpha(cursorFrame, 255)

                    if #enterBoxText == 0 or #enterBoxText == 255 then
                        enterBoxText = "          "
                        BlzFrameSetText(enterBox, "          ")
                    end

                    SetLocalList(cursor.adjustedLine)

                    return
                end
            end

            local found
            firstDifferentChar, found = GetFirstDifferentCharPos(enterBoxText, oldText, math.max(1, firstDifferentChar - 1))
            if found and firstDifferentChar == 1 then
                enterBoxText = "          "
                BlzFrameSetText(enterBox, "          ")
            end
        else
            --Entered char
            local found
            firstDifferentChar, found = GetFirstDifferentCharPos(enterBoxText, oldText, firstDifferentChar)
            if not found then
                if #enterBoxText == 0 or #enterBoxText == 255 then
                    enterBoxText = "          "
                    BlzFrameSetText(enterBox, "          ")
                end
                return
            end

            if editor.LEFT_ARROW_REPLACEMENT_CHAR and sub(enterBoxText, firstDifferentChar, firstDifferentChar + #editor.LEFT_ARROW_REPLACEMENT_CHAR - 1) == editor.LEFT_ARROW_REPLACEMENT_CHAR then
                SetCursorPos(math.max(cursor.pos - 1, 0))
            elseif editor.RIGHT_ARROW_REPLACEMENT_CHAR and sub(enterBoxText, firstDifferentChar, firstDifferentChar + #editor.RIGHT_ARROW_REPLACEMENT_CHAR - 1) == editor.RIGHT_ARROW_REPLACEMENT_CHAR then
                SetCursorPos(math.min(cursor.pos + 1, #currentLines[cursor.adjustedLine]))
            elseif editor.DELETE_REPLACEMENT_CHAR and sub(enterBoxText, firstDifferentChar, firstDifferentChar + #editor.DELETE_REPLACEMENT_CHAR - 1) == editor.DELETE_REPLACEMENT_CHAR then
                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. sub(currentLines[cursor.adjustedLine], cursor.pos + 2)
                coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine] = GetColoredText(currentLines[cursor.adjustedLine], cursor.adjustedLine, currentTab)
                SetCursorPos(cursor.pos)
            else
                local isTab = editor.TAB_REPLACEMENT_CHAR and sub(enterBoxText, firstDifferentChar, firstDifferentChar + #editor.TAB_REPLACEMENT_CHAR - 1) == editor.TAB_REPLACEMENT_CHAR
                local numChars = #enterBoxText - #oldText
                if numChars < 1 then
                    numChars = 1
                end

                local newText
                if isTab then
                    local numSpaces = math.floor((cursor.pos)/4)*4 - cursor.pos + 4
                    newText = ""
                    for __ = 1, numSpaces do
                        newText = newText .. " "
                    end
                elseif not text then
                    if firstDifferentChar == 1 then
                        newText = sub(enterBoxText, 1, numChars + 1)
                    else
                        newText = sub(enterBoxText, firstDifferentChar, firstDifferentChar + numChars - 1)
                    end
                else
                    newText = enterBoxText
                end

                if find(newText, "\n") then
                    --Copy & pasted code chunk
                    local newLines = ConvertStringToLines(newText)
                    for i = 1, #newLines do
                        newLines[i] = newLines[i]:gsub("\t", "    "):gsub("\n", ""):gsub("\r", "")
                    end

                    local newCodeSize = #newLines
                    ShiftLines(newCodeSize, cursor.adjustedLine)
                    highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] + newCodeSize

                    local remainingText = sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                    currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. newLines[1]
                    coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine] = GetColoredText(currentLines[cursor.adjustedLine], cursor.adjustedLine, currentTab)

                    local j = cursor.adjustedLine + 1
                    for i = 2, newCodeSize - 1 do
                        currentLines[j] = newLines[i]
                        coloredCodeLines[currentTab][step[currentTab]][j] = GetColoredText(currentLines[j], j, currentTab)
                        j = j + 1
                    end

                    currentLines[j] = newLines[newCodeSize] .. remainingText
                    coloredCodeLines[currentTab][step[currentTab]][j] = GetColoredText(currentLines[j], j, currentTab)

                    UpdateAllLines()

                    cursor.rawLine = j - lineNumberOffset[currentTab]
                    cursor.adjustedLine = j
                    SetCursorPos(#newLines[#newLines])
                    BlzFrameSetAlpha(cursorFrame, 255)

                    enterBoxText = "          "
                    BlzFrameSetText(enterBox, "          ")
                else
                    --Entered single line or character

                    if editor.LEGAL_CHARACTERS then
                        for i = 1, #newText do
                            if not editor.LEGAL_CHARACTERS[sub(newText, i, i)] and sub(newText, i, i) ~= "\n" then
                                PlayError()
                                enterBoxText = "          "
                                BlzFrameSetText(enterBox, "          ")
                                PrintForUser("|cffff5555Illegal character " .. sub(newText, i, i) .. ".|r")
                                return
                            end
                        end
                    end

                    if editor.AUTO_CLOSE_BRACKETS_AND_QUOTES then
                        local str = currentLines[cursor.adjustedLine]
                        --Do not enter character and simply move cursor forward if bracket is already closed.
                        if sub(str, cursor.pos + 1, cursor.pos + 1) == newText and
                        ((newText == ")" and select(2, str:gsub("\x25(", "")) - select(2, str:gsub("\x25)", "")) <= 0) or
                        (newText == "]" and select(2, str:gsub("\x25[", "")) - select(2, str:gsub("\x25]", "")) <= 0) or
                        (newText == "}" and select(2, str:gsub("{", "")) - select(2, str:gsub("}", "")) <= 0) or
                        (newText == '"' and math.fmod(select(2, str:gsub('[^\\]"', "")), 2) == 0) or
                        (newText == "'" and math.fmod(select(2, str:gsub("[^\\]'", "")), 2) == 0)) then
                            SetCursorPos(cursor.pos + 1)
                        else
                            currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. newText .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                            SetCursorPos(cursor.pos + #newText)
                            if newText == "(" then
                                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. ")" .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                                SearchForClosingBracket()
                            elseif newText == "[" and find(sub(str, 1, cursor.pos), "\x25-\x25-") == nil then
                                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. "]" .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                                SearchForClosingBracket()
                            elseif newText == "{" then
                                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. "}" .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                                SearchForClosingBracket()
                            elseif newText == '"' and math.fmod(select(2, str:gsub('[^\\]"', "")), 2) == 0 then --Only close string when not already in string.
                                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. '"' .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                            elseif newText == "'" and math.fmod(select(2, str:gsub("[^\\]'", "")), 2) == 0 then
                                currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. "'" .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                            end
                        end
                    else
                        currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos) .. newText .. sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
                        SetCursorPos(cursor.pos + #newText)
                    end
                end
            end
        end

        if #enterBoxText == 0 or #enterBoxText == 255 then
            enterBoxText = "          "
            BlzFrameSetText(enterBox, "          ")
        end

        if FUNCTION_PREVIEW then
            if not CheckForAutoCompleteSuggestions(currentLines[cursor.adjustedLine], cursor.rawLine, false, true, false) then
                CheckForFunctionPreviews(currentLines[cursor.adjustedLine], cursor.rawLine, cursor.pos)
            end
        end

        lastKeyStroke = timeElapsed
        lastFrame = cursor.adjustedLine

        if currentLines[cursor.adjustedLine]:match("^\x25s*nd$") then
            currentLines[cursor.adjustedLine] = currentLines[cursor.adjustedLine]:gsub("nd", "end")
            SetCursorPos(cursor.pos + 1)
        end

        --Auto-align on scope close.
        if cursor.pos == #currentLines[cursor.adjustedLine] and (currentLines[cursor.adjustedLine]:match("^\x25s*end") or currentLines[cursor.adjustedLine]:match("^\x25s*\x25}") or currentLines[cursor.adjustedLine]:match("^\x25s*\x25)") or currentLines[cursor.adjustedLine]:match("^\x25s*until") or currentLines[cursor.adjustedLine]:match("^\x25s*else")) then
            local numSpaces = 0
            local previousLine = currentLines[cursor.adjustedLine - 1]
            local i = 1
            while sub(previousLine, i, i) == " " do
                numSpaces = numSpaces + 1
                i = i + 1
            end
            if LineOpensScope(previousLine) then
                numSpaces = numSpaces + 4
            end
            numSpaces = math.max(0, numSpaces - 4)
            local whiteSpace = ""
            for i = 1, numSpaces do
                whiteSpace = whiteSpace .. " "
            end

            local length = #currentLines[cursor.adjustedLine]
            currentLines[cursor.adjustedLine] = whiteSpace .. currentLines[cursor.adjustedLine]:gsub("^\x25s*", "")
            SetCursorPos(cursor.pos - (length - #currentLines[cursor.adjustedLine]))
        end

        --Textmacros
        local replacedCode = HandleTextMacros(currentLines[cursor.adjustedLine])
        if replacedCode and replacedCode ~= currentLines[cursor.adjustedLine] then
            local lengthDiff = #replacedCode - #currentLines[cursor.adjustedLine]
            currentLines[cursor.adjustedLine] = replacedCode
            SetCursorPos(cursor.pos + lengthDiff)
        end

        --Adjust code scroller and window position on new line.
        highestNonEmptyLine[currentTab][step[currentTab]] = math.max(highestNonEmptyLine[currentTab][step[currentTab]], cursor.adjustedLine)
        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        SetLineOffset(lineNumberOffset[currentTab])
        JumpWindow(cursor.adjustedLine)

        coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine] = GetColoredText(currentLines[cursor.adjustedLine], cursor.adjustedLine, currentTab)

        --Set frame text.
        BlzFrameSetText(codeLineFrames[cursor.rawLine], coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine])

        SetCursorX(sub(currentLines[cursor.adjustedLine], 1, cursor.pos))
        BlzFrameSetAlpha(cursorFrame, 255)
    end

    local function Export()
        local currentLines = codeLines[currentTab][step[currentTab]]

        local hasCode = false
        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            if currentLines[i]:find("^\x25s*$") == nil then
                hasCode = true
            end
        end

        if not hasCode then
            return
        end

        if FileIO then
            local saveString = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                if currentLines[i]:match("^\x25s*$") ~= nil then
                    saveString = saveString .. "\n"
                else
                    saveString = saveString .. currentLines[i] .. "\n"
                end
            end

            FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. currentTab:gsub(" ", "") .. ".txt", table.concat(saveString))
        end

        PreloadGenClear()
        PreloadGenStart()

        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            if currentLines[i]:match("^\x25s*$") ~= nil then
                Preload(" ")
            else
                WriteToFile(currentLines[i]:gsub("\\\\", "\\"):gsub("||", "|"))
            end
        end

        PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeExport" .. currentTab:gsub(" ", "") .. ".txt")
    end

    local function AdjustLineDisplay()
        local newValue

        timeElapsed = timeElapsed + 0.01
        executionCount = 0

        for __, parent in pairs(doNotCheckStop) do
            for __, child in pairs(parent) do
                for childKey, __ in pairs(child) do
                    child[childKey] = nil
                end
            end
        end

        if not BlzFrameIsVisible(codeEditorParent) then
            return
        end

        if not WSDebug.TabIsHalted[currentTab] then
            BlzFrameSetVisible(highlights.currentLine, false)
        end

        if BlzFrameGetText(enterBox) ~= enterBoxText then
            ChangeCodeLine()
        end

        if #variableViewer.viewedVariableTrace > 0 and variableViewer.isViewingGlobal and not lastViewedLineNumber[currentTab] and not WSDebug.TabIsHalted[currentTab] then
            UpdateVariableViewer(lastLineNumber[currentTab])
        end

        if tabNavigator.hoveringOver then
            if not BlzFrameIsVisible(tabNavigator.highlights[tabNavigator.hoveringOver]) and not BlzFrameIsVisible(BlzFrameGetChild(tabNavigator.closeButtons[tabNavigator.hoveringOver], 2)) then
                BlzFrameSetVisible(tabNavigator.closeButtons[tabNavigator.hoveringOver], false)
                tabNavigator.hoveringOver = nil
            end
        else
            for i = 1, tabs.amount do
                if BlzFrameIsVisible(tabNavigator.highlights[tabs.names[i]]) then
                    tabNavigator.hoveringOver = tabs.names[i]
                    BlzFrameSetVisible(tabNavigator.closeButtons[tabNavigator.hoveringOver], true)
                    break
                end
            end
        end

        if not checkedForVariableDisplay and timeElapsed - WSDebug.Mouse.lastMove > 0.35 then
            local xs, ys = GetMouseScreenCoordinates(WSDebug.MouseX, WSDebug.MouseY)
            if xs < -0.1333 or xs > 0.93333 or ys < 0 or ys > 0.6 then
                xs, ys = mouseTargetFrameX or 0, mouseTargetFrameY or 0
            end
            local line, pos, xc = GetCursorPos(xs, ys)
            line = line + lineNumberOffset[currentTab]
            if xc and line and pos and pos < #codeLines[currentTab][step[currentTab]][line] then
                CheckForVariableDisplay(line, pos, lastViewedLineNumber[currentTab] or lastLineNumber[currentTab], xs)
            end
            checkedForVariableDisplay = true
        end

        cursorCounter = cursorCounter + 1
        if math.fmod(math.floor(cursorCounter/50), 2) == 0 then
            BlzFrameSetAlpha(cursorFrame, 255)
        else
            BlzFrameSetAlpha(cursorFrame, 0)
        end

        if timeElapsed - lastKeyStroke > editor.MIN_TIME_BETWEEN_UNDO_STEPS and tabs.hasUnsavedChanges[currentTab] then
            ConvertAndValidateLines(codeLines[currentTab][step[currentTab]], currentTab)
            tabs.hasUnsavedChanges[currentTab] = nil

            if tabs.hasUncompiledChanges[currentTab] then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[currentTab] .. "|r")
            end

            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                Export()
            end
        end

        newValue = highestNonEmptyLine[currentTab][step[currentTab]] - BlzFrameGetValue(codeScroller)
        if newValue ~= lineNumberOffset[currentTab] then
            if selection.hasSelection then
                HideSelection()
            end
            lineNumberOffset[currentTab] = newValue
            BlzFrameSetVisible(helper.frame, false)
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetText(codeLineFrames[i], coloredCodeLines[currentTab][step[currentTab]][i + lineNumberOffset[currentTab]])
                if lineNumberWasExecuted[currentTab][i + lineNumberOffset[currentTab]] then
                    BlzFrameSetText(lineNumbers[i], editor.LINE_NUMBER_COLOR .. math.tointeger(i + lineNumberOffset[currentTab]) .. "|r")
                else
                    BlzFrameSetText(lineNumbers[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + lineNumberOffset[currentTab]) .. "|r")
                end
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i + lineNumberOffset[currentTab]]], 0, true)
            end

            SetCurrentLine()

            if cursor.adjustedLine then
                cursor.rawLine = cursor.adjustedLine - lineNumberOffset[currentTab]
                BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + cursor.x, -editor.CODE_TOP_INSET - cursor.rawLine*editor.LINE_SPACING)
                BlzFrameSetVisible(cursorFrame, editBoxFocused and cursor.rawLine >= 1 and cursor.rawLine <= editor.MAX_LINES_ON_SCREEN)
            end

            if tabs.hasError[currentTab] then
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab]))
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab] - 1))
            end
            BlzFrameSetVisible(highlights.error, tabs.hasError[currentTab] and errorLineNumber[currentTab] - lineNumberOffset[currentTab] >= 1 and errorLineNumber[currentTab] - lineNumberOffset[currentTab] <= editor.MAX_LINES_ON_SCREEN)

            if selection.hasSelection then
                SetSelection(GetTextWidth(sub(codeLines[currentTab][step[currentTab]][selection.endLine], 1, selection.endPos)))
            end

            if selection.hasSelection and selection.startLine == selection.endLine then
                SearchForDuplicates()
            end

            if brackets.lines[1] then
                local rawLine = brackets.lines[1] - lineNumberOffset[currentTab]
                if rawLine >= 1 and rawLine <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[1], true)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[1]], 1, brackets.pos[1] - 1)), -editor.CODE_TOP_INSET - rawLine*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[1]], 1, brackets.pos[1])), -editor.CODE_TOP_INSET - (rawLine - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[1], false)
                end
                rawLine = brackets.lines[2] - lineNumberOffset[currentTab]
                if rawLine >= 1 and rawLine <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[2], true)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[2]], 1, brackets.pos[2] - 1)), -editor.CODE_TOP_INSET - rawLine*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[2]], 1, brackets.pos[2])), -editor.CODE_TOP_INSET - (rawLine - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[2], false)
                end
            end

            if BlzFrameIsVisible(searchBar.parent) then
                RenderSearchHighlights()
            end
        end
    end

    local function InsertCodeLine()
        BlzFrameSetFocus(enterBox, true)
        BlzFrameSetVisible(helper.frame, false)
        BlzFrameSetVisible(variableViewer.parent, false)

        IncrementStep()
        local currentLines = codeLines[currentTab][step[currentTab]]

        tabs.hasError[currentTab] = false
        doNotUpdateVariables[currentTab] = false
        tabs.hasUncompiledChanges[currentTab] = true
        tabs.hasUnsavedChanges[currentTab] = true
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        else
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        end

        local openTwoLines = brackets.IS_BRACKET[sub(currentLines[cursor.adjustedLine], cursor.pos, cursor.pos)] and brackets.CORRESPONDING_BRACKET[sub(currentLines[cursor.adjustedLine], cursor.pos, cursor.pos)] == sub(currentLines[cursor.adjustedLine], cursor.pos + 1, cursor.pos + 1)
        local shift = openTwoLines and 2 or 1

        ShiftLines(shift, cursor.adjustedLine + 1)

        currentLines[cursor.adjustedLine + shift] = sub(currentLines[cursor.adjustedLine], cursor.pos + 1)
        coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine + shift] = GetColoredText(currentLines[cursor.adjustedLine + shift], cursor.adjustedLine + shift, currentTab)
        currentLines[cursor.adjustedLine] = sub(currentLines[cursor.adjustedLine], 1, cursor.pos)
        coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine] = GetColoredText(currentLines[cursor.adjustedLine], cursor.adjustedLine, currentTab)

        if shift == 2 then
            currentLines[cursor.adjustedLine + 1] = ""
            coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine + 1] = ""
        end

        lines.debugState[currentTab][cursor.adjustedLine + shift] = 0
        BlzFrameSetTexture(BlzFrameGetChild(stopButtons[cursor.rawLine + shift], 0), "transparentmask.blp", 0, true)

        local lastLine = currentLines[cursor.adjustedLine]
        local __, numSpaces = find(lastLine, "^\x25s*")
        if LineOpensScope(lastLine) then
            numSpaces = numSpaces + 4
        end
        if currentLines[cursor.adjustedLine + 1]:match("^\x25s*end")
        or currentLines[cursor.adjustedLine + 1]:match("^\x25s*}")
        or currentLines[cursor.adjustedLine + 1]:match("^\x25s*\x25)")
        or currentLines[cursor.adjustedLine + 1]:match("^\x25s*until")
        or currentLines[cursor.adjustedLine + 1]:match("^\x25s*else") then
            numSpaces = math.max(0, numSpaces - 4)
        end

        cursor.rawLine = cursor.rawLine + 1
        cursor.adjustedLine = cursor.adjustedLine + 1
        SetCursorPos(numSpaces)

        highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] + shift
        for __ = 1, numSpaces do
            currentLines[cursor.adjustedLine] = " " .. currentLines[cursor.adjustedLine]
        end
        coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine] = GetColoredText(currentLines[cursor.adjustedLine], cursor.adjustedLine, currentTab)
        if shift == 2 then
            for __ = 1, numSpaces - 4 do
                currentLines[cursor.adjustedLine + 1] = " " .. currentLines[cursor.adjustedLine + 1]
            end
            coloredCodeLines[currentTab][step[currentTab]][cursor.adjustedLine + 1] = GetColoredText(currentLines[cursor.adjustedLine + 1], cursor.adjustedLine + 1, currentTab)
        end

        SetCursorX(sub(currentLines[cursor.adjustedLine], 1, cursor.pos))

        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])

        SetLineOffset(lineNumberOffset[currentTab])
        if not JumpWindow(cursor.adjustedLine) then
            UpdateAllLines()
        end

        SetLocalList(cursor.adjustedLine)
    end

    --======================================================================================================================
    --Variable Viewer
    --======================================================================================================================

    Value2String = function(object, tableKey, maxLength, showFourCC)
        local returnstr
        if object == WSDebug.Nil then
            returnstr =  "nil"
        elseif type(object) == "boolean" or object == nil then
            returnstr =  tostring(object)
        elseif type(object) == "number" then
            if showFourCC and type(object) == "number" and math.type(object) == "integer" and object >= 808464432 then
                returnstr = object .. " ('" .. string.pack(">I4", object) .. "')"
            else
                returnstr =  tostring(object)
            end
        elseif type(object) == "string" then
            object = object:gsub("|", "||")
            if tableKey and not tonumber(object) then
                returnstr = sub(object, 1, maxLength)
            else
                returnstr =  '"' .. sub(object, 1, maxLength - 2) .. '"'
            end
        elseif IsHandle[object] then
            if IsWidget[object] then
                if HandleType[object] == "unit" then
                    local str = string.gsub(tostring(object), "unit: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetUnitName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                elseif HandleType[object] == "destructable" then
                    local str = string.gsub(tostring(object), "destructable: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetDestructableName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                else
                    local str = string.gsub(tostring(object), "item: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetItemName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                end
            else
                local str = tostring(object)
                local address = sub(str, (find(str, ":", nil, true) or 0) + 2, str:len())
                returnstr =  HandleType[object] .. (sub(address, 1,1) == "0" and (": " .. sub(address, address:len() - 3, address:len())) or (": " .. address))
            end
        elseif type(object) == "table" and rawget(object, "__name") then
            local str = string.gsub(tostring(object), object.__name .. ": ", "")
            str = string.sub(str, #str - 3, #str)
            returnstr =  object.__name .. " " .. str
        else
            local str = tostring(object)
            local colonPos = find(str, ":")
            if sub(str, colonPos + 2, colonPos + 2) == "0" then
                returnstr =  sub(str, 1, colonPos) .. " " .. sub(str, #str - 3, #str)
            else
                returnstr =  str
            end
        end
        if tableKey and type(object) ~= "string" then
            return "[" .. sub(returnstr, 1, maxLength - 2) .. "]"
        else
            return sub(returnstr, 1, maxLength)
        end
    end

    local function PadNumber(num)
        local tonum = tonumber(num)
        if tonum and tonum < math.maxinteger and tonum > math.mininteger then
            return ("\x2509d"):format(tonum)
        else
            return num
        end
    end

    local function NaturalSort(a, b)
        local aPad = a:gsub("(\x25d+)", PadNumber)
        local bPad = b:gsub("(\x25d+)", PadNumber)

        return aPad < bPad
    end

    local function SortTableKeys(a, b)
        local typeA, typeB = type(a), type(b)
        if typeA == typeB then
            return NaturalSort(tostring(a), tostring(b))
        elseif typeA == "number" or typeB == "number" then
            return typeA == "number"
        else
            return typeA < typeB
        end
    end

    local function ViewVariable()
        local frame = BlzGetTriggerFrame()
        BlzFrameSetEnable(frame, false)
        BlzFrameSetEnable(frame, true)

        local whichVar = variableViewer.nameFromFrame[frame]
        local inRoot = #variableViewer.viewedVariableTrace == 0

        if inRoot then
            variableViewer.isViewingGlobal = false
            for __, name in ipairs(variableViewer.viewedGlobals) do
                if name == whichVar then
                    variableViewer.isViewingGlobal = true
                    break
                end
            end
            if variableViewer.isViewingGlobal then
                variableViewer.viewedVariable = whichVar
                variableViewer.viewedVariableTrace[1] = whichVar
                variableViewer.viewedValueTrace[1] = _G[whichVar]
            else
                local level = visibleVarsOfLine[currentTab][lastViewedLineNumber[currentTab] or lastLineNumber[currentTab]][whichVar]
                variableViewer.viewedVariable = whichVar
                variableViewer.viewedVariableTrace[1] = whichVar
                variableViewer.viewedValueTrace[1] = WSDebug.VarTable[currentTab][level][whichVar]
            end
        elseif whichVar == "__metatable" then
            variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = whichVar
            variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = getmetatable(variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace])
        else
            variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = whichVar
            variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace][whichVar]
        end
        local linkedObject = variableViewer.linkedObject[frame]
        if linkedObject then
            if FCL_Anchor then
                anchor = FCL_Anchor[GetLocalPlayer()]
            end
            local x, y
            if IsWidget[linkedObject] then
                x, y = GetWidgetX(linkedObject), GetWidgetY(linkedObject)
            elseif HandleType[linkedObject] == "rect" then
                x, y = GetRectCenterX(linkedObject), GetRectCenterY(linkedObject)
            elseif HandleType[linkedObject] == "location" then
                x, y = GetLocationX(linkedObject), GetLocationY(linkedObject)
            elseif type(linkedObject) == "table" then
                if type(rawget(linkedObject, "x")) == "number" and type(rawget(linkedObject, "y")) == "number" then
                    x, y = rawget(linkedObject, "x"), rawget(linkedObject, "y")
                elseif type(rawget(linkedObject, "minX")) == "number" and type(rawget(linkedObject, "minY")) == "number" and type(rawget(linkedObject, "maxX")) == "number" and type(rawget(linkedObject, "maxY")) == "number" then
                    x, y = (rawget(linkedObject, "minX") + rawget(linkedObject, "maxX"))/2, (rawget(linkedObject, "minY") + rawget(linkedObject, "maxY"))/2
                end
            end
            if x and y then
                SetCameraPosition(x, y)
            end
        end
        UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
    end

    local function ViewFunctionParam()
        local frame = BlzGetTriggerFrame()
        local whichParam = indexFromFrame[frame]

        variableViewer.viewedVariable = "Function Parameter " .. whichParam
        variableViewer.viewedVariableTrace[1] = "Function Parameter " .. whichParam
        if lastViewedFunctionCall[currentTab] then
            variableViewer.viewedValueTrace[1] = viewedFunctionParams[currentTab][whichParam]
        else
            variableViewer.viewedValueTrace[1] = functionParams[currentTab][whichParam]
        end

        variableViewer.isViewingParams = true
        UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])

        if variableViewer.viewedValueTrace[1] and IsWidget[variableViewer.viewedValueTrace[1]] then
            if FCL_Anchor then
                anchor = FCL_Anchor[GetLocalPlayer()]
            end
            SetCameraPosition(GetWidgetX(variableViewer.viewedValueTrace[1]), GetWidgetY(variableViewer.viewedValueTrace[1]))
        end
    end

    UpdateVariableViewer = function(lineNumber)
        if not codeEditorParent then
            return
        end

        if variableViewer.hasNotBeenExpanded and not variableViewer.isExpanded then
            ToggleVariableViewerExpand()
        end

        local varNames = {}
        local varValues = {}

        local inRoot = #variableViewer.viewedVariableTrace == 0
        local lastVariable, lastValue
        local numHiddenVars = 0

        BlzFrameSetVisible(variableViewer.parent, true)

        local oldNumVisible = numVisibleVars
        local isAlreadyViewed
        if inRoot then
            numVisibleVars = #variableViewer.viewedGlobals
            variableViewer.isViewingParams = nil
            local visibleVars = visibleVarsOfLine[currentTab][lineNumber]
            for var, level in pairs(visibleVars) do
                if (not flags.hideConstants or #var == 1 or find(var, "\x25l")) and (not flags.hideGlobals or level ~= -1) and (not flags.hideFunctions or type(WSDebug.VarTable[currentTab][level][var]) ~= "function") then
                    varNames[#varNames + 1] = var
                    if level == -1 then
                        WSDebug.VarTable[currentTab][level][var] = _G[var]
                        isAlreadyViewed = false
                        for i = 1, #variableViewer.viewedGlobals do
                            if variableViewer.viewedGlobals[i] == var then
                                isAlreadyViewed = true
                                break
                            end
                        end
                        if not isAlreadyViewed then
                            varValues[var] = WSDebug.VarTable[currentTab][level][var]
                            varLevelExecution[currentTab][var] = level
                            numVisibleVars = numVisibleVars + 1
                        end
                    else
                        varValues[var] = WSDebug.VarTable[currentTab][level][var]
                        varLevelExecution[currentTab][var] = level
                        numVisibleVars = numVisibleVars + 1
                    end
                else
                    numHiddenVars = numHiddenVars + 1
                end
            end
            table.sort(varNames, NaturalSort)
        else
            lastVariable = variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace]
            if #variableViewer.viewedVariableTrace == 1 then
                local level = visibleVarsOfLine[currentTab][lineNumber][lastVariable]
                lastValue = level and WSDebug.VarTable[currentTab][level][lastVariable] or variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
            else
                lastValue = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
            end

            numVisibleVars = 0
            local viewedVariableIsVisible = variableViewer.isViewingParams or variableViewer.isViewingGlobal
            if not viewedVariableIsVisible then
                for var, __ in pairs(visibleVarsOfLine[currentTab][lineNumber]) do
                    if var == variableViewer.viewedVariable then
                        viewedVariableIsVisible = true
                        break
                    end
                end
            end
            if viewedVariableIsVisible then
                if type(lastValue) == "table" then
                    if lastValue == WSDebug.Nil then
                        varNames[1] = "nil"
                        numVisibleVars = 1
                    else
                        for var, value in pairs(lastValue) do
                            varNames[#varNames + 1] = var
                            varValues[var] = value
                            numVisibleVars = numVisibleVars + 1
                        end

                        local mt = getmetatable(lastValue)
                        if mt then
                            numVisibleVars = numVisibleVars + 1
                            varNames[#varNames + 1] = "__metatable"
                            varValues.__metatable = mt
                        end

                        if numVisibleVars == 0 then
                            varNames[1] = "|cffaaaaaaEmpty Table|r"
                            numVisibleVars = 1
                        else
                            table.sort(varNames, SortTableKeys)
                        end
                    end
                else
                    numVisibleVars = 1
                    varNames[1] = lastVariable
                    varValues[1] = lastValue
                end
            else
                numVisibleVars = 0
            end
        end

        numVisibleVars = math.min(editor.MAX_LINES_ON_SCREEN, numVisibleVars)

        if not variableViewer.isExpanded then
            return
        end

        for i = numVisibleVars + 1, oldNumVisible do
            BlzFrameSetVisible(variableViewer.frames[i], false)
            BlzFrameSetVisible(variableViewer.valueFrames[i], false)
        end

        BlzFrameSetVisible(buttons.back, not inRoot)

        local scale = variableViewer.TEXT_SCALE
        for i = oldNumVisible + 1, numVisibleVars do
            if not variableViewer.frames[i] then
                variableViewer.frames[i] = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
                BlzFrameSetPoint(variableViewer.frames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - i*editor.LINE_SPACING)/scale)
                BlzFrameSetPoint(variableViewer.frames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
                BlzFrameSetScale(variableViewer.frames[i], scale)
                BlzFrameSetTextAlignment(variableViewer.frames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                indexFromFrame[variableViewer.frames[i]] = i
                BlzFrameSetEnable(variableViewer.frames[i], false)

                variableViewer.valueFrames[i] = BlzCreateFrame("VariableViewerButton", variableViewer.parent, 0, 0)
                variableViewer.textFrames[variableViewer.valueFrames[i]] = BlzFrameGetChild(variableViewer.valueFrames[i], 0)
                BlzFrameSetEnable(variableViewer.textFrames[variableViewer.valueFrames[i]], false)
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - i*editor.LINE_SPACING)/scale)
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
                BlzFrameSetScale(variableViewer.valueFrames[i], scale)
                BlzFrameSetTextAlignment(variableViewer.textFrames[variableViewer.valueFrames[i]], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_RIGHT)
                BlzFrameSetAllPoints(variableViewer.textFrames[variableViewer.valueFrames[i]], variableViewer.valueFrames[i])
                indexFromFrame[variableViewer.valueFrames[i]] = i

                local trig = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trig, variableViewer.valueFrames[i], FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trig, ViewVariable)
            else
                BlzFrameSetVisible(variableViewer.frames[i], true)
                BlzFrameSetVisible(variableViewer.valueFrames[i], true)
            end
        end

        BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + variableViewer.LINE_VERTICAL_INSET + variableViewer.BOTTOM_SPACE + math.max(numVisibleVars - 1, 0)*editor.LINE_SPACING)

        local object
        if inRoot then
            local j
            for i = 1, math.min(#varNames + #variableViewer.viewedGlobals, editor.MAX_LINES_ON_SCREEN) do
                j = i - #variableViewer.viewedGlobals
                if j <= 0 then
                    BlzFrameSetText(variableViewer.frames[i], variableViewer.GLOBAL_COLOR .. variableViewer.viewedGlobals[i]:sub(1, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i]], variableViewer.GLOBAL_COLOR .. Value2String(_G[variableViewer.viewedGlobals[i]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH))
                    BlzFrameSetEnable(variableViewer.valueFrames[i], true)
                    variableViewer.nameFromFrame[variableViewer.valueFrames[i]] = variableViewer.viewedGlobals[i]
                    object = _G[variableViewer.viewedGlobals[i]]
                    if object and (IsWidget[object] or HandleType[object] == "rect" or HandleType[object] == "location"
                    or (type(object) == "table" and ((rawget(object, "x") and rawget(object, "y")) or (rawget(object, "minX") and rawget(object, "minY") and rawget(object, "maxX") and rawget(object, "maxY"))))) then
                        variableViewer.linkedObject[variableViewer.valueFrames[i]] = object
                    else
                        variableViewer.linkedObject[variableViewer.valueFrames[i]] = nil
                    end
                else
                    BlzFrameSetText(variableViewer.frames[i], (varLevelExecution[currentTab][varNames[j]] == -1 and variableViewer.GLOBAL_COLOR or variableViewer.LOCAL_COLOR) .. varNames[j]:sub(1, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i]], (varLevelExecution[currentTab][varNames[j]] == -1 and variableViewer.GLOBAL_COLOR or variableViewer.LOCAL_COLOR) .. Value2String(varValues[varNames[j]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH))
                    BlzFrameSetEnable(variableViewer.valueFrames[i], true)
                    variableViewer.nameFromFrame[variableViewer.valueFrames[i]] = varNames[j]
                    object = varValues[varNames[j]]
                    if object and (IsWidget[object] or HandleType[object] == "rect" or HandleType[object] == "location"
                    or (type(object) == "table" and ((rawget(object, "x") and rawget(object, "y")) or (rawget(object, "minX") and rawget(object, "minY") and rawget(object, "maxX") and rawget(object, "maxY"))))) then
                        variableViewer.linkedObject[variableViewer.valueFrames[i]] = object
                    else
                        variableViewer.linkedObject[variableViewer.valueFrames[i]] = nil
                    end
                end
            end

            if numHiddenVars == 0 then
                BlzFrameSetText(variableViewer.title, "|cffffcc00Variables|r")
            else
                BlzFrameSetText(variableViewer.title, "|cffffcc00Variables|r |cffaaaaaa(" .. numHiddenVars .. " hidden)")
            end
        elseif type(lastValue) == "table" then
            for i = 1, math.min(#varNames, editor.MAX_LINES_ON_SCREEN) do
                if varNames[i] == "|cffaaaaaaEmpty Table|r" or varNames[i] == "nil" then
                    BlzFrameSetText(variableViewer.frames[i], varNames[i])
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i]], "")
                    BlzFrameSetEnable(variableViewer.valueFrames[i], false)
                else
                    BlzFrameSetText(variableViewer.frames[i], variableViewer.LOCAL_COLOR .. Value2String(varNames[i], true, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i]], variableViewer.LOCAL_COLOR .. Value2String(varValues[varNames[i]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetEnable(variableViewer.valueFrames[i], true)
                end
                variableViewer.nameFromFrame[variableViewer.valueFrames[i]] = varNames[i]
                object = varValues[varNames[i]]
                if object and (IsWidget[object] or HandleType[object] == "rect" or HandleType[object] == "location"
                or (type(object) == "table" and ((rawget(object, "x") and rawget(object, "y")) or (rawget(object, "minX") and rawget(object, "minY") and rawget(object, "maxX") and rawget(object, "maxY"))))) then
                    variableViewer.linkedObject[variableViewer.valueFrames[i]] = object
                else
                    variableViewer.linkedObject[variableViewer.valueFrames[i]] = nil
                end
            end

            BlzFrameSetText(variableViewer.title, "|cffffcc00" .. tostring(lastVariable) .. "|r")
        else
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], "")
            BlzFrameSetText(variableViewer.frames[1], Debug and Debug.original.tostring(varValues[1]) or tostring(varValues[1]))
            BlzFrameSetEnable(variableViewer.valueFrames[1], false)

            BlzFrameClearAllPoints(variableViewer.frames[1])
            BlzFrameSetPoint(variableViewer.frames[1], FRAMEPOINT_TOPLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, -variableViewer.LINE_VERTICAL_INSET/scale)
            BlzFrameSetSize(variableViewer.frames[1], variableViewer.WIDTH - 2*variableViewer.LINE_HORIZONTAL_INSET, 0)
            BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, BlzFrameGetHeight(variableViewer.frames[1]) + variableViewer.LINE_VERTICAL_INSET + variableViewer.BOTTOM_SPACE)

            BlzFrameSetText(variableViewer.title, "|cffffcc00" .. tostring(lastVariable) .. "|r")
        end

        if inRoot and (lastViewedFunctionCall[currentTab] or lastFunctionCall[currentTab]) then
            BlzFrameSetPoint(variableViewer.functionFrames[1], FRAMEPOINT_TOPLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - numVisibleVars*editor.LINE_SPACING - variableViewer.FUNCTION_CALL_SPACING)/scale)

            BlzFrameSetText(variableViewer.functionFrames[2], editor.NATIVE_COLOR .. (lastViewedFunctionCall[currentTab] or lastFunctionCall[currentTab]) .. "|r(")
            BlzFrameSetSize(variableViewer.functionFrames[2], 0, 0)

            local params
            if lastViewedFunctionCall[currentTab] then
                params = viewedFunctionParams[currentTab]
            else
                params = functionParams[currentTab]
            end
            for i = 1, #params do
                if not variableViewer.functionParamFrames[i] then
                    variableViewer.functionParamFrames[i] = BlzCreateFrame("VariableViewerButton", variableViewer.parent, 0, 0)
                    variableViewer.functionTextFrames[i] = BlzFrameGetChild(variableViewer.functionParamFrames[i], 0)
                    BlzFrameSetEnable(variableViewer.functionTextFrames[i], false)
                    if i == 1 then
                        BlzFrameSetPoint(variableViewer.functionParamFrames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.functionFrames[2], FRAMEPOINT_BOTTOMLEFT, 0, -editor.LINE_SPACING/scale)
                        BlzFrameSetPoint(variableViewer.functionParamFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.functionFrames[2], FRAMEPOINT_TOPLEFT, (variableViewer.WIDTH - 2*variableViewer.LINE_HORIZONTAL_INSET)/scale, -editor.LINE_SPACING/scale)
                    else
                        BlzFrameSetPoint(variableViewer.functionParamFrames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.functionParamFrames[i - 1], FRAMEPOINT_BOTTOMLEFT, 0, -editor.LINE_SPACING/scale)
                        BlzFrameSetPoint(variableViewer.functionParamFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.functionParamFrames[i - 1], FRAMEPOINT_TOPRIGHT, 0, -editor.LINE_SPACING/scale)
                    end
                    BlzFrameSetScale(variableViewer.functionParamFrames[i], scale)
                    BlzFrameSetTextAlignment(variableViewer.functionTextFrames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                    BlzFrameSetAllPoints(variableViewer.functionTextFrames[i], variableViewer.functionParamFrames[i])
                    indexFromFrame[variableViewer.functionParamFrames[i]] = i

                    local trig = CreateTrigger()
                    BlzTriggerRegisterFrameEvent(trig, variableViewer.functionParamFrames[i], FRAMEEVENT_CONTROL_CLICK)
                    TriggerAddAction(trig, ViewFunctionParam)
                else
                    BlzFrameSetVisible(variableViewer.functionParamFrames[i], true)
                end
                if i < #params then
                    BlzFrameSetText(variableViewer.functionTextFrames[i], "    " .. Value2String(params[i], false, variableViewer.FUNCTION_PARAM_MAX_STRING_LENGTH, true) .. ",")
                else
                    BlzFrameSetText(variableViewer.functionTextFrames[i], "    " .. Value2String(params[i], false, variableViewer.FUNCTION_PARAM_MAX_STRING_LENGTH, true))
                end

                BlzFrameSetPoint(variableViewer.functionFrames[3], FRAMEPOINT_TOPLEFT, variableViewer.functionParamFrames[#params], FRAMEPOINT_TOPLEFT, 0, -editor.LINE_SPACING/scale)
            end

            if #params == 0 then
                BlzFrameSetPoint(variableViewer.functionFrames[3], FRAMEPOINT_TOPLEFT, variableViewer.functionFrames[2], FRAMEPOINT_TOPLEFT, 0, -editor.LINE_SPACING/scale)
            end

            for i = 1, #variableViewer.functionFrames do
                BlzFrameSetVisible(variableViewer.functionFrames[i], true)
            end
            for i = #params + 1, #variableViewer.functionParamFrames do
                BlzFrameSetVisible(variableViewer.functionParamFrames[i], false)
            end

            BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, variableViewer.LINE_VERTICAL_INSET + variableViewer.BOTTOM_SPACE + numVisibleVars*editor.LINE_SPACING + 2*variableViewer.FUNCTION_CALL_SPACING + (#params + 3)*editor.LINE_SPACING)
        else
            for i = 1, #variableViewer.functionFrames do
                BlzFrameSetVisible(variableViewer.functionFrames[i], false)
            end
            for i = 1, #variableViewer.functionParamFrames do
                BlzFrameSetVisible(variableViewer.functionParamFrames[i], false)
            end
        end
    end

    local function GoBack()
        BlzFrameSetEnable(buttons.back, false)
        BlzFrameSetEnable(buttons.back, true)
        variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace] = nil
        variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace] = nil
        UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
        if anchor then
            FCL_Lock(anchor)
        end

        local s = CreateSound("Sound\\Interface\\BigButtonClick.flac" , false, false, false, 10, 10, "DefaultEAXON")
        SetSoundChannel(s, 0)
        StartSound(s)
        KillSoundWhenDone(s)
    end

    --======================================================================================================================
    --Tab Navigation
    --======================================================================================================================

    SwitchToTab = function(whichTab)
        whichTab = type(whichTab) == "number" and tabs.names[whichTab] or whichTab

        if not tabNavigator.frames[whichTab] then
            return
        end

        if selection.hasSelection then
            HideSelection()
        end

        BlzFrameSetAlpha(tabNavigator.highlights[currentTab], 255)
        local color = tabs.wasNotCompiledInDebugMode[currentTab] and editor.TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR or editor.TAB_NAVIGATOR_UNSELECTED_COLOR
        local prefix = tabs.hasUncompiledChanges[currentTab] and "*" or ""
        BlzFrameSetText(tabNavigator.titles[currentTab], color .. prefix .. tabs.truncatedNames[currentTab] .. "|r")
        if tabs.hasUnsavedChanges[currentTab] and editor.ENABLE_SAVE_AND_LOAD and FileIO then
            Export()
        end

        local oldTab = currentTab
        currentTab = whichTab
        color = tabs.wasNotCompiledInDebugMode[currentTab] and editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR or editor.TAB_NAVIGATOR_SELECTED_COLOR
        prefix = tabs.hasUncompiledChanges[currentTab] and "*" or ""
        BlzFrameSetText(tabNavigator.titles[currentTab], color .. prefix .. tabs.truncatedNames[currentTab] .. "|r")

        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        SetLineOffset(lineNumberOffset[currentTab])

        UpdateAllLines()
        if BlzFrameIsVisible(searchBar.parent) then
            FindSearchItems()
            RenderSearchHighlights()
        end

        BlzFrameSetEnable(buttons.redo, step[currentTab] < maxRedo[currentTab])
        BlzFrameSetEnable(buttons.undo, step[currentTab] > 1)

        if WSDebug.TabIsHalted[whichTab] then
            BlzFrameSetVisible(highlights.currentLine, true)
            SetCurrentLine()
        else
            BlzFrameSetVisible(highlights.currentLine, false)
        end

        if tabs.hasError[currentTab] then
            BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab]))
            BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab] - 1))
        end
        BlzFrameSetVisible(highlights.error, tabs.hasError[currentTab] and errorLineNumber[currentTab] - lineNumberOffset[currentTab] >= 1 and errorLineNumber[currentTab] - lineNumberOffset[currentTab] <= editor.MAX_LINES_ON_SCREEN)

        for i = 1, editor.MAX_LINES_ON_SCREEN do
            if lineNumberWasExecuted[currentTab][i + lineNumberOffset[currentTab]] then
                BlzFrameSetText(lineNumbers[i], editor.LINE_NUMBER_COLOR .. math.tointeger(i + lineNumberOffset[currentTab]) .. "|r")
            else
                BlzFrameSetText(lineNumbers[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + lineNumberOffset[currentTab]) .. "|r")
            end
            if lines.debugState[currentTab][i + lineNumberOffset[currentTab]] ~= lines.debugState[oldTab][i + lineNumberOffset[oldTab]] then
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i + lineNumberOffset[currentTab]]], 0, true)
            end
        end

        BlzFrameSetVisible(variableViewer.parent, not tabs.wasNotCompiledInDebugMode[currentTab] and not tabs.hasUncompiledChanges[currentTab])
        if variableViewer.isExpanded then
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
        end
    end

    local function ClickTabButton()
        local whichFrame = BlzGetTriggerFrame()
        BlzFrameSetEnable(whichFrame, false)
        BlzFrameSetEnable(whichFrame, true)
        if tabs.numberFromFrame[whichFrame] ~= tabs.numbers[currentTab] then
            SwitchToTab(tabs.numberFromFrame[whichFrame])
        end
    end

    local function AdjustTabWidths()
        local spaceRequired = 0
        for i = 1, tabs.amount do
            spaceRequired = spaceRequired + tabNavigator.widths[tabs.names[i]]
        end

        local spaceAlloted = (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) + tabs.amount*tabNavigator.OVERLAP - tabNavigator.HEIGHT
        if spaceRequired > spaceAlloted then
            for i = 1, tabs.amount do
                BlzFrameSetSize(tabNavigator.frames[tabs.names[i]], tabNavigator.widths[tabs.names[i]]*spaceAlloted/spaceRequired, tabNavigator.HEIGHT)
                if tabNavigator.widths[tabs.names[i]] > tabNavigator.WIDTH then
                    BlzFrameSetScale(tabNavigator.titles[tabs.names[i]], spaceAlloted/spaceRequired)
                else
                    BlzFrameSetScale(tabNavigator.titles[tabs.names[i]], 1)
                end
            end
        end
    end

    AddTab = function(tabName)
        tabs.amount = tabs.amount + 1

        tabs.names[tabs.amount] = tabName
        tabs.truncatedNames[tabName] = find(tabName, "\\\\") ~= nil and sub(tabName, match(tabName, ".*()\\\\") + 2, nil) or tabName

        tabNavigator.frames[tabName] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
        tabNavigator.titles[tabName] = BlzFrameGetChild(tabNavigator.frames[tabName], 2)
        tabNavigator.highlights[tabName] = BlzFrameGetChild(tabNavigator.frames[tabName], 3)
        BlzFrameSetText(tabNavigator.titles[tabName], editor.TAB_NAVIGATOR_UNSELECTED_COLOR .. tabs.truncatedNames[tabName] .. "|r")
        BlzFrameSetSize(tabNavigator.titles[tabName], 0, 0)
        local width = BlzFrameGetWidth(tabNavigator.titles[tabName])
        tabNavigator.widths[tabName] = math.max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
        BlzFrameSetAllPoints(tabNavigator.titles[tabName], tabNavigator.frames[tabName])
        BlzFrameSetTextAlignment(tabNavigator.titles[tabName], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(tabNavigator.titles[tabName], false)
        BlzFrameSetSize(tabNavigator.frames[tabName], tabNavigator.widths[tabName], tabNavigator.HEIGHT)
        if tabs.amount == 1 then
            BlzFrameSetPoint(tabNavigator.frames[tabName], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
        else
            BlzFrameSetPoint(tabNavigator.frames[tabName], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
        end
        BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[tabName], 1), tabNavigator.frames[tabName])
        BlzFrameSetAlpha(BlzFrameGetChild(tabNavigator.frames[tabName], 1), editor.BLACK_BACKDROP_ALPHA)

        tabs.numbers[tabName] = tabs.amount
        tabs.numberFromFrame[tabNavigator.frames[tabs.names[tabs.amount]]] = tabs.amount

        local closeButton = BlzCreateFrame("CloseEditorButton", tabNavigator.frames[tabs.names[tabs.amount]], 0, 0)
        BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE)
        BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET, -tabNavigator.CLOSE_BUTTON_INSET)
        local icon = BlzFrameGetChild(closeButton, 0)
        local iconClicked = BlzFrameGetChild(closeButton, 1)
        local iconHighlight = BlzFrameGetChild(closeButton, 2)
        BlzFrameSetAllPoints(icon, closeButton)
        BlzFrameSetTexture(icon, "closeEditor.blp", 0, true)
        BlzFrameSetTexture(iconClicked, "closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        BlzFrameSetVisible(closeButton, false)
        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, CloseTab)
        tabs.numberFromFrame[closeButton] = tabs.amount
        tabNavigator.closeButtons[tabs.names[tabs.amount]] = closeButton

        AdjustTabWidths()

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, ClickTabButton)

        BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)

        SaveTabs()
    end

    CloseTab = function()
        local index = tabs.numberFromFrame[BlzGetTriggerFrame()]
        local tabName = tabs.names[index]

        BlzFrameSetVisible(tabNavigator.frames[tabName], false)

        if index == tabs.amount then
            BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[index - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
        elseif index == 1 then
            BlzFrameSetPoint(tabNavigator.frames[tabs.names[index + 1]], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
        else
            BlzFrameSetPoint(tabNavigator.frames[tabs.names[index + 1]], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[index - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
        end

        for i = index + 1, tabs.amount do
            tabs.numbers[tabs.names[i]] = i - 1
            tabs.numberFromFrame[tabNavigator.frames[tabs.names[i]]] = i - 1
            tabs.numberFromFrame[tabNavigator.closeButtons[tabs.names[i]]] = i - 1
            tabs.names[i - 1] = tabs.names[i]
        end

        local currentLines = codeLines[tabName][step[tabName]]
        for i = 1, highestNonEmptyLine[tabName][step[tabName]] do
            currentLines[i] = ""
            coloredCodeLines[tabName][step[tabName]][i] = ""
        end
        highestNonEmptyLine[tabName][step[tabName]] = 0

        tabs.names[tabs.amount] = nil
        tabs.numbers[tabName] = nil

        tabs.hasError[tabName] = nil
        doNotUpdateVariables[tabName] = nil
        WSDebug.TabIsHalted[tabName] = nil

        if tabs.amount == 1 then
            tabs.amount = tabs.amount - 1
            AddTab("Main")
            SwitchToTab("Main")
        else
            if currentTab == tabName then
                if index == tabs.amount then
                    SwitchToTab(tabs.names[index - 1])
                else
                    SwitchToTab(tabs.names[index])
                end
            end
            tabs.amount = tabs.amount - 1

            AdjustTabWidths()
        end

        SaveTabs()
    end

    --======================================================================================================================
    --Code Execution
    --======================================================================================================================

    JumpToError = function(fileName, lineNumber)
        if not editor.LOAD_EXTERNAL_SCRIPTS_ON_ERROR or not canJumpToError or not fileName or not lineNumber then
            return
        end

        local alreadyActive

        for j = 1, tabs.amount do
            if tabs.names[j] == fileName then
                alreadyActive = true
                break
            end
        end

        if not alreadyActive then
            local fileFound = false
            for i = 1, #fileNames do
                if fileNames[i] == fileName then
                    Pull(fileName)
                    fileFound = true
                    break
                end
            end
            if not fileFound then
                return
            end
        end

        EnableEditor(user)
        SwitchToTab(fileName)

        BlzFrameSetVisible(highlights.error, true)
        JumpWindow(lineNumber, true, true)

        errorLineNumber[currentTab] = lineNumber
        BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab]))
        BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(errorLineNumber[currentTab] - lineNumberOffset[currentTab] - 1))

        lastLineNumber[currentTab] = lineNumber
        lastViewedLineNumber[currentTab] = lineNumber
        canJumpToError = false
        numVisibleVars = 0
        UpdateVariableViewer(errorLineNumber[currentTab])

        tabs.hasError[currentTab] = true
        doNotUpdateVariables[currentTab] = true
        BlzFrameSetVisible(highlights.error, true)
    end

    local function Continue()
        if WSDebug.TabIsHalted[currentTab] and coroutine.status(WSDebug.Coroutine[currentTab]) == "suspended" then
            lastHaltedCoroutine = WSDebug.Coroutine[currentTab]
            coroutine.resume(WSDebug.Coroutine[currentTab])
        end
    end

    local function NextLine()
        lineByLine = true
        Continue()
    end

    local function ContinueExecuting()
        lineByLine = false
        Continue()
    end

    local function CompileFunction(rawCode, settings)
        if compiler.RELEASE_VERSION then
            local __, __, originalFunc = ConvertAndValidateLines(rawCode, settings.tab, settings.duringInit, true)

            if originalFunc then
                originalFunc()
            end
            return
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Initialization
        ------------------------------------------------------------------------------------------------------------------------

        lineByLine = false
        canJumpToError = true
        local whichTab = settings.tab
        executionTab = whichTab
        currentStop[whichTab] = 0
        lastLineNumber[whichTab] = 0
        lastViewedLineNumber[whichTab] = nil
        errorLineNumber[whichTab] = 0
        tabs.hasError[whichTab] = false
        lastFunctionCall[whichTab] = nil
        lastViewedFunctionCall[whichTab] = nil
        tabs.hasUncompiledChanges[whichTab] = false
        tabs.wasNotCompiledInDebugMode[whichTab] = not settings.debugMode
        WSDebug.TabIsHalted[whichTab] = false
        doNotUpdateVariables[whichTab] = false
        WSDebug.NoStop = false

        if not settings.duringInit and currentTab == whichTab then
            if settings.debugMode then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[currentTab] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[currentTab] .. "|r")
            end
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                if lineNumberWasExecuted[currentTab][i] then
                    lineNumberWasExecuted[currentTab][i] = nil
                    local rawLineNumber = math.tointeger(i - lineNumberOffset[currentTab])
                    if rawLineNumber >= 1 and rawLineNumber <= editor.MAX_LINES_ON_SCREEN then
                        BlzFrameSetText(lineNumbers[rawLineNumber], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
                    end
                end
            end
        end

        if buttons.haltALICE then
            BlzFrameSetEnable(buttons.haltALICE, true)
        end

        WSDebug.GenerationCounter[whichTab] = WSDebug.GenerationCounter[whichTab] + 1

        for index, __ in pairs(varTable) do
            for var, __ in pairs(varTable[index]) do
                varTable[index][var] = nil
            end
        end
        for index, __ in pairs(visibleVarsOfLine[whichTab]) do
            for var, __ in pairs(visibleVarsOfLine[whichTab][index]) do
                visibleVarsOfLine[whichTab][index][var] = nil
            end
        end
        if settings.runInit then
            for i = 1, 7 do
                for j = 1, #WSDebug.FunctionsToInit[i] do
                    WSDebug.FunctionsToInit[i][j] = nil
                end
            end
        end
        for i = 1, #variableViewer.viewedVariableTrace do
            variableViewer.viewedVariableTrace[i] = nil
            variableViewer.viewedValueTrace[i] = nil
        end

        local success, code, originalFunc = ConvertAndValidateLines(rawCode, whichTab, settings.duringInit, true)

        if not success then
            return
        end

        local length = #code
        local word
        local currentLineNumber = 1
        local beginningOfString
        local inComment, inSingleQuoteString, inDoubleQuoteString, inMultilineString, numEqualSigns
        local tokens = {}
        local lineNumberOfToken = {}
        local lineIsPersistent = {}
        local lineIsEphemeral = {}
        local numTokens = 0
        local inPersistents = false

        ------------------------------------------------------------------------------------------------------------------------
        --Tokenization
        ------------------------------------------------------------------------------------------------------------------------

        local pos = 1
        while pos <= length do
            local oneChar
            local twoChars
            local beginningOfComment
            ::begin::

            if pos > length then
                break
            end

            oneChar = sub(code, pos, pos)

            if oneChar == " " then
                pos = find(code, "[\x25S\n]", pos + 1)
                if not pos then
                    break
                end
                goto begin
            elseif oneChar == "\n" then
                currentLineNumber = currentLineNumber + 1
                if inPersistents then
                    lineIsPersistent[currentLineNumber] = true
                end
                if not inMultilineString then
                    pos = pos + 1
                    inComment = false
                else
                    pos = find(code, "[\n\x25]]", pos + 1)
                    if not pos then
                        break
                    end
                end
                goto begin
            end

            if oneChar == "[" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                local i = pos + 1
                numEqualSigns = 0
                beginningOfString = pos
                while sub(code, i, i) == "=" do
                    numEqualSigns = numEqualSigns + 1
                    i = i + 1
                end
                if sub(code, i, i) == "[" then
                    inMultilineString = true
                    pos = find(code, "[\n\x25]]", pos + 1)
                    if not pos then
                        break
                    end
                    goto begin
                else
                    numTokens = numTokens + 1
                    tokens[numTokens] = "["
                    lineNumberOfToken[numTokens] = currentLineNumber
                    pos = pos + 1
                    goto begin
                end
            elseif oneChar == ";" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                pos = pos + 1
                goto begin
            else
                twoChars = sub(code, pos, pos + 1)
                if twoChars == "--" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                    inComment = true
                    beginningOfComment = pos
                    if sub(code, pos, pos + 2) == "--[" then
                        local i = pos + 3
                        numEqualSigns = 0
                        while sub(code, i, i) == "=" do
                            numEqualSigns = numEqualSigns + 1
                            i = i + 1
                        end
                        if sub(code, i, i) == "[" then
                            inMultilineString = true
                            pos = i + 1
                        else
                            pos = i
                        end
                        pos = find(code, "[\n\x25]]", pos)
                        if not pos then
                            break
                        end
                        goto begin
                    else
                        pos = find(code, "\n", pos + 2)
                        if not pos then
                            break
                        end
                        local commentString = sub(code, beginningOfComment, pos)
                        if find(commentString, "@persistent") then
                            if find(commentString, "@persistents") then
                                inPersistents = true
                            end
                            lineIsPersistent[currentLineNumber] = true
                        elseif find(commentString, "@endpersistents") then
                            inPersistents = false
                        end
                        if find(commentString, "@ephemeral") then
                            lineIsEphemeral[currentLineNumber] = true
                            lineIsPersistent[currentLineNumber] = nil
                        end
                        goto begin
                    end
                end
            end

            if inMultilineString then
                if match(sub(code, pos, pos + 1 + numEqualSigns), "^\x25]\x25=*\x25]$") then
                    inMultilineString = false
                    if not inComment then
                        numTokens = numTokens + 1
                        tokens[numTokens] = sub(code, beginningOfString, pos + 1 + numEqualSigns)
                        lineNumberOfToken[numTokens] = currentLineNumber
                    end
                    inComment = false
                    pos = pos + 2 + numEqualSigns
                    goto begin
                else
                    pos = find(code, "[\n\x25]]", pos + 1)
                    if not pos then
                        break
                    end
                    goto begin
                end
            elseif inComment then
                if inMultilineString then
                    pos = find(code, "[\n\x25]]", pos + 1)
                    if not pos then
                        break
                    end
                else
                    pos = find(code, "\n", pos + 1)
                    if not pos then
                        break
                    end
                end
                goto begin
            elseif oneChar == '"' and not IsQuotationMarkEscaped(code, pos) then
                if not inSingleQuoteString and not inMultilineString then
                    if not inDoubleQuoteString then
                        beginningOfString = pos
                        repeat
                            pos = find(code, '"', pos + 1)
                        until not pos or not IsQuotationMarkEscaped(code, pos)
                        inDoubleQuoteString = true
                        if not pos then
                            break
                        end
                        goto begin
                    else
                        numTokens = numTokens + 1
                        tokens[numTokens] = sub(code, beginningOfString, pos)
                        lineNumberOfToken[numTokens] = currentLineNumber
                        inDoubleQuoteString = false
                    end
                end
                pos = pos + 1
                goto begin
            elseif oneChar == "'" and not IsQuotationMarkEscaped(code, pos) then
                if not inDoubleQuoteString and not inMultilineString then
                    if not inSingleQuoteString then
                        beginningOfString = pos
                        repeat
                            pos = find(code, "'", pos + 1)
                        until not pos or not IsQuotationMarkEscaped(code, pos)
                        inSingleQuoteString = true
                        if not pos then
                            break
                        end
                        goto begin
                    else
                        numTokens = numTokens + 1
                        tokens[numTokens] = sub(code, beginningOfString, pos)
                        lineNumberOfToken[numTokens] = currentLineNumber
                        inSingleQuoteString = false
                    end
                end
                pos = pos + 1
                goto begin
            end

            if sub(code, pos, pos + 2) == "..." then
                numTokens = numTokens + 1
                tokens[numTokens] = "..."
                lineNumberOfToken[numTokens] = currentLineNumber
                pos = pos + 3
                goto begin
            end

            if LUA_TWO_CHAR_OPERATORS[twoChars] then
                numTokens = numTokens + 1
                tokens[numTokens] = twoChars
                lineNumberOfToken[numTokens] = currentLineNumber
                pos = pos + 2
                goto begin
            end

            if LUA_ONE_CHAR_OPERATORS[oneChar] then
                numTokens = numTokens + 1
                tokens[numTokens] = oneChar
                lineNumberOfToken[numTokens] = currentLineNumber
                pos = pos + 1
                goto begin
            end

            if oneChar >= "0" and oneChar <= "9" then
                word = match(code, "^[\x25w_.:#]*[eE][\x25-\x25+]?\x25d+", pos) or match(code, "^[\x25w_.:#]*", pos) --scientific notation
            else
                word = match(code, "^#?\x25s*[\x25w_.:]*", pos)
            end

            if word then
                if find(word, "::") then
                    numTokens = numTokens + 1
                    tokens[numTokens] = sub(word, 1, -3)
                    lineNumberOfToken[numTokens] = currentLineNumber
                    pos = pos + #word - 2
                    goto begin
                end

                numTokens = numTokens + 1
                tokens[numTokens] = word
                lineNumberOfToken[numTokens] = currentLineNumber
                if #word == 0 then
                    pos = pos + 1
                end
                pos = pos + #word
                goto begin
            end

            pos = pos + 1
        end

        tokens[#tokens + 1] = ""
        lineNumberOfToken[#tokens] = lineNumberOfToken[#tokens - 1] or 1

        ------------------------------------------------------------------------------------------------------------------------
        --Transpilation
        ------------------------------------------------------------------------------------------------------------------------

        local finalCode = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
        local executionTabString = "'" .. whichTab .. "'"
        local handleTab = executionTabString:gsub(" (Execute)", "")
        if not settings.duringInit then
            finalCode = finalCode ..
            "local OnInit = setmetatable({}, {__index = function() return function() end end}) " ..
            "local Require = setmetatable({}, {__index = function() return function() end end, __call = function() end}) " ..
            "local wsdebug_result " ..
            "local wsdebug_generationCounter = " .. WSDebug.GenerationCounter[whichTab] .. " " ..
            "local wsdebug_executionTab = " .. executionTabString .. " "
        else
            finalCode = finalCode .. "local wsdebug_result local wsdebug_generationCounter = " .. WSDebug.GenerationCounter[whichTab] .. " local wsdebug_executionTab = " .. executionTabString .. " "
        end

        local stateTrace = {"root"}
        local currentState = stateTrace[1]
        local stateOfToken
        local beginningOfStatementToken = {}
        local beginningOfStatementCode = {}
        local currentLevel = 0
        local nameOfFunction = {}
        local levelOfFunction = setmetatable({}, {__index = function() return -1 end})
        local upvalues = setmetatable({}, {__index = function(self, key) self[key] = {} return self[key] end})
        local lineNumberOfFunction = {}
        local functionIsLocal = {}
        local indexOfFunction = {}
        local tableTrace = {}
        local varName, args
        local untracedTables = 0
        local functionName
        local funcIsLocal
        local skip
        local token
        local currentLine = 1

        local function IsEndOfStatement(k)
            local firstToken = tokens[k - 1]
            local secondToken = tokens[k]
            return ((k == #tokens or LUA_CONTROL_FLOW_STATEMENTS[secondToken]) and not LUA_CONTROL_FLOW_STATEMENTS[firstToken]) or (firstToken ~= "local" and firstToken ~= "function" and not LUA_CONTROL_FLOW_STATEMENTS[firstToken] and not LUA_OPERATORS[secondToken] and not LUA_BINARY_OPERATORS[firstToken] and not END_OF_STATEMENT_IGNORED_CHARS[sub(secondToken, 1, 1)])
        end

        local function InsertCode(whichCode, index)
            table.insert(finalCode, index, whichCode)
            for i = 1, #stateTrace do
                if beginningOfStatementCode[i] and beginningOfStatementCode[i] >= index then
                    beginningOfStatementCode[i] = beginningOfStatementCode[i] + 1
                end
            end
        end

        local function ReduceLevel()
            for var, __ in pairs(varTable[currentLevel]) do
                varTable[currentLevel][var] = nil
            end
            for key, __ in pairs(upvalues[currentLevel]) do
                upvalues[currentLevel][key] = nil
            end
            currentLevel = currentLevel - 1
        end

        local function AddVariables(vars, isLocal, whichLevel, addUpvalues)
            for var in vars:gmatch("[^,]+") do
                var = var:gsub("^\x25s*local\x25s+", ""):gsub(" ", "")
                if find(var, "[.\x25[:]") == nil then
                    if isLocal then
                        varTable[whichLevel][var] = true
                        if addUpvalues then
                            upvalues[whichLevel][var] = true
                        end
                    else
                        for i = -1, whichLevel do
                            if varTable[i][var] then
                                return
                            end
                        end
                        varTable[-1][var] = true
                    end
                end
            end
        end

        local function SetVariables(lineNumber)
            for level = -1, currentLevel do
                for var, __ in pairs(varTable[level]) do
                    visibleVarsOfLine[whichTab][lineNumber][var] = level
                end
            end
        end

        if settings.debugMode then
            ------------------------------------------------------------------------------------------------------------------------
            --Debug mode
            ------------------------------------------------------------------------------------------------------------------------

            local i = 1
            while i <= #tokens do
                token = tokens[i]

                while lineNumberOfToken[i] > currentLine do
                    finalCode = finalCode .. "\n"
                    currentLine = currentLine + 1
                end

                if currentState == "assignment" and (i == #tokens or (not LUA_OPERATORS[token] and not LUA_BINARY_OPERATORS[tokens[i - 1]] and not END_OF_STATEMENT_IGNORED_CHARS[sub(token, 1, 1)])) then
                    local vars = ""
                    local isLocal

                    for j = beginningOfStatementToken[#stateTrace - 1], beginningOfStatementToken[#stateTrace] - 2 do
                        vars = vars .. tokens[j] .. " "
                    end

                    for j = beginningOfStatementCode[#stateTrace - 1], beginningOfStatementCode[#stateTrace] - 1 do
                        if finalCode[j] ~= "\n" then
                            finalCode[j] = ""
                        end
                    end

                    if i == #tokens then
                        finalCode = finalCode .. token
                        skip = true
                    end

                    isLocal = tokens[beginningOfStatementToken[#stateTrace - 1]] == "local"

                    local isPersistent = (settings.smartPersist and stateTrace[#stateTrace - 1] == "root" and not lineIsEphemeral[lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]]])
                    or (not settings.duringInit and lineIsPersistent[lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]]] and (stateTrace[#stateTrace - 1] == "root" or stateTrace[#stateTrace - 1] == "functionbody"))
                    local explicitlyPersistent = lineIsPersistent[lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]]]

                    local isTableAssignment = find(vars, "\x25.") or find(vars, ":") or find(vars, "\x25[")
                    if isTableAssignment then
                        InsertCode(" WSDebug.CheckForStop(" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_executionTab, wsdebug_generationCounter) " .. vars .. " = ", beginningOfStatementCode[#stateTrace - 1])
                        SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                    else
                        if find(vars, ",") then
                            local varsAsStrings = vars:gsub("^local ", ""):gsub(" ", ""):gsub("\x25s*([^,]+)\x25s*", "'\x251'")
                            if isPersistent then
                                InsertCode(" WSDebug.CheckForStop(" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_executionTab, wsdebug_generationCounter)" .. " wsdebug_result = WSDebug.GetVarEx(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. tostring(explicitlyPersistent) .. ", " .. varsAsStrings .. ", ", beginningOfStatementCode[#stateTrace - 1])
                            else
                                InsertCode(" WSDebug.CheckForStop(" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_executionTab, wsdebug_generationCounter)" .. " wsdebug_result = WSDebug.Pack(", beginningOfStatementCode[#stateTrace - 1])
                            end

                            finalCode = finalCode .. ") " .. vars .. "= WSDebug.Unpack(wsdebug_result)" .. " WSDebug.AssignVars(wsdebug_result, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", " .. varsAsStrings .. ") "
                            SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                            AddVariables(vars, isLocal, currentLevel)

                            if stateTrace[#stateTrace - 1] == "root" and not vars:find("\x25[") and not vars:find("\x25.") then
                                local beginning = 1
                                local subvar
                                local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                local commaPos = cleanedVar:find(",")
                                while commaPos do
                                    subvar = cleanedVar:sub(beginning, commaPos - 1)
                                    finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v end "
                                    beginning = commaPos + 1
                                    commaPos = cleanedVar:find(",", beginning)
                                end
                                subvar = cleanedVar:sub(beginning)
                                finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v WSDebug.AssignVar(v, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", '" .. subvar .. "') end "
                            end
                        else
                            local varsAsStrings = vars:gsub("^local ", ""):gsub(" ", ""):gsub("\x25s*([^,]+)\x25s*", "'\x251'")
                            if isPersistent then
                                InsertCode(" WSDebug.CheckForStop(" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_executionTab, wsdebug_generationCounter) " .. vars .. " = WSDebug.GetVar(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. tostring(explicitlyPersistent) .. ", " .. varsAsStrings .. ", ", beginningOfStatementCode[#stateTrace - 1])
                            else
                                InsertCode(" WSDebug.CheckForStop(" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_executionTab, wsdebug_generationCounter) " .. vars .. " = ", beginningOfStatementCode[#stateTrace - 1])
                            end

                            if isPersistent then
                                finalCode = finalCode .. ") WSDebug.AssignVar(" .. vars:gsub("^local ", "") .. ", " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", " .. varsAsStrings .. ") "
                            else
                                finalCode = finalCode .. " WSDebug.AssignVar(" .. vars:gsub("^local ", "") .. ", " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", " .. varsAsStrings .. ") "
                            end
                            SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                            AddVariables(vars, isLocal, currentLevel)

                            if stateTrace[#stateTrace - 1] == "root" and not vars:find("\x25[") and not vars:find("\x25.") then
                                local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. cleanedVar .. " = function(v) " .. cleanedVar .. " = v WSDebug.AssignVar(v, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", '" .. cleanedVar .. "') end "
                            end
                        end
                    end

                    stateTrace[#stateTrace] = nil
                    currentState = stateTrace[#stateTrace]
                    beginningOfStatementToken[#stateTrace] = i
                    beginningOfStatementCode[#stateTrace] = #finalCode + 1
                end

                if token == "goto" then
                    finalCode = finalCode
                    .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) "
                    SetVariables(lineNumberOfToken[i])
                end

                if currentState == "root" or currentState == "functionbody" then
                    if stateOfToken ~= currentState and stateOfToken ~= "index" then
                        beginningOfStatementToken[#stateTrace] = i
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1
                    elseif IsEndOfStatement(i) then
                        if tokens[i - 1] ~= "goto" then
                            if (sub(tokens[i - 1], 1, 1) == '"' or sub(tokens[i - 1], 1, 1) == "'") then
                                InsertCode("WSDebug.CheckForStop(" .. lineNumberOfToken[i - 1] .. ", wsdebug_executionTab, wsdebug_generationCounter) ", beginningOfStatementCode[#stateTrace])
                                SetVariables(lineNumberOfToken[i - 1])
                            else
                                local vars = ""
                                for j = beginningOfStatementToken[#stateTrace], i - 1 do
                                    if tokens[j] ~= "local" then
                                        vars = vars .. tokens[j]
                                    end
                                end
                                local isLocal = tokens[beginningOfStatementToken[#stateTrace]] == "local"
                                local varsAsStrings = vars:gsub("\x25s*([^,]+)\x25s*", "'\x251'")

                                local isPersistent = (settings.smartPersist and stateTrace[#stateTrace] == "root" and not lineIsEphemeral[lineNumberOfToken[i - 1]])
                                or (not settings.duringInit and lineIsPersistent[lineNumberOfToken[i - 1]] and (stateTrace[#stateTrace] == "root" or stateTrace[#stateTrace - 1] == "functionbody"))
                                local explicitlyPersistent = lineIsPersistent[lineNumberOfToken[i - 1]]

                                if isPersistent then
                                    finalCode = finalCode .. "wsdebug_result = WSDebug.GetVarNil(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. tostring(explicitlyPersistent) .. ", " .. varsAsStrings .. ") "
                                    finalCode = finalCode .. vars .. " = WSDebug.Unpack(wsdebug_result)"
                                    .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i - 1] .. ", wsdebug_executionTab, wsdebug_generationCounter)"
                                    .. " WSDebug.AssignVars(wsdebug_result," .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                                else
                                    finalCode = finalCode
                                    .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i - 1] .. ", wsdebug_executionTab, wsdebug_generationCounter)"
                                    .. " WSDebug.AssignVars(nil, " .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                                end
                                SetVariables(lineNumberOfToken[i - 1])
                                AddVariables(vars, isLocal, currentLevel)

                                if currentState == "root" then
                                    if find(vars, ",") then
                                        local beginning = 1
                                        local subvar
                                        local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                        local commaPos = cleanedVar:find(",")
                                        while commaPos do
                                            subvar = cleanedVar:sub(beginning, commaPos - 1)
                                            finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v end "
                                            beginning = commaPos + 1
                                            commaPos = cleanedVar:find(",", beginning)
                                        end
                                        subvar = cleanedVar:sub(beginning)
                                        finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v WSDebug.AssignVar(v, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace]] .. ", '" .. subvar .. "') end "
                                    else
                                        local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                        finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. vars .. " = function(v) " .. cleanedVar .. " = v WSDebug.AssignVar(v, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace]] .. ", '" .. cleanedVar .. "') end "
                                    end
                                end
                            end
                        end
                        beginningOfStatementToken[#stateTrace] = i
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1
                    end
                elseif currentState == "until" and tokens[i - 1] ~= "until" and IsEndOfStatement(i) then
                    ReduceLevel()
                    finalCode = finalCode .. ") "
                    stateTrace[#stateTrace] = nil
                    currentState = stateTrace[#stateTrace]
                    beginningOfStatementToken[#stateTrace] = i
                    beginningOfStatementCode[#stateTrace] = #finalCode + 1
                end
                stateOfToken = currentState
                stateOfToken = currentState

                if currentState == "args" and token ~= ")" then
                    args = args .. token
                end

                if token == "::" then
                    if currentState == "gotodef" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                    else
                        currentState = "gotodef"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                    end
                elseif currentState == "gotodef" then
                    finalCode = finalCode .. token
                elseif LUA_OPERATORS[token] or LUA_KEYWORDS[token] then
                    if token == "(" then
                        if currentState == "functiondef" or currentState == "reversefunctiondef" or currentState == "anonymousfunctiondef" or currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                            currentState = "args"
                            stateTrace[#stateTrace + 1] = "args"
                            finalCode = finalCode .. token
                            args = ""

                        elseif (not LUA_OPERATORS[tokens[i - 1]] and not LUA_CONTROL_FLOW_STATEMENTS[tokens[i - 1]]) or tokens[i - 1] == "]" then
                            currentState = "params"
                            stateTrace[#stateTrace + 1] = currentState
                            if stateTrace[#stateTrace - 1] == "root" or stateTrace[#stateTrace - 1] == "functionbody" then
                                for j = #stateTrace, 1, -1 do
                                    if stateTrace[j] == "root" or stateTrace[j] == "functionbody" then
                                        InsertCode("WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) ", beginningOfStatementCode[j])
                                        SetVariables(lineNumberOfToken[i])
                                        break
                                    end
                                end
                            end

                            if CREATOR_DESTRUCTOR_PAIRS[tokens[i - 1]] then
                                if FRAME_RETURNER_FUNCTIONS[tokens[i - 1]] then
                                    currentState = "doublehandlewrapper"
                                    stateTrace[#stateTrace + 1] = currentState
                                    finalCode[#finalCode] = "WSDebug.ValidateFrame(WSDebug.StoreHandle('" .. tokens[i - 1] .. "', " .. tokens[i - 1] .. ", " .. handleTab .. ", " .. tokens[i - 1] .. "(WSDebug.CatchParams('" .. tokens[i - 1] .. "', wsdebug_executionTab, "
                                else
                                    currentState = "handlewrapper"
                                    stateTrace[#stateTrace + 1] = currentState
                                    finalCode[#finalCode] = "WSDebug.StoreHandle('" .. tokens[i - 1] .. "', " .. tokens[i - 1] .. ", " .. handleTab .. ", " .. tokens[i - 1] .. "(WSDebug.CatchParams('" .. tokens[i - 1] .. "', wsdebug_executionTab, "
                                end
                            elseif FRAME_RETURNER_FUNCTIONS[tokens[i - 1]] then
                                currentState = "handlewrapper"
                                stateTrace[#stateTrace + 1] = currentState
                                finalCode[#finalCode] = "WSDebug.ValidateFrame(" .. tokens[i - 1] .. "(WSDebug.CatchParams('" .. tokens[i - 1] .. "', wsdebug_executionTab, "
                            elseif settings.runInit and tokens[i - 1]:match("Init") ~= nil and (tokens[i - 1]:match("^OnInit.") ~= nil or tokens[i - 1]:match("^WSCode.Init") ~= nil) then
                                finalCode[#finalCode] = "WSDebug.Execute('" .. tokens[i - 1]:match("\x25.(.*)") .. "', "
                                currentState = "onInitWrapper"
                                stateTrace[#stateTrace] = currentState
                            else
                                finalCode[#finalCode] = tokens[i - 1] .. "(WSDebug.CatchParams('" .. tokens[i - 1] .. "', wsdebug_executionTab, "
                            end
                        else
                            currentState = "parenthesis"
                            stateTrace[#stateTrace + 1] = currentState
                            finalCode = finalCode .. token
                        end

                    elseif token == ")" then
                        if currentState == "parenthesis" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            finalCode = finalCode .. token .. " "
                        elseif currentState == "args" then
                            stateTrace[#stateTrace] = nil
                            currentState = "functionbody"
                            stateTrace[#stateTrace + 1] = currentState

                            levelOfFunction[#stateTrace] = currentLevel
                            nameOfFunction[#stateTrace] = functionName
                            functionIsLocal[#stateTrace] = funcIsLocal
                            lineNumberOfFunction[#stateTrace] = lineNumberOfToken[i]
                            currentLevel = currentLevel + 1

                            local argsAsStrings = args:gsub("\x25s*([^,]+)\x25s*", "'\x251'")

                            if functionName then
                                local colonSyntax = find(functionName, ":") ~= nil
                                finalCode = finalCode .. ") "
                                .. "if not coroutine.isyieldable(coroutine.running()) and not WSDebug.TabIsHalted[wsdebug_executionTab] and wsdebug_generationCounter == WSDebug.GenerationCounter[wsdebug_executionTab] then "
                                .. "return " .. (args ~= "" and  ("WSDebug.HandleCoroutine(" .. functionName:gsub(":", ".") .. ", wsdebug_executionTab, " .. (colonSyntax and "self, " or "") .. args .. ")") or
                                "WSDebug.HandleCoroutine(" .. functionName:gsub(":", ".") .. (colonSyntax and ", wsdebug_executionTab, self" or ", wsdebug_executionTab") .. ")")
                                .. " end "
                                .. (#args > 0 and (" WSDebug.AssignVars(WSDebug.Pack(" .. args .. "), " .. currentLevel .. ", wsdebug_executionTab, 0, " .. argsAsStrings .. ")") or "")

                                for l = 1, currentLevel - 1 do
                                    for key, __ in pairs(upvalues[l]) do
                                        finalCode = finalCode .. " WSDebug.AssignVar(" .. key .. ", " .. l .. ", wsdebug_executionTab, 0, '" .. key .. "') "
                                    end
                                end

                                if #args > 0 then
                                    AddVariables(args, true, currentLevel, true)
                                end
                                functionName = nil
                            else
                                numFunctions = numFunctions + 1
                                indexOfFunction[#stateTrace - 1] = numFunctions

                                finalCode = finalCode .. ") "
                                .. "if not coroutine.isyieldable(coroutine.running()) and not WSDebug.TabIsHalted[wsdebug_executionTab] and wsdebug_generationCounter == WSDebug.GenerationCounter[wsdebug_executionTab] then "
                                    .. "return " .. (args ~= "" and  ("WSDebug.HandleCoroutine(WSDebug.FuncList[" .. numFunctions .. "], wsdebug_executionTab, " .. args .. ")") or
                                    ("WSDebug.HandleCoroutine(WSDebug.FuncList[" .. numFunctions .. "], wsdebug_executionTab)"))
                                    .. " end "
                                .. (#args > 0 and (" WSDebug.AssignVars(WSDebug.Pack(" .. args .. "), " .. currentLevel .. ", wsdebug_executionTab, 0, " .. argsAsStrings .. ")") or "")

                                for l = 1, currentLevel - 1 do
                                    for key, __ in pairs(upvalues[l]) do
                                        finalCode = finalCode .. " WSDebug.AssignVar(" .. key .. ", " .. l .. ", wsdebug_executionTab, 0, '" .. key .. "') "
                                    end
                                end

                                if #args > 0 then
                                    AddVariables(args, true, currentLevel, true)
                                end
                            end

                        elseif currentState == "params" or currentState == "handlewrapper" or currentState == "doublehandlewrapper" or currentState == "onInitWrapper" then
                            if tokens[i - 1] == "(" then
                                local j = #finalCode
                                while true do
                                    if finalCode[j]:match("', ") then
                                        finalCode[j] = sub(finalCode[j], 1, -3)
                                        break
                                    end
                                    j = j - 1
                                end
                            end
                            if currentState == "handlewrapper" then
                                finalCode = finalCode .. ") "
                                stateTrace[#stateTrace] = nil                            
                            elseif currentState == "doublehandlewrapper" then
                                finalCode = finalCode .. ")) "
                                stateTrace[#stateTrace] = nil
                            end
                            if currentState == "onInitWrapper" then
                                finalCode = finalCode .. ") "
                            else
                                finalCode = finalCode .. ")) "
                            end
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        else
                            finalCode = finalCode .. token .. " "
                        end

                    elseif token == "function" then
                        if tokens[i + 1] == "(" then
                            if tokens[i - 1] == "=" then
                                currentState = "reversefunctiondef"
                                if compiler.WRAP_IN_CALLER_FUNCTIONS then
                                    local tableStr = ""
                                    for j = 1, #tableTrace do
                                        tableStr = tableStr .. tableTrace[j] .. "."
                                    end
                                    local name
                                    if tokens[i - 2] == "]" then
                                        name = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                                    else
                                        name = tokens[i - 2]
                                    end
                                    if sub(name, 1, 2) ~= "__" then
                                        currentState = "wrappedreversefunctiondef"
                                        finalCode = finalCode .. "WSDebug.GetWrapper('" .. tableStr .. name .. "', wsdebug_executionTab, wsdebug_generationCounter, WSDebug.StoreFunc(function"
                                    else
                                        finalCode = finalCode .. "WSDebug.StoreFunc(function"
                                    end
                                else
                                    finalCode = finalCode .. "WSDebug.StoreFunc(function"
                                end
                            else
                                currentState = "anonymousfunctiondef"
                                finalCode = finalCode .. "WSDebug.StoreFunc(function"
                            end
                        else
                            currentState = "functiondef"
                            funcIsLocal = tokens[i - 1] == "local"
                            finalCode = finalCode .. token .. " "
                        end
                        stateTrace[#stateTrace + 1] = currentState
                        beginningOfStatementToken[#stateTrace] = i + 1

                    elseif token == "if" or token == "while" then
                        currentState = "condition"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])
                        currentLevel = currentLevel + 1

                    elseif token == "elseif" then
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        end
                        currentState = "condition"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])

                    elseif token == "until" then
                        currentState = "until"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])

                    elseif token == "else" then
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        end

                        finalCode = finalCode .. "elseif WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) then "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1

                    elseif token == "for" then
                        currentState = "loopheader"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) " .. token .. " "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        currentLevel = currentLevel + 1

                    elseif token == "then" or token == "do" then
                        if currentState == "condition" then
                            finalCode = finalCode .. ") " .. token .. " "
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        elseif currentState == "loopheader" then
                            finalCode = finalCode .. " " .. token .. " "
                            if tokens[beginningOfStatementToken[#stateTrace] + 1] == "," then
                                varName = (tokens[beginningOfStatementToken[#stateTrace]] .. "," .. tokens[beginningOfStatementToken[#stateTrace] + 2])
                                local varsAsStrings = varName:gsub("\x25s*([^,]+)\x25s*", "'\x251'"):gsub(" ", "")
                                finalCode = finalCode .. "WSDebug.AssignVars({" .. varName .. "}, " .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                            else
                                varName = tokens[beginningOfStatementToken[#stateTrace]]
                                local varsAsStrings = varName:gsub("\x25s*([^,]+)\x25s*", "'\x251'"):gsub(" ", "")
                                finalCode = finalCode .. "WSDebug.AssignVar(" .. varName .. ", " .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                            end
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            AddVariables(varName, true, currentLevel, true)
                        else
                            finalCode = finalCode .. "do "
                            currentLevel = currentLevel + 1
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        end

                    elseif token == "repeat" then
                        currentLevel = currentLevel + 1
                        finalCode = finalCode .. token
                        .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1

                    elseif token == "return" then
                        finalCode = finalCode
                        .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter)"
                        .. " " ..  token .. " "
                        SetVariables(lineNumberOfToken[i])
                        currentState = "returnstatement"
                        stateTrace[#stateTrace + 1] = currentState

                    elseif token == "end" then
                        local noStop
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                            noStop = true
                        end

                        if currentLevel - 1 == levelOfFunction[#stateTrace] then
                            local name = nameOfFunction[#stateTrace]
                            local isLocal = functionIsLocal[#stateTrace]
                            local lineNumber = lineNumberOfFunction[#stateTrace]
                            levelOfFunction[#stateTrace] = -1
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            if currentState == "reversefunctiondef" or currentState == "wrappedreversefunctiondef" or currentState == "anonymousfunctiondef" then
                                if noStop then
                                    finalCode = finalCode ..  token .. ", " .. indexOfFunction[#stateTrace] .. ")"
                                else
                                    finalCode = finalCode .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) " ..  token .. ", " .. indexOfFunction[#stateTrace] .. ")"
                                end
                            else
                                if noStop then
                                    finalCode = finalCode .. token .. " "
                                else
                                    finalCode = finalCode .. "WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) end "
                                end
                            end
                            if currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                                finalCode = finalCode .. ")"
                            end
                            if (currentState == "functiondef" or currentState == "wrappedfunctiondef") and name then
                                finalCode = finalCode .. " WSDebug.AssignVar(" .. name:gsub(":", ".") .. ", " .. (isLocal and (currentLevel - 1) or -1) .. ", wsdebug_executionTab, " .. lineNumber .. ", '" .. name:gsub(":", ".") .. "') "
                                AddVariables(name, isLocal, currentLevel - 1)
                            end
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            SetVariables(lineNumberOfToken[i])
                            if currentState == "functiondef" or currentState == "wrappedfunctiondef" then
                                beginningOfStatementToken[#stateTrace - 1] = i + 1
                                beginningOfStatementCode[#stateTrace - 1] = #finalCode + 1
                            elseif currentState == "functionbody" then
                                beginningOfStatementToken[#stateTrace] = i + 1
                                beginningOfStatementCode[#stateTrace] = #finalCode + 1
                            end
                        else
                            if noStop then
                                finalCode = finalCode .. " end "
                            else
                                finalCode = finalCode .. " WSDebug.CheckForStop(" .. lineNumberOfToken[i] .. ", wsdebug_executionTab, wsdebug_generationCounter) end "
                            end
                            SetVariables(lineNumberOfToken[i])
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        end
                        ReduceLevel()

                    elseif token == "{" then
                        currentState = "tabledef"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                        if tokens[i - 1] == "=" then
                            if tokens[i - 2] == "]" then
                                tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                            else
                                tableTrace[#tableTrace + 1] = tokens[i - 2]
                            end
                        else
                            untracedTables = untracedTables + 1
                        end

                    elseif token == "}" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                        if untracedTables > 0 then
                            untracedTables = untracedTables - 1
                        else
                            tableTrace[#tableTrace] = nil
                        end

                    elseif token == "=" then
                        if currentState ~= "tabledef" and currentState ~= "loopheader" then
                            currentState = "assignment"
                            stateTrace[#stateTrace + 1] = currentState
                            finalCode = finalCode .. token .. " "
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    elseif token == "[" and (currentState == "root" or currentState == "functionbody") then
                        currentState = "index"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                    elseif token == "]" and currentState == "index" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                    elseif token == "," then
                        finalCode = finalCode .. token .. " "
                    elseif not skip then
                        if currentState == "functiondef" then
                            functionName = token
                            if find(functionName, ":") == nil then
                                if tokens[i - 2] == "local" then
                                    finalCode[#finalCode] = functionName
                                    if compiler.WRAP_IN_CALLER_FUNCTIONS then
                                        currentState = "wrappedfunctiondef"
                                        stateTrace[#stateTrace] = currentState
                                        finalCode = finalCode .. " " .. functionName .. " = " .. "WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                    else
                                        finalCode = finalCode .. " " .. functionName .. " = " .. "function"
                                    end
                                else
                                    finalCode[#finalCode] = functionName
                                    if compiler.WRAP_IN_CALLER_FUNCTIONS then
                                        currentState = "wrappedfunctiondef"
                                        stateTrace[#stateTrace] = currentState
                                        finalCode = finalCode .. " = " .. "nil " .. functionName .. " = " .. "WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                    else
                                        finalCode = finalCode .. " = " .. "function"
                                    end
                                end
                            else
                                finalCode = finalCode .. token .. " "
                            end
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    end
                elseif not skip then
                    if currentState == "functiondef" then
                        functionName = token
                        if find(functionName, ":") == nil then
                            if tokens[i - 2] == "local" then
                                finalCode[#finalCode] = functionName
                                if compiler.WRAP_IN_CALLER_FUNCTIONS then
                                    currentState = "wrappedfunctiondef"
                                    stateTrace[#stateTrace] = currentState
                                    finalCode = finalCode .. " " .. functionName .. " = " .. "WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                else
                                    finalCode = finalCode .. " " .. functionName .. " = " .. "function"
                                end
                            else
                                finalCode[#finalCode] = functionName
                                if compiler.WRAP_IN_CALLER_FUNCTIONS then
                                    currentState = "wrappedfunctiondef"
                                    stateTrace[#stateTrace] = currentState
                                    finalCode = finalCode .. " = " .. "nil " .. functionName .. " = " .. "WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                else
                                    finalCode = finalCode .. " = " .. "function"
                                end
                            end
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    else
                        finalCode = finalCode .. token .. " "
                    end
                end

                i = i + 1
            end

            SetVariables(lineNumberOfToken[#tokens] + 1)

            if settings.runInit then
                finalCode = finalCode .. [[
                for j = 1, 7 do
                    for k = 1, #WSDebug.FunctionsToInit[j] do
                        WSDebug.FunctionsToInit[j][k]()
                    end
                end
                ]]
            end

            finalCode = finalCode .. "WSDebug.End(" .. lineNumberOfToken[#tokens] + 1 .. ", wsdebug_executionTab, wsdebug_generationCounter)"

            ------------------------------------------------------------------------------------------------------------------------
            --Parse function names and args
            ------------------------------------------------------------------------------------------------------------------------

            --Executed after transpiling and executing a script in debug mode. Function args are parsed directly on the first run in
            --no debug mode.
            local localDefs = {}
            local openParentheses = 0
            currentState = "root"
            tableTrace = {}
            untracedTables = 0

            for i = 1, #tokens do
                token = tokens[i]

                if token == "(" then
                    openParentheses = openParentheses + 1
                elseif token == ")" then
                    if currentState == "functiondef" or currentState == "reversefunctiondef" then
                        currentState = "functionbody"
                        stateTrace[#stateTrace + 1] = currentState
                    end
                    openParentheses = openParentheses - 1
                elseif token == "{" then
                    if tokens[i - 1] == "=" then
                        if tokens[i - 2] == "]" then
                            tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                        else
                            tableTrace[#tableTrace + 1] = tokens[i - 2]
                        end
                    else
                        untracedTables = untracedTables + 1
                    end
                elseif token == "}" then
                    if untracedTables > 0 then
                        untracedTables = untracedTables - 1
                    else
                        tableTrace[#tableTrace] = nil
                    end
                elseif token == "local" then
                    local j = i + 1
                    if tokens[j] == "function" then
                        j = j + 1
                    end
                    repeat
                        localDefs[tokens[j]] = true
                        j = j + 2
                    until tokens[j - 1] ~= ","
                elseif token == "function" then
                    if untracedTables == 0 then
                        local name
                        local j
                        if tokens[i - 1] == "=" then
                            name = tokens[i - 2]
                            j = i + 2
                        else
                            name = tokens[i + 1]
                            j = i + 3
                        end
                        if name ~= "(" then
                            for k = #tableTrace, 1, -1 do
                                name = tableTrace[k] .. "." .. name
                            end
                            local dotPoint = find(name, "\x25.")
                            if not (dotPoint and localDefs[sub(name, 1, dotPoint - 1)] or localDefs[name]) then
                                args = ""
                                while tokens[j] ~= ")" do
                                    if tokens[j] == "," then
                                        args = args .. ", "
                                    else
                                        args = args .. tokens[j]
                                    end
                                    j = j + 1
                                end
                                args = args .. ","
                                FUNCTION_PREVIEW[name] = args
                            end
                        end
                    end
                end
            end
        else
            ------------------------------------------------------------------------------------------------------------------------
            --No debug mode
            ------------------------------------------------------------------------------------------------------------------------

            local localDefs = {}
            local openParentheses = 0

            for i = 1, #tokens do
                token = tokens[i]

                while lineNumberOfToken[i] > currentLine do
                    finalCode = finalCode .. "\n"
                    currentLine = currentLine + 1
                end

                if token == "(" then
                    openParentheses = openParentheses + 1
                    if settings.runInit and tokens[i - 1]:match("Init") ~= nil and (tokens[i - 1]:match("^OnInit.") ~= nil or tokens[i - 1]:match("^WSCode.Init") ~= nil) then
                        finalCode[#finalCode] = "WSDebug.Execute('" .. tokens[i - 1]:match("\x25.(.*)") .. "', "
                    else
                        finalCode = finalCode .. token
                    end
                elseif token == ")" then
                    if currentState == "functiondef" or currentState == "reversefunctiondef" then
                        currentState = "functionbody"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. ") "
                    else
                        finalCode = finalCode .. ") "
                    end
                    openParentheses = openParentheses - 1
                elseif token == "{" then
                    if tokens[i - 1] == "=" then
                        if tokens[i - 2] == "]" then
                            tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                        else
                            tableTrace[#tableTrace + 1] = tokens[i - 2]
                        end
                    else
                        untracedTables = untracedTables + 1
                    end
                    finalCode = finalCode .. "{"
                elseif token == "}" then
                    if untracedTables > 0 then
                        untracedTables = untracedTables - 1
                    else
                        tableTrace[#tableTrace] = nil
                    end
                    finalCode = finalCode .. "} "
                elseif token == "local" and settings.parse then
                    local j = i + 1
                    if tokens[j] == "function" then
                        j = j + 1
                    end
                    repeat
                        localDefs[tokens[j]] = true
                        j = j + 2
                    until tokens[j - 1] ~= ","

                    finalCode = finalCode .. "local "
                elseif token == "function" then
                    if settings.parse and untracedTables == 0 then
                        local name
                        local j
                        if tokens[i - 1] == "=" then
                            name = tokens[i - 2]
                            j = i + 2
                        else
                            name = tokens[i + 1]
                            j = i + 3
                        end
                        if name ~= "(" then
                            for k = #tableTrace, 1, -1 do
                                name = tableTrace[k] .. "." .. name
                            end
                            local dotPoint = find(name, "\x25.")
                            if not (dotPoint and localDefs[sub(name, 1, dotPoint - 1)] or localDefs[name]) then
                                args = ""
                                while tokens[j] ~= ")" do
                                    if tokens[j] == "," then
                                        args = args .. ", "
                                    else
                                        args = args .. tokens[j]
                                    end
                                    j = j + 1
                                end
                                args = args .. ","
                                FUNCTION_PREVIEW[name] = args
                            end
                        end
                    end
                    finalCode = finalCode .. "function "
                else
                    finalCode = finalCode .. token .. " "
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Execute function
        ------------------------------------------------------------------------------------------------------------------------

        local functionString = table.concat(finalCode)

        if settings.debugMode and diagnostics.DUMP_TRANSPILED_SCRIPTS then
            PreloadGenClear()
            PreloadGenStart()

            local beginning = 1
            local stop
            repeat
                stop = functionString:find("\n", beginning)
                if stop then
                    if stop - beginning > 245 then
                        stop = beginning + 245
                        while functionString:sub(stop, stop) ~= " " and stop > beginning + 1 do
                            stop = stop - 1
                        end
                    end
                else
                    stop = #functionString
                    if stop - beginning > 245 then
                        stop = beginning + 245
                    end
                end
                Preload(functionString:sub(beginning, stop))
                beginning = stop + 1
            until beginning > #functionString

            PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeTranspiled" .. whichTab:sub(1,1):upper() .. whichTab:sub(2):gsub(" ", "") .. ".txt")
            PrintForUser("Transpiled script written to file WSCodeTranspiled" .. whichTab:sub(1,1):upper() .. whichTab:sub(2):gsub(" ", "") .. ".txt.")
        end

        local func, err
        if diagnostics.PROFILE_INIT and settings.duringInit then
            local time = clock()
            func, err = load(functionString, ("WSCode " .. (tabs.names[whichTab] or whichTab or "Unknown")), "t")
            local endTime = clock()
            init.profiler[whichTab] = (init.profiler[whichTab] or 0) + endTime - time
        else
            func, err = load(functionString, ("WSCode " .. (tabs.names[whichTab] or whichTab or "Unknown")), "t")
        end
        if not func then
            if err and err:match("too many local variables") then
                PrintForUser("|cffff5555ERROR at WSCode  " .. (whichTab or "Unknown") .. ": Code chunk could not be transpiled because the local variable limit (200) was exceeded by adding debug variables. The function was compiled in raw form.|r")
            else
                PrintForUser("|cffff5555ERROR at WSCode  " .. (whichTab or "Unknown") .. err .. ": Raw code did compile, but transpiled code did not. Please report this bug along with the code chunk and settings that caused it. The function was compiled in raw form.|r")
            end
            if settings.duringInit then
                func = originalFunc
            else
                return
            end
        end

        if settings.cleanHandles then
            for handle, creator in pairs(handles[whichTab]) do
                _G[CREATOR_DESTRUCTOR_PAIRS[creator]](handle)
                handles[whichTab][handle] = nil
            end
        end

        if settings.duringInit then
            xpcall(func, Debug.errorHandler)
        else
            WSDebug.Coroutine[whichTab] = coroutine.create(func)
            coroutine.resume(WSDebug.Coroutine[whichTab])
        end
    end

    --======================================================================================================================
    --Top Buttons
    --======================================================================================================================

    local function CreateToggleExpandButton(type, texture, whichParent)
        local button = BlzCreateFrame(type, whichParent, 0, 0)
        local icon = BlzFrameGetChild(button, 0)
        local iconClicked = BlzFrameGetChild(button, 1)
        local iconHighlight = BlzFrameGetChild(button, 2)
        BlzFrameSetAllPoints(icon, button)
        BlzFrameSetTexture(icon, texture, 0, true)
        BlzFrameSetTexture(iconClicked, texture, 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, button, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, button, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
        if whichParent == codeEditorParent then
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CLOSE_BUTTON_INSET + editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET)
            TriggerAddAction(trig, ToggleExpand)
            buttons.expand = button
        else
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET)
            TriggerAddAction(trig, ToggleVariableViewerExpand)
            buttons.expandVariableViewer = button
        end
    end

    ToggleExpand = function()
        BlzFrameSetEnable(buttons.expand, false)
        BlzFrameSetEnable(buttons.expand, true)
        editor.isExpanded = not editor.isExpanded

        if editor.isExpanded then
            BlzDestroyFrame(buttons.expand)
            CreateToggleExpandButton("CollapseEditorButton", "collapseEditor.blp", codeEditorParent)
            BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.EXPANDED_X, editor.Y_TOP)
            BlzFrameSetSize(codeEditorParent, editor.EXPANDED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)
            UpdateAllLines()
            editor.ON_EXPAND()
        else
            BlzDestroyFrame(buttons.expand)
            CreateToggleExpandButton("ExpandEditorButton", "expandEditor.blp", codeEditorParent)
            BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
            BlzFrameSetSize(codeEditorParent, editor.COLLAPSED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)
            UpdateAllLines()
            editor.ON_COLLAPSE()
        end

        local spaceRequired = 0
        for i = 1, tabs.amount do
            spaceRequired = spaceRequired + tabNavigator.widths[tabs.names[i]] - tabNavigator.OVERLAP
        end

        AdjustTabWidths()
    end

    ToggleVariableViewerExpand = function()
        BlzFrameSetEnable(buttons.expandVariableViewer, false)
        BlzFrameSetEnable(buttons.expandVariableViewer, true)
        variableViewer.isExpanded = not variableViewer.isExpanded

        if variableViewer.isExpanded then
            BlzDestroyFrame(buttons.expandVariableViewer)
            CreateToggleExpandButton("CollapseEditorButton", "collapseEditor.blp", variableViewer.parent)
            numVisibleVars = 0
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            BlzFrameSetVisible(variableViewer.title, true)
            BlzFrameSetVisible(buttons.back, #variableViewer.viewedVariableTrace > 0)
            if lastFunctionCall[currentTab] then
                for i = 1, #variableViewer.functionFrames do
                    BlzFrameSetVisible(variableViewer.functionFrames[i], true)
                end
                for i = 1, #functionParams[currentTab] do
                    BlzFrameSetVisible(variableViewer.functionParamFrames[i], true)
                end
            end
        else
            BlzDestroyFrame(buttons.expandVariableViewer)
            CreateToggleExpandButton("ExpandEditorButton", "expandEditor.blp", variableViewer.parent)
            BlzFrameSetSize(variableViewer.parent, editor.CLOSE_BUTTON_SIZE + 2*editor.CLOSE_BUTTON_INSET, editor.CLOSE_BUTTON_SIZE + 2*editor.CLOSE_BUTTON_INSET)
            for i = 1, numVisibleVars do
                BlzFrameSetVisible(variableViewer.frames[i], false)
                BlzFrameSetVisible(variableViewer.valueFrames[i], false)
            end
            for i = 1, #variableViewer.functionFrames do
                BlzFrameSetVisible(variableViewer.functionFrames[i], false)
            end
            for i = 1, #variableViewer.functionParamFrames do
                BlzFrameSetVisible(variableViewer.functionParamFrames[i], false)
            end
            BlzFrameSetVisible(variableViewer.title, false)
            BlzFrameSetVisible(buttons.back, false)
            variableViewer.hasNotBeenExpanded = false
        end
    end

    local function HideCodeEditor()
        BlzFrameSetEnable(buttons.hideEditor, false)
        BlzFrameSetEnable(buttons.hideEditor, true)
        BlzFrameSetVisible(codeEditorParent, false)
        editor.ON_DISABLE()
    end

    --======================================================================================================================
    --Benchmark
    --======================================================================================================================

    local function GetMeanAndStdDev()
        local mean = 0
        local numResults = #benchmark.results
        for __, value in ipairs(benchmark.results) do
            mean = mean + value
        end

        mean = mean / numResults

        local varianceTotal = 0
        for __, value in ipairs(benchmark.results) do
            varianceTotal = varianceTotal + (value - mean)^2
        end

        local stddev = math.sqrt(1/(numResults - 1)*varianceTotal)
        local stddevOfMean = stddev/math.sqrt(numResults)

        return mean, stddevOfMean
    end

    local function BenchmarkLoop()
        local time = clock()
        if benchmark.gauge then
            local doNothing = DoNothing
            for __ = 1, benchmark.iterations do
                doNothing()
            end
        else
            local func = benchmark.func
            for __ = 1, benchmark.iterations do
                func()
            end
        end
        local elapsedTime = clock() - time
        if elapsedTime < 0.005 then
            benchmark.iterations = 10*benchmark.iterations
        elseif elapsedTime < 0.05 then
            benchmark.iterations = (benchmark.iterations*0.055/elapsedTime) // 1
        else
            if benchmark.gauge then
                benchmark.emptyFunctionNanoseconds = elapsedTime*10^9/benchmark.iterations
                benchmark.gauge = false
            else
                local executionTime = ((elapsedTime*10^9/benchmark.iterations) - benchmark.emptyFunctionNanoseconds) // 1
                table.insert(benchmark.results, executionTime)
                ClearTextMessages()
                local mean, stddev = GetMeanAndStdDev()
                if stddev > 0 then
                    if mean < 10000 then
                        PrintForUser("Execution time of code chunk is: " .. string.format("\x25.1f", mean) .. " +/- " .. string.format("\x25.1f", stddev) .. " |cff00ff00nano|rseconds.")
                    elseif mean < 10000000 then
                        PrintForUser("Execution time of code chunk is: " .. string.format("\x25.1f", mean/1000) .. " +/- " .. string.format("\x25.1f", stddev/1000) .. " |cffffff00micro|rseconds.")
                    else
                        PrintForUser("Execution time of code chunk is: " .. string.format("\x25.1f", mean/1000000) .. " +/- " .. string.format("\x25.1f", stddev/1000000) .. " |cffff8800milli|rseconds.")
                    end
                else
                    if mean < 10000 then
                        PrintForUser("Execution time of code chunk is: " .. mean .. " |cff00ff00nano|rseconds.")
                    elseif mean < 10000000 then
                        PrintForUser("Execution time of code chunk is: " .. mean//1000 .. " |cffffff00micro|rseconds.")
                    else
                        PrintForUser("Execution time of code chunk is: " .. mean//1000000 .. " |cffff8800milli|rseconds.")
                    end
                end
                benchmark.gauge = true
            end
            benchmark.iterations = 10
        end
        TimerStart(benchmark.TIMER, elapsedTime + 0.01, false, BenchmarkLoop)
    end

    local function Benchmark()
        tabs.hasUncompiledChanges[currentTab] = false
        if benchmark.func then
            PauseTimer(benchmark.TIMER)
            for i = 1, #benchmark.results do
                benchmark.results[i] = nil
            end
            BlzFrameSetTexture(BlzFrameGetChild(buttons.benchmark, 0), "Benchmark.blp", 0, true)
            BlzFrameSetTexture(BlzFrameGetChild(buttons.benchmark, 1), "Benchmark.blp", 0, true)
            PrintForUser("\nBenchmark aborted.")
            benchmark.func = nil
        else
            local adjustedCodeLines = {}
            local currentLines = codeLines[currentTab][step[currentTab]]
            adjustedCodeLines[1] = currentLines[1]
            for i = 2, highestNonEmptyLine[currentTab][step[currentTab]] do
                adjustedCodeLines[i] = "\n" .. currentLines[i]
            end

            local func, error = load(table.concat(adjustedCodeLines), "WSCode " .. (tabs.names[currentTab] or "Main"), "t")
            if not func then
                if Debug then
                    Debug.throwError(error)
                end
                return
            end

            BlzFrameSetTexture(BlzFrameGetChild(buttons.benchmark, 0), "EndBenchmark.blp", 0, true)
            BlzFrameSetTexture(BlzFrameGetChild(buttons.benchmark, 1), "EndBenchmark.blp", 0, true)

            benchmark.iterations = 10
            benchmark.func = func
            benchmark.gauge = true
            BenchmarkLoop()
        end
    end

    --======================================================================================================================
    --Search Bar
    --======================================================================================================================

    local function ShowSearchBar()
        BlzFrameSetEnable(buttons.search, false)
        BlzFrameSetEnable(buttons.search, true)
        BlzFrameSetVisible(searchBar.parent, true)
        BlzFrameSetText(searchBar.textField, "")
        BlzFrameSetFocus(enterBox, false)
        BlzFrameSetFocus(searchBar.textField, true)
    end

    RenderSearchHighlights = function()
        local currentLines = codeLines[currentTab][step[currentTab]]
        local numVisible = 0
        for i = 1, searchBar.numFinds do
            if searchBar.lines[i] > lineNumberOffset[currentTab] and searchBar.lines[i] <= lineNumberOffset[currentTab] + editor.MAX_LINES_ON_SCREEN then
                numVisible = numVisible + 1
                searchBar.highlights[numVisible] = searchBar.highlights[numVisible] or GetTextHighlightFrame("05", 120, "searchHighlight")
                BlzFrameSetPoint(searchBar.highlights[numVisible], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[searchBar.lines[i]], 1, searchBar.startPos[i])), -editor.CODE_TOP_INSET - (searchBar.lines[i] - lineNumberOffset[currentTab])*editor.LINE_SPACING)
                BlzFrameSetPoint(searchBar.highlights[numVisible], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[searchBar.lines[i]], 1, searchBar.endPos[i])), -editor.CODE_TOP_INSET - (searchBar.lines[i] - lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)
                if i == searchBar.searchPos then
                    BlzFrameSetTexture(searchBar.highlights[numVisible], "ReplaceableTextures\\TeamColor\\TeamColor05.blp", 0, true)
                    BlzFrameSetAlpha(searchBar.highlights[numVisible], 150)
                else
                    BlzFrameSetTexture(searchBar.highlights[numVisible], "ReplaceableTextures\\TeamColor\\TeamColor23.blp", 0, true)
                    BlzFrameSetAlpha(searchBar.highlights[numVisible], 120)
                end
            end
        end

        for i = numVisible + 1, #searchBar.highlights do
            ReturnTextHighlightFrame(searchBar.highlights[i])
            searchBar.highlights[i] = nil
        end
    end

    FindSearchItems = function()
        if searchBar.text == "" then
            searchBar.numFinds = 0
            RenderSearchHighlights()
            BlzFrameSetEnable(searchBar.searchDownButton, false)
            BlzFrameSetEnable(searchBar.searchUpButton, false)
            BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")
            return
        end

        local text = searchBar.text:gsub("([\x25^\x25$\x25(\x25)\x25\x25\x25.\x25[\x25]\x25*\x25+\x25-\x25?])", "\x25\x25\x251") --escape all special characters

        if sub(text, 1, 1) == ":" then
            local lineNumber = tonumber(sub(text, 2))
            if lineNumber then
                lineNumber = math.tointeger(lineNumber)
                if lineNumber then
                    JumpWindow(lineNumber, true)
                    searchBar.numFinds = 0
                    RenderSearchHighlights()
                    BlzFrameSetEnable(searchBar.searchDownButton, false)
                    BlzFrameSetEnable(searchBar.searchUpButton, false)
                    BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")
                    return
                end
            end
        end

        local currentLines = codeLines[currentTab][step[currentTab]]
        local str, j, start, stop
        local numFinds = 0
        local searchPos = 1
        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            str = currentLines[i]
            j = 1
            start, stop = str:find(text)
            while start do
                numFinds = numFinds + 1
                searchBar.lines[numFinds] = i
                searchBar.startPos[numFinds] = start - 1
                searchBar.endPos[numFinds] = stop
                if cursor.adjustedLine and (i < cursor.adjustedLine or i == cursor.adjustedLine and cursor.pos < stop) then
                    searchPos = searchPos + 1
                end
                j = j + 1
                start, stop = str:find(text, stop + 1)
            end
        end
        searchBar.numFinds = numFinds
        if searchBar.numFinds > 0 then
            if cursor.adjustedLine then
                searchBar.searchPos = math.min(searchPos, numFinds)
            else
                searchBar.searchPos = 1
            end
            JumpWindow(searchBar.lines[searchBar.searchPos])
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            BlzFrameSetEnable(searchBar.searchDownButton, true)
            BlzFrameSetEnable(searchBar.searchUpButton, true)
        else
            searchBar.searchPos = nil
            BlzFrameSetText(searchBar.numResults, "|cffff0000No results|r")
            BlzFrameSetEnable(searchBar.searchDownButton, false)
            BlzFrameSetEnable(searchBar.searchUpButton, false)
        end
    end

    local function OnSearchBarEdit()
        searchBar.text = BlzGetTriggerFrameText()
        FindSearchItems()
        RenderSearchHighlights()
    end

    local function SearchUp()
        if searchBar.searchPos then
            searchBar.searchPos = searchBar.searchPos - 1
            if searchBar.searchPos == 0 then
                searchBar.searchPos = searchBar.numFinds
            end
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            JumpWindow(searchBar.lines[searchBar.searchPos])
            RenderSearchHighlights()
        end
    end

    local function SearchDown()
        if searchBar.searchPos then
            searchBar.searchPos = searchBar.searchPos + 1
            if searchBar.searchPos > searchBar.numFinds then
                searchBar.searchPos = 1
            end
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            JumpWindow(searchBar.lines[searchBar.searchPos])
            RenderSearchHighlights()
        end
    end

    Pull = function(fileName)
        for i = 1, #fileNames do
            if fileNames[i] == fileName then
                StoreCode(fileName, files[i])
                return true
            end
        end
        PrintForUser("|cffff5555ERROR: No file found with the name " .. fileName .. ".|r")
        return false
    end

    --======================================================================================================================
    --Init
    --======================================================================================================================

    EnableEditor = function(whichPlayer)
        whichPlayer = whichPlayer or GetTriggerPlayer()
        user = user or whichPlayer

        if not BlzLoadTOCFile("CodeEditor.toc") then
            error("CodeEditor.toc failed to load.")
        end

        if codeEditorParent then
            editor.ON_ENABLE()
            if GetLocalPlayer() == user then
                BlzFrameSetVisible(codeEditorParent, true)
            end
            return
        end

        if not HandleType then
            if Debug then
                Debug.throwError("Missing requirement: HandleType.")
            end
            return
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Code Editor
        ------------------------------------------------------------------------------------------------------------------------

        local parent = editor.GET_PARENT()
        if GetHandleId(parent) == 0 then
            if Debug then
                Debug.throwError("Invalid parent frame.")
            end
            return
        end

        codeEditorParent = BlzCreateFrame("CodeEditor", parent, 0, 0)
        if GetHandleId(codeEditorParent) == 0 then
            if Debug then
                Debug.throwError("Missing import: CodeEditor.fdf.")
            end
            return
        end
        BlzFrameSetVisible(codeEditorParent, GetLocalPlayer() == user)

        BlzFrameSetLevel(codeEditorParent, 2)

        local backdrop = BlzFrameGetChild(codeEditorParent, 0)
        BlzFrameSetAllPoints(backdrop, codeEditorParent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        local border = BlzFrameGetChild(codeEditorParent, 1)
        BlzFrameSetAllPoints(border, codeEditorParent)

        local titleFrame = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
        BlzFrameSetText(titleFrame, "|cffffcc00Warcraft Studio Code|r")
        BlzFrameSetEnable(titleFrame, false)
        BlzFrameSetSize(titleFrame, 0, 0)
        BlzFrameSetPoint(titleFrame, FRAMEPOINT_TOP, codeEditorParent, FRAMEPOINT_TOP, 0, editor.TITLE_VERTICAL_SHIFT)

        highlights.error = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetTexture(highlights.error, "ReplaceableTextures\\TeamColor\\TeamColor00.blp", 0, true)
        BlzFrameSetAlpha(highlights.error, 128)
        BlzFrameSetEnable(highlights.error, false)
        BlzFrameSetVisible(highlights.error, false)

        codeScroller = BlzCreateFrame("VerticalSlider", codeEditorParent, 0, 0)
        if GetHandleId(codeScroller) == 0 then
            if Debug then
                Debug.throwError("Missing import: VerticalSlider.fdf.")
            end
            return
        end

        BlzFrameSetPoint(codeScroller, FRAMEPOINT_TOP, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_SCROLLER_HORIZONTAL_INSET, -editor.CODE_TOP_INSET)
        BlzFrameSetSize(codeScroller, 0.012, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)
        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        BlzFrameSetValue(codeScroller, highestNonEmptyLine[currentTab][step[currentTab]])
        BlzFrameSetStepSize(codeScroller, 1)
        BlzFrameSetLevel(codeScroller, 3)
        lineNumberOffset[currentTab] = 0

        local trigStop = CreateTrigger()
        local trigEnter = CreateTrigger()

        for i = 1, editor.MAX_LINES_ON_SCREEN do
            if editor.USE_MONOSPACE_FONT then
                codeLineFrames[i] = BlzCreateFrame("Consolas", codeEditorParent, 0, 0)
            else
                codeLineFrames[i] = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
            end
            BlzFrameSetPoint(codeLineFrames[i], FRAMEPOINT_TOPLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - (i-1)*editor.LINE_SPACING)
            BlzFrameSetPoint(codeLineFrames[i], FRAMEPOINT_BOTTOMRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, 1.0, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(codeLineFrames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            local currentLines = codeLines[currentTab][step[currentTab]]
            if i <= highestNonEmptyLine[currentTab][step[currentTab]] then
                coloredCodeLines[currentTab][step[currentTab]][i] = GetColoredText(currentLines[i], i, 1)
                if i <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetText(codeLineFrames[i], coloredCodeLines[currentTab][step[currentTab]][i])
                end
            else
                BlzFrameSetText(codeLineFrames[i], "")
            end
            BlzFrameSetLevel(codeLineFrames[i], 1)

            lineNumbers[i] = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
            BlzFrameSetPoint(lineNumbers[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_NUMBER_HORIZONTAL_INSET/editor.LINE_NUMBER_SCALE, (-editor.CODE_TOP_INSET - i*editor.LINE_SPACING)/editor.LINE_NUMBER_SCALE)
            BlzFrameSetPoint(lineNumbers[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_LEFT_INSET/editor.LINE_NUMBER_SCALE, (-editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)/editor.LINE_NUMBER_SCALE)
            BlzFrameSetTextAlignment(lineNumbers[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetEnable(lineNumbers[i], false)
            BlzFrameSetScale(lineNumbers[i], editor.LINE_NUMBER_SCALE)
            if lineNumberWasExecuted[currentTab][i] then
                BlzFrameSetText(lineNumbers[i], editor.LINE_NUMBER_COLOR .. i .. "|r")
            else
                BlzFrameSetText(lineNumbers[i], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
            end
            indexFromFrame[lineNumbers[i]] = i

            stopButtons[i] = BlzCreateFrame("CodeEditorButton", codeEditorParent, 0, 0)
            BlzFrameSetPoint(stopButtons[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.STOP_BUTTON_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
            BlzFrameSetPoint(stopButtons[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (i-1)*editor.LINE_SPACING)
            BlzFrameSetAllPoints(BlzFrameGetChild(stopButtons[i], 0), stopButtons[i])
            BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i]], 0, true)
            BlzTriggerRegisterFrameEvent(trigStop, stopButtons[i], FRAMEEVENT_CONTROL_CLICK)
            indexFromFrame[stopButtons[i]] = i
        end

        enterBox = BlzCreateFrame("EscMenuEditBoxTemplate", codeEditorParent, 0, 0)
        BlzFrameSetPoint(enterBox, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOMLEFT, editor.CODE_LEFT_INSET - 0.002, editor.CODE_BOTTOM_INSET - 0.002)
        BlzFrameSetPoint(enterBox, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET + 0.002, -editor.CODE_TOP_INSET + 0.002)
        BlzFrameSetLevel(enterBox, 2)
        BlzFrameSetAlpha(enterBox, 0)
        BlzTriggerRegisterFrameEvent(trigEnter, enterBox, FRAMEEVENT_EDITBOX_ENTER)
        BlzFrameSetText(enterBox, " ")
        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, enterBox, FRAMEEVENT_MOUSE_WHEEL)
        TriggerAddAction(trig, function()
            if BlzGetTriggerFrameValue() > 0 then
                BlzFrameSetValue(codeScroller, BlzFrameGetValue(codeScroller) + 2)
            else
                BlzFrameSetValue(codeScroller, BlzFrameGetValue(codeScroller) - 2)
            end
        end)

        cursorFrame = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetSize(cursorFrame, 0.0008, editor.LINE_SPACING)
        BlzFrameSetTexture(cursorFrame, "ReplaceableTextures\\TeamColor\\TeamColor21.blp", 0, true)
        BlzFrameSetEnable(cursorFrame, false)
        BlzFrameSetVisible(cursorFrame, false)

        TriggerAddAction(trigEnter, InsertCodeLine)
        TriggerAddAction(trigStop, PutStop)

        helper.frame = BlzCreateFrame("TextMessage", codeEditorParent, 0, 0)
        if GetHandleId(helper.frame) == 0 then
            if Debug then
                Debug.throwError("Missing import: NeatTextMessage.fdf.")
            end
        end

        helper.text = BlzFrameGetChild(helper.frame, 0)
        helper.box = BlzFrameGetChild(helper.frame, 1)
        BlzFrameSetAllPoints(helper.box, helper.frame)
        BlzFrameSetVisible(helper.frame, false)
        BlzFrameSetLevel(helper.frame, 3)
        BlzFrameSetLevel(helper.text, 1)
        BlzFrameSetEnable(helper.frame, false)
        BlzFrameSetEnable(helper.text, false)
        BlzFrameSetEnable(helper.box, false)

        if editor.USE_MONOSPACE_FONT then
            widthTestFrame = BlzCreateFrame("Consolas", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0)
        else
            widthTestFrame = BlzCreateFrameByType("TEXT", "", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), "", 0)
        end
        BlzFrameSetVisible(widthTestFrame, false)

        highlights.currentLine = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetTexture(highlights.currentLine, "currentLine.blp", 0, true)
        BlzFrameSetVisible(highlights.currentLine, false)

        BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
        BlzFrameSetSize(codeEditorParent, editor.COLLAPSED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)

		CreateToggleExpandButton("ExpandEditorButton", "expandEditor.blp", codeEditorParent)

		local closeButton = BlzCreateFrame("CloseEditorButton", codeEditorParent, 0, 0)
		BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
		BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET)
        local icon = BlzFrameGetChild(closeButton, 0)
        local iconClicked = BlzFrameGetChild(closeButton, 1)
        local iconHighlight = BlzFrameGetChild(closeButton, 2)
        BlzFrameSetAllPoints(icon, closeButton)
		BlzFrameSetTexture(icon, "closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, "closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, HideCodeEditor)

        ------------------------------------------------------------------------------------------------------------------------
        --Bottom Bar
        ------------------------------------------------------------------------------------------------------------------------

        local maxButtons = 10
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            maxButtons = maxButtons + 1
        end
        if compiler.ENABLE_QUICK_RESTART and FileIO then
            maxButtons = maxButtons + 1
        end
        if ALICE_Config then
            maxButtons = maxButtons + 1
        end

        local function CreateBottomButton(index, texture, callback, tooltip, extendedTooltip)
            local button = BlzCreateFrame("BottomBarButton", codeEditorParent, 0, 0)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOM, (index - 1 - maxButtons/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_BOTTOM, (index - maxButtons/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT + editor.BOTTOM_BUTTON_SIZE)

            local icon = BlzFrameGetChild(button,0)
            local iconClicked = BlzFrameGetChild(button,1)
            BlzFrameClearAllPoints(iconClicked)
            BlzFrameSetPoint(iconClicked, FRAMEPOINT_BOTTOMLEFT, icon, FRAMEPOINT_BOTTOMLEFT, 0.0005, 0.0005)
            BlzFrameSetPoint(iconClicked, FRAMEPOINT_TOPRIGHT, icon, FRAMEPOINT_TOPRIGHT, -0.0005, -0.0005)

            BlzFrameSetTexture(icon, texture, 0, true)
            BlzFrameSetTexture(iconClicked, texture, 0, true)

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, callback)

            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)
            if GetHandleId(tooltipFrame) == 0 then
                error("Missing import: CustomTooltip.fdf.")
            end

            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMRIGHT, codeEditorParent, FRAMEPOINT_BOTTOMRIGHT, -editor.BOTTOM_BUTTON_VERTICAL_SHIFT - editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT + editor.BOTTOM_BUTTON_SIZE)
            BlzFrameSetTooltip(button, tooltipFrame)

            local title = BlzFrameGetChild(tooltipFrame, 0)
            local text = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(title, "|cffffcc00" .. tooltip .. "|r")
            BlzFrameSetText(text, extendedTooltip)
            BlzFrameSetSize(text, 0.22 - 0.012, 0.0)
            BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(text) + 0.035)

            return button
        end

        local function Execute()
            BlzFrameSetEnable(buttons.execute, false)
            BlzFrameSetEnable(buttons.execute, true)
            BlzFrameSetVisible(highlights.currentLine, false)
            BlzFrameSetVisible(highlights.error, false)
            BlzFrameSetVisible(variableViewer.parent, flags.debugMode)

            for i = 1, numVisibleVars do
                BlzFrameSetVisible(variableViewer.frames[i], false)
                BlzFrameSetVisible(variableViewer.valueFrames[i], false)
            end
            numVisibleVars = 0
            if variableViewer.isExpanded then
                BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + 2*variableViewer.LINE_VERTICAL_INSET)
            end

            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetFocus(codeLineFrames[i], false)
                BlzFrameSetEnable(codeLineFrames[i], false)
                BlzFrameSetEnable(codeLineFrames[i], true)
            end

            local lines = {}
            local currentLines = codeLines[currentTab][step[currentTab]]
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                lines[i] = currentLines[i]
            end

            CompileFunction(lines, {
                debugMode = flags.debugMode,
                runInit = flags.runInit,
                smartPersist = flags.smartPersist,
                cleanHandles = flags.cleanHandles,
                tab = currentTab
            })
        end

        local function Undo()
            BlzFrameSetEnable(buttons.undo, false)
            BlzFrameSetEnable(buttons.undo, true)
            BlzFrameSetVisible(variableViewer.parent, false)
            BlzFrameSetVisible(highlights.error, false)
            tabs.hasError[currentTab] = false
            doNotUpdateVariables[currentTab] = false
            tabs.hasUncompiledChanges[currentTab] = true
            tabs.hasUnsavedChanges[currentTab] = true
            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            end

            if step[currentTab] > 1 then
                step[currentTab] = step[currentTab] - 1
                UpdateAllLines()
                BlzFrameSetEnable(buttons.redo, true)
                if step[currentTab] == 1 then
                    BlzFrameSetEnable(buttons.undo, false)
                end

                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
            end

            SetLineOffset(lineNumberOffset[currentTab])
            JumpWindow(lineNumberOfEdit[currentTab][step[currentTab] + 1])

            cursor.adjustedLine = lineNumberOfEdit[currentTab][step[currentTab] + 1]
            SetCursorPos(posOfEdit[currentTab][step[currentTab] + 1])
            cursor.rawLine = cursor.adjustedLine - lineNumberOffset[currentTab]
            SetCursorX(codeLines[currentTab][step[currentTab]][cursor.adjustedLine])
            BlzFrameSetFocus(enterBox, true)
            editBoxFocused = true
            BlzFrameSetVisible(cursorFrame, true)
        end

        local function Redo()
            BlzFrameSetEnable(buttons.redo, false)
            BlzFrameSetEnable(buttons.redo, true)
            BlzFrameSetVisible(variableViewer.parent, false)
            BlzFrameSetVisible(highlights.error, false)
            tabs.hasError[currentTab] = false
            doNotUpdateVariables[currentTab] = false
            tabs.hasUncompiledChanges[currentTab] = true
            tabs.hasUnsavedChanges[currentTab] = true
            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            end

            if step[currentTab] < maxRedo[currentTab] then
                step[currentTab] = step[currentTab] + 1
                UpdateAllLines()
                if step[currentTab] == maxRedo[currentTab] then
                    BlzFrameSetEnable(buttons.redo, false)
                end
                BlzFrameSetEnable(buttons.undo, true)
                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
            end

            SetLineOffset(lineNumberOffset[currentTab])
            JumpWindow(lineNumberOfEdit[currentTab][step[currentTab]])

            cursor.adjustedLine = lineNumberOfEdit[currentTab][step[currentTab]]
            SetCursorPos(posOfEdit[currentTab][step[currentTab]])
            cursor.rawLine = cursor.adjustedLine - lineNumberOffset[currentTab]
            SetCursorX(codeLines[currentTab][step[currentTab]][cursor.adjustedLine])
            editBoxFocused = true
            BlzFrameSetFocus(enterBox, true)
            BlzFrameSetVisible(cursorFrame, true)
        end

        local function ToggleHideEditor()
            if not codeEditorParent or not BlzFrameIsVisible(codeEditorParent) then
                EnableEditor(user)
            else
                BlzFrameSetVisible(codeEditorParent, false)
                editor.ON_DISABLE()
            end
        end

        local function ToggleHaltAlice()
            BlzFrameSetEnable(buttons.haltALICE, false)
            BlzFrameSetEnable(buttons.haltALICE, true)
            if not WSDebug.ALICEhalted then
                ALICE_Halt()
            else
                ALICE_Resume()
            end
        end

        local function LoadFileButton()
            BlzFrameSetEnable(buttons.load, false)
            BlzFrameSetEnable(buttons.load, true)

            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "loadfromfile"
                if currentTab == "Main" then
                    BlzFrameSetText(nameDialog.textField, "Main")
                else
                    BlzFrameSetText(nameDialog.textField, "Tab " .. (tabs.amount + 1))
                end
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter File Name|r")
            end
        end

        local function PullButton()
            BlzFrameSetEnable(buttons.pull, false)
            BlzFrameSetEnable(buttons.pull, true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "pullscript"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Script Name|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        local function ViewGlobalButton()
            BlzFrameSetEnable(buttons.global, false)
            BlzFrameSetEnable(buttons.global, true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "viewglobal"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Global Name|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        local function PrintTraceback()
            BlzFrameSetEnable(buttons.traceback, false)
            BlzFrameSetEnable(buttons.traceback, true)
            if WSDebug.TabIsHalted[currentTab] then
                PrintForUser(">>Traceback:\n" .. WSDebug.Traceback[currentTab])
            else
                ClearTextMessages()
                nameDialog.state = "traceback"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Function Name|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        local function QuickRestartButton()
            BlzFrameSetEnable(buttons.quickRestart, false)
            BlzFrameSetEnable(buttons.quickRestart, true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "quickrestart"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Script Names|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        buttons.execute = CreateBottomButton(1, "ReplaceableTextures\\CommandButtons\\BTNCleavingAttack.blp", Execute, "Execute", "Executes the code in the current tab after applying transformations based on the flags set.")
        buttons.flags = CreateBottomButton(2, "ReplaceableTextures\\CommandButtons\\BTNRallyPoint.blp", function()
            BlzFrameSetEnable(buttons.flags, false)
            BlzFrameSetEnable(buttons.flags, true)
            BlzFrameSetVisible(flagsMenuParent, not BlzFrameIsVisible(flagsMenuParent))
            BlzFrameSetVisible(clearMenuParent, false)
        end, "Flags", "Set various flags that influence code compilation and execution.")
        buttons.clear = CreateBottomButton(3, "ReplaceableTextures\\CommandButtons\\BTNDemolish.blp",  function()
            BlzFrameSetEnable(buttons.clear, false)
            BlzFrameSetEnable(buttons.clear, true)
            BlzFrameSetVisible(clearMenuParent, not BlzFrameIsVisible(clearMenuParent))
            BlzFrameSetVisible(flagsMenuParent, false)
        end, "Demolish", "Clear all breakpoints, delete all code, reset all line highlights, or destroy all handles created in this tab.")
        buttons.undo = CreateBottomButton(4, "ReplaceableTextures\\CommandButtons\\BTNReplay-Loop.blp", Undo, "Undo", "Undo the last edit.")
        BlzFrameSetEnable(buttons.undo, false)
        BlzFrameSetTexture(BlzFrameGetChild(buttons.undo, 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Loop.blp", 0, true)
        buttons.redo = CreateBottomButton(5, "Redo.blp", Redo, "Redo", "Redo the last edit.")
        BlzFrameSetEnable(buttons.redo, false)
        BlzFrameSetTexture(BlzFrameGetChild(buttons.redo, 2), "RedoDisabled.blp", 0, true)
        buttons.global = CreateBottomButton(6, "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp", ViewGlobalButton, "View Global", "Adds a global variable to the variable viewer.")
        buttons.traceback = CreateBottomButton(7, "ReplaceableTextures\\CommandButtons\\BTNHealingWave.blp", PrintTraceback, "Show Traceback", "If a thread in the current tab is halted, prints the traceback for that thread. Otherwise, hooks a global function of your choice, printing the traceback and arguments each time it is called. A hook added this way can be removed by entering that function a second time.")
        BlzFrameSetTexture(BlzFrameGetChild(buttons.traceback, 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNHealingWave.blp", 0, true)
        buttons.search = CreateBottomButton(8, "ReplaceableTextures\\CommandButtons\\BTNReveal.blp", ShowSearchBar, "Search", "Opens the search bar. Go to a specific line by typing :X.")

        local num = 9
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            buttons.load = CreateBottomButton(num, "ReplaceableTextures\\CommandButtons\\BTNLoad.blp", LoadFileButton, "Load From File", "Loads the code automatically saved to a file on an earlier session. The file loaded is based on the name of the current tab.")
            num = num + 1
        end

        buttons.pull = CreateBottomButton(num, "ReplaceableTextures\\CommandButtons\\BTNNagaUnBurrow.blp", PullButton, "Pull Script", "Loads a script file into a new tab. The script file must have been parsed by WSCode.Parse and is referenced by its name set in the Debug.beginFile call.")
        num = num + 1

        if compiler.ENABLE_QUICK_RESTART and FileIO then
            buttons.quickRestart = CreateBottomButton(num, "ReplaceableTextures\\CommandButtons\\BTNAnimalWarTraining.blp", QuickRestartButton, "Quick Restart", "Stores the map script in a text file, respecting all changes you have made within the editor, then restarts the map and loads the map script from that file.\n\nBefore restarting, you can enter the names of additional scripts, separated by commas, which should be transpiled into debug form and added to the editor upon map launch. All scripts added to the editor are automatically transpiled.")
            num = num + 1
        end

        buttons.benchmark = CreateBottomButton(num, "Benchmark.blp", Benchmark, "Benchmark", "Evaluates the execution time of the code in the current tab with no transformations. Do not create any leaking handles within the code you are benchmarking. Stop the benchmark by pressing this button again.")
        num = num + 1

        if ALICE_Config then
            buttons.haltALICE = CreateBottomButton(num, "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", ToggleHaltAlice, "Pause/Resume", "Pause or resume the ALICE cycle.")
            BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Pause.blp", 0, true)
        end

        if ALICE_Config then
            local oldHalt = ALICE_Halt
            ALICE_Halt = function(pauseGame)
                oldHalt(pauseGame)
                WSDebug.ALICEhalted = true
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-SpeedUp.blp", 0, true)
            end

            local oldResume = ALICE_Resume
            ALICE_Resume = function()
                oldResume()
                WSDebug.ALICEhalted = false
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons.haltALICE, 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Pause.blp", 0, true)
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Flags Menu
        ------------------------------------------------------------------------------------------------------------------------

        flagsMenuParent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(flagsMenuParent, 3)
        BlzFrameSetVisible(flagsMenuParent, false)

        backdrop = BlzFrameGetChild(flagsMenuParent, 0)
        BlzFrameSetAllPoints(backdrop, flagsMenuParent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(flagsMenuParent, 1)
        BlzFrameSetAllPoints(border, flagsMenuParent)

        BlzFrameSetPoint(flagsMenuParent, FRAMEPOINT_BOTTOM, buttons.flags, FRAMEPOINT_TOP, 0, 0)

        local function CreateFlagsButton(position, name, tooltip, initiallyEnabled, callback)
            local button = BlzCreateFrame("VariableViewerButton", flagsMenuParent, 0, 0)
            local text = BlzFrameGetChild(button, 0)
            BlzFrameSetEnable(text, false)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, flagsMenuParent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, flagsMenuParent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetAllPoints(text, button)
            indexFromFrame[button] = position

            BlzFrameSetText(text, initiallyEnabled and "|cffffcc00" .. name .. "|r" or "|cff999999" .. name .. "|r")
            local isEnabled = initiallyEnabled

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, function()
                callback()
                isEnabled = not isEnabled
                BlzFrameSetText(text, isEnabled and "|cffffcc00" .. name .. "|r" or "|cff999999" .. name .. "|r")
            end)

            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)

            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMLEFT, flagsMenuParent, FRAMEPOINT_TOPLEFT, 0, 0)
            BlzFrameSetTooltip(button, tooltipFrame)

            local tooltipTitle = BlzFrameGetChild(tooltipFrame, 0)
            local tooltipText = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(tooltipTitle, "|cffffcc00" .. name .. "|r")
            BlzFrameSetText(tooltipText, tooltip)
            BlzFrameSetSize(tooltipText, 0.22 - 0.012, 0.0)
            BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(tooltipText) + 0.035)
        end

        CreateFlagsButton(1, "Debug Mode", "Toggles whether the code in the current tab will be transpiled into its debug form when you press Execute.\n\nDebug mode is required to view variables and use breakpoints.", flags.debugMode, function()
            flags.debugMode = not flags.debugMode
            SaveSettings()
        end)
        CreateFlagsButton(2, "Run OnInit", "Toggles whether function wrapped in OnInit or WSCode.Init calls will be executed when you press Execute.", flags.runInit, function()
            flags.runInit = not flags.runInit
            SaveSettings()
        end)
        CreateFlagsButton(3, "Auto-Clean Handles", "If enabled, all handles created by previous executions of the code in the current tab will be destroyed when you press Execute.\n\nHandle creators and their associated destructors are defined in the config.", flags.cleanHandles, function()
            flags.cleanHandles = not flags.cleanHandles
            SaveSettings()
        end)

        CreateFlagsButton(4, "Smart Persist", "If enabled, local variables and table fields defined by the previous execution of the code in the current tab may be copied over to the new environment when you press Execute.\n\nA variable or field will be copied when it's uninitialized in the new environment.", flags.smartPersist, function()
            flags.smartPersist = not flags.smartPersist
            SaveSettings()
        end)

        CreateFlagsButton(5, "Hide Globals", "Hides all global variables from the variable viewer.", flags.hideGlobals, function()
            flags.hideGlobals = not flags.hideGlobals
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        CreateFlagsButton(6, "Hide Constants", "Hides all variables with a SCREAMING_SNAKE_CASE format from the variable viewer.", flags.hideConstants, function()
            flags.hideConstants = not flags.hideConstants
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        CreateFlagsButton(7, "Hide Functions", "Hides all functions from the variable viewer.", flags.hideFunctions, function()
            flags.hideFunctions = not flags.hideFunctions
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        BlzFrameSetSize(flagsMenuParent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 7*editor.LINE_SPACING)

        flags.minX = (2 - maxButtons/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH/2
        flags.maxX = (2 - maxButtons/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH/2
        flags.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(flagsMenuParent)

        ------------------------------------------------------------------------------------------------------------------------
        --Clear Menu
        ------------------------------------------------------------------------------------------------------------------------

        local function DeleteCode()
            BlzFrameSetVisible(clearMenuParent, false)
            IncrementStep()
            local currentLines = codeLines[currentTab][step[currentTab]]
            local currentColoredLines = coloredCodeLines[currentTab][step[currentTab]]
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                currentLines[i] = ""
                currentColoredLines[i] = ""
            end
            highestNonEmptyLine[currentTab][step[currentTab]] = 0
            UpdateAllLines()
            SetLineOffset(0)
        end

        local function ClearBreakpoints()
            BlzFrameSetVisible(clearMenuParent, false)
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                if lines.debugState[currentTab][i] ~= 0 then
                    lines.debugState[currentTab][i] = 0
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[0], 0, true)
                end
            end
        end

        local function DestroyHandles()
            BlzFrameSetVisible(clearMenuParent, false)
            for handle, creator in pairs(handles[currentTab]) do
                _G[CREATOR_DESTRUCTOR_PAIRS[creator]](handle)
                handles[currentTab][handle] = nil
            end
        end

        local function ResetLineHighlights()
            BlzFrameSetVisible(clearMenuParent, false)
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                lineNumberWasExecuted[currentTab][i] = nil
            end
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetText(lineNumbers[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + lineNumberOffset[currentTab]) .. "|r")
            end
        end

        clearMenuParent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(clearMenuParent, 3)
        BlzFrameSetVisible(clearMenuParent, false)

        backdrop = BlzFrameGetChild(clearMenuParent, 0)
        BlzFrameSetAllPoints(backdrop, clearMenuParent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(clearMenuParent, 1)
        BlzFrameSetAllPoints(border, clearMenuParent)

        BlzFrameSetPoint(clearMenuParent, FRAMEPOINT_BOTTOM, buttons.clear, FRAMEPOINT_TOP, 0, 0)

        local function CreateClearButton(position, name, callback)
            local button = BlzCreateFrame("VariableViewerButton", clearMenuParent, 0, 0)
            local text = BlzFrameGetChild(button, 0)
            BlzFrameSetEnable(text, false)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, clearMenuParent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, clearMenuParent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetAllPoints(text, button)
            indexFromFrame[button] = position

            BlzFrameSetText(text, "|cffffcc00" .. name .. "|r")

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, callback)
        end

        CreateClearButton(1, "Delete Code", DeleteCode)
        CreateClearButton(2, "Clear Breakpoints", ClearBreakpoints)
        CreateClearButton(3, "Reset Lines", ResetLineHighlights)
        CreateClearButton(4, "Destroy Handles", DestroyHandles)

        BlzFrameSetSize(clearMenuParent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 4*editor.LINE_SPACING)

        clearMenu.minX = (4 - maxButtons/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH/2
        clearMenu.maxX = (4 - maxButtons/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH/2
        clearMenu.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(clearMenuParent)

        ------------------------------------------------------------------------------------------------------------------------
        --Variable Viewer
        ------------------------------------------------------------------------------------------------------------------------

        variableViewer.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(variableViewer.parent, 2)
        BlzFrameSetPoint(variableViewer.parent, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + 2*variableViewer.LINE_VERTICAL_INSET)
        BlzFrameSetVisible(variableViewer.parent, hasCodeOnInit)

        backdrop = BlzFrameGetChild(variableViewer.parent, 0)
        BlzFrameSetAllPoints(backdrop, variableViewer.parent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(variableViewer.parent, 1)
        BlzFrameSetAllPoints(border, variableViewer.parent)

        buttons.back = BlzCreateFrameByType("GLUETEXTBUTTON", "", variableViewer.parent, "ScriptDialogButton", 0)
        BlzFrameSetPoint(buttons.back, FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_BOTTOMLEFT, variableViewer.WIDTH/2/0.8 - 0.025, -0.01)
        BlzFrameSetPoint(buttons.back, FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_BOTTOMLEFT, variableViewer.WIDTH/2/0.8 + 0.025, 0.015)
        BlzFrameSetText(buttons.back, "Back")
        BlzFrameSetScale(buttons.back, 0.8)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, buttons.back, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, GoBack)
        BlzFrameSetVisible(buttons.back, false)

        CreateToggleExpandButton("CollapseEditorButton", "collapseEditor.blp", variableViewer.parent)

        variableViewer.title = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
        BlzFrameSetText(variableViewer.title, "|cffffcc00Variables")
        BlzFrameSetSize(variableViewer.title, 0, 0)
        BlzFrameSetPoint(variableViewer.title, FRAMEPOINT_TOPLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET, editor.CHECKBOX_VERTICAL_SHIFT + editor.CHECKBOX_TEXT_VERTICAL_SHIFT)
        BlzFrameSetEnable(variableViewer.title, false)

        variableViewer.functionFrames[1] = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
        BlzFrameSetVisible(variableViewer.functionFrames[1], false)
        BlzFrameSetText(variableViewer.functionFrames[1], "|cffffcc00Last Function Call|r")
        BlzFrameSetScale(variableViewer.functionFrames[1], variableViewer.TEXT_SCALE)
        BlzFrameSetSize(variableViewer.functionFrames[1], 0, 0)
        BlzFrameSetEnable(variableViewer.functionFrames[1], false)
        variableViewer.functionFrames[2] = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
        BlzFrameSetPoint(variableViewer.functionFrames[2], FRAMEPOINT_TOPLEFT, variableViewer.functionFrames[1], FRAMEPOINT_TOPLEFT, 0, -editor.LINE_SPACING - variableViewer.FUNCTION_CALL_SPACING)
        BlzFrameSetVisible(variableViewer.functionFrames[2], false)
        BlzFrameSetEnable(variableViewer.functionFrames[2], false)
        BlzFrameSetScale(variableViewer.functionFrames[2], variableViewer.TEXT_SCALE)
        variableViewer.functionFrames[3] = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
        BlzFrameSetVisible(variableViewer.functionFrames[3], false)
        BlzFrameSetText(variableViewer.functionFrames[3], ")")
        BlzFrameSetSize(variableViewer.functionFrames[3], 0, 0)
        BlzFrameSetEnable(variableViewer.functionFrames[3], false)
        BlzFrameSetScale(variableViewer.functionFrames[3], variableViewer.TEXT_SCALE)

        ------------------------------------------------------------------------------------------------------------------------
        --Context Menu
        ------------------------------------------------------------------------------------------------------------------------

        contextMenu.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(contextMenu.parent, 3)
        BlzFrameSetVisible(contextMenu.parent, false)
        BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 8*editor.LINE_SPACING)

        backdrop = BlzFrameGetChild(contextMenu.parent, 0)
        BlzFrameSetAllPoints(backdrop, contextMenu.parent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(contextMenu.parent, 1)
        BlzFrameSetAllPoints(border, contextMenu.parent)

        local function CreateContextButton(position, name, tooltip, callback)
            local button = BlzCreateFrame("VariableViewerButton", contextMenu.parent, 0, 0)
            local text = BlzFrameGetChild(button, 0)
            BlzFrameSetEnable(text, false)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, contextMenu.parent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, contextMenu.parent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetAllPoints(text, button)
            indexFromFrame[button] = position

            BlzFrameSetText(text, name)

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, callback)

            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)

            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMRIGHT, contextMenu.parent, FRAMEPOINT_TOPRIGHT, 0, 0)
            BlzFrameSetTooltip(button, tooltipFrame)

            local tooltipTitle = BlzFrameGetChild(tooltipFrame, 0)
            local tooltipText = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(tooltipTitle, "|cffffcc00" .. name .. "|r")
            BlzFrameSetText(tooltipText, tooltip)
            BlzFrameSetSize(tooltipText, 0.22 - 0.012, 0.0)
            BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(tooltipText) + 0.035)
            BlzFrameSetVisible(tooltipFrame, false)

            return button
        end

        contextMenu.gotodef = CreateContextButton(1, "Go to Definition", "Go to the declaration of the selected variable within this file.", function()
            local currentLines = codeLines[currentTab][step[currentTab]]
            local word = sub(currentLines[selection.startLine], math.min(selection.startPos, selection.endPos) + 1, math.max(selection.startPos, selection.endPos))
            local start, stop
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                --local var1, var, word / word = / function word
                if find(currentLines[i], "local\x25s+([\x25w_\x25s,]-)\x25f[\x25a]" .. word .. "\x25f[^\x25w_]") ~= nil or find(currentLines[i], word .. "\x25s*=[^=]") ~= nil or find(currentLines[i], "function\x25s+" .. word) ~= nil then
                    start, stop = find(currentLines[i], word)
                end
                if start then
                    selection.startLine = i
                    selection.endLine = i
                    selection.startPos = start - 1
                    selection.endPos = stop
                    SetSelection(GetTextWidth(sub(currentLines[i], 1, stop)))
                    cursor.adjustedLine = selection.startLine
                    cursor.rawLine = selection.startLine - lineNumberOffset[currentTab]
                    SetCursorPos(selection.endPos)
                    SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.adjustedLine], 1, selection.endPos))
                    JumpWindow(i)
                    BlzFrameSetVisible(contextMenu.parent, false)
                    BlzFrameSetFocus(enterBox, true)
                    editBoxFocused = true
                    BlzFrameSetVisible(cursorFrame, true)
                    return
                end
            end

            PlayError()
            BlzFrameSetVisible(contextMenu.parent, false)
        end)

        contextMenu.execute = CreateContextButton(2, "Execute", "Executes the selected code in a new thread and environment. If no code is selected, executes the current line of the cursor instead.", function()
            local lines
            if selection.hasSelection then
                lines = ConvertSelectionToLines()
            else
                lines = {codeLines[currentTab][step[currentTab]][cursor.adjustedLine]}
            end
            CompileFunction(lines, {
                tab = currentTab .. " (Execute)",
            })
            BlzFrameSetVisible(contextMenu.parent, false)
        end)

        local function EvaluateExpression(line)
            local alteredLine = line
            local finds = {}
            local stringList = {}
            line = line:gsub('"[^"]*"', function(str)
                stringList[#stringList + 1] = str
                return "__DSTRING" .. #stringList
            end)
            line = line:gsub("'[^']*'", function(str)
                stringList[#stringList + 1] = str
                return "__SSTRING" .. #stringList
            end)
            for start, match in line:gmatch("()(\x25f[\x25a_][\x25w_]+)") do
                local charBefore = start > 1 and line:sub(start - 1, start - 1) or ""
                if charBefore ~= "." and charBefore ~= ":" then
                    if not finds[match] and not LUA_KEYWORDS[match] then
                        local level = visibleVarsOfLine[currentTab][lastLineNumber[currentTab]][match]
                        if level then
                            alteredLine = alteredLine:gsub("\x25f[\x25a_]" .. match .. "\x25f[^\x25w_]", "(WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. match .. "\"] or match)")
                        end
                    end
                end
                finds[match] = true
            end
            for i = 1, #stringList do
                line = line:gsub("__DSTRING" .. i, '"' .. stringList[i] .. '"'):gsub("__SSTRING" .. i, "'" .. stringList[i] .. "'")
                alteredLine = alteredLine:gsub("__DSTRING" .. i, '"' .. stringList[i] .. '"'):gsub("__SSTRING" .. i, "'" .. stringList[i] .. "'")
            end

            local func = load("PrintForUser([==[" .. line .. "\n>> ]==] .. tostring(" .. alteredLine .. "))", "WSCodeEvaluate", "t")
            if not func then
                PrintForUser("|cffff5555ERROR: Invalid expression for evaluation.|r")
                return
            end
            func()
        end

        contextMenu.evaluate = CreateContextButton(3, "Evaluate", "Prints out the return value of the selected expression. If no code is selected, opens the prompt window, allowing your to evaluate any expression.\n\nLocal variables referenced in the expression must currently be visible to be accessed.", function()
            BlzFrameSetVisible(contextMenu.parent, false)

            if not selection.hasSelection then
                if not BlzFrameIsVisible(nameDialog.parent) then
                    ClearTextMessages()
                    nameDialog.state = "evaluate"
                    BlzFrameSetVisible(nameDialog.parent, true)
                    BlzFrameSetFocus(nameDialog.textField, true)
                    BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Expression|r")
                    BlzFrameSetText(nameDialog.textField, "")
                end
                return
            end

            local lines = ConvertSelectionToLines()
            if #lines > 1 then
                PrintForUser("|cffff5555ERROR: Cannot evaluate expression spanning multiple lines.|r")
                PlayError()
                return
            end

            EvaluateExpression(lines[1])
        end)

        contextMenu.assign = CreateContextButton(4, "Assign", "Opens the prompt window and assigns the entered value to the selected upvalue or table field.", function()
            local lines = ConvertSelectionToLines()
            if #lines > 1 then
                PrintForUser("|cffff5555ERROR: Expression spans multiple lines.|r")
                PlayError()
                return
            end

            local line = lines[1]

            --Upvalue
            if not line:find("[\x25.\x25[]") then
                if line:find("[^\x25w_]") then
                    PrintForUser("|cffff5555ERROR: Invalid expression for assignment.|r")
                    return
                end

                if not WSDebug.Injectors[currentTab][line] then
                    PrintForUser("|cffff5555ERROR: Variable cannot be reassigned.|r")
                    return
                end

                contextMenu.assignTableTrace = nil
                contextMenu.injectorName = line
            else
                --Table field
                local tableName = line:match("^(\x25w+)")

                local level
                local i = selection.startLine
                repeat
                    i = i + 1
                    level = visibleVarsOfLine[currentTab][i][tableName]
                until level or i >= highestNonEmptyLine[currentTab][step[currentTab]]

                if not level then
                    PrintForUser("|cffff5555ERROR: Variable is currently not visible.|r")
                    return
                end

                local lineNumber = i
                local tableTrace = {}

                local stringList = {}
                line = line:gsub('"[^"]*"', function(str)
                    stringList[#stringList + 1] = str
                    return "__STRING" .. #stringList
                end)
                line = line:gsub("'[^']*'", function(str)
                    stringList[#stringList + 1] = str
                    return "__STRING" .. #stringList
                end)

                local beginning = 1
                local tableVar
                local pos
                repeat
                    pos = find(line, "[\x25.\x25[]", beginning)
                    if pos then
                        tableVar = sub(line, beginning, pos - 1)
                    else
                        tableVar = sub(line, beginning)
                    end

                    if beginning == 1 then
                        level = visibleVarsOfLine[currentTab][lineNumber][tableVar]
                        if level then
                            tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                        elseif _G[tableVar] then
                            tableTrace[#tableTrace + 1] = _G[tableVar]
                        else
                            PrintForUser("|cffff5555ERROR: Unknown error.")
                            return
                        end
                    elseif sub(tableVar, -1, -1) == "]" then
                        tableVar = sub(tableVar, 1, -2)
                        if tonumber(tableVar) then
                            tableTrace[#tableTrace + 1] = tonumber(tableVar)
                        elseif sub(tableVar, 1, 1) == "'" or sub(tableVar, 1, 1) == '"' then
                            tableTrace[#tableTrace + 1] = sub(tableVar, 2, -2)
                        else
                            local level = visibleVarsOfLine[currentTab][lineNumber][tableVar]
                            if level then
                                tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                            elseif _G[tableVar] then
                                tableTrace[#tableTrace + 1] = _G[tableVar]
                            else
                                PrintForUser("|cffff5555ERROR: Invalid subtable index.")
                                return
                            end
                        end
                    else
                        tableTrace[#tableTrace + 1] = tableVar
                    end
                    if pos then
                        beginning = pos + 1
                    end
                until pos == nil

                for i = 1, #stringList do
                    for j = 1, #tableTrace do
                        if type(tableTrace[j]) == "string" then
                            tableTrace[j] = tableTrace[j]:gsub("__STRING" .. i, sub(stringList[i], 2, -2))
                        end
                    end
                    line = line:gsub("__STRING" .. i, stringList[i])
                end

                local var = tableTrace[1]
                for i = 2, #tableTrace do
                    if type(var) ~= "table" then
                        PrintForUser("|cffff5555ERROR: Unknown error.")
                        return
                    end
                end

                contextMenu.assignTableTrace = tableTrace
                contextMenu.injectorName = nil
            end

            BlzFrameSetVisible(contextMenu.parent, false)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "assign"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter New Value|r")
                BlzFrameSetText(nameDialog.textField, "")
                BlzFrameSetFocus(nameDialog.textField, true)
            end
        end)

        contextMenu.expose = CreateContextButton(5, "Expose", "Opens the prompt window and assigns the selected local variable to the global with the entered name.", function()
            if selection.startLine ~= selection.endLine then
                PlayError()
                return
            end

            local currentLines = codeLines[currentTab][step[currentTab]]
            local word = sub(currentLines[selection.startLine], math.min(selection.startPos, selection.endPos) + 1, math.max(selection.startPos, selection.endPos))

            if word:find("[^\x25w_]") then
                PlayError()
                return
            end

            local level
            local i = selection.startLine + 1
            while not level and i <= highestNonEmptyLine[currentTab][step[currentTab]] do
                level = visibleVarsOfLine[currentTab][i][word]
                i = i + 1
            end
            if not level then
                PrintForUser("|cffff5555ERROR: Variable is currently not visible.|r")
                return
            end

            contextMenu.exposedValue = WSDebug.VarTable[currentTab][level][word]

            if contextMenu.exposedValue == nil or contextMenu.exposedValue == WSDebug.Nil then
                PrintForUser("|cffff5555ERROR: Exposed variable is nil.")
                return
            end

            BlzFrameSetVisible(contextMenu.parent, false)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "expose"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Global Name|r")
                BlzFrameSetText(nameDialog.textField, word:sub(1,1):upper() .. word:sub(2))
                BlzFrameSetFocus(nameDialog.textField, true)
            end
        end)

        contextMenu.cut = CreateContextButton(6, "Cut", "Cuts the selected text and adds it to the internal buffer. Does not add it to the clipboard.", function()
            clipboard = ConvertSelectionToLines()
            IncrementStep()
            DeleteSelection()
            BlzFrameSetVisible(contextMenu.parent, false)
        end)

        contextMenu.copy = CreateContextButton(7, "Copy", "Adds the selected text to the internal buffer. Does not add it to the clipboard.", function()
            clipboard = ConvertSelectionToLines()
            BlzFrameSetVisible(contextMenu.parent, false)
        end)

        contextMenu.paste = CreateContextButton(8, "Paste", "Inserts the text stored in the internal buffer. To paste text from the clipboard, press Ctrl + V instead.", function()
            if clipboard and #clipboard > 0 then
                IncrementStep()
                if selection.hasSelection then
                    DeleteSelection()
                end
                local text = clipboard[1]
                for i = 2, #clipboard do
                    text = text .. "\n" .. clipboard[i]
                end
                ChangeCodeLine(text)
                BlzFrameSetVisible(contextMenu.parent, false)
                BlzFrameSetFocus(enterBox, true)
            end
        end)

        ------------------------------------------------------------------------------------------------------------------------
        --Tab Navigators
        ------------------------------------------------------------------------------------------------------------------------

        trig = CreateTrigger()
        TriggerAddAction(trig, ClickTabButton)

        local name = tabs.names[1]
        tabs.truncatedNames[name] = find(name, "\\\\") ~= nil and sub(name, match(name, ".*()\\\\") + 2, nil) or name
        tabNavigator.frames[name] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
        tabNavigator.titles[name] = BlzFrameGetChild(tabNavigator.frames[name], 2)
        tabNavigator.highlights[name] = BlzFrameGetChild(tabNavigator.frames[name], 3)
        BlzFrameSetAlpha(tabNavigator.highlights[name], 0)
        if tabs.wasNotCompiledInDebugMode[name] then
            BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[name] .. "|r")
        else
            BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[name] .. "|r")
        end
        BlzFrameSetSize(tabNavigator.titles[name], 0, 0)
        local width = BlzFrameGetWidth(tabNavigator.titles[name])
        tabNavigator.widths[name] = math.max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
        BlzFrameSetAllPoints(tabNavigator.titles[name], tabNavigator.frames[name])
        BlzFrameSetTextAlignment(tabNavigator.titles[name], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(tabNavigator.titles[name], false)
        BlzFrameSetSize(tabNavigator.frames[name], tabNavigator.widths[name], tabNavigator.HEIGHT)
        BlzFrameSetPoint(tabNavigator.frames[name], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
        BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[name], 1), tabNavigator.frames[name])
        BlzFrameSetAlpha(BlzFrameGetChild(tabNavigator.frames[name], 1), editor.BLACK_BACKDROP_ALPHA)
        BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[name], FRAMEEVENT_CONTROL_CLICK)
        tabs.numberFromFrame[tabNavigator.frames[name]] = 1

        for t = 2, tabs.amount do
            name = tabs.names[t]
            tabs.truncatedNames[name] = find(name, "\\\\") ~= nil and sub(name, match(name, ".*()\\\\") + 2, nil) or name
            tabNavigator.frames[name] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
            tabNavigator.titles[name] = BlzFrameGetChild(tabNavigator.frames[name], 2)
            tabNavigator.highlights[name] = BlzFrameGetChild(tabNavigator.frames[name], 3)
            if tabs.wasNotCompiledInDebugMode[name] then
                BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[name] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_UNSELECTED_COLOR .. tabs.truncatedNames[name] .. "|r")
            end
            BlzFrameSetSize(tabNavigator.titles[name], 0, 0)
            width = BlzFrameGetWidth(tabNavigator.titles[name])
            tabNavigator.widths[name] = math.max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
            BlzFrameSetAllPoints(tabNavigator.titles[name], tabNavigator.frames[name])
            BlzFrameSetTextAlignment(tabNavigator.titles[name], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            BlzFrameSetEnable(tabNavigator.titles[name], false)
            BlzFrameSetSize(tabNavigator.frames[name], tabNavigator.widths[name], tabNavigator.HEIGHT)
            BlzFrameSetPoint(tabNavigator.frames[name], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[t - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
            BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[name], 1), tabNavigator.frames[name])
            BlzFrameSetAlpha(BlzFrameGetChild(tabNavigator.frames[name], 1), editor.BLACK_BACKDROP_ALPHA)
            BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[name], FRAMEEVENT_CONTROL_CLICK)
            tabs.numberFromFrame[tabNavigator.frames[name]] = t
        end

        for t = 1, tabs.amount do
            closeButton = BlzCreateFrame("CloseEditorButton", tabNavigator.frames[tabs.names[t]], 0, 0)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[t]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, tabNavigator.frames[tabs.names[t]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET, -tabNavigator.CLOSE_BUTTON_INSET)
            icon = BlzFrameGetChild(closeButton, 0)
            iconClicked = BlzFrameGetChild(closeButton, 1)
            iconHighlight = BlzFrameGetChild(closeButton, 2)
            BlzFrameSetAllPoints(icon, closeButton)
            BlzFrameSetTexture(icon, "closeEditor.blp", 0, true)
            BlzFrameSetTexture(iconClicked, "closeEditor.blp", 0, true)
            BlzFrameClearAllPoints(iconHighlight)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
            BlzFrameSetVisible(closeButton, false)
            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, CloseTab)
            tabs.numberFromFrame[closeButton] = t
            tabNavigator.closeButtons[tabs.names[t]] = closeButton
        end

        tabs.addTabFrame = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
        tabs.addTabTitle = BlzFrameGetChild(tabs.addTabFrame, 2)
        BlzFrameSetText(tabs.addTabTitle, editor.TAB_NAVIGATOR_SELECTED_COLOR .. "+" .. "|r")
        BlzFrameSetAllPoints(tabs.addTabTitle, tabs.addTabFrame)
        BlzFrameSetTextAlignment(tabs.addTabTitle, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(tabs.addTabTitle, false)
        BlzFrameSetSize(tabs.addTabFrame, tabNavigator.HEIGHT, tabNavigator.HEIGHT)
        BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
        BlzFrameSetAllPoints(BlzFrameGetChild(tabs.addTabFrame, 1), tabs.addTabFrame)
        BlzFrameSetAlpha(BlzFrameGetChild(tabs.addTabFrame, 1), editor.BLACK_BACKDROP_ALPHA)

        AdjustTabWidths()

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, tabs.addTabFrame, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetEnable(tabs.addTabFrame, false)
            BlzFrameSetEnable(tabs.addTabFrame, true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "addtab"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Tab Name|r")
                for i = tabs.amount + 1, 1, -1 do
                    local occupado = false
                    for j = 1, tabs.amount do
                        if tabs.names[j] == "Tab " .. i then
                            occupado = true
                            break
                        end
                    end
                    if not occupado then
                        BlzFrameSetText(nameDialog.textField, "Tab " .. i)
                        return
                    end
                end
            end
        end)

        ------------------------------------------------------------------------------------------------------------------------
        --Enter Name Dialog
        ------------------------------------------------------------------------------------------------------------------------

        nameDialog.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(nameDialog.parent, 3)
        BlzFrameSetAbsPoint(nameDialog.parent, FRAMEPOINT_CENTER, 0.4, 0.3)
        BlzFrameSetSize(nameDialog.parent, nameDialog.WIDTH, nameDialog.HEIGHT)

        backdrop = BlzFrameGetChild(nameDialog.parent, 0)
        BlzFrameSetAllPoints(backdrop, nameDialog.parent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(nameDialog.parent, 1)
        BlzFrameSetAllPoints(border, nameDialog.parent)

        nameDialog.title = BlzCreateFrameByType("TEXT", "", nameDialog.parent, "", 0)
        BlzFrameSetPoint(nameDialog.title, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, 0, -nameDialog.TITLE_VERTICAL_SHIFT)
        BlzFrameSetPoint(nameDialog.title, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_BOTTOMLEFT, 0, nameDialog.TITLE_VERTICAL_SHIFT)
        BlzFrameSetTextAlignment(nameDialog.title, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(nameDialog.title, false)

        nameDialog.textField = BlzCreateFrame("EscMenuEditBoxTemplate", nameDialog.parent, 0, 0)
        BlzFrameSetPoint(nameDialog.textField, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOPLEFT, nameDialog.ENTER_BOX_HORIZONTAL_INSET, -nameDialog.ENTER_BOX_VERTICAL_SHIFT - nameDialog.ENTER_BOX_HEIGHT)
        BlzFrameSetPoint(nameDialog.textField, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -nameDialog.ENTER_BOX_HORIZONTAL_INSET,  -nameDialog.ENTER_BOX_VERTICAL_SHIFT)

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, nameDialog.textField, FRAMEEVENT_EDITBOX_ENTER)
        TriggerAddAction(trig, function()
            BlzFrameSetVisible(nameDialog.parent, false)
            BlzFrameSetVisible(helper.frame, false)
            BlzFrameSetFocus(nameDialog.textField, false)

            local enteredName = BlzGetTriggerFrameText():gsub("\\", "\\\\")

            if nameDialog.state == "addtab" then
                for i = 1, #fileNames do
                    if fileNames[i] == enteredName then
                        PrintForUser("|cffff5555ERROR: A file with that name already exists. If you want to add that script to the editor, use Pull Script button instead.|r")
                        PlayError()
                        return
                    end
                end
                for i = 1, tabs.amount do
                    if tabs.names[i] == enteredName then
                        PrintForUser("|cffff5555ERROR: A tab with that name already exists.")
                        PlayError()
                        return
                    end
                end
                AddTab(enteredName)
                SwitchToTab(enteredName)
            elseif nameDialog.state == "viewglobal" then
                if not _G[enteredName] then
                    PrintForUser("|cffff5555ERROR: No global with that name exists.|r")
                    PlayError()
                    return
                end
                for __, name in ipairs(variableViewer.viewedGlobals) do
                    if name == enteredName then
                        return
                    end
                end
                variableViewer.viewedGlobals[#variableViewer.viewedGlobals + 1] = enteredName
                UpdateVariableViewer(lastLineNumber[currentTab])
            elseif nameDialog.state == "pullscript" then
                if Pull(enteredName) then
                    SwitchToTab(enteredName)
                end
            elseif nameDialog.state == "expose" then
                PrintForUser(Value2String(contextMenu.exposedValue, false, nil, true) .. " saved to global " .. enteredName .. ".")
                _G[enteredName] = contextMenu.exposedValue
                variableViewer.viewedGlobals[#variableViewer.viewedGlobals + 1] = enteredName
                UpdateVariableViewer(lastLineNumber[currentTab])
            elseif nameDialog.state == "assign" then
                local value
                if tonumber(enteredName) then
                    value = tonumber(enteredName)
                elseif _G[enteredName] then
                    value = _G[enteredName]
                elseif enteredName:sub(1, 1) == "\"" or enteredName:sub(1, 1) == "'" then
                    value = enteredName:sub(2, -2)
                elseif enteredName == "true" then
                    value = true
                elseif enteredName == "false" then
                    value = false
                elseif enteredName == "nil" then
                    value = nil
                else
                    PrintForUser("|cffff5555ERROR: Invalid value.")
                    return
                end

                if contextMenu.assignTableTrace then
                    local lastTable = contextMenu.assignTableTrace[#contextMenu.assignTableTrace - 1]
                    local lastKey = contextMenu.assignTableTrace[#contextMenu.assignTableTrace]
                    lastTable[lastKey] = value
                    PrintForUser("Assigned value " .. enteredName .. " to table field.")
                else
                    WSDebug.Injectors[currentTab][contextMenu.injectorName](value)
                    PrintForUser("Assigned value " .. enteredName .. " to " .. contextMenu.injectorName .. ".")
                end
                UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            elseif nameDialog.state == "loadfromfile" then
                local str = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. enteredName:gsub(" ", "") .. ".txt")
                if not str then
                    PrintForUser("|cffff5555ERROR: No file found at path " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. enteredName:gsub(" ", "") .. ".|r")
                    return
                end

                StoreCode(enteredName, str)
                SwitchToTab(enteredName)
            elseif nameDialog.state == "quickrestart" then
                local toDebugFiles = {}
                local start = 1
                local commaPos = find(enteredName, ",")
                local thisFile
                while commaPos do
                    thisFile = sub(enteredName, start, commaPos - 1):gsub("^\x25s*", ""):gsub("\x25s*$", "")
                    if existingFiles[thisFile] then
                        toDebugFiles[thisFile] = true
                    else
                        PrintForUser("|cffff5555ERROR: Unrecognized file name " .. thisFile .. ".|r")
                        return
                    end
                    start = commaPos + 1
                    commaPos = find(enteredName, ",", start)
                end
                thisFile = sub(enteredName, start):gsub("^\x25s*", ""):gsub("\x25s*$", "")
                if not find(thisFile, "^\x25s*$") then
                    if existingFiles[thisFile] then
                        toDebugFiles[thisFile] = true
                    else
                        PrintForUser("|cffff5555ERROR: Unrecognized file name " .. thisFile .. ".|r")
                        return
                    end
                end
                QuickRestart(toDebugFiles)
            elseif nameDialog.state == "evaluate" then
                EvaluateExpression(enteredName)
            elseif nameDialog.state == "traceback" then
                local hostTable = _G
                local pos = 1
                local dotPos
                repeat
                    dotPos = enteredName:find("[\x25.:]", pos)
                    if dotPos then
                        hostTable = hostTable[enteredName:sub(pos, dotPos - 1)]
                        pos = dotPos + 1
                    end
                until dotPos == nil

                local funcName = enteredName:sub(pos)
                local func = hostTable[funcName]

                for i = 1, #hookedFuncs.hooked do
                    if hookedFuncs.hooked[i] == func then
                        hostTable[funcName] = hookedFuncs.original[i]
                        hookedFuncs.original[i] = hookedFuncs.original[#hookedFuncs.original]
                        hookedFuncs.original[#hookedFuncs.original] = nil
                        hookedFuncs.hooked[i] = hookedFuncs.hooked[#hookedFuncs.hooked]
                        hookedFuncs.hooked[#hookedFuncs.hooked] = nil
                        PrintForUser("Traceback hook removed for function " .. enteredName .. ".")
                        return
                    end
                end

                hookedFuncs.original[#hookedFuncs.original + 1] = func
                hostTable[funcName] = function(...)
                    local argString
                    if select("#", ...) > 0 then
                        argString = tostring(select(1, ...))
                        for i = 2, select("#", ...) do
                            argString = argString .. ", " .. tostring(select(i, ...))
                        end
                    end
                    PrintForUser("\n|cffffcc00Function:|r " .. enteredName .. "\n|cffffcc00Traceback:|r " .. Debug.traceback() .. "\n|cffffcc00Args:|r " .. argString)
                    func(...)
                end
                hookedFuncs.hooked[#hookedFuncs.hooked + 1] = hostTable[funcName]

                PrintForUser("Traceback hook added to function " .. enteredName .. ".")
            end
        end)

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, nameDialog.textField, FRAMEEVENT_EDITBOX_TEXT_CHANGED)
        TriggerAddAction(trig, function()
            if nameDialog.state ~= "expose" and nameDialog.state ~= "assign" and nameDialog.state ~= "loadfromfile" and nameDialog.state ~= "evaluate" then
                CheckForAutoCompleteSuggestions(BlzGetTriggerFrameText(), nil, true, false, nameDialog.state == "pullscript" or nameDialog.state == "quickrestart", nameDialog.state == "quickrestart")
            end
        end)

        local closeNameDialogButton = BlzCreateFrame("CloseEditorButton", nameDialog.parent, 0, 0)
		BlzFrameSetPoint(closeNameDialogButton, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(closeNameDialogButton, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(closeNameDialogButton, 0)
        iconClicked = BlzFrameGetChild(closeNameDialogButton, 1)
        iconHighlight = BlzFrameGetChild(closeNameDialogButton, 2)
        BlzFrameSetAllPoints(icon, closeNameDialogButton)
		BlzFrameSetTexture(icon, "closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, "closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeNameDialogButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeNameDialogButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeNameDialogButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetVisible(nameDialog.parent, false)
            BlzFrameSetVisible(helper.frame, false)
            BlzFrameSetFocus(nameDialog.textField, false)
        end)

        BlzFrameSetVisible(nameDialog.parent, false)

        ------------------------------------------------------------------------------------------------------------------------
        --Search Bar
        ------------------------------------------------------------------------------------------------------------------------

        searchBar.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(searchBar.parent, 2)
        BlzFrameSetPoint(searchBar.parent, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -searchBar.HORIZONTAL_INSET, -searchBar.VERTICAL_INSET)
        BlzFrameSetSize(searchBar.parent, searchBar.WIDTH, searchBar.HEIGHT)
        BlzFrameSetVisible(searchBar.parent, false)

        backdrop = BlzFrameGetChild(searchBar.parent, 0)
        BlzFrameSetAllPoints(backdrop, searchBar.parent)
        BlzFrameSetAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(searchBar.parent, 1)
        BlzFrameSetAllPoints(border, searchBar.parent)
        BlzFrameSetVisible(border, false)

        searchBar.textField = BlzCreateFrame("SearchBarEditBox", searchBar.parent, 0, 0)
        BlzFrameSetPoint(searchBar.textField, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_BOTTOMLEFT, searchBar.SEARCH_FIELD_LEFT_INSET, searchBar.SEARCH_FIELD_BOTTOM_INSET)
        BlzFrameSetPoint(searchBar.textField, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_FIELD_RIGHT_INSET,  -searchBar.SEARCH_FIELD_TOP_INSET)
        BlzFrameSetVisible(BlzFrameGetChild(searchBar.textField, 0), false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.textField, FRAMEEVENT_EDITBOX_TEXT_CHANGED)
        TriggerAddAction(trig, OnSearchBarEdit)

        local closeSearchBarButton = BlzCreateFrame("CloseEditorButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(closeSearchBarButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(closeSearchBarButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(closeSearchBarButton, 0)
        iconClicked = BlzFrameGetChild(closeSearchBarButton, 1)
        iconHighlight = BlzFrameGetChild(closeSearchBarButton, 2)
        BlzFrameSetAllPoints(icon, closeSearchBarButton)
		BlzFrameSetTexture(icon, "closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, "closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeSearchBarButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeSearchBarButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeSearchBarButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetVisible(searchBar.parent, false)
            BlzFrameSetFocus(searchBar.textField, false)
            for i = 1, #searchBar.highlights do
                ReturnTextHighlightFrame(searchBar.highlights[i])
                searchBar.highlights[i] = nil
            end
        end)

        searchBar.searchDownButton = BlzCreateFrame("SearchDownButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(searchBar.searchDownButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 2*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(searchBar.searchDownButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(searchBar.searchDownButton, 0)
        iconClicked = BlzFrameGetChild(searchBar.searchDownButton, 1)
        iconHighlight = BlzFrameGetChild(searchBar.searchDownButton, 2)
        BlzFrameSetAllPoints(icon, searchBar.searchDownButton)
		BlzFrameSetTexture(icon, "searchArrowDown.blp", 0, true)
		BlzFrameSetTexture(iconClicked, "searchArrowDown.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, searchBar.searchDownButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, searchBar.searchDownButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        BlzFrameSetEnable(searchBar.searchDownButton, false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.searchDownButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, SearchDown)

        searchBar.searchUpButton = BlzCreateFrame("SearchUpButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(searchBar.searchUpButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 3*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(searchBar.searchUpButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 2*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(searchBar.searchUpButton, 0)
        iconClicked = BlzFrameGetChild(searchBar.searchUpButton, 1)
        iconHighlight = BlzFrameGetChild(searchBar.searchUpButton, 2)
        BlzFrameSetAllPoints(icon, searchBar.searchUpButton)
		BlzFrameSetTexture(icon, "searchArrowUp.blp", 0, true)
		BlzFrameSetTexture(iconClicked, "searchArrowUp.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, searchBar.searchUpButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, searchBar.searchUpButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        BlzFrameSetEnable(searchBar.searchUpButton, false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.searchUpButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, SearchUp)

        searchBar.numResults = BlzCreateFrameByType("TEXT", "", searchBar.parent, "", 0)
        BlzFrameSetPoint(searchBar.numResults, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_BOTTOMLEFT, searchBar.NUM_FINDS_LEFT_INSET/0.825, searchBar.NUM_FINDS_TOP_INSET/0.825)
        BlzFrameSetPoint(searchBar.numResults, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.NUM_FINDS_LEFT_INSET/0.825, -searchBar.NUM_FINDS_TOP_INSET/0.825)
        BlzFrameSetScale(searchBar.numResults, 0.825)
        BlzFrameSetEnable(searchBar.numResults, false)
        BlzFrameSetTextAlignment(searchBar.numResults, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")

        ------------------------------------------------------------------------------------------------------------------------
        --Control Triggers
        ------------------------------------------------------------------------------------------------------------------------

        local function CreateControlTriggers(player)
            if editor.NEXT_LINE_HOTKEY then
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, player, _G["OSKEY_" .. editor.NEXT_LINE_HOTKEY], editor.NEXT_LINE_METAKEY, true)
                TriggerAddAction(trig, NextLine)
            end

            if editor.CONTINUE_HOTKEY then
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, player, _G["OSKEY_" .. editor.CONTINUE_HOTKEY], editor.CONTINUE_METAKEY, true)
                TriggerAddAction(trig, ContinueExecuting)
            end

            if editor.TOGGLE_HIDE_EDITOR_HOTKEY then
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, player, _G["OSKEY_" .. editor.TOGGLE_HIDE_EDITOR_HOTKEY], editor.TOGGLE_HIDE_EDITOR_METAKEY, true)
                TriggerAddAction(trig, ToggleHideEditor)
            end

            trig = CreateTrigger()
            TriggerRegisterPlayerEvent(trig, player, EVENT_PLAYER_MOUSE_MOVE)
            TriggerAddAction(trig, function()
                WSDebug.MouseX = BlzGetTriggerPlayerMouseX()
                WSDebug.MouseY = BlzGetTriggerPlayerMouseY()
            end)

            trig = CreateTrigger()
            TriggerRegisterPlayerEvent(trig, player, EVENT_PLAYER_MOUSE_DOWN)
            TriggerAddAction(trig, OnMouseClick)

            trig = CreateTrigger()
            TriggerRegisterPlayerEvent(trig, player, EVENT_PLAYER_MOUSE_UP)
            TriggerAddAction(trig, OnMouseRelease)

            trig = CreateTrigger()
            TriggerRegisterPlayerEvent(trig, player, EVENT_PLAYER_MOUSE_MOVE)
            TriggerAddAction(trig, OnMouseMove)

            --Any registered key event means the enter box is not focused.
            trig = CreateTrigger()
            for name, oskey in pairs(_G) do
                if find(name, "^OSKEY_") then
                    for metakey = 0, 3 do
                        BlzTriggerRegisterPlayerKeyEvent(trig, player, oskey, metakey, true)
                    end
                end
            end
            TriggerAddAction(trig, function()
                editBoxFocused = false
                BlzFrameSetVisible(cursorFrame, false)
            end)
        end

        if whichPlayer then
            CreateControlTriggers(whichPlayer)
        else
            for i = 0, 23 do
                if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    CreateControlTriggers(Player(i))
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Load Tabs
        ------------------------------------------------------------------------------------------------------------------------

        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            if not init.tabsInitialized then
                InitTabs()
            end

            if init.pullTabs then
                for fileName, __ in pairs(init.pullTabs) do
                    if existingFiles[fileName] then
                        if init then
                            local code = table.concat(files[existingFiles[fileName]])
                            if (not code or (not find(code, "@debug") and not find(code, "@store"))) and (not init.debugTabs or not init.debugTabs[fileName]) then
                                Pull(fileName)
                            end
                        else
                            Pull(fileName)
                        end
                    end
                end
            end

            if init.loadTabs then
                for fileName, __ in pairs(init.loadTabs) do
                    local code = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".txt")
                    if code then
                        StoreCode(fileName, code)
                    end
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Misc
        ------------------------------------------------------------------------------------------------------------------------

        TimerStart(CreateTimer(), 0.01, true, AdjustLineDisplay)

        local tableTrace = ""
        local level = 0
        local function GetAllTableFields(source, target)
            level = level + 1
            for key, value in pairs(source) do
                if type(key) == "string" and key ~= "_G" and level <= 4 then
                    target[#target + 1] = key
                    if type(value) == "table" then
                        target[key] = {}
                        tableTrace = tableTrace .. "." .. key
                        GetAllTableFields(value, target[key])
                    end
                end
            end
            table.sort(target)
            level = level - 1
        end

        GetAllTableFields(_G, globalLookupTable)
        for i = 1, #globalLookupTable do
            if not globalLookupTable[globalLookupTable[i]] then
                --globalLookupTable has both a sequence and a dictionary. A table key means global is a table. Otherwise, true.
                globalLookupTable[globalLookupTable[i]] = true
            end
        end

        if not GetTerrainZ then
            local moveableLoc = Location(0, 0)
            GetTerrainZ = function(x, y)
                MoveLocation(moveableLoc, x, y)
                return GetLocationZ(moveableLoc)
            end
        end

        brackets.highlights[1] = GetTextHighlightFrame("08", 130, "bracketHighlight")
        BlzFrameSetVisible(brackets.highlights[1], false)
        brackets.highlights[2] = GetTextHighlightFrame("08", 130, "bracketHighlight")
        BlzFrameSetVisible(brackets.highlights[2], false)

        if hasCodeOnInit then
            UpdateVariableViewer(lastViewedLineNumber[currentTab] or lastLineNumber[currentTab])
            ToggleVariableViewerExpand()
            variableViewer.hasNotBeenExpanded = true
        end

        if editor.LEGAL_CHARACTERS then
            local legalCharacters = editor.LEGAL_CHARACTERS
            editor.LEGAL_CHARACTERS = {}
            for i = 1, #legalCharacters do
                editor.LEGAL_CHARACTERS[sub(legalCharacters, i, i)] = true
            end
        end

        benchmark.TIMER = CreateTimer()

        editor.ON_ENABLE()
    end

    local function AddInit(whichFunc, onWhichPass, initPoint)
        if init == nil then
            return
        end
        if not initialized and not init.inWrap and diagnostics.INIT_OUTSIDE_OF_WRAP_WARNING then
            print("|cffff0000Warning:|r WSCode Init function called from outside of map script wrap.")
        end
        if type(whichFunc) ~= "function" then
            if Debug then
                Debug.throwError("Invalid type passed for whichFunc. Expected function, but type was " .. type(whichFunc) .. ".")
            end
            return
        end
        init[initPoint][#init[initPoint] + 1] = whichFunc
        init.names[whichFunc] = init.currentFunctionName
        init.passes[whichFunc] = onWhichPass or 1
        if onWhichPass then
            if type(onWhichPass) ~= "number" or math.type(onWhichPass) ~= "integer" or onWhichPass < 2 then
                if Debug then
                    Debug.throwError("Invalid type passed for onWhichPass. Must be integer >= 2.")
                end
                return
            end
            init.highestPass[initPoint] = onWhichPass > init.highestPass[initPoint] and onWhichPass or init.highestPass[initPoint]
        end
    end

    --This table is global so that it is accessible within the executed code. Not part of the API.
    WSDebug = {
        CheckForStop = function(lineNumber, whichTab, generationCounter)
            local currentCorot = running()

            executionTab = whichTab

            if doNotCheckStop[whichTab][currentCorot][lineNumber] then
                if compiler.EXECUTION_LIMIT then
                    executionCount = executionCount + 1
                    if executionCount > compiler.EXECUTION_LIMIT then
                        error("Execution limit reached.")
                    end
                end
                return true
            end

            if not lineNumberWasExecuted[whichTab][lineNumber] then
                lineNumberWasExecuted[whichTab][lineNumber] = true
                if currentTab == whichTab then
                    local rawLineNumber = math.tointeger(lineNumber - lineNumberOffset[whichTab])
                    if rawLineNumber >= 1 and rawLineNumber <= editor.MAX_LINES_ON_SCREEN then
                        BlzFrameSetText(lineNumbers[rawLineNumber], editor.LINE_NUMBER_COLOR .. lineNumber .. "|r")
                    end
                end
            end

            if not coroutine.isyieldable(currentCorot) or generationCounter ~= wsdebug.GenerationCounter[whichTab] then
                doNotCheckStop[whichTab][currentCorot][lineNumber] = true
                return true
            end

            if wsdebug.NoStop then
                doNotCheckStop[whichTab][currentCorot][lineNumber] = true
                return true
            end

            if wsdebug.TabIsHalted[whichTab] then
                return true
            end

            currentStop[whichTab] = lineNumber
            lastLineNumber[whichTab] = lineNumber
            wsdebug.Coroutine[whichTab] = currentCorot

            if compiler.EXECUTION_LIMIT then
                executionCount = executionCount + 1
                if executionCount > compiler.EXECUTION_LIMIT then
                    error("Execution limit reached.")
                end
            end

            if lines.debugState[whichTab][lineNumber] == 2 or (lineByLine and lastHaltedCoroutine == wsdebug.Coroutine[whichTab]) then
                if not BlzFrameIsVisible(codeEditorParent) then
                    EnableEditor(user)
                end
                if currentTab ~= whichTab then
                    if not tabs.numbers[whichTab] then
                        Pull(whichTab)
                    end
                    SwitchToTab(whichTab)
                end
                BlzFrameSetVisible(highlights.currentLine, true)
                BlzFrameSetVisible(highlights.error, false)
                JumpWindow(currentStop[whichTab], true, currentTab ~= whichTab)
                SetCurrentLine()

                lastViewedLineNumber[whichTab] = nil
                lastViewedFunctionCall[whichTab] = lastFunctionCall[whichTab]
                for i = 1, math.max(#viewedFunctionParams[whichTab], #functionParams[whichTab]) do
                    viewedFunctionParams[whichTab][i] = functionParams[whichTab][i]
                end

                UpdateVariableViewer(lineNumber)
                local aliceWasHalted
                if ALICE_Where and (ALICE_Where ~= "outsideofcycle" or compiler.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                    ALICE_Halt()
                    aliceWasHalted = true
                    BlzFrameSetEnable(buttons.haltALICE, false)
                end
                wsdebug.TabIsHalted[whichTab] = true
                tabs.hasError[whichTab] = nil
                doNotUpdateVariables[whichTab] = true
                wsdebug.Traceback[whichTab] = Debug.traceback()

                wsdebug.NoStop = true
                editor.ON_BREAK(tabs.names[whichTab])
                wsdebug.NoStop = false
                coroutine.yield()

                wsdebug.TabIsHalted[whichTab] = false
                doNotUpdateVariables[whichTab] = false
                if aliceWasHalted then
                    ALICE_Resume()
                    BlzFrameSetEnable(buttons.haltALICE, true)
                end
                wsdebug.NoStop = true
                editor.ON_RESUME(tabs.names[whichTab])
                wsdebug.NoStop = false
                BlzFrameSetVisible(highlights.currentLine, false)
            elseif lines.debugState[whichTab][lineNumber] == 1 then
                if not BlzFrameIsVisible(codeEditorParent) then
                    EnableEditor(user)
                end
                lastViewedLineNumber[whichTab] = lineNumber
                lastViewedFunctionCall[whichTab] = lastFunctionCall[whichTab]
                for i = 1, math.max(#viewedFunctionParams[whichTab], #functionParams[whichTab]) do
                    viewedFunctionParams[whichTab][i] = functionParams[whichTab][i]
                end
                if currentTab == whichTab then
                    UpdateVariableViewer(lineNumber)
                end
            else
                doNotCheckStop[whichTab][currentCorot][lineNumber] = true
            end
            executionTab = whichTab
            return true
        end,

        AssignVars = function(valueTable, level, codeTab, lineNumber, ...)
            if doNotUpdateVariables[codeTab] then
                return
            end

            local whichVar
            local adjustedLevel
            for i = 1, select("#", ...) do
                whichVar = select(i, ...)
                if level == -1 then
                    adjustedLevel = visibleVarsOfLine[codeTab][lineNumber][whichVar] or -1
                else
                    adjustedLevel = level
                end
                if valueTable and valueTable[i] ~= nil then
                    wsdebug.VarTable[codeTab][adjustedLevel][whichVar] = valueTable[i]
                else
                    wsdebug.VarTable[codeTab][adjustedLevel][whichVar] = wsdebug.Nil
                end
            end
        end,

        AssignVar = function(value, level, codeTab, lineNumber, varName)
            if doNotUpdateVariables[codeTab] then
                return
            end

            if level == -1 then
                level = visibleVarsOfLine[codeTab][lineNumber][varName] or -1
            end
            if value ~= nil then
                wsdebug.VarTable[codeTab][level][varName] = value
            else
                wsdebug.VarTable[codeTab][level][varName] = wsdebug.Nil
            end
        end,

        GetVar = function(codeTab, level, isStrong, varName, value)
            if isStrong then
                local val = wsdebug.VarTable[codeTab][level][varName] or value
                if val == nil then
                    return wsdebug.Nil
                else
                    return val
                end
            else
                local val = wsdebug.VarTable[codeTab][level][varName]
                if type(val) == "table" and type(value) == "table" then
                    for key, entry in pairs(value) do
                        val[key] = entry
                    end
                    return val
                elseif value == nil then
                    if val == wsdebug.Nil then
                        return nil
                    else
                        return val
                    end
                else
                    return value
                end
            end
        end,

        GetVarEx = function(codeTab, level, isStrong, ...)
            local numVars = select("#", ...)//2
            local varName
            local valueTable = {}
            for i = 1, numVars do
                varName = select(i, ...)
                valueTable[i] = wsdebug.GetVar(codeTab, level, isStrong, varName, select(i + numVars, ...))
            end
            return valueTable
        end,

        GetVarNil = function(codeTab, level, isStrong, ...)
            local numVars = select("#", ...)
            local varName
            local valueTable = {}
            for i = 1, numVars do
                varName = select(i, ...)
                valueTable[i] = wsdebug.GetVar(codeTab, level, isStrong, varName)
            end
            return valueTable
        end,

        CatchParams = function(funcName, whichTab, ...)
            if doNotUpdateVariables[whichTab] then
                return ...
            end

            lastFunctionCall[whichTab] = funcName
            local num = select("#", ...)
            for i = 1, num do
                functionParams[whichTab][i] = select(i, ...)
            end
            for i = num + 1, #functionParams[whichTab] do
                functionParams[whichTab][i] = nil
            end
            return ...
        end,

        HandleCoroutine = function(whichFunc, whichTab, ...)
            wsdebug.Coroutine[whichTab] = coroutine.create(whichFunc)
            local result = table.pack(coroutine.resume(wsdebug.Coroutine[whichTab], ...))
            return select(2, table.unpack(result))
        end,

        GetWrapper = function(funcName, whichTab, whichGenCounter, whichFunc)
            if whichGenCounter > wrapperGenerationCounter[whichTab][funcName] then
                wrapperFunc[whichTab][funcName] = wrapperFunc[whichTab][funcName] or function(...) return wrappedFunc[whichTab][funcName](...) end
                wrappedFunc[whichTab][funcName] = whichFunc
                wrapperGenerationCounter[whichTab][funcName] = whichGenCounter
            elseif wrapperFunc[whichTab][funcName] then
                return whichFunc
            else
                wrapperFunc[whichTab][funcName] = function(...) return wrappedFunc[whichTab][funcName](...) end
                wrappedFunc[whichTab][funcName] = whichFunc
            end
            return wrapperFunc[whichTab][funcName]
        end,

        Execute = function(initPoint, ...)
            --Convert WSCode init name into TotalInit init name.
            initPoint = initPoint:gsub("Init", "")
            initPoint = initPoint:sub(1, 1):lower() .. initPoint:sub(2)
            wsdebug.FunctionsToInit[INIT_POINTS[initPoint]][#wsdebug.FunctionsToInit[INIT_POINTS[initPoint]] + 1] = select(-1, ...)
        end,

        FunctionsToInit = setmetatable({}, tab2D),

        StoreHandle = function(creator, creatorFunc, whichTab, ...)
            if _G[creator] == creatorFunc then
                local handle = select(1, ...)
                handles[whichTab][handle] = creator
            end
            return ...
        end,

        ValidateFrame = function(frame)
            if compiler.VALIDATE_FRAMES and frame and GetHandleId(frame) == 0 then
                error("Function returned invalid frame.")
            end
            return frame
        end,

        StoreFunc = function(whichFunction, index)
            wsdebug.FuncList[index] = whichFunction
            return whichFunction
        end,

        FuncList = {},

        End = function(lineNumber, whichTab, generationCounter)
            lastLineNumber[whichTab] = lineNumber
            if not lastViewedLineNumber[whichTab] and variableViewer.isExpanded and generationCounter == wsdebug.GenerationCounter[whichTab] then
                UpdateVariableViewer(lineNumber)
            end
        end,

        Nil = {},

        GenerationCounter = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),

        Vars = {},

        VarTable = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, tab2D) return self[key] end}),

        Coroutine = {},

        TabIsHalted = {},

        Traceback = {},

        Pack = table.pack,
        Unpack = table.unpack,

        Injectors = setmetatable({}, tab2D),

        Mouse = {
            x                       = 0,
            y                       = 0,
            lastMove                = 0,
            ignoreClickUntil        = 0,
            lastClick               = 0,
            leftButtonIsPressed     = false
        }
    }

    wsdebug = WSDebug

    --======================================================================================================================
    --API
    --======================================================================================================================

    StoreCode = function(tabName, functionBody)
        if not tabs.numbers[tabName] then
            if codeEditorParent then
                AddTab(tabName)
            elseif tabs.names[1] == "Main" then
                tabs.names[1] = tabName
                tabs.numbers[tabName] = 1
                tabs.numbers.Main = nil
                if currentTab == "Main" then
                    currentTab = tabName
                end
            else
                tabs.amount = tabs.amount + 1
                tabs.numbers[tabName] = tabs.amount
                tabs.names[tabs.amount] = tabName
            end
        end

        local newLines
        if type(functionBody) == "string" then
            newLines = ConvertStringToLines(functionBody)
            for i = 1, #newLines do
                newLines[i] = newLines[i]:gsub("\t", "    "):gsub("\n", ""):gsub("\r", "")
            end
        else
            newLines = functionBody
        end

        local oldCodeSize = highestNonEmptyLine[tabName][step[tabName]]
        if oldCodeSize > 0 then
            for i = oldCodeSize + 2, #newLines + oldCodeSize + 1 do
                codeLines[tabName][step[tabName]][i] = newLines[i - (oldCodeSize + 1)]
                coloredCodeLines[tabName][step[tabName]][i] = GetColoredText(codeLines[tabName][step[tabName]][i], i, tabName)
            end
            codeLines[tabName][step[tabName]][oldCodeSize + 1] = ""
            coloredCodeLines[tabName][step[tabName]][oldCodeSize + 1] = ""
            highestNonEmptyLine[tabName][step[tabName]] = #newLines + oldCodeSize + 1
        else
            for i = 1, #newLines do
                codeLines[tabName][step[tabName]][i] = newLines[i]
                coloredCodeLines[tabName][step[tabName]][i] = GetColoredText(codeLines[tabName][step[tabName]][i], i, tabName)
            end
            highestNonEmptyLine[tabName][step[tabName]] = #newLines
        end

        return newLines, tabName
    end

    WSCode = {
        ---Parses the provided code, searching for function definitions to generate function previews, then executes the code in chunks delimited by either Debug.beginFile or @beginFile tokens, which must be followed by the script name. Parsed scripts can be added to the editor with the Pull Script button. A script will automatically be transpiled into debug form and added to the editor if a @debug token is found anywhere in the script. Designed to read in the entire map script.
        ---@param functionBody string
        Parse = function(functionBody)
            if (compiler.ENABLE_MAP_SCRIPT_SHARING or compiler.ENABLE_QUICK_RESTART) and not init.afterMain then
                init.mapScript = functionBody
                return
            end

            init.mapScript = nil
            init.inWrap = true

            if compiler.ENABLE_QUICK_RESTART then
                InitTabs()
            end

            local newLines = ConvertStringToLines(functionBody)
            for i = 1, #newLines do
                newLines[i] = newLines[i]:gsub("\t", "    ")
            end

            local beginningOfFile = 1
            local fileName = "anonymous"
            local debug = {}
            local transpile = {}
            local store = {}
            local add = {}
            local requirements = {}
            local requirementIsOptional = {}
            local inGuiTrigger = false

            local function ParseFile(endOfFile, autoIndent)
                local debugthis = init.debugTabs and init.debugTabs[fileName]
                local transpilethis
                local storethis
                local addthis
                local atSign
                local lines = {}
                requirements[#requirements + 1] = {}
                requirementIsOptional[#requirementIsOptional + 1] = {}
                local requirements = requirements[#requirements]
                local requirementIsOptional = requirementIsOptional[#requirementIsOptional]

                local k = 1
                for j = beginningOfFile, endOfFile do
                    lines[k] = newLines[j]
                    atSign = find(lines[k], "@") ~= nil
                    if atSign and find(lines[k], "@require") then
                        local requireString = lines[k]:match("@require(.+)")
                        local pos
                        local startPos = 1
                        repeat
                            pos = requireString:find(",", startPos)
                            if pos then
                                requirements[#requirements + 1] = requireString:sub(startPos, pos - 1):gsub("^\x25s*", ""):gsub("$\x25s*", "")
                                if requirements[#requirements]:sub(1, 1) == "\"" or requirements[#requirements]:sub(1, 1) == "'" then
                                    requirements[#requirements] = requirements[#requirements]:sub(2, -2)
                                end
                                if requirements[#requirements]:sub(-1) == "?" then
                                    requirements[#requirements] = requirements[#requirements]:sub(1, -2)
                                    requirementIsOptional[#requirementIsOptional + 1] = true
                                else
                                    requirementIsOptional[#requirementIsOptional + 1] = false
                                end
                                startPos = pos + 1
                            end
                        until not pos
                        requirements[#requirements + 1] = requireString:sub(startPos):gsub("^\x25s*", ""):gsub("$\x25s*", "")
                        if requirements[#requirements]:sub(1, 1) == "\"" or requirements[#requirements]:sub(1, 1) == "'" then
                            requirements[#requirements] = requirements[#requirements]:sub(2, -2)
                        end
                        if requirements[#requirements]:sub(-1) == "?" then
                            requirements[#requirements] = requirements[#requirements]:sub(1,-2)
                            requirementIsOptional[#requirementIsOptional + 1] = true
                        else
                            requirementIsOptional[#requirementIsOptional + 1] = false
                        end
                    end
                    if atSign and not compiler.RELEASE_VERSION then
                        local hasToken = find(lines[k], "@debug") ~= nil
                        debugthis = debugthis or hasToken or inGuiTrigger and find(lines[k], "udg_wsdebug = true")  ~= nil
                        if hasToken then
                            tabs.wasPulledFromDebugToken[fileName] = true
                        end
                        if debugthis then
                            if find(lines[k], "@nodebug") then
                                debugthis = false
                                addthis = true
                            end
                        end
                        transpilethis = transpilethis or find(lines[k], "@transpile") ~= nil
                        storethis = storethis or find(lines[k], "@store") ~= nil
                    end
                    k = k + 1
                end

                files[#files + 1] = lines
                if existingFiles[fileName] then
                    print("|cffff0000Warning:|r Multiple files exist with the file name " .. fileName .. ".")
                    fileName = "anonymous" .. (#fileNames + 1)
                end
                fileNames[#files] = fileName
                existingFiles[fileName] = #files
                add[#files] = addthis
                debug[#files] = debugthis
                store[#files] = storethis
                transpile[#files] = transpilethis

                local fourSpaces = "    "
                if autoIndent then
                    for i = 1, #lines do
                        lines[i] = match(lines[i], "^\x25s*(.*)") --remove eventual indentation
                    end
                    local level = 0

                    for i = 1, #lines do
                        if find(lines[i], "\x25f[\x25a_]end\x25s*$") ~= nil
                        or find(lines[i], "\x25f[\x25a_]until\x25s*") ~= nil then
                            level = level - 1
                        end
                        if find(lines[i], "\x25s*else\x25*") ~= nil or find(lines[i], "\x25s*elseif[\x25s\x25(]") ~= nil then
                            for __ = 1, level - 1 do
                                lines[i] = fourSpaces .. lines[i]
                            end
                        else
                            for __ = 1, level do
                                lines[i] = fourSpaces .. lines[i]
                            end
                        end
                        if find(lines[i], "\x25f[\x25a_]for[\x25s\x25(]") ~= nil
                        or find(lines[i], "\x25f[\x25a_]do\x25f[^\x25w_]") ~= nil
                        or find(lines[i], "\x25f[\x25a_]if[\x25s\x25(]") ~= nil
                        or find(lines[i], "\x25f[\x25a_]function\x25f[\x25s\x25(]") then
                            level = level + 1
                        end
                    end
                end
            end

            newLines[#newLines + 1] = ""

            local size = #newLines

            local warnedForFileName = {}
            local lastFileName
            for i = 1, size do
                if find(newLines[i], "beginFile") and (find(newLines[i], "Debug.beginFile\x25s*[\"'\x25(][^\x25)]") or find(newLines[i], "@beginFile")) then
                    if fileName ~= "anonymous" then
                        ParseFile(i - 1)
                    end
                    beginningOfFile = i
                    fileName = (newLines[i]:match("Debug\x25.beginFile\x25s*\x25(?\x25s*[\"']([^\"']+)[\"']") or newLines[i]:match("@beginFile\x25s*\"(.+)\"") or newLines[i]:match("@beginFile\x25s*'(.+)'") or newLines[i]:match("@beginFile\x25s*(.+)")):gsub("\\", "\\\\")
                    inGuiTrigger = false
                elseif find(newLines[i], "endFile") and (find(newLines[i], "Debug.endFile\x25s*\x25(\x25s*\x25)") or find(newLines[i], "@endFile")) or i == size then
                    ParseFile(i)
                    beginningOfFile = i + 1
                    lastFileName = fileName
                    fileName = "anonymous"
                    inGuiTrigger = false
                elseif find(newLines[i], "function Trig_") then
                    local newFileName = match(newLines[i], 'function Trig_([\x25w_]+)_\x25f[Actions|Conditions|Func0]'):gsub("_", " ")
                    if newFileName ~= fileName then
                        if fileName ~= "anonymous" then
                            ParseFile(i - 1, true)
                        end
                        beginningOfFile = i
                        fileName = newFileName
                        inGuiTrigger = true
                    end
                elseif fileName == "anonymous" and find(newLines[i], "^\x25s*$") == nil and not warnedForFileName[lastFileName] then
                    PrintForUser("|cffff0000Warning:|r Code outside of file delimiters found after " .. (lastFileName or "unknown") .. ". Code was not executed. Add @beginFile token.")
                    warnedForFileName[(lastFileName or "unknown")] = true
                end
            end

            local function ExecuteScript()
                local completedFunctions = {}
                local skip, noFunctionWasInitialized, everyFunctionWasInitialized

                local saveString
                if init.wripteMapScript then
                    saveString = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
                end

                repeat
                    noFunctionWasInitialized = true
                    everyFunctionWasInitialized = true
                    for i = 1, #files do
                        if not completedFunctions[fileNames[i]] then
                            for j = 1, #files[i] do
                                if find(files[i][j], "^\x25s*$") == nil then
                                    skip = false
                                    for k = 1, #requirements[i] do
                                        if not completedFunctions[requirements[i][k]] and (not requirementIsOptional[i][k] or existingFiles[requirements[i][k]]) then
                                            skip = true
                                            break
                                        end
                                    end
                                    if not skip then
                                        init.currentFunctionName = fileNames[i]
                                        if diagnostics.INIT_DUMP then
                                            PreloadGenClear()
                                            PreloadGenStart()
                                            Preload(fileNames[i])
                                            PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
                                        end
                                        if debug[i] then
                                            StoreCode(fileNames[i], files[i])
                                            hasCodeOnInit = true
                                            CompileFunction(files[i], {
                                                tab = fileNames[i],
                                                parse = FUNCTION_PREVIEW ~= nil,
                                                duringInit = true,
                                                debugMode = true
                                            })
                                        elseif transpile[i] then
                                            CompileFunction(files[i], {
                                                tab = fileNames[i],
                                                parse = FUNCTION_PREVIEW ~= nil,
                                                duringInit = true,
                                                debugMode = true
                                            })
                                        elseif store[i] then
                                            StoreCode(fileNames[i], files[i])
                                            hasCodeOnInit = true
                                        else
                                            if add[i] then
                                                StoreCode(fileNames[i], files[i])
                                            end
                                            CompileFunction(files[i], {
                                                tab = fileNames[i],
                                                parse = FUNCTION_PREVIEW ~= nil,
                                                duringInit = true
                                            })
                                        end

                                        if init.wripteMapScript then
                                            for k = 1, #files[i] do
                                                saveString = saveString .. files[i][k] .. "\n"
                                            end
                                        end

                                        completedFunctions[fileNames[i]] = true
                                        noFunctionWasInitialized = false
                                    else
                                        everyFunctionWasInitialized = false
                                    end
                                    break
                                else
                                    completedFunctions[fileNames[i]] = true
                                end
                            end
                        end
                        numVisibleVars = 0
                    end
                until noFunctionWasInitialized or everyFunctionWasInitialized

                if init.wripteMapScript then
                    FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt", table.concat(saveString))
                    print("Map script written to file " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt.")
                end

                if noFunctionWasInitialized and not everyFunctionWasInitialized then
                    local missingFunctionString = ""
                    local first = true
                    for i = 1, #fileNames do
                        if not completedFunctions[fileNames[i]] and fileNames[i] ~= "anonymous" then
                            if not first then
                                missingFunctionString = missingFunctionString .. ", "
                            else
                                first = false
                            end
                            missingFunctionString = missingFunctionString .. fileNames[i]
                            local firstReq = true
                            for __, requirement in ipairs(requirements[i]) do
                                if not completedFunctions[requirement] then
                                    if firstReq then
                                        missingFunctionString = missingFunctionString .. " (missing "
                                        firstReq = false
                                    else
                                        missingFunctionString = missingFunctionString .. ", "
                                    end
                                    missingFunctionString = missingFunctionString .. requirement
                                end
                            end
                            if not firstReq then
                                missingFunctionString = missingFunctionString .. ")"
                            end
                        end
                    end
                    if Debug then
                        Debug.throwError("Initialization failed: There may be circular or missing dependencies. Failed functions: " .. missingFunctionString .. ".")
                    end
                end

                if diagnostics.INIT_DUMP then
                    PreloadGenClear()
                    PreloadGenStart()
                    Preload("Init successful.")
                    PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
                end

                orderedFileNames = table.pack(table.unpack(fileNames))
                table.sort(orderedFileNames)

                for i = 1, #variableViewer.frames do
                    variableViewer.frames[i] = nil
                end

                if init.suspended then
                    init.suspended = false
                    if not init.completed.main then
                        ExecuteInitList("main")
                    end
                    if not init.completed.global then
                        ExecuteInitList("global")
                    end
                    if not init.completed.trig then
                        ExecuteInitList("trig")
                    end
                    if not init.completed.map then
                        ExecuteInitList("map")
                    end
                    if not init.completed.final then
                        ExecuteInitList("final")
                    end
                end
            end

            local startTime
            if diagnostics.PROFILE_INIT then
                startTime = clock()
            end

            local corot
            corot = coroutine.create(ExecuteScript)
            coroutine.resume(corot)

            if diagnostics.PROFILE_INIT then
                local endTime = clock()
                init.profiler.totalTime = init.profiler.totalTime + endTime - startTime
            end

            init.inWrap = nil
        end,

        ---Adds a breakpoint to a line in the specified tab. The tab can be referenced either by its currentTab index or its name.
        ---@param whichTab string | integer
        ---@param lineNumber integer
        AddBreakPoint = function(whichTab, lineNumber)
            local tabName = whichTab
            if type(whichTab) == "string" then
                whichTab = tabs.numbers[whichTab]
            end
            if not whichTab then
                if Debug then
                    Debug.throwError("Unrecognized currentTab name " .. tabName .. ".")
                end
                return
            end

            lines.debugState[whichTab][lineNumber] = 2

            if BlzFrameIsVisible(codeEditorParent) and currentTab == whichTab and lineNumberOffset[currentTab] < lineNumber and lineNumberOffset[currentTab] >= lineNumber - editor.MAX_LINES_ON_SCREEN then
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[lineNumber], 0), LINE_STATE_ICONS[2], 0, true)
            end
        end,

        ---Halts exeuction of the code when it reaches this line and switches to the tab it is executed in. Script must be compiled in debug mode. A breakpoint added this way cannot be disabled.
        ---@param stopCondition? boolean
        BreakHere = function(stopCondition)
            if stopCondition == false then
                return
            end

            if not coroutine.isyieldable(running()) then
                if Debug then
                    Debug.throwError("Coroutine is not yieldable.")
                end
                return
            end

            local thisTab = executionTab
            local lineNumber = lastLineNumber[thisTab]
            if thisTab == "anonymous" or not lineNumber then
                if Debug then
                    Debug.throwError("Could not identify breakpoint location.")
                end
                return
            end

            if not initialized then
                init.suspended = true
            end

            if WSDebug.TabIsHalted[thisTab] then
                return
            end

            WSDebug.TabIsHalted[thisTab] = true
            doNotUpdateVariables[thisTab] = true
            WSDebug.Traceback[thisTab] = Debug.traceback()
            if not initialized then
                coroutineWaitingForInit = running()
                coroutine.yield()
            end

            local alreadyActive
            local tabIndex
            for j = 1, tabs.amount do
                if tabs.names[j] == thisTab then
                    alreadyActive = true
                    tabIndex = j
                    break
                end
            end

            for i = 0, 23 do
                if user then
                    break
                end
                for __, creator in ipairs(editor.MAP_CREATORS) do
                    if find(GetPlayerName(Player(i)), creator) then
                        user = Player(i)
                        break
                    end
                end
            end

            if alreadyActive then
                EnableEditor(user)
                if currentTab ~= tabIndex then
                    SwitchToTab(tabIndex)
                end
            else
                local found
                for i = 1, #fileNames do
                    if fileNames[i] == thisTab then
                        EnableEditor(user)
                        Pull(thisTab)
                        found = true
                        break
                    end
                end
                if not found then
                    return
                end
            end

            currentStop[thisTab] = lineNumber

            BlzFrameSetVisible(highlights.currentLine, true)
            BlzFrameSetVisible(highlights.error, false)
            JumpWindow(currentStop[thisTab], true, currentTab ~= thisTab)
            SetCurrentLine()
            lastViewedLineNumber[thisTab] = nil
            UpdateVariableViewer(lineNumber)

            local aliceWasHalted
            if ALICE_Where and (ALICE_Where ~= "outsideofcycle" or compiler.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                aliceWasHalted = true
                ALICE_Halt()
            end

            editor.ON_BREAK(tabs.names[thisTab])

            coroutine.yield()

            editor.ON_RESUME(tabs.names[thisTab])

            WSDebug.TabIsHalted[thisTab] = false
            doNotUpdateVariables[thisTab] = false
            if aliceWasHalted then
                ALICE_Resume()
            end
            BlzFrameSetVisible(highlights.currentLine, false)
        end,

        ---Shows or hides the code editor.
        ---@param enable boolean
        Show = function(enable)
            if enable then
                EnableEditor(user)
            else
                BlzFrameSetVisible(codeEditorParent, false)
            end
        end,

        ---Returns whether the code editor has been created.
        ---@return boolean
        IsEnabled = function()
            return codeEditorParent ~= nil
        end,

        ---Returns whether the code editor is visible.
        ---@return boolean
        IsVisible = function()
            return BlzFrameIsVisible(codeEditorParent)
        end,

        ---Returns whether the code editor is expanded.
        ---@return boolean
        IsExpanded = function()
            return editor.isExpanded
        end,

        ---Called before main. The earliest point to initialize outside the Lua root.  
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitMain = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "main")
        end,

        ---Called after InitGlobals. The standard point to initialize.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitGlobal = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "global")
        end,

        ---Called after InitCustomTriggers. Useful for removing hooks that should only apply to GUI events.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitTrig = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "trig")
        end,

        ---Called at the last point in initialization before the loading screen is completed.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitMap = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "map")
        end,

        ---Called immediately after the loading screen has disappeared, and the game has started.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitFinal = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "final")
        end,

        ---Called immediately before InitFinal. Will execute even if initialization was halted.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitEssential = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "essential")
        end
    }
end