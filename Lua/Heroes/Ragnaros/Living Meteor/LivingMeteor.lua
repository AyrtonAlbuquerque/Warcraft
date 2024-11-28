--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Missiles, MouseUtils, TimerUtils, Utilities optional Afterburner
    /* --------------------- Living Meteor v1.5 by Chopinski -------------------- */
    // Credits:
    //     Blizzard         - icon (Edited by me)
    //     AZ               - Meteor model
    //     Magtheridon96    - RegisterPlayerUnitEvent 
    //     Bribe            - SpellEffectEvent
    //     MyPad            - MouseUtils
    //     Verxorian        - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Living Meteor ability
    local ABILITY             = FourCC('A002')
    -- The landing time of the falling meteor
    local LANDING_TIME        = 2.5
    -- The roll time of the rolling meteor
    local ROLLING_TIME        = 2.5
    -- The damage interval of the rolling interval
    local DAMAGE_INTERVAL     = 0.25
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME  = 0.05
    -- The distance from the casting point from where the meteor spawns
    local LAUNCH_OFFSET       = 4500
    -- The starting height fo the meteor
    local START_HEIGHT        = 3000
    -- Meteor Model
    local METEOR_MODEL        = "LivingMeteor.mdl"
    -- Meteor Impact effect model
    local IMPACT_MODEL        = "LivingMeteor.mdl"
    -- Meteor size
    local METEOR_SCALE        = 0.75
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
    -- If true will damage structures
    local DAMAGE_STRUCTURES   = true
    -- If true will damage allies
    local DAMAGE_ALLIES       = false
    -- If true will damage magic immune unit if the
    -- ATTACK_TYPE is not spell damage
    local DAMAGE_MAGIC_IMMUNE = false

    -- The roll distance of the meteor
    local function RollDistance(level)
        return 600. + 100.*level
    end

    -- The landing damage distance of the meteor
    local function LandingDamage(level)
        return 50. + 50.*level
    end

    -- The roll damage distance of the meteor.
    -- will do this damage every DAMAGE_INTERVAL
    local function RollDamage(level)
        return (25.*(level*level -2*level + 2))*DAMAGE_INTERVAL
    end

    -- The size of the area around the impact point where units will be damaged
    -- By default it is the Living Meteor ability field Area of Effect
    local function GetImpactAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The size of the area of the roll meteor that will damage units
    -- every DAMAGE_INTERVAL. by default it is the same as the impact AoE
    local function GetRollAoE(unit, level)
        return GetImpactAoE(unit, level)
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit   = Spell.source.unit
            local player = Spell.source.player
            local level  = Spell.level
            local x      = Spell.x
            local y      = Spell.y

            TimerStart(timer, DRAG_AND_DROP_TIME, false, function()
                local a = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                local this = Missiles:create(x + LAUNCH_OFFSET*Cos(a + bj_PI), y + LAUNCH_OFFSET*Sin(a + bj_PI), START_HEIGHT, x, y, 0)
                
                this.source = unit
                this.owner = player
                this:model(METEOR_MODEL)
                this:scale(METEOR_SCALE)
                this:duration(LANDING_TIME)
                this.angle = a
                this.level = level
                this.rolling = false
                this.aoe = GetRollAoE(unit, level)
                this.damage = LandingDamage(level)
                this.distance = RollDistance(level)
                this.ticks = R2I(DAMAGE_INTERVAL/(1./40.))
                this.i = 0
                this.j = 0

                this.onPeriod = function()
                    if this.rolling then
                        this.i = this.i + 1
                        this.j = this.j + 1

                        if this.j == 25 then
                            this.j = 0
                            if Afterburner then
                                Afterburn(this.x, this.y, this.source)
                            end
                        end

                        if this.i == this.ticks then
                            this.i = 0
                            UnitDamageArea(this.source, this.x, this.y, this.aoe, this.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                        end
                    end
                    
                    return false
                end

                this.onFinish = function()
                    if not this.rolling then
                        DestroyEffect(AddSpecialEffect(IMPACT_MODEL, this.x, this.y))
                        UnitDamageArea(this.source, this.x, this.y, GetImpactAoE(this.source, this.level), this.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                        this:deflect(this.x + this.distance*Cos(this.angle), this.y + this.distance*Sin(this.angle), 0)
                        if Afterburner then
                            Afterburn(this.x, this.y, this.source)
                        end

                        this.rolling = true
                        this.damage = RollDamage(this.level)
                        this:duration(ROLLING_TIME)
                    end

                    return false
                end
    
                this:launch()
                PauseTimer(timer)
                DestroyTimer(timer)
            end) 
        end)
    end)
end