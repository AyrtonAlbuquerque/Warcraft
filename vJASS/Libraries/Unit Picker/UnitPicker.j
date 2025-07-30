library UnitPicker requires Table, RegisterPlayerUnitEvent, Components, Utilities, WorldBounds
    /* ------------------------------------ Unit Picker v1.0 ----------------------------------- */
    // Credits:
    //      Taysen: FDF file and A2S function
    //      Bribe: Table library
    //      Magtheridon: RegisterPlayerUnitEvent library
    //      Hate: Frame border effects
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // Main window 
        private constant real X                         = 0.0
        private constant real Y                         = 0.56
        private constant real WIDTH                     = 0.8
        private constant real HEIGHT                    = 0.4
        private constant real TOOLBAR_BUTTON_SIZE       = 0.02
        private constant integer ROWS                   = 6
        private constant integer COLUMNS                = 3
        private constant string CLOSE_ICON              = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
        private constant string HELP_ICON               = "UI\\Widgets\\EscMenu\\Human\\quest-unknown.blp"
        private constant string LOGIC_ICON              = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"
        private constant string CLEAR_ICON              = "ReplaceableTextures\\CommandButtons\\BTNCancel.blp"
        
        // Details window
        private constant real DETAIL_WIDTH              = 0.3125
        private constant real DETAIL_HEIGHT             = HEIGHT
        private constant integer ABILITY_COUNT          = 6
        private constant real ABILITY_SIZE              = 0.035
        private constant real ABILITY_GAP               = 0.044
        private constant real NAME_WIDTH                = 0.125
        private constant real NAME_HEIGHT               = 0.014
        private constant real NAME_SCALE                = 1
        private constant real MODEL_HEIGHT              = 0.12
        private constant real DESCRIPTION_WIDTH         = 0.31
        private constant real DESCRIPTION_HEIGHT        = 0.17
        private constant real EDIT_WIDTH                = 0.15
        private constant real EDIT_HEIGHT               = 0.0285

        // Attributes
        private constant real ATTRIBUTES_WIDTH          = 0.02
        private constant real ATTRIBUTES_HEIGHT         = 0.02
        private constant real ATTRIBUTE_HIGHLIGHT_SCALE = 0.2
        private constant real ATTRIBUTE_HIGHLIGHT_XOFFSET = 0.052
        private constant real ATTRIBUTE_HIGHLIGHT_YOFFSET = 0.048
        private constant string ATTRIBUTE_HIGHLIGHT     = "goldenbrown.mdx"
        private constant string DAMAGE_TEXTURE          = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
        private constant string ARMOR_TEXTURE           = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
        private constant string HEALTH_TEXTURE          = "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp"
        private constant string MANA_TEXTURE            = "ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp"
        private constant string MOVEMENT_TEXTURE        = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"
        private constant string RANGE_TEXTURE           = "ReplaceableTextures\\CommandButtons\\BTNImprovedBows.blp"
        private constant string MELEE_TEXTURE           = "ReplaceableTextures\\CommandButtons\\BTNSteelMelee.blp"
        private constant string REGENERATION_TEXTURE    = "ReplaceableTextures\\CommandButtons\\BTNRejuvenation.blp"
        private constant string STRENGTH_TEXTURE        = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
        private constant string AGILITY_TEXTURE         = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
        private constant string INTELLIGENCE_TEXTURE    = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"

        // Slots
        private constant real SLOT_WIDTH                = 0.14
        private constant real SLOT_HEIGHT               = 0.05
        private constant real ICON_SIZE                 = 0.04
        private constant real COST_SIZE                 = 0.01
        private constant real COST_WIDTH                = 0.12
        private constant real COST_HEIGHT               = 0.01
        private constant real COST_SCALE                = 0.8
        private constant real SLOT_GAP_X                = 0.02
        private constant real SLOT_GAP_Y                = 0.008
        private constant string GOLD_ICON               = "UI\\Feedback\\Resources\\ResourceGold.blp"
        private constant string WOOD_ICON               = "UI\\Feedback\\Resources\\ResourceLumber.blp"
        private constant string FOOD_ICON               = "UI\\Feedback\\Resources\\ResourceSupply.blp"

        // Category
        private constant integer CATEGORY_COUNT         = 29
        private constant real CATEGORY_SIZE             = 0.02

        // Selected item highlight
        private constant string ITEM_HIGHLIGHT          = "neon_sprite.mdx"
        private constant real HIGHLIGHT_SCALE           = 0.75
        private constant real HIGHLIGHT_XOFFSET         = -0.0052
        private constant real HIGHLIGHT_YOFFSET         = -0.0048

        // Selected ability highlight
        private constant string ABILITY_HIGHLIGHT       = "neon_sprite.mdx"
        private constant real ABILITY_HIGHLIGHT_SCALE   = 0.62
        private constant real ABILITY_HIGHLIGHT_XOFFSET = -0.0042
        private constant real ABILITY_HIGHLIGHT_YOFFSET = -0.0038

        // Tagged item highlight
        private constant string TAG_MODEL               = "crystallid_sprite.mdx"
        private constant real TAG_SCALE                 = 0.75
        private constant real TAG_XOFFSET               = -0.0052
        private constant real TAG_YOFFSET               = -0.0048

        // Scroll
        private constant real SCROLL_DELAY              = 0.075

        // Buy / Sell sound, model and scale
        private constant string SPRITE_MODEL            = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
        private constant real SPRITE_SCALE              = 0.0005
        private constant string SUCCESS_SOUND           = "Abilities\\Spells\\Other\\Transmute\\AlchemistTransmuteDeath1.wav"
        private constant string ERROR_SOUND             = "Sound\\Interface\\Error.wav"

        // Dont touch
        private HashTable table
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    native GetUnitGoldCost takes integer id returns integer
    native GetUnitWoodCost takes integer id returns integer
    
    private struct Ability
        private static unit unit
        private static HashTable ability

        readonly integer id

        private method operator name= takes string value returns nothing
            set ability[id].string[1] = value
        endmethod

        method operator name takes nothing returns string
            return ability[id].string[1]
        endmethod

        private method operator icon= takes string value returns nothing
            set ability[id].string[2] = value
        endmethod

        method operator icon takes nothing returns string
            return ability[id].string[2]
        endmethod

        private method operator tooltip= takes string value returns nothing
            set ability[id].string[3] = value
        endmethod

        method operator tooltip takes nothing returns string
            return ability[id].string[3]
        endmethod

        static method operator [] takes integer id returns thistype
            if id > 0 then
                if ability[id].has(0) then
                    return Ability(ability[id][0])
                else
                    return create(id)
                endif
            endif

            return 0
        endmethod

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            
            if id > 0 and not ability[id].has(0) then
                call UnitAddAbility(unit, id)

                set this.id = id
                set name = GetObjectName(id)
                set icon = BlzGetAbilityIcon(id)
                set tooltip = BlzGetAbilityStringLevelField(BlzGetUnitAbility(unit, id), ABILITY_SLF_TOOLTIP_LEARN_EXTENDED, 0)
                set ability[id][0] = this

                if tooltip == null or tooltip == "" then
                    set tooltip = BlzGetAbilityExtendedTooltip(id, 0)
                endif
            endif

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set ability = HashTable.create()
            set unit = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), 'hpea', WorldBounds.maxX, WorldBounds.maxY, 0)

            call ShowUnit(unit, false)
            call UnitAddAbility(unit, 'Aloc')
        endmethod
    endstruct

    private struct Unit
        private static unit shop
        private static rect rect
        private static integer type
        private static region region
        private static HashTable unitpool
        private static HashTable abilities
        private static player player = Player(bj_PLAYER_NEUTRAL_EXTRA)

        readonly integer id

        private method operator gold= takes integer value returns nothing
            set unitpool[id][1] = value
        endmethod

        method operator gold takes nothing returns integer
            return unitpool[id][1]
        endmethod

        private method operator wood= takes integer value returns nothing
            set unitpool[id][2] = value
        endmethod

        method operator wood takes nothing returns integer
            return unitpool[id][2]
        endmethod

        private method operator food= takes integer value returns nothing
            set unitpool[id][3] = value
        endmethod

        method operator food takes nothing returns integer
            return unitpool[id][3]
        endmethod

        private method operator name= takes string value returns nothing
            set unitpool[id].string[4] = value
        endmethod

        method operator name takes nothing returns string
            return unitpool[id].string[4]
        endmethod

        private method operator icon= takes string value returns nothing
            set unitpool[id].string[5] = value
        endmethod

        method operator icon takes nothing returns string
            return unitpool[id].string[5]
        endmethod

        private method operator tooltip= takes string value returns nothing
            set unitpool[id].string[6] = value
        endmethod

        method operator tooltip takes nothing returns string
            return unitpool[id].string[6]
        endmethod

        method operator categories= takes integer category returns nothing
            set unitpool[id][7] = category
        endmethod 

        method operator categories takes nothing returns integer
            return unitpool[id][7]
        endmethod

        method operator ratio= takes real value returns nothing
            set unitpool[id].real[8] = value
        endmethod 

        method operator ratio takes nothing returns real
            return unitpool[id].real[8]
        endmethod

        method operator texture= takes string value returns nothing
            set unitpool[id].string[9] = value
        endmethod 

        method operator texture takes nothing returns string
            return unitpool[id].string[9]
        endmethod

        method operator range= takes string value returns nothing
            set unitpool[id].string[10] = value
        endmethod 

        method operator range takes nothing returns string
            return unitpool[id].string[10]
        endmethod

        method operator mana= takes string value returns nothing
            set unitpool[id].string[11] = value
        endmethod

        method operator mana takes nothing returns string
            return unitpool[id].string[11]
        endmethod

        method operator health= takes string value returns nothing
            set unitpool[id].string[12] = value
        endmethod

        method operator health takes nothing returns string
            return unitpool[id].string[12]
        endmethod

        method operator armor= takes string value returns nothing
            set unitpool[id].string[13] = value
        endmethod

        method operator armor takes nothing returns string
            return unitpool[id].string[13]
        endmethod

        method operator damage= takes string value returns nothing
            set unitpool[id].string[14] = value
        endmethod

        method operator damage takes nothing returns string
            return unitpool[id].string[14]
        endmethod

        method operator movement= takes string value returns nothing
            set unitpool[id].string[15] = value
        endmethod

        method operator movement takes nothing returns string
            return unitpool[id].string[15]
        endmethod

        method operator agility= takes string value returns nothing
            set unitpool[id].string[16] = value
        endmethod

        method operator agility takes nothing returns string
            return unitpool[id].string[16]
        endmethod

        method operator strength= takes string value returns nothing
            set unitpool[id].string[17] = value
        endmethod

        method operator strength takes nothing returns string
            return unitpool[id].string[17]
        endmethod

        method operator intelligence= takes string value returns nothing
            set unitpool[id].string[18] = value
        endmethod
    
        method operator intelligence takes nothing returns string
            return unitpool[id].string[18]
        endmethod

        method operator agilityPerLevel= takes string value returns nothing
            set unitpool[id].string[19] = value
        endmethod

        method operator agilityPerLevel takes nothing returns string
            return unitpool[id].string[19]
        endmethod

        method operator strengthPerLevel= takes string value returns nothing
            set unitpool[id].string[20] = value
        endmethod

        method operator strengthPerLevel takes nothing returns string
            return unitpool[id].string[20]
        endmethod

        method operator intelligencePerLevel= takes string value returns nothing
            set unitpool[id].string[21] = value
        endmethod

        method operator intelligencePerLevel takes nothing returns string
            return unitpool[id].string[21]
        endmethod

        method operator primary= takes integer value returns nothing
            set unitpool[id][22] = value
        endmethod

        method operator primary takes nothing returns integer
            return unitpool[id][22]
        endmethod

        method operator regeneration= takes string value returns nothing
            set unitpool[id].string[23] = value
        endmethod

        method operator regeneration takes nothing returns string
            return unitpool[id].string[23]
        endmethod

        method operator unique= takes boolean value returns nothing
            set unitpool[id].boolean[24] = value
        endmethod

        method operator unique takes nothing returns boolean
            return unitpool[id].boolean[24]
        endmethod

        method operator ability takes nothing returns Table
            return abilities[id]
        endmethod

        method operator isHero= takes boolean value returns nothing
            set unitpool[id].boolean[25] = value
        endmethod

        method operator isHero takes nothing returns boolean
            return unitpool[id].boolean[25]
        endmethod

        method operator isMelee= takes boolean value returns nothing
            set unitpool[id].boolean[26] = value
        endmethod

        method operator isMelee takes nothing returns boolean
            return unitpool[id].boolean[26]
        endmethod

        method operator isRanged= takes boolean value returns nothing
            set unitpool[id].boolean[27] = value
        endmethod

        method operator isRanged takes nothing returns boolean
            return unitpool[id].boolean[27]
        endmethod

        static method operator [] takes integer id returns thistype
            if id > 0 then
                if unitpool[id].has(0) then
                    return Unit(unitpool[id][0])
                else
                    return create(id)
                endif
            endif

            return 0
        endmethod

        private static method clear takes nothing returns nothing
            local unit u = GetFilterUnit()

            if GetUnitTypeId(u) == type and GetOwningPlayer(u) == player then
                set type = 0

                call RemoveUnit(u)
            endif

            set u = null
        endmethod

        static method addAbilities takes integer id, integer a1, integer a2, integer a3, integer a4, integer a5, integer a6 returns nothing
            local thistype this = Unit[id]

            if this != 0 then
                call ability.flush()

                set ability[0] = Ability[a1]
                set ability[1] = Ability[a2]
                set ability[2] = Ability[a3]
                set ability[3] = Ability[a4]
                set ability[4] = Ability[a5]
                set ability[5] = Ability[a6]
            endif
        endmethod

        static method cost takes integer id, boolean lumber returns integer
            local unit u = CreateUnit(player, id, 0, 0, 0)
            local integer value
            local playerstate resource

            if not IsUnitType(u, UNIT_TYPE_HERO) then
                call RemoveUnit(u)
                set u = null

                if lumber then
                    return GetUnitWoodCost(id)
                endif

                return GetUnitGoldCost(id)
            else
                set type = id

                if lumber then
                    set resource = PLAYER_STATE_RESOURCE_LUMBER
                else
                    set resource = PLAYER_STATE_RESOURCE_GOLD
                endif

                call AddUnitToStock(shop, id, 1, 1)
                call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
                call SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, 9999999)
                set value = GetPlayerState(player, resource)
                call IssueNeutralImmediateOrderById(player, shop, id)
                call RemoveUnitFromStock(shop, id)
                call SetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
                call RemoveUnit(u)
                
                set u = null

                return value - GetPlayerState(player, resource)
            endif
        endmethod

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            local unit u
            
            if id > 0 and not unitpool[id].has(0) then
                set u = CreateUnit(player, id, 0, 0, 0)

                if u != null then
                    set this.id = id
                    set gold = cost(id, false)
                    set wood = cost(id, true)
                    set name = GetUnitName(u)
                    set food = GetUnitFoodUsed(u)
                    set icon = BlzGetAbilityIcon(id)
                    set tooltip = BlzGetAbilityExtendedTooltip(id, 0)
                    set range = N2S(BlzGetUnitWeaponRealField(u, UNIT_WEAPON_RF_ATTACK_RANGE, 0), 0)
                    set mana = I2S(BlzGetUnitMaxMana(u))
                    set health = I2S(BlzGetUnitMaxHP(u))
                    set armor = N2S(BlzGetUnitArmor(u), 1)
                    set damage = I2S(BlzGetUnitBaseDamage(u, 0))
                    set movement = N2S(GetUnitMoveSpeed(u), 0)
                    set regeneration = "|cff00ff00" + N2S(BlzGetUnitRealField(u, UNIT_RF_HIT_POINTS_REGENERATION_RATE), 2) + "|r" + " / |cff51e1e6" + N2S(BlzGetUnitRealField(u, UNIT_RF_MANA_REGENERATION), 2) + "|r"
                    set isHero = IsUnitType(u, UNIT_TYPE_HERO)
                    set isMelee = IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER)
                    set isRanged = IsUnitType(u, UNIT_TYPE_RANGED_ATTACKER)
                    set unitpool[id][0] = this

                    if isHero then
                        set primary = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)
                        set agility = I2S(GetHeroAgi(u, false))
                        set strength = I2S(GetHeroStr(u, false))
                        set intelligence = I2S(GetHeroInt(u, false))
                        set agilityPerLevel = "|cff00ff00 + " + N2S(BlzGetUnitRealField(u, UNIT_RF_AGILITY_PER_LEVEL), 0) + "|r"
                        set strengthPerLevel = "|cff00ff00 + " + N2S(BlzGetUnitRealField(u, UNIT_RF_STRENGTH_PER_LEVEL), 0) + "|r"
                        set intelligencePerLevel = "|cff00ff00 + " + N2S(BlzGetUnitRealField(u, UNIT_RF_INTELLIGENCE_PER_LEVEL), 0) + "|r"
                    endif

                    call RemoveUnit(u)

                    set u = null
                endif
            endif

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set rect = Rect(0, 0, 0, 0)
            set region = CreateRegion()
            set unitpool = HashTable.create()
            set abilities = HashTable.create()
            set shop = CreateUnit(player, 'hpea', 0, 0, 0)

            call SetUnitUseFood(shop, false)
            call UnitAddAbility(shop,'Asid')
            call UnitAddAbility(shop,'Asud')
            call UnitAddAbility(shop, 'Aloc')
            call UnitRemoveAbility(shop, 'Awan')
            call UnitRemoveAbility(shop, 'Aneu')
            call UnitRemoveAbility(shop, 'Ane2')
            call SetUnitAcquireRange(shop, 0)
            call ShowUnit(shop, false)
            call ShowUnit(CreateUnit(player, 'ofrt', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'hcas', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'unp2', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'etoe', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'halt', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'oalt', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'uaod', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call ShowUnit(CreateUnit(player, 'eate', WorldBounds.maxX, WorldBounds.maxY, 0), false)
            call SetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_CAP, 100)
            call IssueNeutralTargetOrder(player, shop, "smart", shop)
            call SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
            call RegionAddRect(region, rect)
            call TriggerRegisterEnterRegion(CreateTrigger(), region, Condition(function thistype.clear))
        endmethod
    endstruct

    private struct Sound
        private static sound success_sound
        private static sound error_sound
        private static sound array noGold
        private static sound array noWood
        private static sound array noFood

        static method gold takes player p returns nothing
            if not GetSoundIsPlaying(noGold[GetHandleId(GetPlayerRace(p))]) then
                call StartSoundForPlayerBJ(p, noGold[GetHandleId(GetPlayerRace(p))])
            endif
        endmethod

        static method wood takes player p returns nothing
            if not GetSoundIsPlaying(noWood[GetHandleId(GetPlayerRace(p))]) then
                call StartSoundForPlayerBJ(p, noWood[GetHandleId(GetPlayerRace(p))])
            endif
        endmethod

        static method food takes player p returns nothing
            if not GetSoundIsPlaying(noFood[GetHandleId(GetPlayerRace(p))]) then
                call StartSoundForPlayerBJ(p, noFood[GetHandleId(GetPlayerRace(p))])
            endif
        endmethod

        static method success takes player p returns nothing
            if not GetSoundIsPlaying(success_sound) then
                call StartSoundForPlayerBJ(p, success_sound)
            endif
        endmethod

        static method error takes player p returns nothing
            if not GetSoundIsPlaying(error_sound) then
                call StartSoundForPlayerBJ(p, error_sound)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer id

            set success_sound = CreateSound(SUCCESS_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(success_sound, 1600)

            set error_sound = CreateSound(ERROR_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(error_sound, 614)

                set id = GetHandleId(RACE_HUMAN)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldHuman")
            call SetSoundDuration(noGold[id], 1618)
            set noWood[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoLumber1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noWood[id], "NoLumberHuman")
            call SetSoundDuration(noWood[id], 1863)
            set noFood[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoFood1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noFood[id], "NoFoodHuman")
            call SetSoundDuration(noFood[id], 1503)

            set id = GetHandleId(RACE_ORC)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldOrc")
            call SetSoundDuration(noGold[id], 1450)
            set noWood[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoLumber1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noWood[id], "NoLumberOrc")
            call SetSoundDuration(noWood[id], 1602)
            set noFood[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoFood1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noFood[id], "NoFoodOrc")
            call SetSoundDuration(noFood[id], 1683)

            set id = GetHandleId(RACE_NIGHTELF)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldNightElf")
            call SetSoundDuration(noGold[id], 1229)
            set noWood[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoLumber1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noWood[id], "NoLumberNightElf")
            call SetSoundDuration(noWood[id], 1500)
            set noFood[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\HuntressNoFood1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noFood[id], "NoFoodNightElf")
            call SetSoundDuration(noFood[id], 1783)

            set id = GetHandleId(RACE_UNDEAD)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldUndead")
            call SetSoundDuration(noGold[id], 2005)
            set noWood[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoLumber1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noWood[id], "NoLumberUndead")
            call SetSoundDuration(noWood[id], 1903)
            set noFood[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoFood1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noFood[id], "NoFoodUndead")
            call SetSoundDuration(noFood[id], 1660)

            set id = GetHandleId(ConvertRace(11))
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldNaga")
            call SetSoundDuration(noGold[id], 2690)
            set noWood[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoLumber1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noWood[id], "NoLumberNaga")
            call SetSoundDuration(noWood[id], 1576)
            set noFood[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoFood1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noFood[id], "NoFoodNaga")
            call SetSoundDuration(noFood[id], 2223)
        endmethod
    endstruct
    
    private struct Attribute extends Button
        private Text value

        method operator text= takes string newText returns nothing
            set value.text = newText
        endmethod

        method operator text takes nothing returns string
            return value.text
        endmethod

        method destroy takes nothing returns nothing
            call value.destroy()
        endmethod

        static method create takes string texture, string tooltip, framehandle parent, textaligntype alignment returns thistype
            local thistype this = thistype.allocate(0, 0, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, parent, true, false)

            set .texture = texture
            set .tooltip.text = tooltip
            set value = Text.create(0, 0, 0.1, ATTRIBUTES_HEIGHT, 1, false, frame, null, TEXT_JUSTIFY_CENTER, alignment)

            if alignment == TEXT_JUSTIFY_LEFT then
                call value.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            else
                call value.setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            endif

            return this
        endmethod
    endstruct

    private struct Slot extends Panel
        UnitPicker picker
        Unit unit
        Button button
        Text name
        Backdrop gold
        Text goldText
        Backdrop wood
        Text woodText
        Backdrop food
        Text foodText
        boolean array drafted[32]

        thistype next
        thistype prev
        thistype left
        thistype right

        private integer current_row
        private integer current_column

        method operator row= takes integer newRow returns nothing
            set current_row = newRow
            set y = - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * newRow))

            call update()
        endmethod

        method operator row takes nothing returns integer
            return current_row
        endmethod

        method operator column= takes integer newColumn returns nothing
            set current_column = newColumn
            set x = 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * newColumn)

            call update()
        endmethod

        method operator column takes nothing returns integer
            return current_column
        endmethod

        method operator available= takes boolean flag returns nothing
            set button.available = flag
        endmethod

        method operator available takes nothing returns boolean
            return button.available
        endmethod

        method destroy takes nothing returns nothing
            call name.destroy()
            call gold.destroy()
            call wood.destroy()
            call food.destroy()
            call button.destroy()
            call goldText.destroy()
            call woodText.destroy()
            call foodText.destroy()
        endmethod

        method update takes nothing returns nothing
            if column <= (picker.columns / 2) and row < 2 then
                set button.tooltip.point = FRAMEPOINT_TOPLEFT
            elseif column >= ((picker.columns / 2) + 1) and row < 2 then
                set button.tooltip.point = FRAMEPOINT_TOPRIGHT
            elseif column <= (picker.columns / 2) and row >= 2 then
                set button.tooltip.point = FRAMEPOINT_BOTTOMLEFT
            else
                set button.tooltip.point = FRAMEPOINT_BOTTOMRIGHT
            endif
        endmethod

        method move takes integer row, integer column returns nothing
            set .row = row
            set .column = column
        endmethod

        static method create takes UnitPicker picker, Unit u, real x, real y, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, SLOT_WIDTH, SLOT_HEIGHT, parent, "Leaderboard", false)

            set .x = x
            set .y = y
            set unit = u
            set .picker = picker
            set next = 0
            set prev = 0
            set right = 0
            set left = 0
            set button = Button.create(0, 0, ICON_SIZE, ICON_SIZE, frame, false, true)
            set button.tooltip.point = FRAMEPOINT_TOPRIGHT
            set name = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, button.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set gold = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, name.frame, GOLD_ICON)
            set goldText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, gold.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set wood = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, gold.frame, WOOD_ICON)
            set woodText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, wood.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set food = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, wood.frame, FOOD_ICON)
            set foodText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, food.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set table[button][0] = this

            call button.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.006, 0)
            call name.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0, 0)
            call gold.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            call goldText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            call wood.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            call woodText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            call food.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            call foodText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)

            if unit != 0 then
                set button.texture = unit.icon
                set button.tooltip.text = unit.tooltip + "\n\n|cffFFCC00Double or Right click to buy|r"
                set button.tooltip.name = unit.name
                set button.tooltip.icon = unit.icon
                set name.text = unit.name
                set goldText.text = "|cffFFCC00" + I2S(unit.gold) + "|r"
                set woodText.text = "|cff265526" + I2S(unit.wood) + "|r"
                set foodText.text = "|cff742b2b" + I2S(unit.food) + "|r"

                if u.unique then
                    set button.tooltip.text = button.tooltip.text + "\n\n|cffFFCC00Unique|r"
                endif
            endif

            return this
        endmethod

        private method onScroll takes nothing returns nothing
            if GetLocalPlayer() == GetTriggerPlayer() then
                call picker.onScroll()
            endif
        endmethod

        private method onClick takes nothing returns nothing
            call picker.detail(unit, GetTriggerPlayer())
        endmethod

        private method onMiddleClick takes nothing returns nothing
            // if shop.favorites.has(item.id, GetTriggerPlayer()) then
            //     call shop.favorites.remove(item, GetTriggerPlayer())
            // else
            //     call shop.favorites.add(item, GetTriggerPlayer())
            // endif
        endmethod

        private method onDoubleClick takes nothing returns nothing
            if button.active and button.available then
                if picker.buy(unit, GetTriggerPlayer()) then
                    set button.active = not unit.unique

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            else
                call Sound.error(GetTriggerPlayer())
            endif
        endmethod

        private method onRightClick takes nothing returns nothing
            if button.active and button.available then
                if picker.buy(unit, GetTriggerPlayer()) then
                    set button.active = not unit.unique

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            else
                call Sound.error(GetTriggerPlayer())
            endif
        endmethod
    endstruct
    
    private struct Detail extends Panel
        private UnitPicker picker
        private Text name
        private Panel unit
        private Panel abilities
        private Button selected
        private TextArea description
        private Attribute damage
        private Attribute armor
        private Attribute health
        private Attribute mana
        private Attribute movement
        private Attribute agility
        private Attribute strength
        private Attribute intelligence
        private Attribute range
        private Attribute regeneration
        private HashTable ability
        // private Sprite unit

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == ABILITY_COUNT
                                call table.remove(ability[i][j])
                                call Button(ability[i][j]).destroy()
                            set j = j + 1
                        endloop

                        call ability.remove(i)
                    endif
                set i = i + 1
            endloop

            call name.destroy()
            call unit.destroy()
            call abilities.destroy()
            call selected.destroy()
            call description.destroy()
            call damage.destroy()
            call armor.destroy()
            call health.destroy()
            call mana.destroy()
            call movement.destroy()
            call agility.destroy()
            call strength.destroy()
            call intelligence.destroy()
            call range.destroy()
            call regeneration.destroy()
            call ability.destroy()
        endmethod

        method show takes Unit u, player p returns nothing
            local integer id = GetPlayerId(p)
            local integer i = 0
            local integer j = 0
            local Ability spell

            if u != 0 and GetLocalPlayer() == p then
                set name.text = u.name
                set unit.texture = u.texture
                set unit.width = MODEL_HEIGHT * u.ratio
                set description.text = u.tooltip
                set damage.text = u.damage
                set armor.text = u.armor
                set health.text = u.health
                set mana.text = u.mana
                set movement.text = u.movement
                set agility.visible = u.isHero
                set strength.visible = u.isHero
                set intelligence.visible = u.isHero
                set range.visible = u.isHero
                set regeneration.visible = u.isHero

                if u.isHero then
                    set range.text = u.range
                    set regeneration.text = u.regeneration
                    set agility.text = u.agility + u.agilityPerLevel
                    set strength.text = u.strength + u.strengthPerLevel
                    set intelligence.text = u.intelligence + u.intelligencePerLevel

                    call agility.display(null, 0, 0, 0)
                    call strength.display(null, 0, 0, 0)
                    call intelligence.display(null, 0, 0, 0)

                    if u.isMelee then
                        set range.texture = MELEE_TEXTURE
                        set range.tooltip.text = "Melee"
                    else
                        set range.texture = RANGE_TEXTURE
                        set range.tooltip.text = "Ranged"
                    endif

                    if u.primary == 3 then
                        call agility.display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    elseif u.primary == 2 then
                        call intelligence.display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    elseif u.primary == 1 then
                        call strength.display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    endif
                endif

                if selected != 0 then
                    call selected.display(null, 0, 0, 0)
                endif

                loop
                    exitwhen i == ABILITY_COUNT
                        set spell = u.ability[i]
                        set Button(ability[id][i]).visible = false

                        if spell != 0 then
                            set Button(ability[id][j]).texture = spell.icon
                            set Button(ability[id][j]).tooltip.text = spell.tooltip
                            set Button(ability[id][j]).tooltip.name = spell.name
                            set Button(ability[id][j]).tooltip.icon = spell.icon
                            set Button(ability[id][j]).visible = true
                            set j = j + 1
                        endif
                    set i = i + 1
                endloop
            endif
        endmethod

        static method create takes UnitPicker picker returns thistype
            local thistype this = thistype.allocate(0, 0, DETAIL_WIDTH, DETAIL_HEIGHT, picker.frame, "EscMenuBackdrop", false)
            local integer i = 0
            local integer j = 0
            
            set .picker = picker
            set ability = HashTable.create()
            set name = Text.create(0, 0, NAME_WIDTH, NAME_HEIGHT, NAME_SCALE, false, frame, null, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
            set unit = Panel.create(0, 0, MODEL_HEIGHT, MODEL_HEIGHT, name.frame, "TransparentBackdrop", false)
            set abilities = Panel.create(0, 0, DETAIL_WIDTH - 0.05, 0.05, unit.frame, "TransparentBackdrop", false)
            set description = TextArea.create(0, 0, DESCRIPTION_WIDTH, DESCRIPTION_HEIGHT, abilities.frame, "DescriptionArea")
            set damage = Attribute.create(DAMAGE_TEXTURE, "Damage", frame, TEXT_JUSTIFY_LEFT)
            set armor = Attribute.create(ARMOR_TEXTURE, "Armor", damage.frame, TEXT_JUSTIFY_LEFT)
            set health = Attribute.create(HEALTH_TEXTURE, "Health", armor.frame, TEXT_JUSTIFY_LEFT)
            set mana = Attribute.create(MANA_TEXTURE, "Mana", health.frame, TEXT_JUSTIFY_LEFT)
            set movement = Attribute.create(MOVEMENT_TEXTURE, "Movement", mana.frame, TEXT_JUSTIFY_LEFT)
            set agility = Attribute.create(AGILITY_TEXTURE, "Agility", frame, TEXT_JUSTIFY_RIGHT)
            set agility.visible = false
            set strength = Attribute.create(STRENGTH_TEXTURE, "Strength", agility.frame, TEXT_JUSTIFY_RIGHT)
            set strength.visible = false
            set intelligence = Attribute.create(INTELLIGENCE_TEXTURE, "Intelligence", strength.frame, TEXT_JUSTIFY_RIGHT)
            set intelligence.visible = false
            set range = Attribute.create(RANGE_TEXTURE, "Range", intelligence.frame, TEXT_JUSTIFY_RIGHT)
            set range.visible = false
            set regeneration = Attribute.create(REGENERATION_TEXTURE, "Regeneration", range.frame, TEXT_JUSTIFY_RIGHT)

            // set unit = Sprite.create(0, 0, background.width, background.height, background.frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER)
            // set unit.model = "Model.mdx"
            // set unit.scale = 0.0005

            call setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_RIGHT, 0, 0)
            call name.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0, -0.0225)
            call unit.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call abilities.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call description.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0.025, 0)
            call damage.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.025, -0.05)
            call armor.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call health.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call mana.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call movement.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call agility.setPoint(FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.025, -0.05)
            call strength.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call intelligence.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call range.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            call regeneration.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        loop
                            exitwhen j == ABILITY_COUNT
                                set ability[i][j] = Button.create(0.005 + ABILITY_GAP*j, - 0.0075, ABILITY_SIZE, ABILITY_SIZE, abilities.frame, false, false)
                                set Button(ability[i][j]).visible = false
                                set Button(ability[i][j]).tooltip.point = FRAMEPOINT_TOP
                                set Button(ability[i][j]).onClick = function thistype.onClicked
                                set table[ability[i][j]][0] = this
                                set table[ability[i][j]][1] = j
                            set j = j + 1
                        endloop
                    endif
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local thistype this = table[b][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                set description.text = b.tooltip.text

                if selected != 0 then
                    call selected.display(null, 0, 0, 0)
                endif

                set selected = b

                call selected.display(ABILITY_HIGHLIGHT, ABILITY_HIGHLIGHT_SCALE, ABILITY_HIGHLIGHT_XOFFSET, ABILITY_HIGHLIGHT_YOFFSET)
            endif
        endmethod
    endstruct

    private struct Category extends Panel
        UnitPicker picker
        integer count
        integer active
        boolean andLogic
        integer array value[CATEGORY_COUNT]
        Button array button[CATEGORY_COUNT]

        method destroy takes nothing returns nothing
            loop
                exitwhen count == -1
                    call table.remove(button[count])
                    call button[count].destroy()
                set count = count - 1
            endloop
        endmethod

        method reset takes nothing returns nothing
            local integer i = 0

            set active = 0

            loop
                exitwhen i > CATEGORY_COUNT
                    set button[i].active = false
                set i = i + 1
            endloop

            call picker.filter(active, andLogic)
        endmethod

        method add takes string icon, string description returns integer
            if count < CATEGORY_COUNT then
                set count = count + 1
                set value[count] = R2I(Pow(2, count))

                if count > 0 then
                    set button[count] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, button[count - 1].frame, true, false)
                    call button[count].setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
                else
                    set button[count] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, frame, true, false)
                    call button[count].setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.005, 0)
                endif

                set button[count].texture = icon
                set button[count].active = false
                set button[count].tooltip.text = description
                set button[count].onClick = function thistype.onClicked
                set table[button[count]][0] = this
                set table[button[count]][1] = count

                return value[count]
            else
                call BJDebugMsg("Maximum number os categories reached.")
            endif

            return 0
        endmethod

        static method create takes UnitPicker picker returns thistype
            local thistype this = thistype.allocate(0, 0, WIDTH, 0.03, picker.frame, "Leaderboard", false)

            set count = -1
            set active = 0
            set andLogic = true
            set .picker = picker

            call setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, -0.0075)

            return this
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button category = GetTriggerComponent()
            local thistype this = table[category][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                set category.active = not category.active

                if category.active then
                    set active = active + value[table[category][1]]
                else
                    set active = active - value[table[category][1]]
                endif

                call picker.filter(active, andLogic)
            endif
        endmethod
    endstruct
    
    struct UnitPicker extends Panel
        private static HashTable unitpool
        private static integer array bans
        private static thistype array array

        private timer timer
        private boolean isVisible
        private boolean keepOpen

        readonly real x
        readonly real y
        readonly real timeout
        readonly integer banCount
        readonly integer size
        readonly integer drafts
        readonly integer index
        readonly integer rows
        readonly integer columns
        readonly Slot first
        readonly Slot last
        readonly Slot head
        readonly Slot tail
        readonly EditBox edit
        readonly Text banText
        readonly Button ban
        readonly Button close
        readonly Button clear
        readonly Button logic
        readonly Detail details
        readonly Category category
        readonly HashTable scrolls

        method operator visible= takes boolean visibility returns nothing
            local integer id = GetPlayerId(GetLocalPlayer())

            set isVisible = visibility or keepOpen

            if not isVisible then
                set array[id] = 0
            else
                set array[id] = this

                if table[this].has(id) then
                    call detail(Slot(table[this][id]).unit, GetLocalPlayer())
                else
                    call detail(Slot(unitpool[this][0]).unit, GetLocalPlayer())
                endif
            endif
            
            call BlzFrameSetVisible(frame, isVisible)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator keepOpened= takes boolean flag returns nothing
            set keepOpen = flag

            if not visible and keepOpen then
                set visible = true
            endif
        endmethod

        method operator keepOpened takes nothing returns boolean
            return keepOpen
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local Slot slot = unitpool[this][0]

            loop
                exitwhen slot == 0
                    call slot.destroy()
                set slot = slot.next
            endloop

            call table.remove(this)
            call unitpool.remove(this)
            call ban.destroy()
            call edit.destroy()
            call close.destroy()
            call clear.destroy()
            call logic.destroy()
            call banText.destroy()
            call details.destroy()
            call category.destroy()
        endmethod

        method buy takes Unit u, player p returns boolean
            local integer id = GetPlayerId(p)
            local integer cap = GetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_CAP)
            local integer gold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
            local integer lumber = GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER)
            local integer food = cap - GetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_USED)
            local unit new

            if u.gold <= gold and u.wood <= lumber and (u.food <= food or cap == 0) and not ban.visible then
                set new = CreateUnit(p, u.id, x, y, 0)

                if new != null then
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold - u.gold)
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, lumber - u.wood)
                    call Sound.success(p)
                else
                    call Sound.error(p)
                    return false
                endif

                set new = null

                return true
            else
                if ban.visible then
                    call Sound.error(p)
                else
                    if u.gold > gold then
                        call Sound.gold(p)
                    elseif u.wood > lumber then
                        call Sound.wood(p)
                    elseif u.food > food and cap != 0 then
                        call Sound.food(p)
                    else
                        call Sound.error(p)
                    endif
                endif

                return false
            endif

            return false
        endmethod

        method scroll takes boolean down returns boolean
            local Slot slot = first
            
            if (down and tail != last) or (not down and head != first) then
                loop
                    exitwhen slot == 0
                        if down then
                            call slot.move(slot.row - 1, slot.column)
                        else
                            call slot.move(slot.row + 1, slot.column)
                        endif

                        set slot.visible = slot.row >= 0 and slot.row <= rows - 1 and slot.column >= 0 and slot.column <= columns - 1

                        if slot.row == 0 and slot.column == 0 then
                            set head = slot
                        endif

                        if (slot.row == rows - 1 and slot.column == columns - 1) or (slot == last and slot.visible) then
                            set tail = slot
                        endif
                    set slot = slot.right
                endloop

                return true
            endif

            return false
        endmethod

        method scrollTo takes Unit u, player p returns nothing
            local Slot slot

            if u != 0 and GetLocalPlayer() == p then
                set slot = Slot(table[this][u.id])
    
                loop
                    exitwhen slot.visible or not scroll(true)
                endloop
            endif
        endmethod

        method draft takes nothing returns nothing
            local Table used = Table.create()
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer tries
            local boolean reused = false
            local Slot slot

            if drafts > 0 and drafts < index then
                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
                        if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                            set j = 0

                            loop
                                exitwhen j >= drafts
                                    set tries = 0
                                    set k = GetRandomInt(0, index)
                                    set slot = Slot(unitpool[this][k])

                                    loop
                                        exitwhen tries > index
                                            if slot != 0 and not used.has(slot) then
                                                set used[slot] = 1
                                                set slot.drafted[i] = true

                                                if reused then
                                                    set slot.unit.unique = false
                                                endif

                                                exitwhen true
                                            endif

                                            set k = ModuloInteger(k + 1, index)
                                            set slot = Slot(unitpool[this][k])
                                        set tries = tries + 1
                                    endloop

                                    if tries > index then
                                        set reused = true
                                        call used.flush()
                                    endif
                                set j = j + 1
                            endloop
                        endif
                    set i = i + 1
                endloop
            endif

            call used.flush()
            call used.destroy()
            call category.reset()
        endmethod

        method filter takes integer categories, boolean andLogic returns nothing
            local Slot slot = unitpool[this][0]
            local boolean process
            local integer i = -1

            set size = 0
            set first = 0
            set last = 0
            set head = 0
            set tail = 0

            loop
                exitwhen slot == 0
                    if andLogic then
                        set process = categories == 0 or BlzBitAnd(slot.unit.categories, categories) >= categories
                    else
                        set process = categories == 0 or BlzBitAnd(slot.unit.categories, categories) > 0
                    endif

                    if edit.text != "" and edit.text != null then
                        set process = process and find(StringCase(slot.unit.name, false), StringCase(edit.text, false))
                    endif

                    set process = process and (slot.drafted[GetPlayerId(GetLocalPlayer())] or banCount > 0)

                    if process then
                        set i = i + 1
                        set size = size + 1
                        call slot.move(R2I(i/columns), ModuloInteger(i, columns))
                        set slot.visible = slot.row >= 0 and slot.row <= rows - 1 and slot.column >= 0 and slot.column <= columns - 1
                    
                        if i > 0 then
                            set slot.left = last
                            set last.right = slot
                        else
                            set first = slot
                            set head = first
                        endif

                        if slot.visible then
                            set tail = slot
                        endif

                        set last = slot
                    else
                        set slot.visible = false
                    endif
                set slot = slot.next
            endloop
        endmethod

        method select takes Unit u, player p returns nothing
            local integer id = GetPlayerId(p)

            if u != 0 and GetLocalPlayer() == p then
                if table[this].has(id) then
                    call Slot(table[this][id]).button.display(null, 0, 0, 0)
                endif

                set table[this][id] = Slot(table[this][u.id])
                call Slot(table[this][id]).button.display(ITEM_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
            endif
        endmethod

        method detail takes Unit u, player p returns nothing
            if u != 0 then
                call select(u, p)
                call details.show(u, p)
            else
                if GetLocalPlayer() == p then
                    call filter(category.active, category.andLogic)
                    call scrollTo(Slot(table[this][GetPlayerId(p)]).unit, p)
                endif
            endif
        endmethod

        private method find takes string source, string target returns boolean
            local integer sourceLength = StringLength(source)
            local integer targetLenght = StringLength(target)
            local integer i = 0

            if targetLenght <= sourceLength then
                loop
                    exitwhen i > sourceLength - targetLenght
                        if SubString(source, i, i + targetLenght) == target then
                            return true
                        endif
                    set i = i + 1
                endloop
            endif

            return false
        endmethod

        method addCategory takes string icon, string description returns integer
            return category.add(icon, description)
        endmethod

        method add takes integer id, boolean unique, string texture, real ratio, integer categories returns nothing
            local Slot slot
            local Unit u

            if not table[this].has(id) then
                set u = Unit[id]

                if u != 0 then
                    set size = size + 1
                    set index = index + 1
                    set u.ratio = ratio
                    set u.unique = unique
                    set u.texture = texture
                    set u.categories = categories
                    set slot = Slot.create(this, u, 0, 0, frame)
                    set slot.row = R2I(index/COLUMNS)
                    set slot.column = ModuloInteger(index, COLUMNS)
                    set slot.drafted[GetPlayerId(GetLocalPlayer())] = not (drafts > 0)
                    set slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1

                    if index > 0 then
                        set slot.prev = last
                        set slot.left = last
                        set last.next = slot
                        set last.right = slot
                    else
                        set first = slot
                        set head = slot
                    endif

                    if slot.visible then
                        set tail = slot
                    endif

                    set last = slot
                    set table[this][id] = slot
                    set unitpool[this][index] = slot
                else
                    call BJDebugMsg("Invalid unit code: " + A2S(id))
                endif
            else
                call BJDebugMsg("The unit " + GetObjectName(id) + " is already registered for the instance " + I2S(this))
            endif
        endmethod

        static method create takes real spawnX, real spawnY, integer bansPerPlayer, real banTimeout, integer draftCount, boolean showPicks returns thistype
            local thistype this = thistype.allocate(X, Y, WIDTH, HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0), "EscMenuBackdrop", false)
            local integer i = 0

            set x = spawnX
            set y = spawnY
            set first = 0
            set last = 0
            set head = 0
            set tail = 0
            set size = 0
            set index = -1
            set banCount = 0
            set drafts = draftCount
            set timeout = banTimeout
            set keepOpen = false
            set rows = ROWS
            set columns = COLUMNS
            set timer = NewTimerEx(this)
            set scrolls = HashTable.create()
            set details = Detail.create(this)
            set category = Category.create(this)
            set ban = Component.create(0, 0, 0.1, 0.03, frame, "ComponentFrame", "ScriptDialogButton", false)
            set ban.visible = bansPerPlayer > 0
            set ban.onClick = function thistype.onBan
            set banText = Text.create(0, 0, ban.width, ban.height, 1, false, ban.frame, "Ban (" + I2S(bansPerPlayer) + "): " + N2S(timeout, 0), TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            set close = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true, false)
            set close.texture = CLOSE_ICON
            set close.tooltip.text = "Close"
            set close.onClick = function thistype.onClose
            set clear = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, close.frame, true, false)
            set clear.texture = CLEAR_ICON
            set clear.tooltip.text = "Clear"
            set clear.onClick = function thistype.onClear
            set logic = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, clear.frame, true, false)
            set logic.texture = LOGIC_ICON
            set logic.active = false
            set logic.tooltip.text = "AND"
            set logic.onClick = function thistype.onLogic
            set edit = EditBox.create(0, 0, EDIT_WIDTH, EDIT_HEIGHT, logic.frame, "EscMenuEditBoxTemplate")
            set edit.onText = function thistype.onSearch
            set table[ban][0] = this
            set table[edit][0] = this
            set table[close][0] = this
            set table[clear][0] = this
            set table[logic][0] = this

            call ban.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0.007)
            call banText.setPoint(FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0, 0)
            call close.setPoint(FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_TOPRIGHT, -0.005, -0.0025)
            call clear.setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            call logic.setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            call edit.setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)

            if bansPerPlayer > 0 then
                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
                        if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                            set bans[i] = bansPerPlayer
                            set banCount = banCount + bansPerPlayer
                        endif
                    set i = i + 1
                endloop

                call TimerStart(timer, 1, true, function thistype.onPeriod)
            else
                if drafts > 0 then
                    call TimerStart(NewTimerEx(this), 1, false, function thistype.onDraft)
                endif
            endif

            set visible = false

            return this
        endmethod

        method onScroll takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local integer direction = R2I(BlzGetTriggerFrameValue())
            
            if scrolls[id][0] != direction then
                set scrolls[id][0] = direction
                set scrolls[id][1] = 0
            else
                set scrolls[id][1] = scrolls[id][1] + 1
            endif

            if GetLocalPlayer() == GetTriggerPlayer() then
                if scrolls[id][1] == 1 then
                    call scroll(direction < 0)
                else
                    call scroll(direction < 0)
                endif
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if this != 0 then
                set timeout = timeout - 1
                set banText.text = "Ban (" + I2S(bans[GetPlayerId(GetLocalPlayer())]) + "): " + N2S(timeout, 0)

                if banCount <= 0 or timeout <= 0 then
                    set banCount = 0
                    set ban.visible = false

                    call draft()
                    call ReleaseTimer(GetExpiredTimer())
                endif
            endif
        endmethod

        private static method onBan takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]
            local integer id = GetPlayerId(GetTriggerPlayer())
            local Slot slot
            
            if this != 0 then
                set slot = Slot(table[this][id])

                if slot != 0 and bans[id] > 0 then
                    if slot.available then
                        set slot.available = false
                        set bans[id] = bans[id] - 1
                        set banCount = banCount - 1
                    else
                        call Sound.error(GetTriggerPlayer())
                    endif
                else
                    call Sound.error(GetTriggerPlayer())
                endif
            endif
        endmethod

        private static method onDraft takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if this != 0 then
                call draft()
                call ReleaseTimer(GetExpiredTimer())
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local integer id = GetPlayerId(GetLocalPlayer())
            local thistype this = array[id]

            if this != 0 then
                set scrolls[id][1] = scrolls[id][1] - 1

                if scrolls[id][1] > 0 then
                    call scroll(scrolls[id][0] < 0)
                else
                    set scrolls[id][1] = 0
                endif
            endif
        endmethod

        private static method onSearch takes nothing returns nothing
            local thistype this = table[GetTriggerEditBox()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                call filter(category.active, category.andLogic)
            endif
        endmethod

        private static method onClose takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set visible = false
                endif
            endif
        endmethod

        private static method onClear takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                call category.reset()
            endif
        endmethod

        private static method onLogic takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                set logic.active = not logic.active
                set category.andLogic = not category.andLogic 

                if category.andLogic then
                    set logic.tooltip.text = "AND"
                else
                    set logic.tooltip.text = "OR"
                endif

                call filter(category.active, category.andLogic)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()
            set unitpool = HashTable.create()

            if SCROLL_DELAY > 0 then
                call TimerStart(CreateTimer(), SCROLL_DELAY, true, function thistype.onExpire)
            endif
        endmethod
    endstruct

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateUnitPicker takes real spawnX, real spawnY, integer bansPerPlayer, real banTimeout, integer draftCount, boolean showPicks returns UnitPicker
        return UnitPicker.create(spawnX, spawnY, bansPerPlayer, banTimeout, draftCount, showPicks)
    endfunction
    
    function UnitPickerAddCategory takes UnitPicker picker, string icon, string description returns integer
        return picker.addCategory(icon, description)
    endfunction

    function UnitPickerAddUnit takes UnitPicker picker, integer id, boolean unique, string texture, real ratio, integer categories returns nothing
        call picker.add(id, unique, texture, ratio, categories)
    endfunction

    function UnitAddAbilities takes integer id, integer a1, integer a2, integer a3, integer a4, integer a5, integer a6 returns nothing
        call Unit.addAbilities(id, a1, a2, a3, a4, a5, a6)
    endfunction

    function ShowUnitPicker takes UnitPicker picker, player p, boolean flag returns nothing
        if GetLocalPlayer() == p and picker != 0 then
            set picker.visible = flag
        endif
    endfunction

    function UnitPickerKeepOpened takes UnitPicker picker, player p, boolean flag returns nothing
        if GetLocalPlayer() == p and picker != 0 then
            set picker.keepOpened = flag
        endif
    endfunction
endlibrary