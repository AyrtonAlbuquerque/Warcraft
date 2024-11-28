--[[ requires RegisterPlayerUnitEvent, Utilities
    /* -------------------- Yulon Blessing v1.1 by Chopinski -------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Palaslayer     - icon
    //     AZ             - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY          = FourCC('A004')
    -- The Model
    local MODEL            = "DragonBless.mdl"
    -- The model in the caster
    local CASTER_MODEL     = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
    -- The attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end
    
    -- The percentage of health converted per level
    local function GetPercentage(level)
        return 0.02 + 0.*level
    end
    
    -- The minimum health percentage allowed for a conversion to occur
    local function GetMinHealthPercentage(level)
        return 10. + 0.*level
    end
    
    -- The ability period
    local function GetPeriod(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The Unit Filter.
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitAlly(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    YulonBlessing = setmetatable({}, {})
    local mt = getmetatable(YulonBlessing)
    mt.__index = mt
    
    local array = {}
    local active = {}
    
    function mt:execute()
        local level = GetUnitAbilityLevel(self.unit, ABILITY)
        
        if GetUnitLifePercent(self.unit) >= GetMinHealthPercentage(level) and UnitAlive(self.unit) then
            local amount = BlzGetUnitMaxHP(self.unit)*GetPercentage(level)
            
            DestroyEffectTimed(AddSpecialEffectTarget(CASTER_MODEL, self.unit, ATTACH_POINT), 1)
            SetWidgetLife(self.unit, GetWidgetLife(self.unit) - amount)
            AddUnitMana(self.unit, amount)
            GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.unit, level), nil)
            GroupRemoveUnit(self.group, self.unit)
            for i = 0, BlzGroupGetSize(self.group) - 1 do
                local unit = BlzGroupUnitAt(self.group, i)
                if UnitFilter(self.player, unit) then
                    DestroyEffect(AddSpecialEffectTarget(MODEL, unit, ATTACH_POINT))
                    SetWidgetLife(unit, GetWidgetLife(unit) + amount)
                    AddUnitMana(unit, amount)
                end
            end
        else
            IssueImmediateOrderById(self.unit, 852544)
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
            local order = GetIssuedOrderId()
            local this
        
            if order == 852543 or order == 852544 then
                local unit = GetOrderedUnit()
                active[unit] = order == 852543
                
                if array[unit] then
                    this = array[unit]
                else
                    this = {}
                    setmetatable(this, mt)
                    
                    this.timer = CreateTimer()
                    this.unit = unit
                    this.group = CreateGroup()
                    this.player = GetOwningPlayer(unit)
                    array[unit] = this
                end
                
                if active[unit] then
                    TimerStart(this.timer, GetPeriod(unit, GetUnitAbilityLevel(unit, ABILITY)), true, function()
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)
                        
                        if level > 0 then
                            if active[this.unit] then
                                this:execute()
                            end
                        else
                            PauseTimer(this.timer)
                            DestroyTimer(this.timer)
                            DestroyGroup(this.group)
                            
                            array[this.unit] = nil
                            this = nil
                        end
                    end)
                else
                    PauseTimer(this.timer)
                end
            end
        end)
        
        RegisterSpellEffectEvent(ABILITY, function()
            local this
            
            if array[Spell.source.unit] then
                this = array[Spell.source.unit]
            else
                this = {}
                setmetatable(this, mt)
                
                this.timer = CreateTimer()
                this.unit = Spell.source.unit
                this.group = CreateGroup()
                this.player = Spell.source.player
                array[this.unit] = this
            end
            this:execute()
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            if GetLearnedSkill() == ABILITY then
                local unit = GetTriggerUnit()

                if active[unit] then
                    IssueImmediateOrderById(unit, 852544)
                    IssueImmediateOrderById(unit, 852543)
                end
            end
        end)
    end)
end