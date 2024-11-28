--[[ FelBeam requires Missiles, SpellEffectEvent, NewBonus, Utilities
    /* ----------------------- Fel Beam v1.4 by Chopinski ----------------------- */
    // Credits:
    //     BPower    - Missile Library
    //     Bribe     - SpellEffectEvent
    //     AZ        - Fel Beam model
    //     nGy       - Haunt model
    //     The Panda - ToxicBeam icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Rain of Fel Fire ability
    FelBeam_ABILITY     = FourCC('A001')
    -- The beam inicial z offset
    local START_HEIGHT  = 60
    -- The beam final z offset
    local END_HEIGHT    = 60
    -- The landing time of the falling misisle
    local LANDING_TIME  = 1.5
    -- The impact radius of the missile that will damage units.
    local IMPACT_RADIUS = 120.
    -- The missile model
    local MISSILE_MODEL = "Fel_Beam.mdx"
    -- The size of the fel beam
    local MISSILE_SCALE = 0.5
    -- The beam missile speed
    local MISSILE_SPEED = 1250
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE   = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC
    -- The curse model
    local CURSE_MODEL   = "FelCurse.mdx"
    -- The curse attachment point
    local CURSE_ATTACH  = "chest"

    -- The search range of units after a cursed unit dies
    local function GetSearchRange(level)
        return 1000. + 0.*level
    end
    
    -- The damage amount
    local function GetDamage(level)
        return 50. * (level*level -2*level + 2)
    end

    -- The amount of armor reduced
    function FelBeam_GetArmorReduction(level)
        return level + 1
    end

    -- How long the curse lasts
    function FelBeam_GetCurseDuration(level)
        return 15. + 0.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Curse = setmetatable({}, {})
    local mt = getmetatable(Curse)
    mt.__index = mt
    
    Curse.cursed = {}
    local timer = CreateTimer()
    local array = {}
    local n = {}
    local key = 0
    
    function mt:destroy(i)
        DestroyEffect(self.effect)
        AddUnitBonus(self.unit, BONUS_ARMOR, self.armor)

        array[i] = array[key]
        key = key - 1
        Curse.cursed[self.unit] = nil
        n[self.unit] = nil
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:create(unit, duration, armor)
        local this

        if n[unit] then
            this = n[unit]
        else
            this = {}
            setmetatable(this, mt)
            
            this.unit = unit
            this.armor = armor
            this.effect = AddSpecialEffectTarget(CURSE_MODEL, unit, CURSE_ATTACH)
            key = key + 1
            array[key] = this
            n[unit] = this

            AddUnitBonus(unit, BONUS_ARMOR, -armor)
            if key == 1 then
                TimerStart(timer, 0.5, true, function()
                    local i = 1
                    
                    while i <= key do
                        local this = array[i]
                        
                        if this.ticks <= 0 or not UnitAlive(this.unit) then
                            i = this:destroy(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
        this.ticks = duration/0.5
    end
    
    FelBeam = setmetatable({}, {})
    local mt = getmetatable(FelBeam)
    mt.__index = mt
    
    FelBeam.source = {}
    
    function mt:launch(this, source, target, level)
        this.source = source
        this.target = target
        this:model(MISSILE_MODEL)
        this:scale(MISSILE_SCALE)
        this:speed(MISSILE_SPEED)
        this.damage = GetDamage(level)
        this.owner = GetOwningPlayer(source)
        this.armor = FelBeam_GetArmorReduction(level)
        this.curse_duration = FelBeam_GetCurseDuration(level)
        self.source[target] = source

        this.onFinish = function()
            if UnitAlive(this.target) then
                Curse.cursed[this.target] = true
                if UnitDamageTarget(this.source, this.target, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                    Curse:create(this.target, this.curse_duration, this.armor)
                end
            end

            return true
        end

        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(FelBeam_ABILITY, function()
            local this = Missiles:create(Spell.source.x, Spell.source.y, START_HEIGHT, Spell.target.x, Spell.target.y, END_HEIGHT)
            
            FelBeam:launch(this, Spell.source.unit, Spell.target.unit, Spell.level)
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()
            local caster = FelBeam.source[unit]
        
            if Curse.cursed[unit] then
                local level
                
                if not FelBeam.source[unit] then
                    caster = GetKillingUnit()
                    level  = 1
                else
                    level = GetUnitAbilityLevel(caster, FelBeam_ABILITY)
                end
        
                local x = GetUnitX(unit)
                local y = GetUnitY(unit)
                local z = GetUnitZ(unit)
                local group = GetEnemyUnitsInRange(GetOwningPlayer(caster), x, y, GetSearchRange(level), false, false)
                if BlzGroupGetSize(group) > 0 then
                    local u = GroupPickRandomUnitEx(group)
                    local this = Missiles:create(x, y, z, GetUnitX(u), GetUnitY(u), END_HEIGHT)
                    FelBeam:launch(this, caster, u, level)
                end
                DestroyGroup(group)
                FelBeam.source[unit] = nil
                Curse.cursed[unit] = nil
            end
        end)
    end)
end