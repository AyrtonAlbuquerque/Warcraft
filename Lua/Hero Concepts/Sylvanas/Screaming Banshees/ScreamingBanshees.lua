--[[ requires SpellEffectEvent, NewBonusUtils, Missiles, Utilities
    /* ------------------ Screaming Banshees v1.2 by Chopinski ------------------ */
    // Credits:
    //     Bribe        - SpellEffectEvent
    //     4eNNightmare - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Screaming Banshees ability
    local ABILITY       = FourCC('A00I')
    -- The raw code of the Screaming Banshees Teleport ability
    local TELEPORT      = FourCC('A00J')
    -- The missile model
    local MISSILE_MODEL = "Abilities\\Spells\\Undead\\Possession\\PossessionTarget.mdl"
    -- The missile size
    local MISSILE_SCALE = 1.25
    -- The missile speed
    local MISSILE_SPEED = 750.
    -- The hit model
    local HIT_MODEL     = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
    -- The attachment point
    local ATTACH_POINT  = "origin"

    -- The misisle max distance
    local function GetDistance(level)
        return 800. + 100.*level
    end

    -- The armor reductoin duration
    local function GetDuration(level)
        return 10. + 0.*level
    end

    -- The amount of armor reduced when passing through units
    local function GetArmorReduction(level)
        return 2 + 2*level
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 100. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local n = {}
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local a = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local r = GetDistance(Spell.level)
            local this = Missiles:create(Spell.source.x, Spell.source.y, 50, Spell.source.x + r*Cos(a), Spell.source.y + r*Sin(a), 50)

            this.source = Spell.source.unit
            this.owner = Spell.source.player
            this:speed(MISSILE_SPEED)
            this:model(MISSILE_MODEL)
            this:scale(MISSILE_SCALE)
            this.collision = GetCollisionSize(Spell.level)
            this.armor = GetArmorReduction(Spell.level)
            this.dur = GetDuration(Spell.level)
            this.finish = false
            n[this.source] = this

            UnitAddAbility(Spell.source.unit, TELEPORT)
            BlzUnitHideAbility(Spell.source.unit, ABILITY, true)
            
            this.onPeriod = function()
                return this.finish
            end
            
            this.onHit = function(unit)
                if Filtered(this.owner, unit) then
                    DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, unit, ATTACH_POINT))
                    AddUnitBonusTimed(unit, BONUS_ARMOR, -this.armor, this.dur)
                end

                return false
            end
            
            this.onRemove = function()
                UnitRemoveAbility(this.source, TELEPORT)
                BlzUnitHideAbility(this.source, ABILITY, false)
            end
            
            this:launch()
        end)
        
        RegisterSpellEffectEvent(TELEPORT, function()
            local this

            if n[Spell.source.unit] then
                local this = n[Spell.source.unit]
                SetUnitX(Spell.source.unit, this.x)
                SetUnitY(Spell.source.unit, this.y)
                this.finish = true
                n[Spell.source.unit] = nil
            end
        end)
    end)
end