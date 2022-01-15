--[[ requires Missiles, SpellEffectEvent
    /* ------------------- Rain of Fel Fire v1.4 by Chopinski ------------------- */
    // Credits:
    //     The Panda - InfernalShower icon
    //     Mythic    - Rain of Fire model
    //     Bribe     - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- the raw code of the Rain of Fel Fire ability
    local ABILITY             = FourCC('A000')
    -- the starting height of the missile
    local START_HEIGHT        = 2000
    -- The landing time of the falling misisle
    local LANDING_TIME        = 1.5
    -- The impact radius of the missile that will damage units.
    local IMPACT_RADIUS       = 120.
    -- the missile model
    local MISSILE_MODEL       = "FelRain.mdx"
    -- the dot model
    local DOT_MODEL           = "BurnLarge.mdx"
    -- the dot attachment point
    local DOT_ATTACH          = "origin"
    -- The Attack type of the damage dealt on imapact (Spell)
    local  IMPACT_ATTACK_TYPE = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt on impact
    local IMPACT_DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    -- The Attack type of the damage over time
    local DOT_ATTACK_TYPE    = ATTACK_TYPE_HERO
    -- The Damage type of the damage over time
    local DOT_DAMAGE_TYPE    = DAMAGE_TYPE_UNIVERSAL
    
    -- How long the spell will last
    local function GetDuration(level)
        return 10. + 0.*level
    end

    -- The interval at which the rain of fire meteors spwan
    local function GetInterval(level)
        return 0.2 + 0.*level
    end

    -- The max range that a rain of fel fire missile can spawn
    -- By default it is the ability Area of Effect Field value
    local function GetRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The amount of damage dealt when the missile lands
    local function GetImpactDamage(level)
        return 25.*level
    end

    -- The amount of damage over time dealt to units in range of the impact area
    local function GetDoTDamage(level)
        return 5.*level
    end

    -- How long the dot will last
    local function GetDoTDuration(level)
        return 4. + 0.*level
    end

    -- The interval at which the dot effect will do damage
    local function GetDoTInterval(level)
        return 1. + 0.*level
    end

    -- Filter for the units that will be damaged on impact and get DoT
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local timer = CreateTimer()
        local array = {}
        local n = {}
        local key = 0
        
        DoT = setmetatable({}, {})
        local mt = getmetatable(DoT)
        mt.__index = mt
        
        function mt:destroy(i)
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
        
        function mt:create(source, target, damage, level)
            local this
            
            if n[target] then
                this = n[target]
            else
                this = {}
                setmetatable(this, mt)
                
                this.source = source
                this.target = target
                this.damage = damage
                this.effect = AddSpecialEffectTarget(DOT_MODEL, target, DOT_ATTACH)
                key = key + 1
                array[key] = this
                n[target] = this

                if key == 1 then
                    TimerStart(timer, GetDoTInterval(level), true, function()
                        local i = 1
                        
                        while i <= key do
                            local this = array[i]
                        
                            if this.ticks > 0 and UnitAlive(this.target) then
                                UnitDamageTarget(this.source, this.target, this.damage, true, false, DOT_ATTACK_TYPE, DOT_DAMAGE_TYPE, nil)
                            else
                                i = this:destroy(i)
                            end
                            this.ticks = this.ticks - 1
                            i = i + 1
                        end
                    end)
                end
            end
            this.ticks = GetDoTDuration(level)/GetDoTInterval(level)
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local source = Spell.source.unit
            local player = Spell.source.player
            local level = Spell.level
            local duration = GetDuration(Spell.level)
            local i = duration/GetInterval(Spell.level)
            local ox = Spell.x
            local oy = Spell.y

            TimerStart(timer, GetInterval(Spell.level), true, function()
                if i > 0 then
                    local theta = 2*bj_PI*GetRandomReal(0, 1)
                    local radius = GetRandomRange(GetRange(source, level))
                    local x = ox + radius*Cos(theta)
                    local y = oy + radius*Sin(theta)  
                    local this = Missiles:create(x, y, START_HEIGHT, x, y, 20)

                    this:model(MISSILE_MODEL)
                    this:duration(LANDING_TIME)
                    this.damage = GetImpactDamage(level)
                    this.source = source
                    this.owner = player
                    this.level = level

                    this.onFinish = function()
                        local group = CreateGroup()

                        GroupEnumUnitsInRange(group, this.x, this.y, IMPACT_RADIUS, nil)
                        for j = 0, BlzGroupGetSize(group) - 1 do
                            local unit = BlzGroupUnitAt(group, j)
                            if DamageFilter(this.owner, unit) then
                                if UnitDamageTarget(this.source, unit, this.damage, false, false, IMPACT_ATTACK_TYPE, IMPACT_DAMAGE_TYPE, nil) then
                                    DoT:create(this.source, unit, GetDoTDamage(this.level), this.level)
                                end
                            end
                        end
                        DestroyGroup(group)
                        
                        return true
                    end

                    this:launch()
                else
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end
                i = i - 1
            end)
        end)
    end)
end