---@beginFile UnitPicker
---@debug
---@diagnostic disable: need-check-nil
OnInit("UnitPicker", function(requires)
    requires "Class"
    requires "Utilities"
    requires "Components"
    requires "WorldBounds"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- Main window
    local X                           = 0.0
    local Y                           = 0.56
    local WIDTH                       = 0.8
    local HEIGHT                      = 0.4
    local TOOLBAR_BUTTON_SIZE         = 0.02
    local ROWS                        = 6
    local COLUMNS                     = 3
    local MAX_PICKS_SHOWED            = 12
    local CLOSE_ICON                  = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
    local RANDOM_ICON                 = "UI\\Widgets\\EscMenu\\Human\\quest-unknown.blp"
    local LOGIC_ICON                  = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"
    local CLEAR_ICON                  = "ReplaceableTextures\\CommandButtons\\BTNCancel.blp"
    local USE_GOLD                    = true
    local USE_WOOD                    = true
    local USE_FOOD                    = true

    -- Details window
    local DETAIL_WIDTH                = 0.3125
    local DETAIL_HEIGHT               = HEIGHT
    local ABILITY_COUNT               = 6
    local ABILITY_SIZE                = 0.035
    local ABILITY_GAP                 = 0.044
    local NAME_WIDTH                  = 0.125
    local NAME_HEIGHT                 = 0.014
    local NAME_SCALE                  = 1
    local MODEL_HEIGHT                = 0.12
    local DESCRIPTION_WIDTH           = 0.31
    local DESCRIPTION_HEIGHT          = 0.15
    local EDIT_WIDTH                  = 0.15
    local EDIT_HEIGHT                 = 0.0285

    -- Attributes
    local ATTRIBUTES_WIDTH            = 0.02
    local ATTRIBUTES_HEIGHT           = 0.02
    local ATTRIBUTE_HIGHLIGHT_SCALE   = 0.2
    local ATTRIBUTE_HIGHLIGHT_XOFFSET = 0.052
    local ATTRIBUTE_HIGHLIGHT_YOFFSET = 0.048
    local ATTRIBUTE_HIGHLIGHT         = "goldenbrown.mdx"
    local DAMAGE_TEXTURE              = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
    local ARMOR_TEXTURE               = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
    local HEALTH_TEXTURE              = "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp"
    local MANA_TEXTURE                = "ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp"
    local MOVEMENT_TEXTURE            = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"
    local RANGE_TEXTURE               = "ReplaceableTextures\\CommandButtons\\BTNImprovedBows.blp"
    local MELEE_TEXTURE               = "ReplaceableTextures\\CommandButtons\\BTNSteelMelee.blp"
    local REGENERATION_TEXTURE        = "ReplaceableTextures\\CommandButtons\\BTNRejuvenation.blp"
    local STRENGTH_TEXTURE            = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
    local AGILITY_TEXTURE             = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
    local INTELLIGENCE_TEXTURE        = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"

    -- Slots
    local SLOT_WIDTH                  = 0.14
    local SLOT_HEIGHT                 = 0.05
    local ICON_SIZE                   = 0.04
    local COST_SIZE                   = 0.01
    local COST_WIDTH                  = 0.12
    local COST_HEIGHT                 = 0.01
    local COST_SCALE                  = 0.8
    local SLOT_GAP_X                  = 0.02
    local SLOT_GAP_Y                  = 0.008
    local GOLD_ICON                   = "UI\\Feedback\\Resources\\ResourceGold.blp"
    local WOOD_ICON                   = "UI\\Feedback\\Resources\\ResourceLumber.blp"
    local FOOD_ICON                   = "UI\\Feedback\\Resources\\ResourceSupply.blp"

    -- Category
    local CATEGORY_COUNT              = 28
    local CATEGORY_SIZE               = 0.02

    -- Selected item highlight
    local ITEM_HIGHLIGHT              = "neon_sprite.mdx"
    local HIGHLIGHT_SCALE             = 0.75
    local HIGHLIGHT_XOFFSET           = -0.0052
    local HIGHLIGHT_YOFFSET           = -0.0048

    -- Selected ability highlight
    local ABILITY_HIGHLIGHT           = "neon_sprite.mdx"
    local ABILITY_HIGHLIGHT_SCALE     = 0.62
    local ABILITY_HIGHLIGHT_XOFFSET   = -0.0042
    local ABILITY_HIGHLIGHT_YOFFSET   = -0.0038

    -- Tagged item highlight
    local TAG_MODEL                   = "crystallid_sprite.mdx"
    local TAG_SCALE                   = 0.75
    local TAG_XOFFSET                 = -0.0052
    local TAG_YOFFSET                 = -0.0048

    -- Scroll
    local SCROLL_DELAY                = 0.03

    -- Buy / Sell sound, model and scale
    local SPRITE_MODEL                = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
    local SPRITE_SCALE                = 0.0005
    local SUCCESS_SOUND               = "Abilities\\Spells\\Other\\Transmute\\AlchemistTransmuteDeath1.wav"
    local ERROR_SOUND                 = "Sound\\Interface\\Error.wav"
    local ALERT_SOUND                 = "Sound\\Interface\\Rescue.wav"

    -- Dont touch
    local array                       = {}

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    -- ---------------------------------------- Ability ---------------------------------------- --
    local Ability = Class()

    do
        local unit
        local ability = {}

        Ability:property("name", {
            get = function(self) return ability[self.id][1] end,
            set = function(self, value) ability[self.id][1] = value end
        })

        Ability:property("icon", {
            get = function(self) return ability[self.id][2] end,
            set = function(self, value) ability[self.id][2] = value end
        })

        Ability:property("tooltip", {
            get = function(self) return ability[self.id][3] end,
            set = function(self, value) ability[self.id][3] = value end
        })

        function Ability.get(id)
            if id and id > 0 then
                if ability[id] then
                    return ability[id][0]
                else
                    return Ability.create(id)
                end
            end

            return nil
        end

        function Ability.create(id)
            local this = Ability.allocate()

            if id and id > 0 and not ability[id] then
                UnitAddAbility(unit, id)

                ability[id] = {}
                ability[id][0] = this

                this.id = id
                this.name = GetObjectName(id)
                this.icon = BlzGetAbilityIcon(id)
                this.tooltip = BlzGetAbilityStringLevelField(BlzGetUnitAbility(unit, id), ABILITY_SLF_TOOLTIP_LEARN_EXTENDED, 0)

                if this.tooltip == nil or this.tooltip == "" then
                    this.tooltip = BlzGetAbilityExtendedTooltip(id, 0)
                end
            end

            return this
        end

        function Ability.onInit()
            unit = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), S2A('hpea'), WorldBounds.maxX, WorldBounds.maxY, 0)

            ShowUnit(unit, false)
            UnitAddAbility(unit, S2A('Aloc'))
        end
    end

    -- ------------------------------------------ Unit ----------------------------------------- --
    local Unit = Class()

    do
        local shop
        local unittype = 0
        local unitpool = {}
        local abilities = {}
        local rect = Rect(0, 0, 0, 0)
        local region = CreateRegion()
        local player = Player(bj_PLAYER_NEUTRAL_EXTRA)

        Unit:property("gold", {
            get = function(self) return unitpool[self.id][1] end,
            set = function(self, value) unitpool[self.id][1] = value end
        })

        Unit:property("wood", {
            get = function(self) return unitpool[self.id][2] end,
            set = function(self, value) unitpool[self.id][2] = value end
        })

        Unit:property("food", {
            get = function(self) return unitpool[self.id][3] end,
            set = function(self, value) unitpool[self.id][3] = value end
        })

        Unit:property("name", {
            get = function(self) return unitpool[self.id][4] end,
            set = function(self, value) unitpool[self.id][4] = value end
        })

        Unit:property("icon", {
            get = function(self) return unitpool[self.id][5] end,
            set = function(self, value) unitpool[self.id][5] = value end
        })

        Unit:property("tooltip", {
            get = function(self) return unitpool[self.id][6] end,
            set = function(self, value) unitpool[self.id][6] = value end
        })

        Unit:property("categories", {
            get = function(self) return unitpool[self.id][7] end,
            set = function(self, value) unitpool[self.id][7] = value end
        })

        Unit:property("ratio", {
            get = function(self) return unitpool[self.id][8] end,
            set = function(self, value) unitpool[self.id][8] = value end
        })

        Unit:property("texture", {
            get = function(self) return unitpool[self.id][9] end,
            set = function(self, value) unitpool[self.id][9] = value end
        })

        Unit:property("range", {
            get = function(self) return unitpool[self.id][10] end,
            set = function(self, value) unitpool[self.id][10] = value end
        })

        Unit:property("mana", {
            get = function(self) return unitpool[self.id][11] end,
            set = function(self, value) unitpool[self.id][11] = value end
        })

        Unit:property("health", {
            get = function(self) return unitpool[self.id][12] end,
            set = function(self, value) unitpool[self.id][12] = value end
        })

        Unit:property("armor", {
            get = function(self) return unitpool[self.id][13] end,
            set = function(self, value) unitpool[self.id][13] = value end
        })

        Unit:property("damage", {
            get = function(self) return unitpool[self.id][14] end,
            set = function(self, value) unitpool[self.id][14] = value end
        })

        Unit:property("movement", {
            get = function(self) return unitpool[self.id][15] end,
            set = function(self, value) unitpool[self.id][15] = value end
        })

        Unit:property("agility", {
            get = function(self) return unitpool[self.id][16] end,
            set = function(self, value) unitpool[self.id][16] = value end
        })

        Unit:property("strength", {
            get = function(self) return unitpool[self.id][17] end,
            set = function(self, value) unitpool[self.id][17] = value end
        })

        Unit:property("intelligence", {
            get = function(self) return unitpool[self.id][18] end,
            set = function(self, value) unitpool[self.id][18] = value end
        })

        Unit:property("agilityPerLevel", {
            get = function(self) return unitpool[self.id][19] end,
            set = function(self, value) unitpool[self.id][19] = value end
        })

        Unit:property("strengthPerLevel", {
            get = function(self) return unitpool[self.id][20] end,
            set = function(self, value) unitpool[self.id][20] = value end
        })

        Unit:property("intelligencePerLevel", {
            get = function(self) return unitpool[self.id][21] end,
            set = function(self, value) unitpool[self.id][21] = value end
        })

        Unit:property("primary", {
            get = function(self) return unitpool[self.id][22] end,
            set = function(self, value) unitpool[self.id][22] = value end
        })

        Unit:property("regeneration", {
            get = function(self) return unitpool[self.id][23] end,
            set = function(self, value) unitpool[self.id][23] = value end
        })

        Unit:property("unique", {
            get = function(self) return unitpool[self.id][24] end,
            set = function(self, value) unitpool[self.id][24] = value end
        })

        Unit:property("ability", {
            get = function(self) return abilities[self.id] end,
            set = function(self, value) abilities[self.id] = value end
        })

        Unit:property("isHero", {
            get = function(self) return unitpool[self.id][25] end,
            set = function(self, value) unitpool[self.id][25] = value end
        })

        Unit:property("isMelee", {
            get = function(self) return unitpool[self.id][26] end,
            set = function(self, value) unitpool[self.id][26] = value end
        })

        Unit:property("isRanged", {
            get = function(self) return unitpool[self.id][27] end,
            set = function(self, value) unitpool[self.id][27] = value end
        })

        function Unit.get(id)
            if id and id > 0 then
                if unitpool[id] then
                    return unitpool[id][0]
                else
                    return Unit.create(id)
                end
            end

            return nil
        end

        function Unit.clear()
            local unit = GetFilterUnit()

            if GetUnitTypeId(unit) == unittype and GetOwningPlayer(unit) == player then
                unittype = 0

                RemoveUnit(unit)
            end
        end

        function Unit.register(id, a1, a2, a3, a4, a5, a6)
            local this = Unit.get(id)

            if this then
                this.ability = {}
                this.ability[0] = Ability.get(a1)
                this.ability[1] = Ability.get(a2)
                this.ability[2] = Ability.get(a3)
                this.ability[3] = Ability.get(a4)
                this.ability[4] = Ability.get(a5)
                this.ability[5] = Ability.get(a6)
            end
        end

        function Unit.cost(id, lumber)
            local unit = CreateUnit(player, id, 0, 0, 0)
            local value
            local resource

            if not IsUnitType(unit, UNIT_TYPE_HERO) then
                RemoveUnit(unit)
                unit = nil

                if lumber then
                    return GetUnitWoodCost(id)
                end

                return GetUnitGoldCost(id)
            else
                unittype = id

                if lumber then
                    resource = PLAYER_STATE_RESOURCE_LUMBER
                else
                    resource = PLAYER_STATE_RESOURCE_GOLD
                end

                AddUnitToStock(shop, id, 1, 1)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, 9999999)
                value = GetPlayerState(player, resource)
                IssueNeutralImmediateOrderById(player, shop, id)
                RemoveUnitFromStock(shop, id)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
                RemoveUnit(unit)

                return value - GetPlayerState(player, resource)
            end
        end

        function Unit.create(id)
            local this = Unit.allocate()

            if id and id > 0 and not unitpool[id] then
                local unit = CreateUnit(player, id, 0, 0, 0)

                if unit then
                    unitpool[id] = {}
                    unitpool[id][0] = this

                    this.id = id
                    this.name = GetUnitName(unit)
                    this.icon = BlzGetAbilityIcon(id)
                    this.tooltip = BlzGetAbilityExtendedTooltip(id, 0)
                    this.range = N2S(BlzGetUnitWeaponRealField(unit, UNIT_WEAPON_RF_ATTACK_RANGE, 0), 0)
                    this.mana = I2S(BlzGetUnitMaxMana(unit))
                    this.health = I2S(BlzGetUnitMaxHP(unit))
                    this.armor = N2S(BlzGetUnitArmor(unit), 1)
                    this.damage = I2S(BlzGetUnitBaseDamage(unit, 0))
                    this.movement = N2S(GetUnitMoveSpeed(unit), 0)
                    this.regeneration = "|cff00ff00" .. N2S(BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE), 2) .. "|r" .. " / |cff51e1e6" .. N2S(BlzGetUnitRealField(unit, UNIT_RF_MANA_REGENERATION), 2) .. "|r"
                    this.isHero = IsUnitType(unit, UNIT_TYPE_HERO)
                    this.isMelee = IsUnitType(unit, UNIT_TYPE_MELEE_ATTACKER)
                    this.isRanged = IsUnitType(unit, UNIT_TYPE_RANGED_ATTACKER)

                    if USE_GOLD then
                        this.gold = Unit.cost(id, false)
                    else
                        this.gold = 0
                    end

                    if USE_WOOD then
                        this.wood = Unit.cost(id, true)
                    else
                        this.wood = 0
                    end

                    if USE_FOOD then
                        this.food = GetUnitFoodUsed(unit)
                    else
                        this.food = 0
                    end

                    if this.isHero then
                        this.primary = BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)
                        this.agility = I2S(GetHeroAgi(unit, false))
                        this.strength = I2S(GetHeroStr(unit, false))
                        this.intelligence = I2S(GetHeroInt(unit, false))
                        this.agilityPerLevel = "|cff00ff00 + " .. N2S(BlzGetUnitRealField(unit, UNIT_RF_AGILITY_PER_LEVEL), 0) .. "|r"
                        this.strengthPerLevel = "|cff00ff00 + " .. N2S(BlzGetUnitRealField(unit, UNIT_RF_STRENGTH_PER_LEVEL), 0) .. "|r"
                        this.intelligencePerLevel = "|cff00ff00 + " .. N2S(BlzGetUnitRealField(unit, UNIT_RF_INTELLIGENCE_PER_LEVEL), 0) .. "|r"
                    end

                    RemoveUnit(unit)
                end
            end

            return this
        end

        function Unit.onInit()
            shop = CreateUnit(player, S2A('hpea'), 0, 0, 0)

            SetUnitUseFood(shop, false)
            UnitAddAbility(shop, S2A('Asid'))
            UnitAddAbility(shop, S2A('Asud'))
            UnitAddAbility(shop, S2A('Aloc'))
            UnitRemoveAbility(shop, S2A('Awan'))
            UnitRemoveAbility(shop, S2A('Aneu'))
            UnitRemoveAbility(shop, S2A('Ane2'))
            SetUnitAcquireRange(shop, 0)
            ShowUnit(shop, false)
            ShowUnit(CreateUnit(player, S2A('ofrt'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('hcas'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('unp2'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('etoe'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('halt'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('oalt'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('uaod'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            ShowUnit(CreateUnit(player, S2A('eate'), WorldBounds.maxX, WorldBounds.maxY, 0), false)
            SetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_CAP, 100)
            IssueNeutralTargetOrder(player, shop, "smart", shop)
            SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
            RegionAddRect(region, rect)
            TriggerRegisterEnterRegion(CreateTrigger(), region, Condition(Unit.clear))
        end
    end

    -- ----------------------------------------- Sound ----------------------------------------- --
    local Sound = Class()

    do
        local noGold = {}
        local noWood = {}
        local noFood = {}

        Sound.error_sound = CreateSound(ERROR_SOUND, false, false, false, 10, 10, "")
        Sound.success_sound = CreateSound(SUCCESS_SOUND, false, false, false, 10, 10, "")
        Sound.alert_sound = CreateSound(ALERT_SOUND, false, false, false, 10, 10, "")

        function Sound.gold(player)
            if not GetSoundIsPlaying(noGold[GetHandleId(GetPlayerRace(player))]) then
                StartSoundForPlayerBJ(player, noGold[GetHandleId(GetPlayerRace(player))])
            end
        end

        function Sound.wood(player)
            if not GetSoundIsPlaying(noWood[GetHandleId(GetPlayerRace(player))]) then
                StartSoundForPlayerBJ(player, noWood[GetHandleId(GetPlayerRace(player))])
            end
        end

        function Sound.food(player)
            if not GetSoundIsPlaying(noFood[GetHandleId(GetPlayerRace(player))]) then
                StartSoundForPlayerBJ(player, noFood[GetHandleId(GetPlayerRace(player))])
            end
        end

        function Sound.success(player)
            if not GetSoundIsPlaying(Sound.success_sound) then
                StartSoundForPlayerBJ(player, Sound.success_sound)
            end
        end

        function Sound.error(player)
            if not GetSoundIsPlaying(Sound.error_sound) then
                StartSoundForPlayerBJ(player, Sound.error_sound)
            end
        end

        function Sound.alert(player)
            if not GetSoundIsPlaying(Sound.alert_sound) then
                StartSoundForPlayerBJ(player, Sound.alert_sound)
            end
        end

        function Sound.onInit()
            local id

            SetSoundDuration(Sound.success_sound, 1600)
            SetSoundDuration(Sound.error_sound, 614)
            SetSoundDuration(Sound.alert_sound, 2500)

            id = GetHandleId(RACE_HUMAN)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldHuman")
            SetSoundDuration(noGold[id], 1618)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberHuman")
            SetSoundDuration(noWood[id], 1863)
            noFood[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoFood1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noFood[id], "NoFoodHuman")
            SetSoundDuration(noFood[id], 1503)

            id = GetHandleId(RACE_ORC)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldOrc")
            SetSoundDuration(noGold[id], 1450)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberOrc")
            SetSoundDuration(noWood[id], 1602)
            noFood[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoFood1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noFood[id], "NoFoodOrc")
            SetSoundDuration(noFood[id], 1683)

            id = GetHandleId(RACE_NIGHTELF)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldNightElf")
            SetSoundDuration(noGold[id], 1229)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberNightElf")
            SetSoundDuration(noWood[id], 1500)
            noFood[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\HuntressNoFood1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noFood[id], "NoFoodNightElf")
            SetSoundDuration(noFood[id], 1783)

            id = GetHandleId(RACE_UNDEAD)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldUndead")
            SetSoundDuration(noGold[id], 2005)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberUndead")
            SetSoundDuration(noWood[id], 1903)
            noFood[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoFood1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noFood[id], "NoFoodUndead")
            SetSoundDuration(noFood[id], 1660)

            id = GetHandleId(ConvertRace(11))
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldNaga")
            SetSoundDuration(noGold[id], 2690)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberNaga")
            SetSoundDuration(noWood[id], 1576)
            noFood[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoFood1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noFood[id], "NoFoodNaga")
            SetSoundDuration(noFood[id], 2223)
        end
    end

    -- --------------------------------------- Attribute --------------------------------------- --
    local Attribute = Class(Button)

    do
        Attribute:property("text", {
            get = function(self) return self.value.text end,
            set = function(self, value) self.value.text = value end
        })

        function Attribute:destroy()
            self.value:destroy()
        end

        function Attribute.create(texture, tooltip, parent, alignment)
            local this = Attribute.allocate(0, 0, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, parent, true, false)

            this.texture = texture
            this.tooltip.text = tooltip
            this.value = Text.create(0, 0, 0.1, ATTRIBUTES_HEIGHT, 1, false, this.frame, nil, TEXT_JUSTIFY_CENTER, alignment)

            if alignment == TEXT_JUSTIFY_LEFT then
                this.value:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            else
                this.value:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            end

            return this
        end
    end

    -- ------------------------------------------ Pick ----------------------------------------- --
    local Pick = Class(Panel)

    do
        Pick:property("unit", {
            get = function(self) return self.picked end,
            set = function(self, value)
                self.picked = value
                self.button.texture = value.icon
                self.button.tooltip.text = value.tooltip
                self.button.tooltip.name = value.name
                self.button.tooltip.icon = value.icon
                self.name.text = value.name
            end
        })

        Pick:property("text", {
            get = function(self) return self.name.text end,
            set = function(self, value) self.name.text = value end
        })

        function Pick:destroy()
            self.button:destroy()
            self.name:destroy()
        end

        function Pick.create(picker, parent, left)
            local this = Pick.allocate(0, 0, SLOT_WIDTH, SLOT_HEIGHT, parent, "Leaderboard", false)

            this.picker = picker
            this.button = Button.create(0, 0, ICON_SIZE, ICON_SIZE, this.frame, false, true)
            this.button.texture = RANDOM_ICON
            this.button.tooltip.icon = RANDOM_ICON
            array[this.button] = this

            if left then
                this.button.tooltip.point = FRAMEPOINT_TOPLEFT
                this.name = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, 1, false, this.button.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT)

                this.button:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_RIGHT, -0.006, 0)
                this.name:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            else
                this.button.tooltip.point = FRAMEPOINT_TOPRIGHT
                this.name = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, 1, false, this.button.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)

                this.button:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.006, 0)
                this.name:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            end

            return this
        end
    end

    -- ------------------------------------------ Slot ----------------------------------------- --
    local Slot = Class(Panel)

    do
        Slot:property("row", {
            get = function(self) return self._row or 0 end,
            set = function(self, value)
                self._row = value
                self.y = - (0.03 + ((SLOT_HEIGHT + SLOT_GAP_Y) * value))

                self:update()
            end
        })

        Slot:property("column", {
            get = function(self) return self._column or 0 end,
            set = function(self, value)
                self._column = value
                self.x = 0.03 + ((SLOT_WIDTH + SLOT_GAP_X) * value)

                self:update()
            end
        })

        Slot:property("filtered", {
            get = function(self) return self.filter or false end,
            set = function(self, value)
                self.filter = value
            end
        })

        Slot:property("available", {
            get = function(self) return self.button.available end,
            set = function(self, value)
                self.button.available = value
            end
        })

        function Slot:destroy()
            self.name:destroy()
            self.gold:destroy()
            self.wood:destroy()
            self.food:destroy()
            self.button:destroy()
            self.goldText:destroy()
            self.woodText:destroy()
            self.foodText:destroy()
        end

        function Slot:update()
            if self.column <= (self.picker.columns / 2) and self.row < 2 then
                self.button.tooltip.point = FRAMEPOINT_TOPLEFT
            elseif self.column >= ((self.picker.columns / 2) + 1) and self.row < 2 then
                self.button.tooltip.point = FRAMEPOINT_TOPRIGHT
            elseif self.column <= (self.picker.columns / 2) and self.row >= 2 then
                self.button.tooltip.point = FRAMEPOINT_BOTTOMLEFT
            else
                self.button.tooltip.point = FRAMEPOINT_BOTTOMRIGHT
            end
        end

        function Slot:move(row, column)
            self.row = row
            self.column = column
        end

        function Slot.create(picker, unit, x, y, parent)
            local this = Slot.allocate(x, y, SLOT_WIDTH, SLOT_HEIGHT, parent, "Leaderboard", false)

            this.x = x
            this.y = y
            this.unit = unit
            this.picker = picker
            this.next = nil
            this.prev = nil
            this.right = nil
            this.left = nil
            this.drafted = {}
            this.button = Button.create(0, 0, ICON_SIZE, ICON_SIZE, this.frame, false, true)
            this.button.tooltip.point = FRAMEPOINT_TOPRIGHT
            this.name = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.button.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.gold = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, this.name.frame, GOLD_ICON)
            this.goldText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.gold.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.wood = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, this.gold.frame, WOOD_ICON)
            this.woodText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.wood.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.food = Backdrop.create(0, 0, COST_SIZE, COST_SIZE, this.wood.frame, FOOD_ICON)
            this.foodText = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.food.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            array[this.button] = this

            this.button:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.006, 0)
            this.name:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0, 0)
            this.gold:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            this.goldText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            this.wood:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            this.woodText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
            this.food:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0, -0.003)
            this.foodText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)

            if unit then
                this.button.texture = unit.icon
                this.button.tooltip.text = unit.tooltip .. "\n\n|cffFFCC00Double or Right click to buy|r"
                this.button.tooltip.name = unit.name
                this.button.tooltip.icon = unit.icon
                this.name.text = unit.name
                this.goldText.text = "|cffFFCC00" .. I2S(unit.gold) .. "|r"
                this.woodText.text = "|cff265526" .. I2S(unit.wood) .. "|r"
                this.foodText.text = "|cff742b2b" .. I2S(unit.food) .. "|r"

                if unit.unique then
                    this.button.tooltip.text = this.button.tooltip.text .. "\n\n|cffFFCC00Unique|r"
                end
            end

            return this
        end

        function Slot:onScroll()
            if GetLocalPlayer() == GetTriggerPlayer() then
                self.picker:onScroll()
            end
        end

        function Slot:onClick()
            self.picker:detail(self.unit, GetTriggerPlayer())
        end

        function Slot:onMiddleClick()
            if GetLocalPlayer() == GetTriggerPlayer() then
                if self.button.tagged then
                    self.button:tag(nil, 0, 0, 0)
                else
                    self.button:tag(TAG_MODEL, TAG_SCALE, TAG_XOFFSET, TAG_YOFFSET)
                end
            end
        end

        function Slot:onDoubleClick()
            if self.button.active and self.button.available then
                if self.picker:buy(self.unit, GetTriggerPlayer()) then
                    self.button.active = not self.unit.unique

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        self.button:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    end
                end
            else
                Sound.error(GetTriggerPlayer())
            end
        end

        function Slot:onRightClick()
            if self.button.active and self.button.available then
                if self.picker:buy(self.unit, GetTriggerPlayer()) then
                    self.button.active = not self.unit.unique

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        self.button:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    end
                end
            else
                Sound.error(GetTriggerPlayer())
            end
        end
    end

    -- ----------------------------------------- Detail ---------------------------------------- --
    local Detail = Class(Panel)

    do
        function Detail:destroy()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    for j = 0, ABILITY_COUNT - 1 do
                        self.ability[i][j]:destroy()
                    end
                end
            end

            for i = 0, CATEGORY_COUNT - 1 do
                self.category[i]:destroy()
            end

            self.name:destroy()
            self.unit:destroy()
            self.abilities:destroy()
            self.selected:destroy()
            self.description:destroy()
            self.damage:destroy()
            self.armor:destroy()
            self.health:destroy()
            self.mana:destroy()
            self.movement:destroy()
            self.agility:destroy()
            self.strength:destroy()
            self.intelligence:destroy()
            self.range:destroy()
            self.regeneration:destroy()
        end

        function Detail:show(unit, player)
            local id = GetPlayerId(player)
            local j = 0

            if unit and player == GetLocalPlayer() then
                self.name.text = unit.name
                self.unit.texture = unit.texture
                self.unit.width = MODEL_HEIGHT * unit.ratio
                self.description.text = unit.tooltip
                self.damage.text = unit.damage
                self.armor.text = unit.armor
                self.health.text = unit.health
                self.mana.text = unit.mana
                self.movement.text = unit.movement
                self.agility.visible = unit.isHero
                self.strength.visible = unit.isHero
                self.intelligence.visible = unit.isHero
                self.range.visible = unit.isHero
                self.regeneration.visible = unit.isHero
                
                if unit.isHero then
                    self.range.text = unit.range
                    self.regeneration.text = unit.regeneration
                    self.agility.text = unit.agility .. unit.agilityPerLevel
                    self.strength.text = unit.strength .. unit.strengthPerLevel
                    self.intelligence.text = unit.intelligence .. unit.intelligencePerLevel

                    self.agility:display(nil, 0, 0, 0)
                    self.strength:display(nil, 0, 0, 0)
                    self.intelligence:display(nil, 0, 0, 0)

                    if unit.isMelee then
                        self.range.texture = MELEE_TEXTURE
                        self.range.tooltip.text = "Melee"
                    else
                        self.range.texture = RANGE_TEXTURE
                        self.range.tooltip.text = "Ranged"
                    end

                    if unit.primary == 3 then
                        self.agility:display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    elseif unit.primary == 2 then
                        self.intelligence:display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    elseif unit.primary == 1 then
                        self.strength:display(ATTRIBUTE_HIGHLIGHT, ATTRIBUTE_HIGHLIGHT_SCALE, ATTRIBUTE_HIGHLIGHT_XOFFSET, ATTRIBUTE_HIGHLIGHT_YOFFSET)
                    end
                end

                if self.selected then
                    self.selected:display(nil, 0, 0, 0)
                end

                for i = 0, ABILITY_COUNT - 1 do
                    local spell = unit.ability[i]
                    self.ability[id][i].visible = false

                    if spell then
                        self.ability[id][j].texture = spell.icon
                        self.ability[id][j].tooltip.text = spell.tooltip
                        self.ability[id][j].tooltip.name = spell.name
                        self.ability[id][j].tooltip.icon = spell.icon
                        self.ability[id][j].visible = true
                        j = j + 1
                    end
                end

                j = 0

                for i = 0, CATEGORY_COUNT - 1 do
                    self.category[i].visible = false

                    if i <= self.picker.category.count then
                        if BlzBitAnd(unit.categories, self.picker.category.value[i]) > 0 then
                            self.category[j].texture = self.picker.category.button[i].texture
                            self.category[j].tooltip.text = self.picker.category.button[i].tooltip.text
                            self.category[j].active = true
                            self.category[j].visible = true
                            j = j + 1
                        end
                    end
                end
            end
        end

        function Detail.create(picker)
            local this = Detail.allocate(0, 0, DETAIL_WIDTH, DETAIL_HEIGHT, picker.frame, "EscMenuBackdrop", false)

            this.picker = picker
            this.ability = {}
            this.category = {}
            this.name = Text.create(0, 0, NAME_WIDTH, NAME_HEIGHT, NAME_SCALE, false, this.frame, nil, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
            this.unit = Panel.create(0, 0, MODEL_HEIGHT, MODEL_HEIGHT, this.name.frame, "TransparentBackdrop", false)
            this.abilities = Panel.create(0, 0, DETAIL_WIDTH - 0.05, 0.05, this.unit.frame, "TransparentBackdrop", false)
            this.description = TextArea.create(0, 0, DESCRIPTION_WIDTH, DESCRIPTION_HEIGHT, this.abilities.frame, "DescriptionArea")
            this.damage = Attribute.create(DAMAGE_TEXTURE, "Damage", this.frame, TEXT_JUSTIFY_LEFT)
            this.armor = Attribute.create(ARMOR_TEXTURE, "Armor", this.damage.frame, TEXT_JUSTIFY_LEFT)
            this.health = Attribute.create(HEALTH_TEXTURE, "Health", this.armor.frame, TEXT_JUSTIFY_LEFT)
            this.mana = Attribute.create(MANA_TEXTURE, "Mana", this.health.frame, TEXT_JUSTIFY_LEFT)
            this.movement = Attribute.create(MOVEMENT_TEXTURE, "Movement", this.mana.frame, TEXT_JUSTIFY_LEFT)
            this.agility = Attribute.create(AGILITY_TEXTURE, "Agility", this.frame, TEXT_JUSTIFY_RIGHT)
            this.agility.visible = false
            this.strength = Attribute.create(STRENGTH_TEXTURE, "Strength", this.agility.frame, TEXT_JUSTIFY_RIGHT)
            this.strength.visible = false
            this.intelligence = Attribute.create(INTELLIGENCE_TEXTURE, "Intelligence", this.strength.frame, TEXT_JUSTIFY_RIGHT)
            this.intelligence.visible = false
            this.range = Attribute.create(RANGE_TEXTURE, "Range", this.intelligence.frame, TEXT_JUSTIFY_RIGHT)
            this.range.visible = false
            this.regeneration = Attribute.create(REGENERATION_TEXTURE, "Regeneration", this.range.frame, TEXT_JUSTIFY_RIGHT)

            this:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_RIGHT, 0, 0)
            this.name:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0, -0.0225)
            this.unit:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.abilities:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.description:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0.025, 0)
            this.damage:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.025, -0.05)
            this.armor:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.health:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.mana:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.movement:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.agility:setPoint(FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.025, -0.05)
            this.strength:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.intelligence:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.range:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.regeneration:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    this.ability[i] = {}

                    for j = 0, ABILITY_COUNT - 1 do
                        this.ability[i][j] = Button.create(0.005 + ABILITY_GAP*j, - 0.0075, ABILITY_SIZE, ABILITY_SIZE, this.abilities.frame, false, false)
                        this.ability[i][j].visible = false
                        this.ability[i][j].tooltip.point = FRAMEPOINT_TOP
                        this.ability[i][j].OnClick = Detail.onClicked
                        array[this.ability[i][j]] = { this, j }
                    end
                end
            end

            for i = 0, CATEGORY_COUNT - 1 do
                if i == 0 then
                    this.category[i] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, this.frame, true, false)
                    this.category[i]:setPoint(FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.025, 0.025)
                else
                    this.category[i] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, this.category[i - 1].frame, true, false)
                    this.category[i]:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
                end

                this.category[i].visible = false
            end

            return this
        end

        function Detail.onClicked()
            local button = GetTriggerComponent()
            local this = array[button][1]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this.description.text = button.tooltip.text

                if this.selected then
                    this.selected:display(nil, 0, 0, 0)
                end

                this.selected = button

                this.selected:display(ABILITY_HIGHLIGHT, ABILITY_HIGHLIGHT_SCALE, ABILITY_HIGHLIGHT_XOFFSET, ABILITY_HIGHLIGHT_YOFFSET)
            end
        end
    end

    -- ---------------------------------------- Category --------------------------------------- --
    local Category = Class(Panel)

    do
        function Category:destroy()
            for i = self.count, -1, -1 do
                if self.button[i] then
                    self.button[i]:destroy()
                end
            end
        end

        function Category:reset()
            self.active = 0

            for i = 0, CATEGORY_COUNT - 1 do
                if self.button[i] then
                    self.button[i].active = false
                end
            end

            self.picker:filter(self.active, self.andLogic)
        end

        function Category:add(icon, description)
            if self.count < CATEGORY_COUNT then
                self.count = self.count + 1
                self.value[self.count] = R2I(Pow(2, self.count))

                if self.count > 0 then
                    self.button[self.count] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, self.button[self.count - 1].frame, true, false)
                    self.button[self.count]:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)
                else
                    self.button[self.count] = Button.create(0, 0, CATEGORY_SIZE, CATEGORY_SIZE, self.frame, true, false)
                    self.button[self.count]:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.005, 0)
                end

                self.button[self.count].texture = icon
                self.button[self.count].active = false
                self.button[self.count].tooltip.text = description
                self.button[self.count].OnClick = Category.onClicked
                array[self.button[self.count]] = { self, self.count }

                return self.value[self.count]
            else
                print("Maximum number of categories reached.")
            end

            return 0
        end

        function Category.create(picker)
            local this = Category.allocate(0, 0, WIDTH, 0.03, picker.frame, "Leaderboard", false)

            this.count = -1
            this.active = 0
            this.value = {}
            this.button = {}
            this.picker = picker
            this.andLogic = true

            this:setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, -0.0075)

            return this
        end

        function Category.onClicked()
            local category = GetTriggerComponent()
            local this = array[category][1]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                category.active = not category.active

                if category.active then
                    this.active = this.active + this.value[array[category][2]]
                else
                    this.active = this.active - this.value[array[category][2]]
                end

                this.picker:filter(this.active, this.andLogic)
            end
        end
    end

    -- --------------------------------------- UnitPicker -------------------------------------- --
    do
        UnitPicker = Class(Panel)

        local bans = {}
        local unitpool = {}

        UnitPicker:property("visible", {
            get = function(self) return self.isVisible end,
            set = function(self, value)
                local id = GetPlayerId(GetLocalPlayer())

                self.isVisible = value or self.keepOpen

                if not self.isVisible then
                    array[id] = nil
                else
                    array[id] = self

                    if array[self][id] then
                        self:detail(array[self][id].unit, GetLocalPlayer())
                    else
                        self:detail(unitpool[self][0].unit, GetLocalPlayer())
                    end
                end

                BlzFrameSetVisible(self.frame, self.isVisible)
            end
        })

        UnitPicker:property("keepOpened", {
            get = function(self) return self.keepOpen end,
            set = function(self, value)
                self.keepOpen = value

                if not self.visible and self.keepOpen then
                    self.visible = true
                end
            end
        })

        function UnitPicker:destroy()
            local slot = unitpool[self][0]

            while slot do
                slot:destroy()
                slot = slot.next
            end

            for i = 0, MAX_PICKS_SHOWED - 1 do
                if self.pick[i] then
                    self.pick[i]:destroy()
                end
            end

            self.ban:destroy()
            self.edit:destroy()
            self.close:destroy()
            self.clear:destroy()
            self.logic:destroy()
            self.banText:destroy()
            self.details:destroy()
            self.category:destroy()
        end

        function UnitPicker:buy(unit, player)
            local id = GetPlayerId(player)
            local cap = GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_CAP)
            local gold = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
            local lumber = GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
            local food = cap - GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_USED)
            local new

            if unit.gold <= gold and unit.wood <= lumber and (unit.food <= food or cap == 0) and not self.ban.visible then
                new = CreateUnit(player, unit.id, self.spawnX, self.spawnY, 0)

                if new then
                    SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, gold - unit.gold)
                    SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, lumber - unit.wood)
                    Sound.success(player)

                    if self.showPicks and self.pick[id] then
                        self.pick[id].unit = unit
                    end
                else
                    Sound.error(player)
                    return false
                end

                return true
            else
                if self.ban.visible then
                    Sound.error(player)
                else
                    if unit.gold > gold then
                        Sound.gold(player)
                    elseif unit.wood > lumber then
                        Sound.wood(player)
                    elseif unit.food > food and cap ~= 0 then
                        Sound.food(player)
                    else
                        Sound.error(player)
                    end
                end

                return false
            end

            return false
        end

        function UnitPicker:scroll(down)
            local slot = self.first

            if (down and self.tail ~= self.last and not self.last.visible) or (not down and self.head ~= self.first) then
                while slot do
                    if down then
                        slot:move(slot.row - 1, slot.column)
                    else
                        slot:move(slot.row + 1, slot.column)
                    end

                    slot.visible = slot.row >= 0 and slot.row <= self.rows - 1 and slot.column >= 0 and slot.column <= self.columns - 1 and slot.filtered

                    if slot.row == 0 and slot.column == 0 then
                        self.head = slot
                    end

                    if (slot.row == self.rows - 1 and slot.column == self.columns - 1) or (slot == self.last and slot.visible) then
                        self.tail = slot
                    end

                    slot = slot.right
                end

                return true
            end

            return false
        end

        function UnitPicker:scrollTo(unit, player)
            if unit and player == GetLocalPlayer() then
                local slot = array[self][unit.id]

                repeat until slot.visible or not self:scroll(true)
            end
        end

        function UnitPicker:random(player)
            local j = GetRandomInt(0, self.index)
            local id = GetPlayerId(player)
            local slot = unitpool[self][j]

            if self.index >= 0 and slot then
                for i = 0, self.index do
                    if slot.available and slot.button.active and slot.drafted[id] then
                        if self:buy(slot.unit, player) then
                            slot.button.active = not slot.unit.unique

                            SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + R2I(slot.unit.gold * self.discount))
                            SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER) - R2I(slot.unit.wood * self.discount))
                        else
                            Sound.error(player)
                        end

                        break
                    end

                    j = ModuloInteger(j + 1, self.index)
                    slot = unitpool[self][j]
                end
            end
        end

        function UnitPicker:draft()
            local k
            local slot
            local used = {}
            local tries = 0
            local reused = false

            if self.drafts > 0 and self.drafts < self.index then
                for i = 0, bj_MAX_PLAYER_SLOTS do
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        for j = 0, self.drafts - 1 do
                            tries = 0
                            k = GetRandomInt(0, self.index)
                            slot = unitpool[self][k]

                            while tries <= self.index do
                                if slot and not used[slot] then
                                    used[slot] = 1
                                    slot.drafted[i] = true

                                    if reused then
                                        slot.unit.unique = false
                                    end

                                    break
                                end

                                k = ModuloInteger(k + 1, self.index)
                                slot = unitpool[self][k]
                                tries = tries + 1
                            end

                            if tries > self.index then
                                reused = true
                                used = {}
                            end
                        end
                    end
                end
            end

            used = nil
            self.category:reset()
        end

        function UnitPicker:filter(categories, andLogic)
            local slot = unitpool[self][0]
            local process
            local i = -1

            self.size = 0
            self.first = nil
            self.last = nil
            self.head = nil
            self.tail = nil

            while slot do
                if andLogic then
                    process = categories == 0 or BlzBitAnd(slot.unit.categories, categories) >= categories
                else
                    process = categories == 0 or BlzBitAnd(slot.unit.categories, categories) > 0
                end

                if self.edit.text ~= "" and self.edit.text ~= nil then
                    process = process and self:find(StringCase(slot.unit.name, false), StringCase(self.edit.text, false))
                end

                process = process and (slot.drafted[GetPlayerId(GetLocalPlayer())] or self.banCount > 0)
                slot.filtered = process

                if process then
                    i = i + 1
                    self.size = self.size + 1
                    slot:move(R2I(i/self.columns), ModuloInteger(i, self.columns))
                    slot.visible = slot.row >= 0 and slot.row <= self.rows - 1 and slot.column >= 0 and slot.column <= self.columns - 1

                    if i > 0 then
                        slot.left = self.last
                        self.last.right = slot
                    else
                        self.first = slot
                        self.head = self.first
                    end

                    if slot.visible then
                        self.tail = slot
                    end

                    self.last = slot
                else
                    slot.visible = false
                end

                slot = slot.next
            end
        end

        function UnitPicker:select(unit, player)
            local id = GetPlayerId(player)

            if unit then
                if GetLocalPlayer() == player and array[self][id] then
                    array[self][id].button:display(nil, 0, 0, 0)
                end

                array[self][id] = array[self][unit.id]

                if GetLocalPlayer() == player then
                    array[self][id].button:display(ITEM_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                end
            end
        end

        function UnitPicker:detail(unit, player)
            if unit then
                self:select(unit, player)
                self.details:show(unit, player)
            else
                if GetLocalPlayer() == player then
                    self:filter(self.category.active, self.category.andLogic)
                    self:scrollTo(array[self][GetPlayerId(player)].unit, player)
                end
            end
        end

        function UnitPicker:find(source, target)
            local sourceLength = StringLength(source)
            local targetLength = StringLength(target)
            local i = 0

            if targetLength <= sourceLength then
                while i <= sourceLength - targetLength do
                    if SubString(source, i, i + targetLength) == target then
                        return true
                    end

                    i = i + 1
                end
            end

            return false
        end

        function UnitPicker:addCategory(icon, description)
            return self.category:add(icon, description)
        end

        function UnitPicker:add(id, unique, texture, ratio, categories)
            local slot

            if not array[self][id] then
                local unit = Unit.get(id)

                if unit then
                    self.size = self.size + 1
                    self.index = self.index + 1
                    unit.ratio = ratio
                    unit.unique = unique
                    unit.texture = texture
                    unit.categories = categories or 0
                    slot = Slot.create(self, unit, 0, 0, self.frame)
                    slot.row = R2I(self.index/COLUMNS)
                    slot.column = ModuloInteger(self.index, COLUMNS)
                    slot.filtered = true
                    slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1

                    if self.index > 0 then
                        slot.prev = self.last
                        slot.left = self.last
                        self.last.next = slot
                        self.last.right = slot
                    else
                        self.first = slot
                        self.head = slot
                    end

                    if slot.visible then
                        self.tail = slot
                    end

                    for i = 0, bj_MAX_PLAYER_SLOTS do
                        slot.drafted[i] = not (self.drafts > 0)
                    end

                    self.last = slot
                    array[self][id] = slot
                    unitpool[self][self.index] = slot
                else
                    print("Invalid unit code: " .. A2S(id))
                end
            else
                print("The unit " .. GetObjectName(id) .. " is already registered for the instance " .. tostring(self))
            end
        end

        function UnitPicker.create(spawnX, spawnY, randomDiscount, bansPerPlayer, banTimeout, draftCount, showPicks)
            local this = UnitPicker.allocate(X, Y, WIDTH, HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0), "EscMenuBackdrop", false)

            this.spawnX = spawnX
            this.spawnY = spawnY
            this.first = nil
            this.last = nil
            this.head = nil
            this.tail = nil
            this.size = 0
            this.left = true
            this.index = -1
            this.banCount = 0
            this.drafts = draftCount
            this.timeout = banTimeout
            this.keepOpen = false
            this.showPicks = showPicks
            this.discount = randomDiscount
            this.rows = ROWS
            this.columns = COLUMNS
            this.pick = {}
            this.scrolls = {}
            this.details = Detail.create(this)
            this.category = Category.create(this)
            this.ban = Component.create(0, 0, 0.1, 0.03, this.frame, "ComponentFrame", "ScriptDialogButton", false)
            this.ban.visible = bansPerPlayer > 0
            this.ban.OnClick = UnitPicker.onBan
            this.banText = Text.create(0, 0, this.ban.width, this.ban.height, 1, false, this.ban.frame, "Ban (" .. I2S(bansPerPlayer) .. "): " .. N2S(this.timeout, 0), TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            this.close = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
            this.close.texture = CLOSE_ICON
            this.close.tooltip.text = "Close"
            this.close.OnClick = UnitPicker.onClose
            this.clear = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.close.frame, true, false)
            this.clear.texture = CLEAR_ICON
            this.clear.tooltip.text = "Clear"
            this.clear.OnClick = UnitPicker.onClear
            this.logic = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.clear.frame, true, false)
            this.logic.texture = LOGIC_ICON
            this.logic.active = false
            this.logic.tooltip.text = "AND"
            this.logic.OnClick = UnitPicker.onLogic
            this.randomize = Button.create(0, 0, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.logic.frame, true, false)
            this.randomize.texture = RANDOM_ICON
            this.randomize.tooltip.text = "Random (" .. I2S(R2I(this.discount * 100)) .. "% Discount)"
            this.randomize.OnClick = UnitPicker.onRandom
            this.edit = EditBox.create(0, 0, EDIT_WIDTH, EDIT_HEIGHT, this.randomize.frame, "EscMenuEditBoxTemplate")
            this.edit.OnText = UnitPicker.onSearch

            array[this] = {}
            unitpool[this] = {}
            array[this.ban] = this
            array[this.edit] = this
            array[this.close] = this
            array[this.clear] = this
            array[this.logic] = this
            array[this.randomize] = this

            this.ban:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0.007)
            this.banText:setPoint(FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0, 0)
            this.close:setPoint(FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_TOPRIGHT, -0.005, -0.0025)
            this.clear:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            this.logic:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            this.randomize:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)
            this.edit:setPoint(FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0, 0)

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    this.scrolls[i] = {}
                end
            end

            if bansPerPlayer > 0 then
                for i = 0, bj_MAX_PLAYER_SLOTS do
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                        bans[i] = bansPerPlayer
                        this.banCount = this.banCount + bansPerPlayer
                    end
                end

                TimerStart(CreateTimer(), 1, true, function()
                    this.timeout = this.timeout - 1
                    this.banText.text = "Ban (" .. I2S(bans[GetPlayerId(GetLocalPlayer())]) .. "): " .. N2S(this.timeout, 0)

                    if this.banCount <= 0 or this.timeout <= 0 then
                        this.banCount = 0
                        this.ban.visible = false

                        this:draft()
                        Sound.alert(GetLocalPlayer())
                        PauseTimer(GetExpiredTimer())
                        DestroyTimer(GetExpiredTimer())
                    end
                end)
            else
                if this.drafts > 0 then
                    TimerStart(CreateTimer(), 1, false, function()
                        this:draft()
                        DestroyTimer(GetExpiredTimer())
                    end)
                end
            end

            if showPicks then
                for i = 0, MAX_PICKS_SHOWED - 1 do
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                        this.pick[i] = Pick.create(this, this.frame, this.left)
                        this.pick[i].text = GetPlayerName(Player(i))

                        if this.left then
                            this.pick[i]:setPoint(FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT, 0.005, -0.03 - R2I(i/2)*(SLOT_HEIGHT + SLOT_GAP_Y))
                        else
                            this.pick[i]:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, -0.005, -0.03 - R2I(i/2)*(SLOT_HEIGHT + SLOT_GAP_Y))
                        end

                        this.left = not this.left
                    end
                end
            end

            this.visible = false

            return this
        end

        function UnitPicker:onScroll()
            local id = GetPlayerId(GetTriggerPlayer())
            local direction = R2I(BlzGetTriggerFrameValue())

            if (self.scrolls[id][0] or 0) ~= direction then
                self.scrolls[id][0] = direction
                self.scrolls[id][1] = 0
            else
                self.scrolls[id][1] = (self.scrolls[id][1] or 0) + 1
            end

            if GetLocalPlayer() == GetTriggerPlayer() then
                if self.scrolls[id][1] == 1 and SCROLL_DELAY > 0 then
                    self:scroll(direction < 0)
                elseif SCROLL_DELAY <= 0 then
                    self:scroll(direction < 0)
                end
            end
        end

        function UnitPicker.onBan()
            local this = array[GetTriggerComponent()]
            local id = GetPlayerId(GetTriggerPlayer())

            if this then
                local slot = array[this][id]

                if slot and bans[id] > 0 then
                    if slot.available then
                        slot.available = false
                        bans[id] = bans[id] - 1
                        this.banCount = this.banCount - 1
                    else
                        Sound.error(GetTriggerPlayer())
                    end
                else
                    Sound.error(GetTriggerPlayer())
                end
            end
        end

        function UnitPicker.onExpire()
            local id = GetPlayerId(GetLocalPlayer())
            local this = array[id]

            if this then
                this.scrolls[id][1] = (this.scrolls[id][1] or 0) - 1

                if this.scrolls[id][1] > 0 then
                    this:scroll((this.scrolls[id][0] or 0) < 0)
                else
                    this.scrolls[id][1] = 0
                end
            end
        end

        function UnitPicker.onSearch()
            local this = array[GetTriggerEditBox()]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this:filter(this.category.active, this.category.andLogic)
            end
        end

        function UnitPicker.onClose()
            local this = array[GetTriggerComponent()]

            if this then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    this.visible = false
                end
            end
        end

        function UnitPicker.onClear()
            local this = array[GetTriggerComponent()]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this.category:reset()
            end
        end

        function UnitPicker.onLogic()
            local this = array[GetTriggerComponent()]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this.logic.active = not this.logic.active
                this.category.andLogic = not this.category.andLogic

                if this.category.andLogic then
                    this.logic.tooltip.text = "AND"
                else
                    this.logic.tooltip.text = "OR"
                end

                this:filter(this.category.active, this.category.andLogic)
            end
        end

        function UnitPicker.onRandom()
            local this = array[GetTriggerComponent()]

            if this then
                this:random(GetTriggerPlayer())
            end
        end

        function UnitPicker.onEsc()
            local this = array[GetPlayerId(GetTriggerPlayer())]

            if this then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    this.visible = false
                end
            end
        end

        function UnitPicker.onInit()
            local trigger = CreateTrigger()

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    TriggerRegisterPlayerEventEndCinematic(trigger, Player(i))
                end
            end

            if SCROLL_DELAY > 0 then
                TimerStart(CreateTimer(), SCROLL_DELAY, true, UnitPicker.onExpire)
            end

            TriggerAddCondition(trigger, Condition(UnitPicker.onEsc))
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function CreateUnitPicker(spawnX, spawnY, randomDiscount, bansPerPlayer, banTimeout, draftCount, showPicks)
        return UnitPicker.create(spawnX, spawnY, randomDiscount, bansPerPlayer, banTimeout, draftCount, showPicks)
    end
    
    function UnitPickerAddCategory(picker, icon, description)
        return picker:addCategory(icon, description)
    end

    function UnitPickerAddUnit(picker, id, unique, texture, ratio, categories)
        picker:add(id, unique, texture, ratio, categories)
    end

    function UnitPickerRegisterUnit(id, a1, a2, a3, a4, a5, a6)
        Unit.register(id, a1, a2, a3, a4, a5, a6)
    end

    function ShowUnitPicker(picker, player, flag)
        if picker and GetLocalPlayer() == player then
            picker.visible = flag
        end
    end

    function UnitPickerKeepOpened(picker, player, flag)
        if picker and GetLocalPlayer() == player then
            picker.keepOpened = flag
        end
    end
end)
