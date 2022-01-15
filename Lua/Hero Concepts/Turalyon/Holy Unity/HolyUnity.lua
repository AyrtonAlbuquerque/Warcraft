--[[ requires RegisterPlayerUnitEvent
    /* ---------------------- Holy unity v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     KelThuzad      - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Holy Unity Ability
    local ABILITY       = FourCC('A008')
    -- The raw code of the Turalyon unit in the editor
    local TURALYON_ID   = FourCC('H000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Turalyon will gain Holy Unity at this level 
    local GAIN_AT_LEVEL = 20
    -- The Holy Unity update period
    local PERIOD        = 0.3

    -- The Holy Unity AoE
    local function GetAoE(unit, level)
        return 500. + 0.*level
    end

    -- The Holy Unity bonus per unit type
    local function GetBonus(unit, level)
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5 + 0*level
        else
            return 2 + 0*level
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    HolyUnity = setmetatable({}, {})
    local mt = getmetatable(HolyUnity)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local key = 0
    
    function mt:destroy(i)
        DestroyGroup(self.group)

        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:onLevelUp()
        if GAIN_AT_LEVEL > 0 then
            local unit = GetTriggerUnit()
            if GetUnitTypeId(unit) == TURALYON_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                local this = {}
                setmetatable(this, mt)
                
                this.unit = unit
                this.group = CreateGroup()
                this.player = GetOwningPlayer(unit)
                key = key + 1
                array[key] = this

                UnitAddAbility(unit, ABILITY)
                UnitMakeAbilityPermanent(unit, true, ABILITY)
                this.ability = BlzGetUnitAbility(unit, ABILITY)

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                        
                        while i <= key do
                            local this = array[i]
                            local level = GetUnitAbilityLevel(this.unit, ABILITY)
                            local bonus = 0

                            if level > 0 then
                                GroupEnumUnitsInRange(this.group, GetUnitX(this.unit), GetUnitY(this.unit), GetAoE(this.unit, level), nil)
                                GroupRemoveUnit(this.group, this.unit)
                                for j = 0, BlzGroupGetSize(this.group) - 1 do
                                    local u = BlzGroupUnitAt(this.group, j)
                                    if UnitAlive(u) and IsUnitAlly(u, this.player) then
                                        bonus = bonus + GetBonus(u, level)
                                    end
                                end
                                BlzSetAbilityIntegerLevelField(this.ability, ABILITY_ILF_STRENGTH_BONUS_ISTR, level - 1, bonus)
                                IncUnitAbilityLevel(this.unit, ABILITY)
                                DecUnitAbilityLevel(this.unit, ABILITY)
                            else
                                i = this:destroy(i)
                            end
                            i = i + 1
                        end
                    end)
                end
            end
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            HolyUnity:onLevelUp()
        end)
    end)
end