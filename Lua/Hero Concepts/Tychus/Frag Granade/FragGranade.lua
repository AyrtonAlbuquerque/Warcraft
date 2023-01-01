--[[ requires SpellEffectEvent, Missiles, NewBonusUtils, Utilities, optional ArsenalUpgrade, CrowdControl
    /* ---------------------- Bullet Time v1.3 by Chopinski --------------------- */
    // Credits:
    //     Blizzard          - Icon
    //     Vexorian          - TimerUtils
    //     Bribe             - SpellEffectEvent
    //     Magtheridon96     - RegisterPlayerUnitEvent
    //     WILL THE ALMIGHTY - Explosion model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Frag Granade ability
    FragGranade_ABILITY   = FourCC('A001')
    -- The Frag Granade model
    local MODEL           = "Abilities\\Weapons\\MakuraMissile\\MakuraMissile.mdl"
    -- The Frag Granade scale
    local SCALE           = 2.
    -- The Frag Granade speed
    local SPEED           = 1000.
    -- The Frag Granade arc
    local ARC             = 45.
    -- The Frag Granade Explosion model
    local EXPLOSION       = "Explosion.mdl"
    -- The Frag Granade Explosion model scale
    local EXP_SCALE       = 1.
    -- The Frag Granade proximity Period
    local PERIOD          = 0.25
    -- The Frag Granade stun model
    local STUN_MODEL      = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The Frag Granade stun model attach point
    local STUN_ATTACH     = "overhead"

    -- The Frag Granade armor reduction duraton
    local function GetArmorDuration(level)
        return 5. + 0.*level
    end

    -- The Frag Granade armor reduction
    local function GetArmor(level)
        return 2 + 2*level
    end

    -- The Frag Granade Explosion AOE
    local function GetAoE(level)
        return 150. + 50.*level
    end

    -- The Frag Granade Proximity AOE
    local function GetProximityAoE(level)
        return 100. + 0.*level
    end

    -- The Frag Granade damage
    local function GetDamage(level)
        return 50. + 50.*level
    end

    -- The Frag Granade lasting duraton
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, FragGranade_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Frag Granade stun duration
    local function GetStunDuration(level)
        return 1.5 + 0.*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local timer = CreateTimer()
        local array = {}
        local key = 0
    
        Mine = setmetatable({}, {})
        local mt = getmetatable(Mine)
        mt.__index = mt
        
        function mt:destroy(i)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            DestroyEffect(AddSpecialEffectEx(EXPLOSION, self.x, self.y, 0, EXP_SCALE))

            array[i] = array[key]
            key = key - 1
            self = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:explode()
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)
            for i = 0, BlzGroupGetSize(self.group) - 1 do
                local u = BlzGroupUnitAt(self.group, i)
                if DamageFilter(self.player, u) then
                    if UnitDamageTarget(self.unit, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        AddUnitBonusTimed(u, BONUS_ARMOR, -self.armor, self.armor_dur)
                        if self.stun > 0 then
                            StunUnit(u, self.stun, STUN_MODEL, STUN_ATTACH, false)
                        end
                    end
                end
            end
        end
        
        function mt:create(source, owner, level, x, y, damage, aoe, armor, armor_dur, stun, duration)
            local this = {}
            setmetatable(this, mt)

            this.unit = source
            this.player = owner
            this.damage = damage
            this.duration = duration
            this.armor = armor
            this.armor_dur = armor_dur
            this.aoe = aoe
            this.x = x
            this.y = y
            this.stun = stun
            this.proximity = GetProximityAoE(level)
            this.effect = AddSpecialEffectEx(MODEL, x, y, 20, SCALE)
            this.group = CreateGroup()
            key = key + 1
            array[key] = this

            BlzSetSpecialEffectTimeScale(this.effect, 0)

            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1

                    while i <= key do
                        local this = array[i]
                        
                        if this.duration > 0 then
                            GroupEnumUnitsInRange(this.group, this.x, this.y, this.proximity, nil)
                            for j = 0, BlzGroupGetSize(this.group) - 1 do
                                local unit = BlzGroupUnitAt(this.group, j)
                                if DamageFilter(this.player, unit) then
                                    this.duration = 0
                                    this:explode()
                                    break
                                end
                            end

                            if this.duration == 0 then
                                i = this:destroy(i)
                            end
                        else
                            this:explode()
                            i = this:destroy(i)
                        end
                        this.duration = this.duration - PERIOD
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    FragGranade = setmetatable({}, {})
    local mt = getmetatable(FragGranade)
    mt.__index = mt
    
    function mt:onCast()
        local this = Missiles:create(Spell.source.x, Spell.source.y, 75, Spell.x, Spell.y, 0)
    
        this:speed(SPEED)
        this:model(MODEL)
        this:scale(SCALE)
        this:arc(ARC)
        this.source = Spell.source.unit
        this.owner = Spell.source.player
        this.level = Spell.level
        this.stun = 0.
        this.damage = GetDamage(Spell.level)
        this.aoe = GetAoE(Spell.level)
        this.armor = GetArmor(Spell.level)
        this.armor_dur = GetArmorDuration(Spell.level)
        this.group = CreateGroup()
        
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(Spell.source.unit, ArsenalUpgrade_ABILITY) > 0 then
                this.stun = GetStunDuration(Spell.level)
            end
        end

        this.onFinish = function()
            local i = 0

            GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
            for j = 0, BlzGroupGetSize(this.group) - 1 do
                local unit = BlzGroupUnitAt(this.group, j)
                if DamageFilter(this.owner, unit) then
                    i = i + 1
                    if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        AddUnitBonusTimed(unit, BONUS_ARMOR, -this.armor, this.armor_dur)
                        if this.stun > 0 then
                            StunUnit(unit, this.stun, STUN_MODEL, STUN_ATTACH, false)
                        end
                    end
                end
            end
            DestroyGroup(this.group)

            if i > 0 then
                DestroyEffect(AddSpecialEffectEx(EXPLOSION, this.x, this.y, 0, EXP_SCALE))
            else
                Mine:create(this.source, this.owner, this.level, this.x, this.y, this.damage, this.aoe, this.armor, this.armor_dur, this.stun, GetDuration(this.source, this.level))
            end

            return true
        end

        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(FragGranade_ABILITY, function()
            FragGranade:onCast()
        end)
    end)
end