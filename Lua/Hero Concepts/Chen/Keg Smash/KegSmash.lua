--[[ requires SpellEffectEvent, NewBonusUtils, Utilities, Missiles
    /* ----------------------- Keg Smash v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     JesusHipster       - Barrel model
    //     EvilCryptLord      - Brew Cloud model (edited by me)
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Keg Smash Ability
    local ABILITY      = FourCC('A001')
    -- The Keg Smash Ignite ability
    local IGNITE       = FourCC('A004')
    -- The Keg Smash Brew Cloud Ability
    local DEBUFF       = FourCC('A002')
    -- The Keg Smash Brew Cloud debuff
    KegSmash_BUFF      = FourCC('BNdh')
    -- The Keg Smash Missile model
    local MODEL        = "RollingKegMissle.mdl"
    -- The Keg Smash Missile scale
    local SCALE        = 1.25
    -- The Keg Smash Missile speed
    local SPEED        = 1000.
    -- The Keg Smash Brew Cloud model
    local CLOUD        = "BrewCloud.mdl"
    -- The Keg Smash Brew Cloud scale
    local CLOUD_SCALE  = 0.6
    -- The Keg Smash Brew Cloud Period
    local PERIOD       = 0.5

    -- The Keg Smash miss chance per level
    local function GetChance(level)
        return 20.*level
    end

    -- The Keg Smash Brew Cloud duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Keg Smash AoE
    function KegSmash_GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Keg Smash Damage
    local function GetDamage(level)
        return 75. + 50.*level
    end

    -- The Keg Smash Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        Ignite = setmetatable({}, {})
        local mt = getmetatable(Ignite)
        mt.__index = mt
    
        local proxy = {}
    
        function mt:create(x, y, damage, duration, aoe, interval, source)
            local this = {}
            local timer = CreateTimer()
            local unit = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            local ability

            this.unit = source
            this.damage = damage
            proxy[unit] = this

            UnitAddAbility(unit, IGNITE)
            ability = BlzGetUnitAbility(unit, IGNITE)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            IncUnitAbilityLevel(unit, IGNITE)
            DecUnitAbilityLevel(unit, IGNITE)
            IssuePointOrder(unit, "flamestrike", x, y)
            TimerStart(timer, duration + 0.05, false, function()
                this = nil
                proxy[unit] = nil
                DummyRecycle(unit)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end
        
        onInit(function()
            local this
            
            if proxy[Damage.source.unit] and GetEventDamage() > 0 then
                this = proxy[Damage.source.unit]
                BlzSetEventDamage(0)
                UnitDamageTarget(this.unit, Damage.target.unit, this.damage, false, false, Damage.attacktype, Damage.damagetype, nil)
            end
        end)
    end
    
    BrewCloud = setmetatable({}, {})
    local mt = getmetatable(BrewCloud)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local n = {}
    local key = 0
    
    function mt:destroy(i)
        UnitRemoveAbility(self.unit, DEBUFF)
        DestroyGroup(self.group)
        DestroyEffect(self.effect)
        DummyRecycle(self.unit)

        n[self.unit] = nil
        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:ignite(unit, damage, duration, interval)
        if n[unit] then
            local this = n[unit]
            if not this.ignited then
                this.ignited = true
                this.duration = 0
                Ignite:create(this.x, this.y, damage, duration, this.aoe, interval, this.source)
            end
        end
    end
    
    function mt:active(unit)
        local this = n[unit]

        if this then
            return not this.ignited
        end

        return false
    end
    
    function mt:create(player, source, unit, x, y, aoe, duration, level)
        local this = {}
        setmetatable(this, mt)

        this.x = x 
        this.y = y
        this.aoe = aoe
        this.level = level
        this.source = source
        this.player = player
        this.unit = unit
        this.ignited = false
        this.group = CreateGroup()
        this.effect = AddSpecialEffectEx(CLOUD, x, y, 0, CLOUD_SCALE)
        this.duration = R2I(duration/PERIOD)
        key = key + 1
        array[key] = this
        n[unit] = this
        

        if key == 1 then
            TimerStart(timer, PERIOD, true, function()
                local i = 1
                
                while i <= key do
                    local this = array[i]
                
                    if this.duration > 0 then
                        if not this.ignited then
                            GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                            for j = 0, BlzGroupGetSize(this.group) - 1 do
                                local u = BlzGroupUnitAt(this.group, j)
                                if UnitAlive(u) and IsUnitEnemy(u, this.player) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                                    IssueTargetOrder(this.unit, "drunkenhaze", u)
                                end
                            end
                        else
                            DestroyEffect(this.effect)
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
    
    KegSmash = setmetatable({}, {})
    local mt = getmetatable(KegSmash)
    mt.__index = mt
    
    function mt:onCast()
        local this = Missiles:create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)

        this:model(MODEL)
        this:scale(SCALE)
        this:speed(SPEED)
        this.source = Spell.source.unit 
        this.owner = Spell.source.player
        this.level = Spell.level
        this.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
        this.group = CreateGroup()
        this.damage = GetDamage(Spell.level)
        this.aoe = KegSmash_GetAoE(Spell.source.unit, Spell.level)
        this.dur = GetDuration(Spell.source.unit, Spell.level)

        UnitAddAbility(this.unit, DEBUFF)
        SetUnitAbilityLevel(this.unit, DEBUFF, Spell.level)
        
        this.onFinish = function()
            BrewCloud:create(this.owner, this.source, this.unit, this.x, this.y, this.aoe, this.dur, this.level)
            GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
            for i = 0, BlzGroupGetSize(this.group) - 1 do
                local u = BlzGroupUnitAt(this.group, i)
                if DamageFilter(this.owner, u) then
                    if UnitDamageTarget(this.source, u, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        IssueTargetOrder(this.unit, "drunkenhaze", u)
                    end
                end
            end
            DestroyGroup(this.group)

            return true
        end
        
        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            KegSmash:onCast()
        end)
        
        RegisterSpellEffectEvent(DEBUFF, function()
            if GetUnitAbilityLevel(Spell.target.unit, KegSmash_BUFF) == 0 then
                LinkBonusToBuff(Spell.target.unit, BONUS_MISS_CHANCE, GetChance(Spell.level), KegSmash_BUFF)
            end
        end)
    end)
end