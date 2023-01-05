library TasItemShop initializer init_function requires TasItemFusion, Power2, Table, ItemHolder, ToggleIconButtonGroup, optional FrameLoader
    globals
        public real xPos = 0.0
        public real yPos = - 0.02
        public framepointtype posPoint = FRAMEPOINT_TOP
        public boolean posScreenRelative = true
        public real toolTipPosX = 0.085
        public real toolTipPosY = 0.47
        public framepointtype toolTipPosPoint = FRAMEPOINT_TOPRIGHT
        public framepointtype toolTipPosPointParent = null
        public real toolTipSizeX = 0.2 
        public real toolTipSizeXBig = 0.2
        public real toolTipLimitBig = 300
        public string boxFrameName = "TasItemShopRaceBackdrop"
        public string boxButtonListFrameName = "EscMenuControlBackdropTemplate"
        public string boxRefFrameName = "EscMenuControlBackdropTemplate"
        public string boxCatFrameName = "EscMenuControlBackdropTemplate"
        public string boxUndoFrameName = "TasItemShopRaceBackdrop"
        public string boxDefuseFrameName = "TasItemShopRaceBackdrop"
        public string buttonListHighLightFrameName = "TasItemShopSelectedHighlight"
        public real boxFrameBorderGap = 0.0065
        public real boxButtonListBorderGap = 0.0065
        public real boxRefBorderGap = 0.0065
        public real boxCatBorderGap = 0.0055
        public real boxUndoBorderGap = 0.0045
        public real boxDefuseBorderGap = 0.0045
        public real boxSellBorderGap = 0.0045
        public real buttonListButtonGapCol = 0.001
        public real buttonListButtonGapRow = 0.005
        public boolean flexibleShop = true
        public boolean sharedItems = false
        public boolean canProviderGetItem = true
        public boolean canUndo = true
        public boolean canDefuse = true
        public string DefuseButtonIcon = "ReplaceableTextures\\CommandButtons\\BTNdemolish"
        public string DefuseButtonIconDisabled = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNdemolish"
        public boolean canSellItems = true
        public real SellFactor = 0.75
        public boolean SellUsesCostModifier = true
        public string SellButtonIcon = "ReplaceableTextures\\CommandButtons\\BTNReturnGoods"
        public string SellButtonIconDisabled = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReturnGoods"
        public string MainUserTexture = "ui\\widgets\\console\\human\\commandbutton\\human-multipleselection-border" 
        public string MainItemTexture = "ui\\widgets\\console\\human\\commandbutton\\human-multipleselection-border" 
        public real shopRange = 450
        public real updateTime = 0.33
        public string textUpgrades = "Upgrade"
        public string textMats = "Requires"
        public string textInventory = "Inventory"
        public string textUser = "User"
        public string textCanNotBuyPrefix = "Can not buy: "
        public string textCanNotBuySufix = "OUTOFSTOCKTOOLTIP"
        public string textNoValidShopper = "No valid Shoper"
        public string textUndo = "Undo: "
        public string textUnBuyable = "xxxxxxx"
        public string textDefuse = "Defuse:"
        public string textSell = "Sell:"
        public string textQuickLink = "Shortcuts:"
        public string categoryModeTextAnd = "ui\\widgets\\battlenet\\bnet-mainmenu-friends-disabled"
        public string categoryModeTextOr = "Or"
        public string categoryModeIconOr = "ui\\widgets\\battlenet\\bnet-mainmenu-friends-up"
        public string categoryModeIconAnd = "And"
        public oskeytype quickLinkKey = OSKEY_LSHIFT
        public integer refButtonCountMats = 5
        public integer refButtonCountUp = 5
        public integer refButtonCountInv = 6 
        public integer refButtonCountUser = 2
        public integer refButtonCountQuickLink = 5
        public real refButtonSize = 0.02
        public real refButtonGap = 0.003
        public real refButtonPageSize = 0.012
        public boolean refButtonPageRotate = true
        public string refButtonPageUp = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp"
        public string refButtonPageDown = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown"
        public real refButtonBoxSizeY = 0.047
        public boolean inventoryRightClickSell = true
        public boolean inventoryShowMainOnly = true
        public boolean userButtonOrder = true
        public real doubleClickTimeOut = 0.25
        public string spriteModel = "war3mapImported\\BansheeMissile.mdx"
        public real spriteScale = 0.0006
        public integer spriteAnimationIndex = 1
        public integer buttonListRows = 6
        public integer buttonListCols = 6
        public boolean buttonListShowGold = true
        public boolean buttonListShowLumber = false
        public boolean buyButtonShowGold = true
        public boolean buyButtonShowLumber = false
        public string buttonListButtonName = "TasButtonSmall"
        public real buttonListButtonSizeX = 0.1
        public real buttonListButtonSizeY = 0.0325
        public real categoryButtonSize = 0.019

        public integer array Selected
        public integer array SelectedCategory
        public item array SelectedItem
        public timer Timer
        public boolean IsReforged
        public group TempGroup = CreateGroup()
        public unit TempUnit
        public real TempRange
        public player TempPlayer
        public integer CREATE_CONTEXT_CURRENT = - 1
        public integer CREATE_CONTEXT_SELL = - 2
        public integer ButtonListIndex
        public integer CategoryModButtonIndex
        public integer RefButtonBoxRows = 0
        public framehandle array RefButtonBoxFrameLast
        public framehandle array RefButtonBoxFrameFirst
        public real array RefButtonBoxSize
        public Table Shops        
        public integer ShopCount = 0
        public real array ShopRange
        public boolean array ShopWhiteList
        public trigger array ShopCostAction
        public HashTable ShopsItems
        public HashTable ShopsGold
        public HashTable ShopsLumber
        public Table array UndoItems
        public Table array UndoResults
        public integer array UndoResultCode
        public integer array UndoGold
        public integer array UndoLumber
        public integer UndoPlayerSize = 800
        public integer array UndoPlayerCount
        public string array UndoActionName
        public item array UndoStackGainer
        public integer array UndoStackGained
        public Table TasItemCategory
        public string array CategoryIcon
        public string array CategoryText
        public integer CategoryCount = 0
        public integer array CategoryValues
        public integer MissingCount = 0
        public integer array MissingItemCode
        public integer array HaggleSkill
        public real array HaggleGold
        public real array HaggleLumber
        public real array HaggleLumberAdd
        public real array HaggleGoldAdd
        public integer HaggleCount = 0
        public integer array CategoryPlayerValues
        public framehandle FrameSprite
        public framehandle FrameSpriteParent
        public framehandle FrameParentSuper
        public framehandle FrameParentSuperUI
        public framehandle FrameSuperBox
        public framehandle FrameTitelText
        public framehandle FrameFullscreen
        public framehandle FrameTasButtonList
        public framehandle FrameCategoryBox
        public framehandle FrameUndoBox
        public framehandle FrameUndoButton
        public framehandle FrameUndoButtonIcon
        public framehandle FrameUndoButtonIconPushed
        public framehandle FrameUndoText
        public framehandle FrameDefuseBox
        public framehandle FrameDefuseButton
        public framehandle FrameDefuseText
        public framehandle FrameSellBox
        public framehandle FrameSellButton
        public framehandle FrameSellText
        public framehandle FrameUserBox
        public framehandle FrameUserText
        public framehandle FrameUserPage
        public framehandle FrameUserPageUp
        public framehandle FrameUserPageText
        public framehandle FrameUserPageDown
        public framehandle FrameInventoryBox
        public framehandle FrameInventoryText
        public framehandle FrameInventoryPage
        public framehandle FrameInventoryPageUp
        public framehandle FrameInventoryPageText
        public framehandle FrameInventoryPageDown
        public framehandle FrameMaterialBox
        public framehandle FrameMaterialText
        public framehandle FrameMaterialPage
        public framehandle FrameMaterialPageUp
        public framehandle FrameMaterialPageText
        public framehandle FrameMaterialPageDown
        public framehandle FrameUpgradeBox
        public framehandle FrameUpgradeText
        public framehandle FrameUpgradePage
        public framehandle FrameUpgradePageUp
        public framehandle FrameUpgradePageText
        public framehandle FrameUpgradePageDown
        public Table array QuickLink
        public boolean array QuickLinkKeyActive
        public framehandle FrameQuickLinkBox
        public framehandle FrameQuickLinkBoxHighLight
        public framehandle FrameQuickLinkText
        public framehandle FrameQuickLinkPage
        public framehandle FrameQuickLinkPageUp
        public framehandle FrameQuickLinkPageText
        public framehandle FrameQuickLinkPageDown
        public trigger ButtonTriggerInventory
        public trigger ButtonTriggerInventoryPage
        public trigger ButtonTriggerMaterial
        public trigger ButtonTriggerMaterialPage
        public trigger ButtonTriggerUser
        public trigger ButtonTriggerUserPage
        public trigger ButtonTriggerUpgrade
        public trigger ButtonTriggerUpgradePage
        public trigger ButtonTriggerSell
        public trigger ButtonTriggerDefuse
        public trigger ButtonTriggerBuy
        public trigger ButtonTriggerUndo
        public trigger ButtonTriggerClear
        public trigger ButtonTriggerSelect
        public trigger ButtonTriggerOrder
        public trigger ButtonTriggerESC
        public trigger ButtonTriggerClearFocus
        public trigger ButtonTriggerParentScroll
        public trigger ButtonTriggerCategoryMode
        public trigger ButtonTriggerQuickLink
        public trigger ButtonTriggerQuickLinkPage
        public trigger ButtonTriggerQuickLinkKeyPress
        public trigger ButtonTriggerQuickLinkKeyRelease
        public integer RefButtonCount = 0
        public framehandle array RefButton
        public framehandle array RefButtonIcon
        public framehandle array RefButtonIconPushed
        public framehandle array RefButtonOverlay
        public framehandle array RefButtonOverlay2
        public framehandle array RefButtonToolTip
        public framehandle array RefButtonToolTipIcon
        public framehandle array RefButtonToolTipText
        public framehandle array RefButtonToolTipName
        public integer RefButtonInventoryStart
        public integer RefButtonInventoryEnd
        public integer RefButtonUpgradeStart
        public integer RefButtonUpgradeEnd
        public integer RefButtonMaterialStart
        public integer RefButtonMaterialEnd       
        public integer RefButtonUserStart
        public integer RefButtonUserEnd
        public integer RefButtonQuickLinkStart
        public integer RefButtonQuickLinkEnd
        public Table TempTable
        public HashTable TempHashTable
        public integer BUY_ABLE_ITEMS_Count = 0
        public integer array BUY_ABLE_ITEMS
        public HashTable BuyAbleMarked
        public Table MarkedItemCodes
        public group array Shoper
        public real DoubleClickStamp
        public unit array ShoperMain
        public unit array CurrentShop
        public integer LocalShopObject
        public integer array CurrentOffSetInventory
        public integer array CurrentOffSetMaterial
        public integer array CurrentOffSetUpgrade
        public integer array CurrentOffSetUser
        public integer array CurrentOffSetQuickLink
        public real xSize
        public real ySize
        public integer TempGold
        public integer TempLumber
        public real TempGoldR
        public real TempLumberR
    endglobals
    
    public function GetParent takes nothing returns framehandle
        local framehandle parent
        if IsReforged then
            set parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        else
            call CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, "title")
            set parent = BlzGetFrameByName("Leaderboard", 0)
            call BlzFrameSetSize(parent, 0, 0)
            call BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)
        endif
        return parent
    endfunction
    
    public function CostModifier takes real gold, real lumber, integer itemCode, unit buyer, unit shop, integer shopObject returns nothing
        local integer loopA
        local integer level
        local integer skill
        set loopA = HaggleCount
        
        loop
            exitwhen loopA < 1
            set skill = HaggleSkill[loopA]
            set level = GetUnitAbilityLevel(buyer, skill)
            if level > 0 then
                set gold = gold * (HaggleGold[loopA] + HaggleGoldAdd[loopA] * level)
                set lumber = lumber * (HaggleLumber[loopA] + HaggleLumberAdd[loopA] * level)
            endif
            set loopA = loopA - 1
        endloop

        if shopObject > 0 then
            if ShopsGold[shopObject].real.has(itemCode) then
                set gold = gold * ShopsGold[shopObject].real[itemCode]
                set lumber = lumber * ShopsLumber[shopObject].real[itemCode]
            else
                set gold = gold * ShopsGold[shopObject].real[0]
                set lumber = lumber * ShopsLumber[shopObject].real[0]
            endif
            set TempGoldR = gold
            set TempLumberR = lumber
            call TriggerEvaluate(ShopCostAction[Shops[shopObject]])
        endif

        set TempGold = R2I(gold + 0.5)
        set TempLumber = R2I(lumber + 0.5)
    endfunction

    public function GetItemSellCosts takes unit u, unit shop, item i returns nothing
        local integer itemCode = GetItemTypeId(i)
        local integer gold 
        local integer lumber
        local integer charges
        set gold = R2I(TasItemGetCostGold(itemCode) * SellFactor)
        set lumber = R2I(TasItemGetCostLumber(itemCode) * SellFactor)
        if SellUsesCostModifier then
            call CostModifier(gold, lumber, itemCode, u, shop, GetUnitTypeId(shop))
            set gold = TempGold
            set lumber = TempLumber
        endif
        set charges = TasItemGetCharges(itemCode)
        if charges > 0 then
            set gold = GetItemCharges(i) * gold / charges
            set lumber = GetItemCharges(i) * lumber / charges
        endif
        set TempGold = gold
        set TempLumber = lumber
    endfunction

    public function IsValidShopper takes player p, unit shop , unit u, real range returns boolean
        if not IsUnitOwnedByPlayer(u, p) then
            return false
        endif

        if UnitInventorySize(u) < 1 then
            return false
        endif

        if IsUnitType(u, UNIT_TYPE_DEAD) then
            return false
        endif

        if IsUnitPaused(u) then
            return false
        endif

        if IsUnitHidden(u) then
            return false
        endif

        if IsUnitIllusion(u) then
            return false
        endif

        if not IsUnitInRange(shop, u, range) then
            return false
        endif

        return true
    endfunction
    
    public function ShowSprite takes framehandle frame, player p returns nothing
        if GetLocalPlayer() != p then
            return
        endif
        call BlzFrameSetVisible(FrameSpriteParent, true)
        call BlzFrameSetModel(FrameSprite, spriteModel, 0)
        call BlzFrameSetSpriteAnimate(FrameSprite, spriteAnimationIndex, 0)
        call BlzFrameSetPoint(FrameSprite, FRAMEPOINT_CENTER, frame, FRAMEPOINT_CENTER, 0, 0)
    endfunction
    
    function TasItemSetCategory takes integer itemCode, integer category returns nothing
        set TasItemCategory[itemCode] = category
    endfunction

    function TasItemShopAdd takes integer itemCode, integer category returns nothing
        if itemCode <= 0 then
            return
        endif
        call TasItemSetCategory(itemCode, category)
        set BUY_ABLE_ITEMS_Count = BUY_ABLE_ITEMS_Count + 1
        set BUY_ABLE_ITEMS[BUY_ABLE_ITEMS_Count] = itemCode
        call TasItemCaclCost(itemCode)
    endfunction

    function TasItemShopAdd5 takes integer a, integer b, integer c, integer d, integer e returns nothing
        call TasItemShopAdd(a, 0)
        call TasItemShopAdd(b, 0)
        call TasItemShopAdd(c, 0)
        call TasItemShopAdd(d, 0)
        call TasItemShopAdd(e, 0)
    endfunction

    function TasItemShopAddHaggleSkill takes integer skill, real goldBase, real lumberBase, real goldAdd, real lumberAdd returns nothing
        set HaggleCount = HaggleCount + 1
        set HaggleSkill[HaggleCount] = skill
        set HaggleGold[HaggleCount] = goldBase
        set HaggleGoldAdd[HaggleCount] = goldAdd
        set HaggleLumber[HaggleCount] = lumberBase
        set HaggleLumberAdd[HaggleCount] = lumberAdd  
    endfunction

    function TasItemShopAddCategory takes string icon, string text returns integer
        if CategoryCount >= 31 then
            call BJDebugMsg("TasItemShop - To many Categories!! new category " + text + ", " + icon)
        else
            set CategoryCount = CategoryCount + 1
            set CategoryIcon[CategoryCount] = icon
            set CategoryText[CategoryCount] = text
            set CategoryValues[CategoryCount] = GetPower2Value(CategoryCount)
        endif
        return CategoryValues[CategoryCount]
    endfunction

    function TasItemShopCreateShop takes integer unitCode, boolean whiteList, real goldFactor, real lumberFactor, code costFunction returns integer
        if not Shops.has(unitCode) then
            set ShopCount = ShopCount + 1
            set Shops[unitCode] = ShopCount
            set ShopWhiteList[ShopCount] = whiteList
            set ShopCostAction[ShopCount] = CreateTrigger()
            if costFunction != null then
                call TriggerAddCondition(ShopCostAction[ShopCount], Filter(costFunction))
            endif
            set ShopsGold[unitCode].real[0] = goldFactor
            set ShopsLumber[unitCode].real[0] = lumberFactor
        endif
        return Shops[unitCode]
    endfunction

    function TasItemShopSetMode takes integer unitCode, boolean whiteList returns nothing
        set ShopWhiteList[Shops[unitCode]] = whiteList
    endfunction

    function TasItemShopAddShop takes integer unitCode, integer itemCode returns nothing
        if itemCode <= 0 then
            return
        endif
        call TasItemShopCreateShop(unitCode, false, 1.0, 1.0, null)
        call TasItemCaclCost(itemCode)
        set ShopsItems[unitCode].boolean[itemCode] = true
        set ShopsItems[unitCode][0] = ShopsItems[unitCode][0] + 1
        set ShopsItems[unitCode][ShopsItems[unitCode][0]] = itemCode
    endfunction

    function TasItemShopAddShop5 takes integer unitCode, integer a, integer b, integer c, integer d, integer e returns nothing
        call TasItemShopAddShop(unitCode, a)
        call TasItemShopAddShop(unitCode, b)
        call TasItemShopAddShop(unitCode, c)
        call TasItemShopAddShop(unitCode, d)
        call TasItemShopAddShop(unitCode, e)
    endfunction
    
    function TasItemShopGoldFactor takes integer unitCode, real factor, integer itemCode returns nothing
        call TasItemShopCreateShop(unitCode, false, 1.0, 1.0, null)
        set ShopsGold[unitCode].real[itemCode] = factor
    endfunction

    function TasItemShopLumberFactor takes integer unitCode, real factor, integer itemCode returns nothing
        call TasItemShopCreateShop(unitCode, false, 1.0, 1.0, null)
        set ShopsLumber[unitCode].real[itemCode] = factor
    endfunction

    public function ClearQuickLink takes player p returns nothing
        call QuickLink[GetPlayerId(p)].flush()
    endfunction

    public function SetQuickLink takes player p, integer itemCode returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer loopA

        call TasItemCaclCost(itemCode) 

        if QuickLink[playerIndex].boolean[itemCode] then
            set loopA = QuickLink[playerIndex][0]
            loop
                exitwhen loopA <= 0
                if QuickLink[playerIndex][loopA] == itemCode then
                    set QuickLink[playerIndex][loopA] = QuickLink[playerIndex][QuickLink[playerIndex][0]]
                    set QuickLink[playerIndex][0] = QuickLink[playerIndex][0] - 1
                    set QuickLink[playerIndex].boolean[itemCode] = false

                    if QuickLink[playerIndex][0] <= refButtonCountQuickLink then
                        set CurrentOffSetQuickLink[playerIndex] = 0
                    endif
                    exitwhen true
                endif
                
                set loopA = loopA - 1
            endloop
        else
            set QuickLink[playerIndex][0] = QuickLink[playerIndex][0] + 1
            set QuickLink[playerIndex][QuickLink[playerIndex][0]] = itemCode
            set QuickLink[playerIndex].boolean[itemCode] = true
        endif
    endfunction

    public function CanBuyItem takes integer itemCode, integer shopObject, player p returns boolean
        local boolean whilteList
        if shopObject > 0 then
            set whilteList = ShopWhiteList[Shops[shopObject]]
            if (not ShopsItems[shopObject].boolean[itemCode] and whilteList) or (ShopsItems[shopObject].boolean[itemCode] and not whilteList)  then
                return false
            endif
            
            if ShopsItems[shopObject].boolean[itemCode] and whilteList then
                return true
            endif
        endif
        return BuyAbleMarked[GetPlayerId(p)].boolean[itemCode]
    endfunction

    public function AllMatsProvided takes player p, integer itemCode, integer shopObject returns boolean
        local integer loopA = 0
        local integer playerIndex = GetPlayerId(p)
        local integer v
        set MissingCount = 0
        call TasItemFusionGetMissingMaterial(p, itemCode, true)
        set loopA = TasItemFusion_PlayerMissing[playerIndex][0]
        loop
            exitwhen loopA <= 0
            set v = TasItemFusion_PlayerMissing[playerIndex][loopA]
            if not CanBuyItem(v, shopObject, p) then
                set MissingCount = MissingCount + 1
                set MissingItemCode[MissingCount] = v
            endif
            set loopA = loopA - 1
        endloop
        return MissingCount == 0
    endfunction

    public function updateItemFrame takes integer createContext, integer data, boolean showGold, boolean showLumber returns nothing
        local integer lumber
        local integer gold
        local integer playerIndex = GetPlayerId(GetLocalPlayer())
        if createContext != CREATE_CONTEXT_CURRENT then
            call BlzFrameSetVisible(BlzGetFrameByName(buttonListHighLightFrameName, createContext), MarkedItemCodes.boolean[data])
        endif

        call BlzFrameSetTexture(BlzGetFrameByName("TasButtonIcon", createContext), BlzGetAbilityIcon(data), 0, false)
        call BlzFrameSetText(BlzGetFrameByName("TasButtonText", createContext), GetObjectName(data))

        call BlzFrameSetTexture(BlzGetFrameByName("TasButtonListTooltipIcon", createContext), BlzGetAbilityIcon(data), 0, false)
        call BlzFrameSetText(BlzGetFrameByName("TasButtonListTooltipName", createContext), GetObjectName(data))
        call BlzFrameSetText(BlzGetFrameByName("TasButtonListTooltipText", createContext), BlzGetAbilityExtendedTooltip(data, 0))

        if StringLength(BlzGetAbilityExtendedTooltip(data, 0)) >= toolTipLimitBig then
            call BlzFrameSetSize(BlzGetFrameByName("TasButtonListTooltipText", createContext), toolTipSizeXBig, 0)
        else
            call BlzFrameSetSize(BlzGetFrameByName("TasButtonListTooltipText", createContext), toolTipSizeX, 0)
        endif

        if showGold or showLumber then
            // has material -> Fusion
            if TasItemFusion_BuiltWay[data][0] > 0 then
                call TasItemFusionCalc(GetLocalPlayer(), data, true)
                set gold = TasItemFusionGold
                set lumber = TasItemFusionLumber
            else
                set gold = TasItemGetCostGold(data)
                set lumber = TasItemGetCostLumber(data)
            endif
            call CostModifier(gold, lumber, data, ShoperMain[playerIndex], CurrentShop[playerIndex], LocalShopObject)
            set gold = TempGold
            set lumber = TempLumber

            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonTextGold", createContext), showGold)
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonIconGold", createContext), showGold)
            if showGold then
                if GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_GOLD) >= gold then
                    call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", createContext), I2S(gold))
                else
                    call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", createContext), "|cffff2010" + I2S(gold))
                endif
            else
                call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", createContext), "0")
            endif
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonTextLumber", createContext), showLumber)
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonIconLumber", createContext), showLumber)
            if showLumber then
                if GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_LUMBER) >= lumber then
                    call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", createContext), I2S(lumber))
                else
                    call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", createContext), "|cffff2010" + I2S(lumber))
                endif
            else
                call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", createContext), "0")
            endif
        else
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonTextGold", createContext), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonIconGold", createContext), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonTextLumber", createContext), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasButtonIconLumber", createContext), false)
        endif
    endfunction

    public function updateItemFrameAction takes nothing returns nothing
        local integer buttonIndex = S2I(BlzFrameGetText(TasButtonListFrame))
        local integer context = TasButtonListCreateContext[TasButtonListIndex] + buttonIndex
        
        call updateItemFrame(context, TasButtonListData, buttonListShowGold, buttonListShowLumber)
    endfunction

    public function updateUndoButton takes integer data, string actionName returns nothing
        call BlzFrameSetTexture(FrameUndoButtonIcon, BlzGetAbilityIcon(data), 0, false)
        call BlzFrameSetTexture(FrameUndoButtonIconPushed, BlzGetAbilityIcon(data), 0, false)
        call BlzFrameSetText(FrameUndoText, GetLocalizedString(textUndo) + actionName + "\n" + GetObjectName(data))
    endfunction

    public function CreateUndo takes player p, integer itemCode, integer gold, integer lumber, string actionName returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer index
        set UndoPlayerCount[playerIndex] = UndoPlayerCount[playerIndex] + 1
        set index = UndoPlayerCount[playerIndex] + playerIndex * UndoPlayerSize

        if UndoItems[index] == null then
            set UndoItems[index] = Table.create()
        endif

        if UndoResults[index] == null then
            set UndoResults[index] = Table.create()
        endif

        set UndoActionName[index] = actionName
        set UndoResultCode[index] = itemCode
        set UndoGold[index] = gold
        set UndoLumber[index] = lumber

        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(FrameUndoBox, true)
            call updateUndoButton(itemCode, actionName)            
        endif

        return index
    endfunction

    public function updateRefButton takes integer buttonIndex, integer data, unit u returns nothing
        if data > 0 then
            call BlzFrameSetVisible(RefButton[buttonIndex], true)
            call BlzFrameSetTexture(RefButtonIcon[buttonIndex], BlzGetAbilityIcon(data), 0, false)
            call BlzFrameSetTexture(RefButtonIconPushed[buttonIndex], BlzGetAbilityIcon(data), 0, false)
            call BlzFrameSetTexture(RefButtonToolTipIcon[buttonIndex], BlzGetAbilityIcon(data), 0, false)
            
            if RefButtonToolTipName[buttonIndex] != RefButtonToolTipText[buttonIndex] then
                call BlzFrameSetText(RefButtonToolTipName[buttonIndex], GetObjectName(data))
                call BlzFrameSetText(RefButtonToolTipText[buttonIndex], BlzGetAbilityExtendedTooltip(data, 0))
                if StringLength(BlzGetAbilityExtendedTooltip(data, 0)) >= toolTipLimitBig then
                    call BlzFrameSetSize(RefButtonToolTipText[buttonIndex], toolTipSizeXBig, 0)
                else
                    call BlzFrameSetSize(RefButtonToolTipText[buttonIndex], toolTipSizeX, 0)
                endif
            else
                call BlzFrameSetText(RefButtonToolTipText[buttonIndex], GetObjectName(data))
            endif
            
        
            if u != null and IsUnitType(u, UNIT_TYPE_HERO) then
                call BlzFrameSetText(RefButtonToolTipText[buttonIndex], BlzFrameGetText(RefButtonToolTipText[buttonIndex]) + "\n" + GetHeroProperName(u))
            endif
        else
            call BlzFrameSetVisible(RefButton[buttonIndex], false)
        endif
    endfunction

    public function updateRefButtonsInventory takes player p returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer count = TasItemFusion_PlayerItems[playerIndex][0]
        local boolean valid
        local integer offSet = CurrentOffSetInventory[playerIndex]
        local integer validCounter = 0
        local integer loopA = 1
        local integer buttonIndex
        local item i

        call BlzFrameSetVisible(FrameInventoryBox, true)
        call BlzFrameSetText(FrameInventoryPageText, I2S(offSet / refButtonCountInv + 1))
        call BlzFrameSetVisible(FrameInventoryPage, not inventoryShowMainOnly and count > refButtonCountInv)
        loop
            
            set buttonIndex = loopA + RefButtonInventoryStart
            if not inventoryShowMainOnly then
                set valid = (loopA + offSet <= count)
                call BlzFrameSetVisible(RefButton[buttonIndex], valid)
                if valid then
                    set validCounter = validCounter + 1
                    call updateRefButton(buttonIndex, GetItemTypeId(TasItemFusion_PlayerItems[playerIndex].item[loopA + offSet]), null)
                    call BlzFrameSetVisible(RefButtonOverlay[buttonIndex], TasItemFusion_PlayerItems[playerIndex].item[loopA + offSet] == SelectedItem[playerIndex])
                endif
            else
                set i = UnitItemInSlot(ShoperMain[playerIndex], loopA - 1)
                call updateRefButton(buttonIndex, GetItemTypeId(i), null)
                call BlzFrameSetVisible(RefButtonOverlay[buttonIndex], i == SelectedItem[playerIndex])
                if i != null then
                    set validCounter = validCounter + 1
                endif
            endif

            set loopA = loopA + 1
            exitwhen loopA > refButtonCountInv

            // body
        endloop
        
        set i = null
        return validCounter
    endfunction

    public function updateRefButtonsMaterial takes player p, integer result returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer count = TasItemFusion_BuiltWay[result][0]
        local boolean valid
        local integer offSet = CurrentOffSetMaterial[playerIndex]
        local integer validCounter = 0
        local integer loopA = 1
        local integer buttonIndex

        call BlzFrameSetVisible(FrameMaterialBox, true)
        call BlzFrameSetText(FrameMaterialPageText, I2S(offSet / refButtonCountMats + 1))
        call BlzFrameSetVisible(FrameMaterialPage, count > refButtonCountMats)
        loop
            set buttonIndex = loopA + RefButtonMaterialStart
            set valid = (loopA + offSet <= count)
            call BlzFrameSetVisible(RefButton[buttonIndex], valid)
            if valid then
                set validCounter = validCounter + 1
                call updateRefButton(buttonIndex, TasItemFusion_BuiltWay[result][loopA + offSet], null)
            endif

            set loopA = loopA + 1
            exitwhen loopA > refButtonCountMats

            // body
        endloop
        
        return validCounter
    endfunction

    public function updateRefButtonsUpgrades takes player p, integer result returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer count = TasItemFusion_UsedIn[result][0]
        local boolean valid
        local integer offSet = CurrentOffSetUpgrade[playerIndex]
        local integer validCounter = 0
        local integer loopA = 1
        local integer buttonIndex

        call BlzFrameSetVisible(FrameUpgradeBox, true)
        call BlzFrameSetText(FrameUpgradePageText, I2S(offSet / refButtonCountUp + 1))
        call BlzFrameSetVisible(FrameUpgradePage, count > refButtonCountUp)
        loop
            set buttonIndex = loopA + RefButtonUpgradeStart
            set valid = (loopA + offSet <= count)
            call BlzFrameSetVisible(RefButton[buttonIndex], valid)
            if valid then
                set validCounter = validCounter + 1
                call updateRefButton(buttonIndex, TasItemFusion_UsedIn[result][loopA + offSet], null)
                call BlzFrameSetVisible(RefButtonOverlay2[buttonIndex], BlzFrameIsVisible(RefButton[buttonIndex]) and not CanBuyItem(TasItemFusion_UsedIn[result][loopA + offSet], LocalShopObject, p))
            endif

            set loopA = loopA + 1
            exitwhen loopA > refButtonCountUp

            // body
        endloop
        
        return validCounter
    endfunction

    public function updateRefButtonsQuickLink takes player p returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer count = QuickLink[playerIndex][0]
        local boolean valid
        local integer offSet = CurrentOffSetQuickLink[playerIndex]
        local integer validCounter = 0
        local integer loopA = 1
        local integer buttonIndex

        call BlzFrameSetVisible(FrameQuickLinkBox, true)
        call BlzFrameSetText(FrameQuickLinkPageText, I2S(offSet / refButtonCountQuickLink + 1))
        call BlzFrameSetVisible(FrameQuickLinkPage, count > refButtonCountQuickLink)
        loop
            
            set buttonIndex = loopA + RefButtonQuickLinkStart
            set valid = (loopA + offSet <= count)
            call BlzFrameSetVisible(RefButton[buttonIndex], valid)
            if valid then
                set validCounter = validCounter + 1
                call updateRefButton(buttonIndex, QuickLink[playerIndex][loopA + offSet], null)
                call BlzFrameSetVisible(RefButtonOverlay2[buttonIndex], BlzFrameIsVisible(RefButton[buttonIndex]) and not CanBuyItem(QuickLink[playerIndex][loopA + offSet], LocalShopObject, p))
            endif

            set loopA = loopA + 1
            exitwhen loopA > refButtonCountQuickLink
        endloop
        
        return validCounter
    endfunction

    public function updateRefButtonsUser takes player p returns integer
        local integer playerIndex = GetPlayerId(p)
        local integer count = BlzGroupGetSize(Shoper[playerIndex])
        local boolean valid
        local integer offSet = CurrentOffSetUser[playerIndex]
        local unit u
        local integer validCounter = 0
        local integer loopA = 1
        local integer buttonIndex

        call BlzFrameSetVisible(FrameUserBox, true)
        call BlzFrameSetText(FrameUserPageText, I2S(offSet / refButtonCountUser + 1))
        call BlzFrameSetVisible(FrameUserPage, count > refButtonCountUser)
        
        loop
            set buttonIndex = loopA + RefButtonUserStart
            set valid = (loopA + offSet <= count)
            call BlzFrameSetVisible(RefButton[buttonIndex], valid)
            if valid then
                set validCounter = validCounter + 1
                set u = BlzGroupUnitAt(Shoper[playerIndex], loopA + offSet - 1)
                call updateRefButton(buttonIndex, GetUnitTypeId(u), u)
            endif

            set loopA = loopA + 1
            exitwhen loopA > refButtonCountUser

            // body
        endloop
        set u = null
        
        return validCounter
    endfunction

    public function updateHaveMats takes player p, integer data returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer mat
        local integer offset = CurrentOffSetMaterial[playerIndex]
        local integer loopA = 1
        local integer buttonIndex
        call TempTable.flush()
        //call TasItemFusionGetUseableMaterial(p, data, true, true)
        loop
            set buttonIndex = loopA + RefButtonMaterialStart
            
            if BlzFrameIsVisible(RefButton[buttonIndex]) then
                
                set mat = TasItemFusion_BuiltWay[data][loopA + offset]
                set TempTable[mat] = TempTable[mat] + 1
                
                call BlzFrameSetVisible(RefButtonOverlay[buttonIndex], TempTable[mat] <= TasItemFusion_PlayerItems[playerIndex][mat])
                call BlzFrameSetVisible(RefButtonOverlay2[buttonIndex], not BlzFrameIsVisible(RefButtonOverlay[buttonIndex]) and not CanBuyItem(mat, LocalShopObject, p))
                
            endif
            set loopA = loopA + 1
            exitwhen loopA > refButtonCountMats
        endloop
    endfunction

    public function updateOverLayMainSelected takes player p returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer loopA = 1
        local integer offset = CurrentOffSetUser[playerIndex]
        local integer buttonIndex
        loop
            exitwhen loopA > refButtonCountUser
            set buttonIndex = loopA + RefButtonUserStart
            call BlzFrameSetVisible(RefButtonOverlay[buttonIndex], BlzFrameIsVisible(RefButton[buttonIndex]) and ShoperMain[playerIndex] == BlzGroupUnitAt(Shoper[playerIndex], loopA - 1 + offset))
            set loopA = loopA + 1
        endloop
    endfunction

    public function GiveItem takes unit u, item i, integer undo returns nothing
        local integer oldCharges = GetItemCharges(i)
        local integer itemCode = GetItemTypeId(i)
        local integer loopA = 0
        local item i2
        
        call UnitAddItem(u, i)
        
        if oldCharges > 0 and undo > 0 then
            if GetItemCharges(i) != oldCharges then
                loop
                    set i2 = UnitItemInSlot(u, loopA)
                    if GetItemTypeId(i2) == itemCode and i2 != i then
                        set UndoStackGainer[undo] = i2
                        set UndoStackGained[undo] = oldCharges - GetItemCharges(i)
                    endif
                    set loopA = loopA + 1
                    exitwhen loopA >= bj_MAX_INVENTORY
                endloop
            endif
        endif        
        set i2 = null
    endfunction

    public function GiveItemGroup takes player p, item i, integer undoIndex returns nothing
        local boolean found
        local unit u
        local integer playerIndex = GetPlayerId(p)
        local integer loopA
        call SetItemPlayer(i, p, true)
        call GiveItem(ShoperMain[playerIndex], i, undoIndex)

        if canProviderGetItem and GetHandleId(i) > 0 and not UnitHasItem(ShoperMain[playerIndex], i)  then
            set found = false
            set loopA = BlzGroupGetSize(Shoper[playerIndex]) - 1
            loop
                exitwhen loopA <= 0
                set u = BlzGroupUnitAt(Shoper[playerIndex], loopA)
                call GiveItem(u, i, undoIndex)
                if GetHandleId(i) == 0 or UnitHasItem(u, i) then
                    if canUndo then
                        set UndoResults[undoIndex][0] = UndoResults[undoIndex][0] + 1
                        set UndoResults[undoIndex].item[UndoResults[undoIndex][0]] = i
                        set UndoResults[undoIndex].unit[- UndoResults[undoIndex][0]] = u
                    endif
                    set found = true
                    exitwhen true
                endif
                set loopA = loopA - 1
            endloop
            if not found and canUndo then
                set UndoResults[undoIndex][0] = UndoResults[undoIndex][0] + 1
                set UndoResults[undoIndex].item[UndoResults[undoIndex][0]] = i
                set UndoResults[undoIndex].unit[- UndoResults[undoIndex][0]] = u
            endif
        else
            if canUndo then
                set UndoResults[undoIndex][0] = UndoResults[undoIndex][0] + 1
                set UndoResults[undoIndex].item[UndoResults[undoIndex][0]] = i
                set UndoResults[undoIndex].unit[- UndoResults[undoIndex][0]] = ShoperMain[playerIndex]
            endif
        endif
        set u = null
    endfunction

    public function setSelected takes player p, integer data returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer oldData = Selected[playerIndex]
        local integer loopA
        local integer buttonIndex
        set Selected[playerIndex] = data
        
        if oldData != data then
            set CurrentOffSetUpgrade[playerIndex] = 0
            set CurrentOffSetMaterial[playerIndex] = 0
            set SelectedItem[playerIndex] = null
            
            if p == GetLocalPlayer() then
                if canDefuse then
                    call BlzFrameSetEnable(FrameDefuseButton, false)
                endif
                if canSellItems then
                    call BlzFrameSetEnable(FrameSellButton, false)
                endif
                set MarkedItemCodes.boolean[oldData] = false
                set MarkedItemCodes.boolean[data] = true
            endif
        endif
        if p == GetLocalPlayer() then            
            if refButtonCountUp > 0 then
                if TasItemFusion_UsedIn[data][0] > 0 then
                    call updateRefButtonsUpgrades(p, data)
                else
                    call BlzFrameSetVisible(FrameUpgradeBox, false)
                endif
            endif
            if refButtonCountMats > 0 then
                if TasItemFusion_BuiltWay[data][0] > 0 then
                    call updateRefButtonsMaterial(p, data)
                    call updateHaveMats(p, data)
                else
                    call BlzFrameSetVisible(FrameMaterialBox, false)
                endif
            endif
            if refButtonCountInv > 0 then
                if TasItemFusion_PlayerItems[playerIndex][0] > 0 then
                    call updateRefButtonsInventory(p)
                else
                    call BlzFrameSetVisible(FrameInventoryBox, false)
                endif
            endif
            if refButtonCountQuickLink > 0 then
                call updateRefButtonsQuickLink(p)
            endif
            if refButtonCountUser > 0 then
                call updateRefButtonsUser(p)
                call updateOverLayMainSelected(p)
            endif
            
            call updateItemFrame(CREATE_CONTEXT_CURRENT, data, buyButtonShowGold, buyButtonShowLumber)
            if (buyButtonShowGold or buyButtonShowLumber) and not flexibleShop and (not CanBuyItem(data, LocalShopObject, p) or (TasItemFusion_BuiltWay[data][0] > 0 and not AllMatsProvided(p, data, LocalShopObject))) then
                call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", CREATE_CONTEXT_CURRENT), GetLocalizedString(textUnBuyable))
                call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", CREATE_CONTEXT_CURRENT), GetLocalizedString(textUnBuyable))
            endif
        endif
    endfunction
    
    public function setSelectedItem takes player p, item i returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = GetItemTypeId(i)
        set SelectedItem[playerIndex] = i
        if i != null then
            if GetLocalPlayer() == p then
                if canDefuse then
                    call BlzFrameSetText(FrameDefuseText, GetLocalizedString(textDefuse) + "\n" + BlzGetAbilityTooltip(itemCode, 0))
                    call BlzFrameSetEnable(FrameDefuseButton, TasItemFusion_BuiltWay[itemCode][0] > 0)
                endif

                if canSellItems then
                    call GetItemSellCosts(ShoperMain[playerIndex], CurrentShop[playerIndex], i)

                    call BlzFrameSetText(FrameSellText, GetLocalizedString(textSell) + " " + GetItemName(i) + "\n" + GetLocalizedString("GOLD") + " " + I2S(TempGold) + "\n" + GetLocalizedString("LUMBER") + " " + I2S(TempLumber))
                    call BlzFrameSetEnable(FrameSellButton, true)
                endif
            endif
        endif
    endfunction
    
    function TasItemShopUIShow takes player p, unit shop, group shopperGroup, unit mainShoper returns nothing
        local boolean flag = (shop != null)
        local integer playerIndex = GetPlayerId(p)
        local boolean isNewShopType = GetUnitTypeId(CurrentShop[playerIndex]) != GetUnitTypeId(shop)
        local integer oldSize = TasItemFusion_PlayerItems[playerIndex][0]
        local integer loopA
        local integer loopB
        local integer undoPlayerIndex
        local integer index
        local integer shopObject
        if p == GetLocalPlayer() then
            call BlzFrameSetVisible(FrameParentSuper, flag)
            if flag then
                call BlzFrameSetVisible(BlzFrameGetParent(FrameParentSuper), true)
            endif
        endif

        if flag then            
            set CurrentShop[playerIndex] = shop

            if mainShoper != null then
                set ShoperMain[playerIndex] = mainShoper
            elseif shopperGroup != null then
                set ShoperMain[playerIndex] = FirstOfGroup(shopperGroup)
            endif
            if shopperGroup != null then
                call GroupClear(Shoper[playerIndex])
                // when a group was given     
                call BlzGroupAddGroupFast(shopperGroup, Shoper[playerIndex])
            endif

            call GroupAddUnit(Shoper[playerIndex], mainShoper)

            call TasItemFusionGetUseableItems(p, Shoper[playerIndex], not sharedItems)
            
            if oldSize != TasItemFusion_PlayerItems[playerIndex][0] then                
                set CurrentOffSetInventory[playerIndex] = 0
            endif
            if isNewShopType then
                //call BJDebugMsg("isNewShopType")
                // has to unmark buyAble
                set shopObject = GetUnitTypeId(shop)
                call BuyAbleMarked[playerIndex].flush()
                
                call TasButtonListClearDataEx(ButtonListIndex, playerIndex)
                // has custom Shop Data?
                if Shops.has(shopObject) then
                    // WhiteListMode?
                    if ShopWhiteList[Shops[shopObject]] then
                        set loopA = 1
                        set loopB = ShopsItems[shopObject][0]
                        loop
                            exitwhen loopA > loopB
                            call TasButtonListAddDataEx(ButtonListIndex, ShopsItems[shopObject][loopA], playerIndex)
                            set BuyAbleMarked[playerIndex].boolean[ShopsItems[shopObject][loopA]] = true
                            set loopA = loopA + 1
                        endloop
                    else
                        // BlackListMode
                        set loopA = 1
                        loop
                            exitwhen loopA > BUY_ABLE_ITEMS_Count
                            if not ShopsItems[shopObject].boolean[BUY_ABLE_ITEMS[loopA]] then
                                call TasButtonListAddDataEx(ButtonListIndex, BUY_ABLE_ITEMS[loopA], playerIndex)
                                set BuyAbleMarked[playerIndex].boolean[BUY_ABLE_ITEMS[loopA]] = true
                            endif
                            set loopA = loopA + 1
                        endloop
                    endif
                else
                    // none custom Shop, add all data.
                    set loopA = 1
                    loop
                        exitwhen loopA > BUY_ABLE_ITEMS_Count
                        call TasButtonListAddDataEx(ButtonListIndex, BUY_ABLE_ITEMS[loopA], playerIndex)
                        set BuyAbleMarked[playerIndex].boolean[BUY_ABLE_ITEMS[loopA]] = true
                        set loopA = loopA + 1
                    endloop
                endif
            endif
            if GetLocalPlayer() == p then
                if IsUnitType(ShoperMain[playerIndex], UNIT_TYPE_HERO) then
                    call BlzFrameSetText(FrameTitelText, GetUnitName(shop) + " - " + GetHeroProperName(ShoperMain[playerIndex]))
                else
                    call BlzFrameSetText(FrameTitelText, GetUnitName(shop) + " - " + GetUnitName(ShoperMain[playerIndex]))
                endif
                
                set LocalShopObject = GetUnitTypeId(shop)
                if isNewShopType then
                    call TasButtonListSearch(ButtonListIndex, null)
                endif
            endif
            call UpdateTasButtonList(ButtonListIndex)
            call setSelected(p, Selected[playerIndex])
            call setSelectedItem(p, SelectedItem[playerIndex])
        else
            set CurrentShop[playerIndex] = null
            if canUndo then
                // loop the undo of that player from last to first
                set loopA = 1
                //call BJDebugMsg("LoopA:"+I2S(loopA))
                set undoPlayerIndex = playerIndex * UndoPlayerSize
                loop
                    exitwhen loopA > UndoPlayerCount[playerIndex]
                    
                    set index = undoPlayerIndex + loopA
                    //call BJDebugMsg(UndoActionName[index])
                    set loopB = UndoItems[index][0]
                    loop
                        exitwhen loopB <= 0
                        // call BJDebugMsg("LoopB:"+I2S(loopB))
                        // call BJDebugMsg("Remove:"+GetItemName(UndoItems[index].item[loopB]))
                        call SetItemVisible(UndoItems[index].item[loopB], true)

                        call RemoveItem(UndoItems[index].item[loopB])
                        set loopB = loopB - 1
                    endloop
                    set UndoStackGainer[index] = null
                    call UndoResults[index].flush()
                    call UndoItems[index].flush()
                    set loopA = loopA + 1
                endloop

                if GetLocalPlayer() == p then
                    call BlzFrameSetVisible(FrameUndoBox, false)
                endif
                set UndoPlayerCount[playerIndex] = 0
            endif
        endif
    endfunction
    
    public function BuyItem takes player p, integer itemCode returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer gold
        local integer lumber
        local integer shopObject = GetUnitTypeId(CurrentShop[playerIndex])
        local integer loopA
        local integer undoIndex
        local item i
        local unit u
        local item newItem
        local boolean isFusion = TasItemFusion_BuiltWay[itemCode][0] > 0
        
        //call BJDebugMsg(GetPlayerName(p) + " Wana Buy " + GetObjectName(itemCode) + " with " + GetUnitName(ShoperMain[playerIndex]))
        if BlzGroupGetSize(Shoper[playerIndex]) == 0 then
            if GetLocalPlayer() == p then
                call BJDebugMsg(GetLocalizedString(textNoValidShopper))
            endif
            return
        endif
        
        // can not buy this?
        if not flexibleShop and not CanBuyItem(itemCode, shopObject, p) then
            if GetLocalPlayer() == p then
                call BJDebugMsg(GetObjectName(itemCode) + " " + GetLocalizedString(textCanNotBuySufix))
            endif
            return
        endif

        // has material -> Fusion
        if isFusion then
            call TasItemFusionCalc(p, itemCode, false)
            set gold = TasItemFusionGold
            set lumber = TasItemFusionLumber
        else
            set gold = TasItemGetCostGold(itemCode)
            set lumber = TasItemGetCostLumber(itemCode)
        endif

        call CostModifier(gold, lumber, itemCode, ShoperMain[playerIndex], CurrentShop[playerIndex], shopObject)
        set gold = TempGold
        set lumber = TempLumber
        // only items buyable in the shop can be replaced by Gold? Also ignore non fusion items.
        if not flexibleShop and isFusion then
            if not AllMatsProvided(p, itemCode, shopObject) then
                if GetLocalPlayer() == p then
                    call BJDebugMsg(GetLocalizedString(textCanNotBuyPrefix) + " " + GetObjectName(itemCode))
                    set loopA = MissingCount
                    loop
                        exitwhen loopA <= 0
                        call BJDebugMsg(GetObjectName(MissingItemCode[loopA]) + " " + GetLocalizedString(textCanNotBuySufix))
                        set loopA = loopA - 1
                    endloop
                endif
                return
            endif
        endif

        if GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) >= gold then
            if GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) >= lumber then
                //call BJDebugMsg("Accept Request")
                if canUndo then
                    set undoIndex = CreateUndo(p, itemCode, gold, lumber, " Buy")
                                       
                    if isFusion and TasItemFusion_PlayerMaterial[playerIndex][0] > 0 then
                        
                        set loopA = TasItemFusion_PlayerMaterial[playerIndex][0]
                        set UndoItems[undoIndex][0] = loopA
                        loop
                            set i = TasItemFusion_PlayerMaterial[playerIndex].item[loopA]
                            set u = ItemHolder_get(i)
                            set UndoItems[undoIndex].unit[- loopA] = u
                            set UndoItems[undoIndex].item[loopA] = i
                            //call BJDebugMsg("Hide Item")
                            call UnitRemoveItem(u, i)
                            call SetItemVisible(i, false)
                            set loopA = loopA - 1
                            exitwhen loopA <= 0
                        endloop
                    endif

                else
                    if isFusion and TasItemFusion_PlayerMaterial[playerIndex][0] > 0 then
                        set loopA = TasItemFusion_PlayerMaterial[playerIndex][0]
                        loop
                            call RemoveItem(TasItemFusion_PlayerMaterial[playerIndex].item[loopA])
                            set loopA = loopA - 1
                            exitwhen loopA <= 0
                        endloop
                    endif
                endif
                call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_GOLD, - gold)
                call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_LUMBER, - lumber)
                set newItem = CreateItem(itemCode, GetUnitX(ShoperMain[playerIndex]), GetUnitY(ShoperMain[playerIndex]))
                //call BJDebugMsg("NewItem: "+ I2S(GetHandleId(newItem)))
                call GiveItemGroup(p, newItem, undoIndex)

                //CreateItem(itemCode, GetPlayerStartLocationX(player), GetPlayerStartLocationY(player))
                call TasItemShopUIShow(p, CurrentShop[playerIndex], null, null)
            elseif not GetSoundIsPlaying(SoundNoLumber[GetHandleId(GetPlayerRace(p))]) then
                call StartSoundForPlayerBJ(p, SoundNoLumber[GetHandleId(GetPlayerRace(p))])
            endif
        elseif not GetSoundIsPlaying(SoundNoGold[GetHandleId(GetPlayerRace(p))]) then
            call StartSoundForPlayerBJ(p, SoundNoGold[GetHandleId(GetPlayerRace(p))])
        endif

        set newItem = null
        set i = null
        set u = null
        // call BJDebugMsg("BuyItem Done")
    endfunction

    public function SellItem takes player p, item i returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode
        local integer gold
        local integer lumber
        local integer undoIndex
        local integer loopA
        local boolean wasSelectedItem = (i == SelectedItem[playerIndex])
        if i == null then
            return
        endif
        set itemCode = GetItemTypeId(i)
        call GetItemSellCosts(ShoperMain[playerIndex], CurrentShop[playerIndex], i)
        set gold = TempGold
        set lumber = TempLumber

        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_GOLD, gold)
        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_LUMBER, lumber)
        if canUndo then
            set undoIndex = CreateUndo(p, itemCode, - gold, - lumber, GetLocalizedString(textSell))
            set UndoItems[undoIndex][0] = 1
            set UndoItems[undoIndex].item[1] = i
            set UndoItems[undoIndex].unit[- 1] = ItemHolder_get(i)
            call UnitRemoveItem(ItemHolder_get(i), i)
            call SetItemVisible(i, false)
            
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(FrameUndoBox, true)
                call updateUndoButton(UndoResultCode[undoIndex], GetLocalizedString(textSell))
            endif
        else
            call RemoveItem(i)
        endif

        if wasSelectedItem then
            if GetLocalPlayer() == p then
                call BlzFrameSetEnable(FrameSellButton, false)
            endif
            set SelectedItem[playerIndex] = null
        endif
    endfunction

    private function ButtonListFunction_Search takes nothing returns boolean
        return FindIndex(StringCase(GetObjectName(TasButtonListData), false), StringCase(TasButtonListText, false)) >= 0
    endfunction

    private function ButtonListFunction_Filter takes nothing returns boolean
        local integer selected = SelectedCategory[GetPlayerId(GetLocalPlayer())]
        if ToggleIconButtonGetValue(CategoryModButtonIndex, GetLocalPlayer()) == 0 then
            return selected == 0 or BlzBitAnd(TasItemCategory[TasButtonListData], selected) >= selected
        else
            return selected == 0 or BlzBitAnd(TasItemCategory[TasButtonListData], selected) > 0
        endif
    endfunction

    private function ButtonListFunction_LeftClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local real time
        if p == GetLocalPlayer() then
            set time = TimerGetElapsed(Timer)
            if Selected[playerIndex] == TasButtonListData and time - DoubleClickStamp <= doubleClickTimeOut then
                // finish the timer, so the player has to do 2 clicks again to trigger a DoubleClick
                set DoubleClickStamp = 0
                call BlzFrameClick(BlzGetFrameByName("TasButton", CREATE_CONTEXT_CURRENT))
            else
                set DoubleClickStamp = time
            endif
        endif
        if QuickLinkKeyActive[playerIndex] then
            call SetQuickLink(p, TasButtonListData)
        endif
        call setSelected(p, TasButtonListData)
    endfunction

    private function ButtonListFunction_RightClick takes nothing returns nothing
        call BuyItem(GetTriggerPlayer(), TasButtonListData)
    endfunction

    private function ButtonListFunction_AsyncRightClick takes nothing returns nothing
        call ShowSprite(TasButtonListFrame, GetTriggerPlayer())
    endfunction

    private function ButtonListFunction_AsyncLeftClick takes nothing returns nothing
    endfunction

    private function ButtonListFunction_CategoryAction takes nothing returns nothing
        set SelectedCategory[GetPlayerId(ToggleIconButton_Player)] = ToggleIconButtonGroup_Value 
        if GetLocalPlayer() == ToggleIconButton_Player then
            call TasButtonListSearch(TasButtonListIndex, "")
        endif
    endfunction

    public function AddClearFocus takes framehandle frame returns nothing
        call BlzTriggerRegisterFrameEvent(ButtonTriggerClearFocus, frame, FRAMEEVENT_CONTROL_CLICK)
    endfunction

    public function CreateRefButton takes framehandle parent, trigger t, boolean advancedTooltip returns integer
        local framehandle frame
        set RefButtonCount = RefButtonCount + 1
        set frame = BlzCreateFrame("TasItemShopRefButton", parent, 0, RefButtonCount)
        set RefButton[RefButtonCount] = frame
        set RefButtonIcon[RefButtonCount] = BlzGetFrameByName("TasItemShopRefButtonBackdrop", RefButtonCount)
        set RefButtonIconPushed[RefButtonCount] = BlzGetFrameByName("TasItemShopRefButtonBackdropPushed", RefButtonCount)
        set RefButtonOverlay[RefButtonCount] = BlzGetFrameByName("TasItemShopRefButtonBackdropBackdrop", RefButtonCount)
        set RefButtonOverlay2[RefButtonCount] = BlzGetFrameByName("TasItemShopRefButtonBackdropBackdrop2", RefButtonCount)
        
        call BlzFrameSetSize(frame, refButtonSize, refButtonSize)
        call BlzFrameSetVisible(RefButtonOverlay[RefButtonCount], false)
        call BlzFrameSetVisible(RefButtonOverlay2[RefButtonCount], false)

        if advancedTooltip then
            call CreateTasButtonTooltip(frame, FrameParentSuper, 0)
            set RefButtonToolTip[RefButtonCount] = BlzGetFrameByName("TasButtonListTooltipBox" , 0)
            set RefButtonToolTipName[RefButtonCount] = BlzGetFrameByName("TasButtonListTooltipName" , 0)
            set RefButtonToolTipIcon[RefButtonCount] = BlzGetFrameByName("TasButtonListTooltipIcon" , 0)
            set RefButtonToolTipText[RefButtonCount] = BlzGetFrameByName("TasButtonListTooltipText" , 0)
            call BlzFrameClearAllPoints(RefButtonToolTipText[RefButtonCount])
            if toolTipPosPointParent != null then
                call BlzFrameSetPoint(RefButtonToolTipText[RefButtonCount], toolTipPosPoint, frame, toolTipPosPointParent, toolTipPosX, toolTipPosY)
            else
                call BlzFrameSetAbsPoint(RefButtonToolTipText[RefButtonCount], toolTipPosPoint, toolTipPosX, toolTipPosY)
            endif
        else
            set RefButtonToolTipName[RefButtonCount] = CreateSimpleTooltip(frame, "User")
            set RefButtonToolTipText[RefButtonCount] = RefButtonToolTipName[RefButtonCount]
            set RefButtonToolTip[RefButtonCount] = BlzGetFrameByName("EscMenuControlBackdropTemplate" , 0) // this has to match the used box for tooltips from Tooltip buttons
        endif
        call BlzTriggerRegisterFrameEvent(t, frame, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(t, frame, FRAMEEVENT_MOUSE_UP)
        call AddClearFocus(frame)
        set frame = null
        return RefButtonCount
    endfunction

    public function CreateRefButtons takes integer amount, framehandle parent, framehandle textFrame, trigger t, boolean advancedTooltip returns integer
        local integer loopA = 1
        loop
            exitwhen loopA > amount
            call CreateRefButton(parent, t, advancedTooltip)
            if loopA == 1 then
                call BlzFrameSetPoint(RefButton[RefButtonCount], FRAMEPOINT_TOPLEFT, textFrame, FRAMEPOINT_BOTTOMLEFT, 0.0, - 0.003)
            else
                call BlzFrameSetPoint(RefButton[RefButtonCount], FRAMEPOINT_BOTTOMLEFT, RefButton[RefButtonCount - 1], FRAMEPOINT_BOTTOMRIGHT, refButtonGap, 0)
            endif
            call BlzFrameSetText(RefButton[RefButtonCount], I2S(loopA))
            set loopA = loopA + 1
        endloop
        
        return RefButtonCount
    endfunction

    public function CreateRefPage takes framehandle parent, framehandle textFrame, trigger t, integer pageSize returns nothing
        local framehandle array frames
        
        set frames[1] = BlzCreateFrameByType("FRAME", "TasItemShopUIPageControl", parent, "", 0)
        set frames[2] = BlzCreateFrame("TasItemShopCatButton", frames[1], 0, 0)
        set frames[3] = BlzGetFrameByName("TasItemShopCatButtonBackdrop", 0)
        set frames[4] = BlzGetFrameByName("TasItemShopCatButtonBackdropPushed", 0)
        set frames[5] = BlzCreateFrame("TasItemShopCatButton", frames[1], 0, 1)
        set frames[6] = BlzGetFrameByName("TasItemShopCatButtonBackdrop", 1)
        set frames[7] = BlzGetFrameByName("TasItemShopCatButtonBackdropPushed", 1)
        set frames[8] = BlzCreateFrame("TasButtonTextTemplate", frames[1], 0, 0)
        call BlzFrameSetText(frames[8], "00")
        call BlzFrameSetSize(frames[2], refButtonPageSize, refButtonPageSize)
        call BlzFrameSetSize(frames[5], refButtonPageSize, refButtonPageSize)
        call BlzTriggerRegisterFrameEvent(t, frames[2], FRAMEEVENT_CONTROL_CLICK)
        call AddClearFocus(frames[2])
        call AddClearFocus(frames[5])
        call BlzTriggerRegisterFrameEvent(t, frames[2], FRAMEEVENT_MOUSE_UP)
        call BlzTriggerRegisterFrameEvent(t, frames[5], FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(t, frames[5], FRAMEEVENT_MOUSE_UP)
        call BlzFrameSetTexture(frames[3], refButtonPageUp, 0, false)
        call BlzFrameSetTexture(frames[4], refButtonPageUp, 0, false)
        call BlzFrameSetTexture(frames[6], refButtonPageDown, 0, false)
        call BlzFrameSetTexture(frames[7], refButtonPageDown, 0, false)

        //call BlzFrameSetPoint(frames[2], FRAMEPOINT_TOPLEFT, textFrame, FRAMEPOINT_TOPRIGHT, 0.003, 0)
        //call BlzFrameSetPoint(frames[8], FRAMEPOINT_TOPLEFT, frames[2], FRAMEPOINT_TOPRIGHT, 0.003, 0)
        //call BlzFrameSetPoint(frames[5], FRAMEPOINT_TOPLEFT, frames[8], FRAMEPOINT_TOPRIGHT, 0.003, 0)

        call BlzFrameSetPoint(frames[2], FRAMEPOINT_TOPRIGHT, frames[8], FRAMEPOINT_TOPLEFT, - 0.003, 0)
        call BlzFrameSetPoint(frames[8], FRAMEPOINT_TOPRIGHT, frames[5], FRAMEPOINT_TOPLEFT, - 0.003, 0)
        call BlzFrameSetPoint(frames[5], FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_TOPRIGHT, - boxFrameBorderGap, - boxFrameBorderGap)

        //call BlzFrameSetPoint(frames[2], FRAMEPOINT_TOPLEFT, textFrame, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
        //call BlzFrameSetPoint(frames[8], FRAMEPOINT_TOPLEFT, textFrame, FRAMEPOINT_TOPRIGHT, 0.003, 0)
        //call BlzFrameSetPoint(frames[5], FRAMEPOINT_TOPLEFT, frames[2], FRAMEPOINT_BOTTOMLEFT, 0, -0.003)


        //CreateTasButtonTooltip(frames[index], FrameSuperBox)
        call BlzFrameSetText(frames[2], I2S(pageSize))
        call BlzFrameSetText(frames[5], I2S(- pageSize))

        //refButtons.Page = frames[1]
        //refButtons.PageUp = frames[2]
        //refButtons.PageDown = frames[5]
        //refButtons.PageText = frames[8]
        //return frames
    endfunction
    
    public function PlaceRefButtonBox takes framehandle box returns nothing
        local integer loopA
        local boolean found

        if RefButtonBoxRows == 0 then
            call BlzFrameSetPoint(box, FRAMEPOINT_TOPRIGHT, FrameTasButtonList, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
            set RefButtonBoxRows = RefButtonBoxRows + 1
            set RefButtonBoxFrameFirst[RefButtonBoxRows] = box
            set RefButtonBoxFrameLast[RefButtonBoxRows] = box
            set RefButtonBoxSize[RefButtonBoxRows] = xSize - BlzFrameGetWidth(box)
            set ySize = ySize + refButtonBoxSizeY
            call BlzFrameSetSize(FrameParentSuperUI, xSize, ySize)
        else
            set found = false
            set loopA = 1
            loop
                exitwhen loopA > RefButtonBoxRows
                if RefButtonBoxSize[loopA] - BlzFrameGetWidth(box) >= 0 then
                    set found = true
                    call BlzFrameSetPoint(box, FRAMEPOINT_TOPRIGHT, RefButtonBoxFrameLast[loopA], FRAMEPOINT_TOPLEFT, 0, 0)
                    set RefButtonBoxFrameLast[loopA] = box
                    set RefButtonBoxSize[loopA] = RefButtonBoxSize[loopA] - BlzFrameGetWidth(box)
                    exitwhen true
                endif
                set loopA = loopA + 1
            endloop
            
            if not found then
                call BlzFrameSetPoint(box, FRAMEPOINT_TOPRIGHT, RefButtonBoxFrameFirst[RefButtonBoxRows], FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                set RefButtonBoxRows = RefButtonBoxRows + 1
                set RefButtonBoxFrameFirst[RefButtonBoxRows] = box
                set RefButtonBoxFrameLast[RefButtonBoxRows] = box
                set RefButtonBoxSize[RefButtonBoxRows] = xSize - BlzFrameGetWidth(box)
                set ySize = ySize + refButtonBoxSizeY
                call BlzFrameSetSize(FrameParentSuperUI, xSize, ySize)
            endif
        endif
    endfunction

    function TasItemShopUICreate takes nothing returns nothing
        local framehandle frame
        local framehandle parent
        local integer loopA
        local integer groupObject
        local framehandle array frames
        local integer array categoryIndexes
        local integer buttonsInRow 
        local integer rows
        local framehandle clearButton
        set RefButtonCount = 0
        set RefButtonBoxRows = 0
        call BlzLoadTOCFile("war3mapImported\\Templates.toc")
        call BlzLoadTOCFile("war3mapImported\\TasItemShop.toc")

        //set UpdateCounterText = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
        //call BlzFrameSetAbsPoint(UpdateCounterText, FRAMEPOINT_TOPLEFT, 0.2, 0.55)

        set parent = GetParent()        

        if posScreenRelative then
            set frame = BlzCreateFrameByType("FRAME", "Fullscreen", parent, "", 0)
            call BlzFrameSetVisible(frame, false)
            call BlzFrameSetSize(frame, 0.8, 0.6)
            call BlzFrameSetAbsPoint(frame, FRAMEPOINT_BOTTOM, 0.4, 0)
            set FrameFullscreen = frame
        endif

        set xSize = 0.02 + buttonListCols * buttonListButtonSizeX + buttonListButtonGapCol * (buttonListCols - 1)
        //ySize = 0.1285 + buttonListRows*buttonListButtonSizeY + refButtonBoxSizeY
        //set ySize = 0.0815 + buttonListRows*buttonListButtonSizeY
        set ySize = 0.0815 + buttonListRows * buttonListButtonSizeY + buttonListButtonGapRow * (buttonListRows - 1)


        
        // super
        set FrameParentSuper = BlzCreateFrameByType("FRAME", "TasItemShopUI", parent, "", 0)
        call BlzFrameSetSize(FrameParentSuper, 0.001, 0.001)

        set parent = BlzCreateFrameByType("BUTTON", "TasItemShopUI", FrameParentSuper, "", 0)
        call BlzFrameSetSize(parent, xSize, ySize)
        call BlzTriggerRegisterFrameEvent(ButtonTriggerParentScroll, parent, FRAMEEVENT_MOUSE_WHEEL)
        call AddClearFocus(parent)
        if posScreenRelative then
            call BlzFrameSetPoint(parent, posPoint, FrameFullscreen, posPoint, xPos, yPos)
        else
            call BlzFrameSetAbsPoint(parent, posPoint, xPos, yPos)
        endif
        
        set FrameParentSuperUI = parent


        set frame = BlzCreateFrame(boxFrameName, parent, 0, 0)
        call BlzFrameSetAllPoints(frame, parent)
        set FrameSuperBox = frame

        // round down, boxSize - 2times gap to border / buttonSize + gap between buttons
        
        set buttonsInRow = R2I((xSize - (boxCatBorderGap) * 2) / (categoryButtonSize + 0.003))
        // round up
        set rows = R2I(1 + (CategoryCount / buttonsInRow))
        //call BJDebugMsg(I2S(buttonsInRow)+ ", " + I2S(rows))
        //print(#TasItemShopUI.Categories, buttonsInRow, rows)
        set ySize = ySize + rows * categoryButtonSize
        // ButtonList
        set parent = BlzCreateFrame(boxButtonListFrameName, FrameSuperBox, 0, 0)
        call BlzFrameSetPoint(parent, FRAMEPOINT_TOPRIGHT, FrameSuperBox, FRAMEPOINT_TOPRIGHT, 0, 0)  
        // baseSizeY = 0.0455
        call BlzFrameSetSize(parent, xSize, 0.0455 + buttonListRows * buttonListButtonSizeY + rows * categoryButtonSize + buttonListButtonGapRow * (buttonListRows - 1))
        set ButtonListIndex = CreateTasButtonList10(buttonListButtonName, buttonListCols, buttonListRows, parent, function ButtonListFunction_LeftClick, function ButtonListFunction_RightClick, function updateItemFrameAction, function ButtonListFunction_Search, function ButtonListFunction_Filter, function ButtonListFunction_AsyncLeftClick, function ButtonListFunction_AsyncRightClick, buttonListButtonGapCol, buttonListButtonGapRow)
        set FrameTasButtonList = parent
        set loopA = buttonListRows * buttonListCols
        loop
            exitwhen loopA <= 0
            set frame = BlzGetFrameByName("TasButtonListTooltipText", TasButtonListCreateContext[ButtonListIndex] + loopA)
            call BlzFrameClearAllPoints(frame)
            if toolTipPosPointParent != null then
                call BlzFrameSetPoint(frame, toolTipPosPoint, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + loopA), toolTipPosPointParent, toolTipPosX, toolTipPosY)
            else
                call BlzFrameSetAbsPoint(frame, toolTipPosPoint, toolTipPosX, toolTipPosY)
            endif
            if buttonListHighLightFrameName != null and buttonListHighLightFrameName != ""  then
                set frame = BlzCreateFrame(buttonListHighLightFrameName, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + loopA), 0, TasButtonListCreateContext[ButtonListIndex] + loopA)
                call BlzFrameSetAllPoints(frame, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + loopA))
                call BlzFrameSetVisible(frame, false)
            endif
            set loopA = loopA - 1
        endloop
        

        // category
        set frame = BlzCreateFrame(boxCatFrameName, parent, 0, 0)
        call BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, TasButtonListInputFrame[ButtonListIndex], FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        call BlzFrameSetSize(frame, xSize, 0.0135 + rows * categoryButtonSize)
        set FrameCategoryBox = frame
        set parent = frame

        set groupObject = CreateToggleIconButtonGroup(function ButtonListFunction_CategoryAction)
        set ToggleIconButton_DefaultSizeX = categoryButtonSize
        set ToggleIconButton_DefaultSizeY = categoryButtonSize
        //frame = ToggleIconButtonGroupModeButton(groupObject, parent).Button
        
        set frame = ToggleIconButtonGroupClearButton(groupObject, parent, "ReplaceableTextures\\CommandButtons\\BTNCancel")
        //BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, FrameSuperBox, FRAMEPOINT_TOPLEFT, boxFrameBorderGap, -boxFrameBorderGap)
        call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, FrameSuperBox, FRAMEPOINT_TOPLEFT, boxFrameBorderGap, - boxFrameBorderGap)
        call BlzTriggerRegisterFrameEvent(ButtonTriggerClear, frame, FRAMEEVENT_CONTROL_CLICK)
        call AddClearFocus(frame)
        set clearButton = frame

        set CategoryModButtonIndex = CreateToggleIconButton(parent, 1, GetLocalizedString(categoryModeTextOr), categoryModeIconOr, 0, GetLocalizedString(categoryModeTextAnd), categoryModeIconAnd)
        call BlzFrameSetPoint(ToggleIconButton_Button[CategoryModButtonIndex], FRAMEPOINT_BOTTOMLEFT, clearButton, FRAMEPOINT_BOTTOMRIGHT, 0.003, 0)
        call BlzTriggerRegisterFrameEvent(ButtonTriggerCategoryMode, ToggleIconButton_Button[CategoryModButtonIndex], FRAMEEVENT_CONTROL_CLICK)
        
        set loopA = 1
        loop
            exitwhen loopA > CategoryCount
            set categoryIndexes[loopA] = CreateToggleIconButtonSimple(parent, CategoryValues[loopA], GetLocalizedString(CategoryText[loopA]), CategoryIcon[loopA])
            if loopA == 1 then
                call BlzFrameSetPoint(ToggleIconButton_Button[categoryIndexes[loopA]], FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxCatBorderGap, - boxCatBorderGap)
            else
                call BlzFrameSetPoint(ToggleIconButton_Button[categoryIndexes[loopA]], FRAMEPOINT_TOPLEFT, ToggleIconButton_Button[categoryIndexes[loopA - 1]], FRAMEPOINT_TOPRIGHT, 0.003, 0)
            endif
            call ToggleIconButtonGroupAddButton(groupObject, categoryIndexes[loopA])
            set loopA = loopA + 1
        endloop

        set loopA = 2
        loop
            exitwhen loopA > rows
            //    print((index-1)*buttonsInRow + 1, "->", (index-2)*buttonsInRow + 1)
            call BlzFrameSetPoint(ToggleIconButton_Button[categoryIndexes[(loopA - 1) * buttonsInRow + 1]], FRAMEPOINT_TOPLEFT, ToggleIconButton_Button[categoryIndexes[(loopA - 2) * buttonsInRow + 1]], FRAMEPOINT_BOTTOMLEFT, 0, - 0.001)
            //BlzFrameSetPoint(frames[(index-1)*buttonsInRow + 1].Button, FRAMEPOINT_TOPLEFT, frames[(index-2)*buttonsInRow + 1].Button, FRAMEPOINT_BOTTOMLEFT, 0, -0.001)        
            set loopA = loopA + 1
        endloop
        
        set frame = BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + 1)
        call BlzFrameClearAllPoints(frame)
        //call BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, FrameCategoryBox, FRAMEPOINT_BOTTOMRIGHT, -0.014, 0)
        call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, FrameCategoryBox, FRAMEPOINT_BOTTOMLEFT, 0.0045, 0)

        // built from
        if refButtonCountMats > 0 then
            set parent = BlzCreateFrame(boxRefFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, (refButtonSize + refButtonGap) * refButtonCountMats + boxFrameBorderGap * 2, refButtonBoxSizeY)
            call PlaceRefButtonBox(parent)
            set FrameMaterialBox = parent

            set frame = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxRefBorderGap, - boxRefBorderGap)
            call BlzFrameSetText(frame, GetLocalizedString(textMats))
            set FrameMaterialText = frame
            set RefButtonMaterialStart = RefButtonCount
            set RefButtonMaterialEnd = CreateRefButtons(refButtonCountMats, parent, frame, ButtonTriggerMaterial, true)

            call CreateRefPage(parent, FrameMaterialText, ButtonTriggerMaterialPage, refButtonCountMats)
            set FrameMaterialPage = BlzGetFrameByName("TasItemShopUIPageControl", 0)
            set FrameMaterialPageUp = BlzGetFrameByName("TasItemShopCatButton", 0)
            set FrameMaterialPageDown = BlzGetFrameByName("TasItemShopCatButton", 1)
            set FrameMaterialPageText = BlzGetFrameByName("TasButtonTextTemplate", 0)
        endif

        // possible upgrades
        if refButtonCountUp > 0 then
            set parent = BlzCreateFrame(boxRefFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, (refButtonSize + refButtonGap) * refButtonCountUp + boxFrameBorderGap * 2, refButtonBoxSizeY)
            call PlaceRefButtonBox(parent)
            set FrameUpgradeBox = parent

            set frame = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxRefBorderGap, - boxRefBorderGap)
            call BlzFrameSetText(frame, GetLocalizedString(textUpgrades))
            set FrameUpgradeText = frame
            set RefButtonUpgradeStart = RefButtonCount
            set RefButtonUpgradeEnd = CreateRefButtons(refButtonCountUp, parent, frame, ButtonTriggerUpgrade, true)

            call CreateRefPage(parent, FrameUpgradeText, ButtonTriggerUpgradePage, refButtonCountUp)
            set FrameUpgradePage = BlzGetFrameByName("TasItemShopUIPageControl", 0)
            set FrameUpgradePageUp = BlzGetFrameByName("TasItemShopCatButton", 0)
            set FrameUpgradePageDown = BlzGetFrameByName("TasItemShopCatButton", 1)
            set FrameUpgradePageText = BlzGetFrameByName("TasButtonTextTemplate", 0)
        endif
        
        if refButtonCountQuickLink > 0 then
            set parent = BlzCreateFrame(boxRefFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, (refButtonSize + refButtonGap) * refButtonCountUp + boxFrameBorderGap * 2, refButtonBoxSizeY)
            call PlaceRefButtonBox(parent)
            set FrameQuickLinkBox = parent

            set frame = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxRefBorderGap, - boxRefBorderGap)
            call BlzFrameSetText(frame, GetLocalizedString(textQuickLink))
            set FrameQuickLinkText = frame

            set FrameQuickLinkBoxHighLight = BlzCreateFrame(buttonListHighLightFrameName, parent, 0, 0)
            call BlzFrameSetAllPoints(FrameQuickLinkBoxHighLight, parent)
            call BlzFrameSetVisible(FrameQuickLinkBoxHighLight, false)

            set RefButtonQuickLinkStart = RefButtonCount
            set RefButtonQuickLinkEnd = CreateRefButtons(refButtonCountQuickLink, parent, frame, ButtonTriggerQuickLink, true)

            call CreateRefPage(parent, FrameQuickLinkText, ButtonTriggerQuickLinkPage, refButtonCountUp)
            set FrameQuickLinkPage = BlzGetFrameByName("TasItemShopUIPageControl", 0)
            set FrameQuickLinkPageUp = BlzGetFrameByName("TasItemShopCatButton", 0)
            set FrameQuickLinkPageDown = BlzGetFrameByName("TasItemShopCatButton", 1)
            set FrameQuickLinkPageText = BlzGetFrameByName("TasButtonTextTemplate", 0)

        endif

        // Inventory
        if refButtonCountInv > 0 then
            set parent = BlzCreateFrame(boxRefFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, (refButtonSize + refButtonGap) * refButtonCountInv + boxFrameBorderGap * 2, refButtonBoxSizeY)
            call PlaceRefButtonBox(parent)
            set FrameInventoryBox = parent
            

            set frame = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxRefBorderGap, - boxRefBorderGap)
            call BlzFrameSetText(frame, GetLocalizedString(textInventory))
            set FrameInventoryText = frame
            set RefButtonInventoryStart = RefButtonCount
            set RefButtonInventoryEnd = CreateRefButtons(refButtonCountInv, parent, frame, ButtonTriggerInventory, true)

            set loopA = RefButtonInventoryStart
            loop
                exitwhen loopA > RefButtonInventoryEnd
                call BlzFrameSetTexture(RefButtonOverlay[loopA], MainItemTexture, 0, true)
                set loopA = loopA + 1
            endloop

            call CreateRefPage(parent, FrameInventoryText, ButtonTriggerInventoryPage, refButtonCountInv)
            set FrameInventoryPage = BlzGetFrameByName("TasItemShopUIPageControl", 0)
            set FrameInventoryPageUp = BlzGetFrameByName("TasItemShopCatButton", 0)
            set FrameInventoryPageDown = BlzGetFrameByName("TasItemShopCatButton", 1)
            set FrameInventoryPageText = BlzGetFrameByName("TasButtonTextTemplate", 0)
        endif

        // User
        if refButtonCountUser > 0 then
            set parent = BlzCreateFrame(boxRefFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, (refButtonSize + refButtonGap) * refButtonCountUser + boxFrameBorderGap * 2, refButtonBoxSizeY)
            call PlaceRefButtonBox(parent)
            set FrameUserBox = parent

            set frame = BlzCreateFrame("TasButtonTextTemplate", parent, 0, 0)
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, boxRefBorderGap, - boxRefBorderGap)
            call BlzFrameSetText(frame, GetLocalizedString(textUser))
            set FrameUserText = frame
            set RefButtonUserStart = RefButtonCount
            set RefButtonUserEnd = CreateRefButtons(refButtonCountUser, parent, frame, ButtonTriggerUser, false)

            set loopA = RefButtonUserStart
            loop
                exitwhen loopA > RefButtonUserEnd
                call BlzFrameSetTexture(RefButtonOverlay[loopA], MainUserTexture, 0, true)
                set loopA = loopA + 1
            endloop
            
            call CreateRefPage(parent, FrameUserText, ButtonTriggerUserPage, refButtonCountUser)
            set FrameUserPage = BlzGetFrameByName("TasItemShopUIPageControl", 0)
            set FrameUserPageUp = BlzGetFrameByName("TasItemShopCatButton", 0)
            set FrameUserPageDown = BlzGetFrameByName("TasItemShopCatButton", 1)
            set FrameUserPageText = BlzGetFrameByName("TasButtonTextTemplate", 0)
        endif

        
        
        set frame = BlzCreateFrame("TasButton", FrameSuperBox, 0, CREATE_CONTEXT_CURRENT)
        call CreateTasButtonTooltip(frame, FrameSuperBox, CREATE_CONTEXT_CURRENT)       

        call BlzGetFrameByName("TasButtonIcon", CREATE_CONTEXT_CURRENT)
        call BlzGetFrameByName("TasButtonText", CREATE_CONTEXT_CURRENT)
        call BlzGetFrameByName("TasButtonIconGold", CREATE_CONTEXT_CURRENT)
        call BlzGetFrameByName("TasButtonTextGold", CREATE_CONTEXT_CURRENT)
        call BlzGetFrameByName("TasButtonIconLumber", CREATE_CONTEXT_CURRENT)
        call BlzGetFrameByName("TasButtonTextLumber", CREATE_CONTEXT_CURRENT)
        
        
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOM, FrameSuperBox, FRAMEPOINT_BOTTOM, 0, boxFrameBorderGap)
        call BlzTriggerRegisterFrameEvent(ButtonTriggerBuy, frame, FRAMEEVENT_CONTROL_CLICK)
        call AddClearFocus(frame)
        
        set frame = BlzCreateFrame("TasButtonTextTemplate", FrameSuperBox, 0, 0)
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMRIGHT, TasButtonListInputFrame[ButtonListIndex], FRAMEPOINT_BOTTOMLEFT, - boxFrameBorderGap, 0)
        call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, ToggleIconButton_Button[CategoryModButtonIndex], FRAMEPOINT_TOPRIGHT, boxFrameBorderGap, 0)
        call BlzFrameSetTextAlignment(frame, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        call BlzFrameSetText(frame, "Name")
        set FrameTitelText = frame

        call BlzFrameClearAllPoints(BlzGetFrameByName("TasButtonListTooltipText", CREATE_CONTEXT_CURRENT))
        if toolTipPosPointParent != null then
            call BlzFrameSetPoint(BlzGetFrameByName("TasButtonListTooltipText", CREATE_CONTEXT_CURRENT), toolTipPosPoint, BlzGetFrameByName("TasButton", CREATE_CONTEXT_CURRENT), toolTipPosPointParent, toolTipPosX, toolTipPosY)
        else
            call BlzFrameSetAbsPoint(BlzGetFrameByName("TasButtonListTooltipText", CREATE_CONTEXT_CURRENT), toolTipPosPoint, toolTipPosX, toolTipPosY)
        endif

        if canUndo then
            set parent = BlzCreateFrame(boxUndoFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, refButtonSize + boxUndoBorderGap * 2, refButtonSize + boxUndoBorderGap * 2)
            call BlzFrameSetPoint(parent, FRAMEPOINT_BOTTOMLEFT, FrameSuperBox, FRAMEPOINT_BOTTOMLEFT, 0.00, 0.00)
            
            set FrameUndoBox = parent
            
            set FrameUndoButton = BlzCreateFrame("TasItemShopCatButton", parent, 0, 0)
            set FrameUndoButtonIcon = BlzGetFrameByName("TasItemShopCatButtonBackdrop", 0)
            set FrameUndoButtonIconPushed = BlzGetFrameByName("TasItemShopCatButtonBackdropPushed", 0)
            set FrameUndoText = CreateSimpleTooltip(FrameUndoButton, textUndo)

            set frame = FrameUndoButton
            call BlzFrameSetSize(frame, refButtonSize, refButtonSize)
            call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
            call BlzTriggerRegisterFrameEvent(ButtonTriggerUndo, frame, FRAMEEVENT_CONTROL_CLICK)
            call AddClearFocus(frame)
            call BlzFrameSetVisible(FrameUndoBox, false)
        endif

        if canDefuse then
            set parent = BlzCreateFrame(boxDefuseFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, refButtonSize + boxDefuseBorderGap * 2, refButtonSize + boxDefuseBorderGap * 2)
            call BlzFrameSetPoint(parent, FRAMEPOINT_BOTTOMRIGHT, FrameSuperBox, FRAMEPOINT_BOTTOMRIGHT, 0.00, 0.00)
            set FrameDefuseBox = parent
            set FrameDefuseButton = BlzCreateFrame("TasItemShopCatButton", parent, 0, 0)
            set FrameDefuseText = CreateSimpleTooltip(FrameDefuseButton, textDefuse)
            call BlzFrameClearAllPoints(FrameDefuseText)
            call BlzFrameSetPoint(FrameDefuseText, FRAMEPOINT_BOTTOMRIGHT, FrameDefuseButton, FRAMEPOINT_TOPRIGHT, 0, 0.008)

            set frame = FrameDefuseButton
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdrop", 0), DefuseButtonIcon, 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdropPushed", 0), DefuseButtonIcon, 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdropDisabled", 0), DefuseButtonIconDisabled, 0, false)
            call BlzFrameSetSize(frame, refButtonSize, refButtonSize)
            call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
            call BlzTriggerRegisterFrameEvent(ButtonTriggerDefuse, frame, FRAMEEVENT_CONTROL_CLICK)
            call AddClearFocus(frame)
            call BlzFrameSetEnable(FrameDefuseButton, false)
        endif

        if canSellItems then
            set parent = BlzCreateFrame(boxDefuseFrameName, FrameSuperBox, 0, 0)
            call BlzFrameSetSize(parent, refButtonSize + boxSellBorderGap * 2, refButtonSize + boxSellBorderGap * 2)
            if canDefuse then
                call BlzFrameSetPoint(parent, FRAMEPOINT_BOTTOMRIGHT, FrameDefuseBox, FRAMEPOINT_BOTTOMLEFT, 0.00, 0.00)
            else
                call BlzFrameSetPoint(parent, FRAMEPOINT_BOTTOMRIGHT, FrameSuperBox, FRAMEPOINT_BOTTOMRIGHT, 0.00, 0.00)
            endif

            set FrameSellBox = parent
            set FrameSellButton = BlzCreateFrame("TasItemShopCatButton", parent, 0, 0)

            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdrop", 0), SellButtonIcon, 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdropPushed", 0), SellButtonIcon, 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemShopCatButtonBackdropDisabled", 0), SellButtonIconDisabled, 0, false)
            set frame = FrameSellButton
            call BlzFrameSetSize(frame, refButtonSize, refButtonSize)
            call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
            call BlzTriggerRegisterFrameEvent(ButtonTriggerSell, frame, FRAMEEVENT_CONTROL_CLICK)
            call AddClearFocus(frame)
            call BlzFrameSetEnable(FrameSellButton, false)

            set FrameSellText = CreateSimpleTooltip(frame, textSell)
            call BlzFrameClearAllPoints(FrameSellText)
            call BlzFrameSetPoint(FrameSellText, FRAMEPOINT_BOTTOMRIGHT, FrameSellButton, FRAMEPOINT_TOPRIGHT, 0, 0.008)
        endif
        

        set parent = BlzCreateFrameByType("BUTTON", "TasRightClickSpriteParent", FrameSuperBox, "", 0)
        call BlzFrameSetLevel(parent, 99)
        set frame = BlzCreateFrameByType("SPRITE", "TasRightClickSprite", parent, "", 0)
        call BlzFrameSetSize(frame, refButtonSize, refButtonSize)
        call BlzFrameSetScale(frame, spriteScale)
        call BlzFrameSetModel(frame, spriteModel, 0)   
        call BlzFrameSetVisible(parent, false)
        set FrameSpriteParent = parent
        set FrameSprite = frame  
        //fitRefBoxes()
        call BlzFrameSetSize(FrameParentSuperUI, xSize, ySize)
        call BlzFrameSetVisible(FrameParentSuper, false)
    endfunction

    public function RefButtonPageChange takes integer current, integer add, integer min, integer max, player p returns integer
        local integer remain
        local integer size = IAbsBJ(add)
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            set current = current + add
            if not refButtonPageRotate then
                if current < min then
                    set current = min
                endif
                if current >= max then
                    set current = max - add
                endif
            else
                if add > 0 then
                    if current >= max then
                        set current = min
                    endif
                else
                    if current < min then
                        set remain = ModuloInteger(max, size)
                        // last page is incomplete?
                        if remain > 0 then
                            set current = max - remain
                        else
                            set current = max - size
                        endif
                    endif
                endif
            endif
        elseif IsRightClick(p) then
            call StartSoundForPlayerBJ(p, ToggleIconButton_Sound)
            // right clicks jump to the first or last Page
            if add > 0 then
                set current = max - size
            else
                set current = min
            endif
        endif
        
        return current
    endfunction

    public function RefButtonAction takes integer itemCode returns nothing
        local player p = GetTriggerPlayer()
        local framehandle frame = BlzGetTriggerFrame()
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            // print(GetPlayerName(player), "Clicked Material", index)
            call setSelected(p, itemCode)
        else
            if IsRightClick(p) then
                call ShowSprite(frame, p)
                call StartSoundForPlayerBJ(p, ToggleIconButton_Sound)
                call BuyItem(p, itemCode)
            endif
        endif
    endfunction

    private function TriggerFuctionDefuse takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode
        local item i
        local integer gold
        local integer lumber
        local integer undoIndex
        local integer loopA
        local integer loopB
        local unit u
        if SelectedItem[playerIndex] == null then
            return
        endif
        set i = SelectedItem[playerIndex]
        set itemCode = GetItemTypeId(i)
        set SelectedItem[playerIndex] = null
        
        set gold = TasItemGetCostGold(itemCode)
        set lumber = TasItemGetCostLumber(itemCode)
        set loopA = TasItemFusion_BuiltWay[itemCode][0]
        loop
            exitwhen loopA <= 0
            set gold = gold - TasItemGetCostGold(TasItemFusion_BuiltWay[itemCode][loopA])
            set lumber = lumber - TasItemGetCostLumber(TasItemFusion_BuiltWay[itemCode][loopA])
            set loopA = loopA - 1
            // body
        endloop

        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_GOLD, gold)
        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_LUMBER, lumber)
        if canUndo then
            set undoIndex = CreateUndo(p, itemCode, - gold, - lumber, " Defuse")
            set UndoItems[undoIndex][0] = 1
            set UndoItems[undoIndex].item[1] = i
            set UndoItems[undoIndex].unit[- 1] = ItemHolder_get(i)
            call UnitRemoveItem(ItemHolder_get(i), i)
            call SetItemVisible(i, false)
            
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(FrameUndoBox, true)
                call updateUndoButton(UndoResultCode[undoIndex], " Defuse")
            endif

        else
            call RemoveItem(i)
        endif
        set loopA = TasItemFusion_BuiltWay[itemCode][0]
        loop
            exitwhen loopA <= 0
            set i = CreateItem(TasItemFusion_BuiltWay[itemCode][loopA], GetUnitX(ShoperMain[playerIndex]), GetUnitY(ShoperMain[playerIndex]))
            call GiveItemGroup(p, i, undoIndex)
            
            set loopA = loopA - 1
        endloop
        
        if GetLocalPlayer() == p then
            call BlzFrameSetEnable(FrameDefuseButton, false)
        endif
    endfunction
    
    private function TriggerFuctionSell takes nothing returns nothing
        call SellItem(GetTriggerPlayer(), SelectedItem[GetPlayerId(GetTriggerPlayer())])
    endfunction

    private function TriggerFuctionBuy takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        call ShowSprite(BlzGetTriggerFrame(), p)
        call BuyItem(p, itemCode)
        set p = null
    endfunction

    public function ShopSelectionActionGroupEnum takes nothing returns nothing
        if not IsValidShopper(TempPlayer, TempUnit, GetEnumUnit(), TempRange) then
            call GroupRemoveUnit(TempGroup, GetEnumUnit())
        endif
    endfunction
    
    public function ShopSelectionAction takes player p, unit shop, unit target returns nothing
        local integer playerIndex = GetPlayerId(p)
        local integer shopObject = GetUnitTypeId(shop) 
        local real oldRange = shopRange
        local integer shopIndex = Shops[shopObject]
        // is a registered shop UnitType?
        if shopIndex != 0 then
            set TempPlayer = p
            set TempRange = ShopRange[shopObject]
            if TempRange < 1 then
                set TempRange = oldRange
            endif

            call GroupEnumUnitsInRange(TempGroup, GetUnitX(shop), GetUnitY(shop), TempRange + 400, null)
            // remove unallowed shoppers
            set TempUnit = shop
            call ForGroup(TempGroup, function ShopSelectionActionGroupEnum)
            set shopRange = oldRange
            if target == null and IsUnitInGroup(ShoperMain[playerIndex], TempGroup) then
                set target = ShoperMain[playerIndex]
            endif
            
            call TasItemShopUIShow(p, shop, TempGroup, target)
        elseif CurrentShop[playerIndex] != null then            
            call TasItemShopUIShow(p, null, null, null)
        endif
    endfunction

    private function TriggerFuctionUser takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer index = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + CurrentOffSetUser[playerIndex]
        local unit u = BlzGroupUnitAt(Shoper[playerIndex], index - 1)

        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            call IssueNeutralTargetOrder(p, CurrentShop[playerIndex], "smart", u)
            if not userButtonOrder then
                call ShopSelectionAction(p, CurrentShop[playerIndex], u)
            endif
            
        else
            if IsRightClick(p) then
                call SelectUnitForPlayerSingle(u, p)
            endif
        endif
    endfunction

    private function TriggerFuctionUserPage takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer max = BlzGroupGetSize(Shoper[playerIndex])
        local integer min = 0
        local integer add = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        
        set CurrentOffSetUser[playerIndex] = RefButtonPageChange(CurrentOffSetUser[playerIndex], add, min, max, p)
        if GetLocalPlayer() == p then
            call updateRefButtonsUser(p)
            call updateOverLayMainSelected(p)
        endif
    endfunction

    private function TriggerFuctionInventory takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local framehandle frame = BlzGetTriggerFrame()
        local integer index = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + CurrentOffSetInventory[playerIndex]
        local item i
        local integer itemCode

        if inventoryShowMainOnly then
            set i = UnitItemInSlot(ShoperMain[playerIndex], index - 1)
        else
            set i = TasItemFusion_PlayerItems[playerIndex].item[index]
        endif

        set itemCode = GetItemTypeId(i)
        
        call TasItemCaclCost(itemCode)

        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            call setSelected(p, itemCode)
            call setSelectedItem(p, i)
        else
            if IsRightClick(p) then
                call ShowSprite(frame, p)
                call StartSoundForPlayerBJ(p, ToggleIconButton_Sound)
                if canSellItems and inventoryRightClickSell then
                    call SellItem(p, i)
                else
                    call BuyItem(p, itemCode)
                endif
            endif
        endif

        set i = null
        set frame = null
        set p = null
    endfunction

    private function TriggerFuctionInventoryPage takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer max = TasItemFusion_PlayerItems[playerIndex][0]
        local integer min = 0
        local integer add = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        
        set CurrentOffSetInventory[playerIndex] = RefButtonPageChange(CurrentOffSetInventory[playerIndex], add, min, max, p)
        if GetLocalPlayer() == p then
            call updateRefButtonsInventory(p)
        endif
    endfunction

    private function TriggerFuctionUpgrade takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer index = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + CurrentOffSetUpgrade[playerIndex]
        
        call RefButtonAction(TasItemFusion_UsedIn[itemCode][index])
    endfunction

    private function TriggerFuctionUpgradePage takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer max = TasItemFusion_UsedIn[itemCode][0]
        local integer min = 0
        local integer add = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        
        set CurrentOffSetUpgrade[playerIndex] = RefButtonPageChange(CurrentOffSetUpgrade[playerIndex], add, min, max, p)

        if GetLocalPlayer() == p then
            call updateRefButtonsUpgrades(p, itemCode)
            call updateHaveMats(p, itemCode)
        endif
    endfunction
    
    private function TriggerFuctionQuickLink takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer index = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + CurrentOffSetQuickLink[playerIndex]
        local integer itemCode = QuickLink[playerIndex][index]
        if QuickLinkKeyActive[playerIndex] and BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            call SetQuickLink(p, itemCode)
        else
            call RefButtonAction(itemCode)
        endif
    endfunction

    private function TriggerFuctionQuickLinkPage takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer max = QuickLink[playerIndex][0]
        local integer min = 0
        local integer add = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        
        set CurrentOffSetQuickLink[playerIndex] = RefButtonPageChange(CurrentOffSetQuickLink[playerIndex], add, min, max, p)
        if GetLocalPlayer() == p then
            call updateRefButtonsQuickLink(p)
        endif
    endfunction

    private function TriggerFuctionMaterial takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer index = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + CurrentOffSetMaterial[playerIndex]
        call RefButtonAction(TasItemFusion_BuiltWay[itemCode][index])
    endfunction

    private function TriggerFuctionMaterialPage takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer itemCode = Selected[playerIndex]
        local integer max = TasItemFusion_BuiltWay[itemCode][0]
        local integer min = 0
        local integer add = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        
        set CurrentOffSetMaterial[playerIndex] = RefButtonPageChange(CurrentOffSetMaterial[playerIndex], add, min, max, p)
        if GetLocalPlayer() == p then
            call updateRefButtonsMaterial(p, itemCode)
            call updateHaveMats(p, itemCode)
        endif
    endfunction

    private function TriggerFuctionUndo takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer playerIndex = GetPlayerId(p)
        local integer loopA
        local integer undoIndex = UndoPlayerSize * playerIndex + UndoPlayerCount[playerIndex]

        if UndoPlayerCount[playerIndex] <= 0 then
            return
        endif

        set undoIndex = UndoPlayerSize * playerIndex + UndoPlayerCount[playerIndex]
        
        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_GOLD, UndoGold[undoIndex])
        call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_RESOURCE_LUMBER, UndoLumber[undoIndex])

        set loopA = UndoResults[undoIndex][0]
        loop
            exitwhen loopA <= 0
            call RemoveItem(UndoResults[undoIndex].item[loopA])
            set UndoResults[undoIndex].item[loopA] = null
            set UndoResults[undoIndex].unit[- loopA] = null
            set loopA = loopA - 1
        endloop
        
        set UndoResults[undoIndex][0] = 0
        
        if UndoStackGainer[undoIndex] != null then
            call SetItemCharges(UndoStackGainer[undoIndex], GetItemCharges(UndoStackGainer[undoIndex]) - UndoStackGained[undoIndex])
            set UndoStackGainer[undoIndex] = null
        endif
        
        set loopA = UndoItems[undoIndex][0]
        loop
            exitwhen loopA <= 0
            call SetItemVisible(UndoItems[undoIndex].item[loopA], true)
            call UnitAddItem(UndoItems[undoIndex].unit[- loopA], UndoItems[undoIndex].item[loopA])
            set UndoItems[undoIndex].item[loopA] = null
            set UndoItems[undoIndex].unit[- loopA] = null
            set loopA = loopA - 1
        endloop
        set UndoItems[undoIndex][0] = 0
        
        set UndoPlayerCount[playerIndex] = UndoPlayerCount[playerIndex] - 1
        call TasItemShopUIShow(p, CurrentShop[playerIndex], null, null)
        if GetLocalPlayer() == p then
            
            if UndoPlayerCount[playerIndex] > 0 then
                call BlzFrameSetVisible(FrameUndoBox, true)
                call updateUndoButton(UndoResultCode[undoIndex - 1], UndoActionName[undoIndex - 1])
            else
                call BlzFrameSetVisible(FrameUndoBox, false)
            endif
        endif
    endfunction

    private function TriggerFuctionClear takes nothing returns nothing
        if GetTriggerPlayer() == GetLocalPlayer() then
            call BlzFrameSetText(TasButtonListInputFrame[ButtonListIndex], "")
        endif
    endfunction
    
    private function TriggerFuctionSelect takes nothing returns nothing
        call ShopSelectionAction(GetTriggerPlayer(), GetTriggerUnit(), null)
    endfunction

    private function TriggerFuctionOrder takes nothing returns nothing
        if Shops[GetUnitTypeId(GetTriggerUnit())] != 0 then
            call ShopSelectionAction(GetOwningPlayer(GetOrderTargetUnit()), GetTriggerUnit(), GetOrderTargetUnit())
        endif
    endfunction  

    private function TriggerFuctionESC takes nothing returns nothing
        call TasItemShopUIShow(GetTriggerPlayer(), null, null, null)
    endfunction 

    private function TriggerFuctionClearFocus takes nothing returns nothing
        local framehandle frame = BlzGetTriggerFrame()
        if GetTriggerPlayer() == GetLocalPlayer() then
            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
        endif
        set frame = null
    endfunction 

    private function TriggerFuctionParentScroll takes nothing returns nothing
        local framehandle frame = TasButtonListSlider[ButtonListIndex] 
        if GetLocalPlayer() == GetTriggerPlayer() then
            if BlzGetTriggerFrameValue() > 0 then
                call BlzFrameSetValue(frame, BlzFrameGetValue(frame) + TasButtonListStepSize[ButtonListIndex])
            else
                call BlzFrameSetValue(frame, BlzFrameGetValue(frame) - TasButtonListStepSize[ButtonListIndex])
            endif
        endif
        set frame = null
    endfunction 

    private function TriggerFuctionCategoryMode takes nothing returns nothing
        if GetTriggerPlayer() == GetLocalPlayer() then
            call TasButtonListSearch(ButtonListIndex, null)
        endif
    endfunction

    private function TriggerFuctionReleaseQuickLinkKey takes nothing returns nothing
        set QuickLinkKeyActive[GetPlayerId(GetTriggerPlayer())] = false
        if refButtonCountQuickLink > 0 and GetTriggerPlayer() == GetLocalPlayer() then
            call BlzFrameSetVisible(FrameQuickLinkBoxHighLight, false)
        endif
    endfunction

    private function TriggerFuctionPressQuickLinkKey takes nothing returns nothing
        set QuickLinkKeyActive[GetPlayerId(GetTriggerPlayer())] = true
        if refButtonCountQuickLink > 0 and GetTriggerPlayer() == GetLocalPlayer() then
            call BlzFrameSetVisible(FrameQuickLinkBoxHighLight, true)
        endif
    endfunction
    
    public function TimerUpdate takes nothing returns nothing
        local player p
        local unit u
        local integer loopA
        if posScreenRelative then
            call BlzFrameSetSize(FrameFullscreen, I2R(BlzGetLocalClientWidth()) / BlzGetLocalClientHeight() * 0.6, 0.6)
        endif
        
        set loopA = 0
        loop
            exitwhen loopA >= bj_MAX_PLAYER_SLOTS
            set p = Player(loopA)
            if CurrentShop[loopA] != null then
                call ShopSelectionAction(p, CurrentShop[loopA], null)
            endif
            set loopA = loopA + 1
        endloop
    endfunction

    private function At0s takes nothing returns nothing
        local integer loopA
        local player p
        
        call TimerStart(Timer, 9999999999, false, null)
        call TimerStart(CreateTimer(), updateTime, true, function TimerUpdate)

        set loopA = BUY_ABLE_ITEMS_Count
        loop
            exitwhen loopA <= 0
            call TasItemCaclCost(BUY_ABLE_ITEMS[loopA])
            set loopA = loopA - 1
        endloop
               
        set loopA = 0
        loop
            exitwhen loopA >= bj_MAX_PLAYER_SLOTS
            set Shoper[loopA] = CreateGroup()

            set loopA = loopA + 1
        endloop
        call TasItemShopUICreate()
        
    endfunction

    public function CreateTriggerEx takes code action returns trigger
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, action)
        return t
    endfunction

    private function init_function takes nothing returns nothing    
        local integer loopA
        local integer loopB
        set IsReforged = false
        set Shops = Table.create()
        set ShopsItems = HashTable.create()
        set ShopsGold = HashTable.create()
        set ShopsLumber = HashTable.create()
        set TasItemCategory = Table.create()
        set TempTable = Table.create()
        set TempHashTable = HashTable.create()
        set BuyAbleMarked = HashTable.create()
        set MarkedItemCodes = Table.create()

        set ButtonTriggerInventory = CreateTriggerEx(function TriggerFuctionInventory)
        set ButtonTriggerInventoryPage = CreateTriggerEx(function TriggerFuctionInventoryPage)
        set ButtonTriggerMaterial = CreateTriggerEx(function TriggerFuctionMaterial)
        set ButtonTriggerMaterialPage = CreateTriggerEx(function TriggerFuctionMaterialPage)
        set ButtonTriggerUser = CreateTriggerEx(function TriggerFuctionUser)
        set ButtonTriggerUserPage = CreateTriggerEx(function TriggerFuctionUserPage)
        set ButtonTriggerUpgrade = CreateTriggerEx(function TriggerFuctionUpgrade)
        set ButtonTriggerUpgradePage = CreateTriggerEx(function TriggerFuctionUpgradePage)
        set ButtonTriggerSell = CreateTriggerEx(function TriggerFuctionSell)
        set ButtonTriggerDefuse = CreateTriggerEx(function TriggerFuctionDefuse)
        set ButtonTriggerBuy = CreateTriggerEx(function TriggerFuctionBuy)
        set ButtonTriggerUndo = CreateTriggerEx(function TriggerFuctionUndo)
        set ButtonTriggerClear = CreateTriggerEx(function TriggerFuctionClear)
        set ButtonTriggerSelect = CreateTriggerEx(function TriggerFuctionSelect)
        set ButtonTriggerESC = CreateTriggerEx(function TriggerFuctionESC)
        set ButtonTriggerClearFocus = CreateTriggerEx(function TriggerFuctionClearFocus)
        set ButtonTriggerParentScroll = CreateTriggerEx(function TriggerFuctionParentScroll)
        set ButtonTriggerCategoryMode = CreateTriggerEx(function TriggerFuctionCategoryMode)
        set ButtonTriggerQuickLinkKeyPress = CreateTriggerEx(function TriggerFuctionPressQuickLinkKey)
        set ButtonTriggerQuickLinkKeyRelease = CreateTriggerEx(function TriggerFuctionReleaseQuickLinkKey)
        set ButtonTriggerQuickLink = CreateTriggerEx(function TriggerFuctionQuickLink)
        set ButtonTriggerQuickLinkPage = CreateTriggerEx(function TriggerFuctionQuickLinkPage)
        
        if userButtonOrder then 
            set ButtonTriggerOrder = CreateTriggerEx(function TriggerFuctionOrder)
            call TriggerRegisterAnyUnitEventBJ(ButtonTriggerOrder, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        endif
        
        call TriggerRegisterAnyUnitEventBJ(ButtonTriggerSelect, EVENT_PLAYER_UNIT_SELECTED)
        
        set loopA = 0
        loop
            call TriggerRegisterPlayerEventEndCinematic(ButtonTriggerESC, Player(loopA))
            set QuickLink[loopA] = Table.create()
            if quickLinkKey != null then
                set loopB = 0
                loop
                    call BlzTriggerRegisterPlayerKeyEvent(ButtonTriggerQuickLinkKeyPress, Player(loopA), quickLinkKey, loopB, true)
                    call BlzTriggerRegisterPlayerKeyEvent(ButtonTriggerQuickLinkKeyRelease, Player(loopA), quickLinkKey, loopB, false)
                    set loopB = loopB + 1
                    exitwhen loopB >= 16 
                endloop
            endif
            set loopA = loopA + 1
            exitwhen loopA >= bj_MAX_PLAYER_SLOTS
        endloop
        
        set Timer = CreateTimer()
        call TimerStart(Timer, 0 , false, function At0s)
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function TasItemShopUICreate)
        endif
    endfunction
endlibrary