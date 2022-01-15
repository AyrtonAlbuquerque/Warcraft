--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Missiles, TimedHandles, Utilities, optional Sulfuras, Afterburner
    /* -------------------- Sulfuras Smash v1.5 by Chopinski -------------------- */
    // Credtis:
    //     Systemfre1       - Sulfuras model
    //     AZ               - crack model
    //     Blizzard         - icon (edited by me)
    //     Magtheridon96    - RegisterPlayerUnitEvent 
    //     Bribe            - SpellEffectEvent, UnitIndexer
    //     TriggerHappy     - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Sulfuras Smash ability
    local ABILITY             = FourCC('A005')
    -- The landing time of the falling sulfuras
    local LANDING_TIME        = 1.25
    -- The distance from the casting point from 
    -- where the sulfuras spawns
    local LAUNCH_OFFSET       = 4500
    -- The starting height of sufuras
    local START_HEIGHT        = 3000
    -- Sufuras Model
    local SULFURAS_MODEL      = "Sulfuras.mdl"
    -- Sulfuras Impact effect model
    local IMPACT_MODEL        = "Smash.mdl"
    -- Sufuras size
    local SULFURAS_SCALE      = 3.
    -- Size of the impact model
    local IMPACT_SCALE        = 2.
    -- How long will the impact model lasts
    local IMPACT_DURATION     = 10.
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC

    -- The stun time for units at the center of impact
    local function GetStunTime(unit)
        local i = GetUnitUserData(unit)
    
        if Sulfuras_stacks[i] then
            return 1 + 0.25*R2I(Sulfuras_stacks[i]*0.01)
        else
            return 1.5
        end
    end
    
    -- The AoE for damage, by default is the AoE editor field of the ability
    local function GetNormalAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The AoE for enemies in the center of impact that will be stunned and take doubled damage
    local function GetCenterAoE(level)
        return 200. + 0.*level
    end

    -- Ability impact damage
    local function GetDamage(level)
        return 250.*level
    end

    -- Filter for units that will be damage on impact
    local function DamageFilter(source, target)
        return UnitAlive(target) and IsUnitEnemy(target, GetOwningPlayer(source)) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    end
    
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local a = AngleBetweenCoordinates(Spell.x, Spell.y, GetUnitX(Spell.source.unit), GetUnitY(Spell.source.unit))
            local this = Missiles:create(Spell.x + LAUNCH_OFFSET*Cos(a), Spell.y + LAUNCH_OFFSET*Sin(a), START_HEIGHT, Spell.x, Spell.y, 0)
            
            this:model(SULFURAS_MODEL)
            this:scale(SULFURAS_SCALE)
            this:duration(LANDING_TIME)
            this.source = Spell.source.unit
            this.level = Spell.level
            this.damage = GetDamage(Spell.level)
            this.owner = Spell.source.player
            this.stun = GetStunTime(Spell.source.unit)
            this.aoe = GetCenterAoE(Spell.level)

            this.onFinish = function()
                local group = CreateGroup()

                GroupEnumUnitsInRange(group, this.x, this.y, GetNormalAoE(this.source, this.level), nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local unit = BlzGroupUnitAt(group, i)
                    if DamageFilter(this.source, unit) then
                        if DistanceBetweenCoordinates(this.x, this.y, GetUnitX(unit), GetUnitY(unit)) <= this.aoe then
                            UnitDamageTarget(this.source, unit, 2*this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                            StunUnit(unit, this.stun)
                        else
                            UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                        end
                    end
                end
                DestroyGroup(group)
                DestroyEffectTimed(AddSpecialEffectEx(IMPACT_MODEL, this.x, this.y, 0, IMPACT_SCALE), IMPACT_DURATION)
                
                if Afterburner then
                    Afterburn(this.x, this.y, this.source)
                end

                return true
            end

            this:launch()
        end)
    end)
end