--[[ requires SpellEffectEvent, NewBonus, Utilities, Missiles, optional KegSmash
    /* -------------------- Breath of Fire v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     AZ                 - Breth of Fire model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Breath of Fire Ability
    BreathOfFire_ABILITY    = FourCC('A003')
    -- The raw code of the Utilities library dummy
    local Utilities_DUMMY   = FourCC('dumi')
    -- The Breath of Fire model
    local MODEL             = "BreathOfFire.mdl"
    -- The Breath of Fire scale
    local SCALE             = 0.75
    -- The Breath of Fire Missile speed
    local SPEED             = 500.
    -- The Breath of Fire DoT period
    local PERIOD            = 1.
    -- The Breath of Fire DoT model
    local DOT_MODEL         = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
    -- The Breath of Fire DoT model attach point
    local ATTACH            = "origin"

    -- The Breath of Fire final AoE
    local function GetFinalArea(level)
        return 400. + 0.*level
    end

    -- The Breath of Fire cone width
    local function GetCone(level)
        return 60. + 0.*level
    end

    -- The Breath of Fire DoT/Brew Cloud ignite duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, BreathOfFire_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Breath of Fire travel distance, by default the ability cast range
    local function GetDistance(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, BreathOfFire_ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The Breath of Fire DoT damage
    local function GetDoTDamage(level)
        return 10.*level
    end

    -- The Breath of Fire Brew Cloud ignite damage
    local function GetIgniteDamage(level)
        return 25.*level
    end

    -- The Breath of Fire Brew Cloud ignite damage interval
    local function GetIgniteInterval(level)
        return 1. + 0.*level
    end

    -- The Breath of Fire Damage
    local function GetDamage(level)
        return 50. + 50.*level
    end

    -- The Breath of Fire armor reduction
    local function GetArmorReduction(level)
        return 5 + 0*level
    end

    -- The Breath of Fire Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        DoT = setmetatable({}, {})
        local mt = getmetatable(DoT)
        mt.__index = mt
        
        local timer = CreateTimer()
        local array = {}
        local n = {}
        local key = 0
        
        function mt:destroy(i)
            AddUnitBonus(self.target, BONUS_ARMOR, self.armor)
            DestroyEffect(self.effect)

			array[i] = array[key]
            key = key - 1
            n[self.target] = nil
            self = nil

			if key == 0 then
                PauseTimer(timer)
			end

			return i - 1
        end
        
        function mt:create(source, target, level)
            local this
        
            if n[target] then
                this = n[target]
            else
                this = {}
                setmetatable(this, mt)
                
                n[target] = this
                key = key + 1
                array[key] = this
                
                this.source = source
                this.target = target
                this.damage = GetDoTDamage(level)
                this.effect = AddSpecialEffectTarget(DOT_MODEL, target, ATTACH)
                this.armor = 0
                

                if KegSmash then
                    if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                        this.armor = GetArmorReduction(level)
                        AddUnitBonus(target, BONUS_ARMOR, -this.armor)
                    end
                end

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                
                        while i <= key do
                            local this = array[i]
                            
                            if this.duration > 0 then
                                if UnitAlive(this.target) then
                                    if KegSmash then
                                        if GetUnitAbilityLevel(this.target, KegSmash_BUFF) > 0 then
                                            UnitDamageTarget(this.source, this.target, 2*this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                        else
                                            UnitDamageTarget(this.source, this.target, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                        end
                                    else
                                        UnitDamageTarget(this.source, this.target, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                    end
                                else
                                    i = this:destroy(i)
                                end
                            else
                                i = this:destroy(i)
                            end
                            this.duration = this.duration - 1
                            i = i + 1
                        end
                    end)
                end
            end
            this.duration = R2I(GetDuration(source, level)/PERIOD)
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(BreathOfFire_ABILITY, function()
            local a = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local d = GetDistance(Spell.source.unit, Spell.level)
            local effect = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE)
            local this = Missiles:create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)

            this:speed(SPEED)
            this.source = Spell.source.unit 
            this.owner = Spell.source.player
            this.level = Spell.level
            this.centerX = Spell.source.x
            this.centerY = Spell.source.y
            this.face = a*bj_RADTODEG
            this.distance = d
            this.fov = GetCone(Spell.level)
            this.damage = GetDamage(Spell.level)
            this.collision = GetFinalArea(Spell.level)
            this.group = CreateGroup()
            this.ignite_damage = GetIgniteDamage(Spell.level)
            this.ignite_duration = GetDuration(Spell.source.unit, Spell.level)
            this.ignite_interval = GetIgniteInterval(Spell.level)

            BlzSetSpecialEffectYaw(effect, a)
            DestroyEffect(effect)
            
            this.onPeriod = function()
                if KegSmash then
                    GroupEnumUnitsOfPlayer(this.group, this.owner, nil)
                    for i = 0, BlzGroupGetSize(this.group) - 1 do
                        local unit = BlzGroupUnitAt(this.group, i)
                        if GetUnitTypeId(unit) == Utilities_DUMMY and BrewCloud:active(unit) then
                            local d = DistanceBetweenCoordinates(this.x, this.y, GetUnitX(unit), GetUnitY(unit))
                            if d <= this.collision + KegSmash_GetAoE(this.source, this.level)/2 and IsUnitInCone(unit, this.centerX, this.centerY, 2*this.distance, this.face, 180) then
                                BrewCloud:ignite(unit, this.ignite_damage, this.ignite_duration, this.ignite_interval)
                            end
                        end
                    end
                end

                return false
            end
            
            this.onHit = function(unit)
                if IsUnitInCone(unit, this.centerX, this.centerY, this.distance, this.face, this.fov) then
                    if DamageFilter(this.owner, unit) then
                        if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            DoT:create(this.source, unit, this.level)
                        end
                    end
                end

                return false
            end
            
            this.onRemove = function()
                DestroyGroup(this.group)
            end
            
            this:launch()
        end)
    end)
end