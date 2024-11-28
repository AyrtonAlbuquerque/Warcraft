--[[ requires SpellEffectEvent, PluginSpellEffect, Missiles
    /* -------------------------- Zap v1.2 by Chopinski ------------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Zap ability
    Zap_ABILITY        = FourCC('A008')
    -- The Zap model
    local MODEL        = "ZapMissile.mdl"
    -- The Zap scale
    local SCALE        = 1.
    -- The Zap Missile speed
    local SPEED        = 2000.
    -- The Zap Missile heigth
    local HEIGHT       = 150.
    -- The Zap Missile damage model
    local IMPACT_MODEL = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
    -- The Zap Missile damage model attach point
    local ATTACH       = "origin"

    -- The Zap missile collision
    local function GetCollision(level)
        return 150. + 0.*level
    end

    -- The Zap damage
    local function GetDamage(level)
        return 150.*level
    end

    -- The Zap mana drain per second
    local function GetManaDrain(level)
        return 100.*level
    end

    -- The Zap Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Zap = setmetatable({}, {})
    local mt = getmetatable(Zap)
    mt.__index = mt
    
    function mt:onCast()
        local this = Missiles:create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, HEIGHT)

        this:model(MODEL)
        this:scale(SCALE)
        this:speed(SPEED)
        this.source = Spell.source.unit
        this.owner = Spell.source.player
        this.damage = GetDamage(Spell.level)
        this.collision = GetCollision(Spell.level)
        this.mana = GetManaDrain(Spell.level)*0.025

        this.onPeriod = function()
            local hasMana = this.mana <= GetUnitState(this.source, UNIT_STATE_MANA)

            if hasMana then
                AddUnitMana(this.source, -this.mana)
            end

            return not hasMana
        end
        
        this.onHit = function(unit)
            if DamageFilter(this.owner, unit) then
                UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, nil)
                DestroyEffect(AddSpecialEffectTarget(IMPACT_MODEL, unit, ATTACH))
            end

            return false
        end
        
        this.onRemove = function()
            SetUnitX(this.source, this.x)
            SetUnitY(this.source, this.y)
            BlzPauseUnitEx(this.source, false)
            ShowUnit(this.source, true)
            SelectUnitAddForPlayer(this.source, this.owner)
        end


        BlzPauseUnitEx(Spell.source.unit, true)
        ShowUnit(Spell.source.unit, false)
        
        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(Zap_ABILITY, function()
           Zap:onCast() 
        end)
    end)
end