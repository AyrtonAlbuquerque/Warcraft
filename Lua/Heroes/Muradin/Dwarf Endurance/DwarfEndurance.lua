--[[ requires RegisterPlayerUnitEvent, DamageInterface
    /* -------------------- Dwarf Endurance v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Magtheridon96  - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Dwarf Endurance ability
    local ABILITY        = FourCC('A007')
    -- The period at which health is restored
    local PERIOD         = 0.1
    -- The model used
    local HEAL_EFFECT    = "GreenHeal.mdl"
    -- The attachment point
    local ATTACH_POINT   = "origin"

    -- The time necessary for muradin to not take damage until the ability activates
    local function GetCooldown()
        return 4.
    end

    -- The heal per second
    local function GetHeal(level)
        return 25. + 25.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    DwarfEndurance = setmetatable({}, {})
    local mt = getmetatable(DwarfEndurance)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local n = {}
    local key = 0
    
    function mt:destroy(i)
        DestroyEffect(self.effect)

        array[i] = array[key]
        key = key - 1
        n[self.unit] = nil
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:onLevelUp()
        local unit = GetTriggerUnit()
    
        if GetLearnedSkill() == ABILITY and not n[unit] then
            local this = {}
            setmetatable(this, mt)
            
            this.unit = unit
            this.effect = AddSpecialEffectTarget(HEAL_EFFECT, unit, ATTACH_POINT)
            this.count = 0
            key = key + 1
            array[key] = this
            n[unit] = this

            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    
                    while i <= key do
                        local this = array[i]
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)
                        
                        if level > 0 then
                            if this.count <= 0 then
                                if UnitAlive(this.unit) then
                                    SetWidgetLife(this.unit, GetWidgetLife(this.unit) + GetHeal(level)*PERIOD)
                                end
                            else
                                this.count = this.count - 1
                                if this.effect then
                                    DestroyEffect(this.effect)
                                    this.effect = nil
                                end

                                if this.count <= 0 then
                                    this.effect = AddSpecialEffectTarget(HEAL_EFFECT, this.unit, ATTACH_POINT)
                                end
                            end
                        else
                            i = this:destroy(i)
                        end
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    onInit(function()
        RegisterAnyDamageEvent(function()
            if GetUnitAbilityLevel(Damage.target.unit, ABILITY) > 0 then
                if n[Damage.target.unit] then
                    this = n[Damage.target.unit]
                    this.count = R2I(GetCooldown()/PERIOD)
                end
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            DwarfEndurance:onLevelUp()
        end)
    end)
end