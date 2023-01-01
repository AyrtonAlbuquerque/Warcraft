--[[
    /* --------------------- DamageInterface v2.4 by Chopinski --------------------- */
    Allows for easy registration of specific damage type events like on attack
    damage or on spell damage, etc...
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- This constant is used to define if the system will cache
    -- extra information from a Damage Event, like the unit
    -- Custom value (UnitUserData), a unit Handle Id, and more
    -- Additionaly you can see the Cache function below
    -- to have an idea and comment the members you want cached or not
    local CACHE_EXTRA = true

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Damage = {
        source = {
            unit,
            player,
            handle,
            isHero,
            isMelee,
            isRanged,
            isStructure,
            isMagicImmune,
            id,
            x,
            y,
            z
        },
        target = {
            unit,
            player,
            handle,
            isHero,
            isMelee,
            isRanged,
            isStructure,
            isMagicImmune,
            id,
            x,
            y,
            z
        },
        damagetype,
        attacktype,
        isSpell,
        isAttack,
        isEnemy,
        isAlly
    }
    local after  = {}
    local before = {}
    local damage = {}
    local damaging = {}
    local trigger = CreateTrigger()
    local location = Location(0, 0)
    
    local function GetUnitZ(unit)
        MoveLocation(location, GetUnitX(unit), GetUnitY(unit))
        return GetUnitFlyHeight(unit) + GetLocationZ(location)
    end

    local function Cache(source, target, damagetype, attacktype)
        Damage.damagetype  = damagetype
        Damage.attacktype  = attacktype
        Damage.source.unit = source
        Damage.target.unit = target
        Damage.isAttack    = damagetype == DAMAGE_TYPE_NORMAL
        Damage.isSpell     = attacktype == ATTACK_TYPE_NORMAL

        -- You can comment the members you dont want to be cached
        -- or set CACHE_EXTRA = false to not save them at all
        if CACHE_EXTRA then
            Damage.source.player        = GetOwningPlayer(source)
            Damage.target.player        = GetOwningPlayer(target)
            Damage.isEnemy              = IsUnitEnemy(target, Damage.source.player)
            Damage.isAlly               = IsUnitAlly(target, Damage.source.player)
            Damage.source.isMelee       = IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER)
            Damage.source.isRanged      = IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER)
            Damage.target.isMelee       = IsUnitType(target, UNIT_TYPE_MELEE_ATTACKER)
            Damage.target.isRanged      = IsUnitType(target, UNIT_TYPE_RANGED_ATTACKER)
            Damage.source.isHero        = IsUnitType(source, UNIT_TYPE_HERO)
            Damage.target.isHero        = IsUnitType(target, UNIT_TYPE_HERO)
            Damage.source.isStructure   = IsUnitType(source, UNIT_TYPE_STRUCTURE)
            Damage.target.isStructure   = IsUnitType(target, UNIT_TYPE_STRUCTURE)
            Damage.source.isMagicImmune = IsUnitType(source, UNIT_TYPE_MAGIC_IMMUNE)
            Damage.target.isMagicImmune = IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
            Damage.source.x             = GetUnitX(source)
            Damage.source.y             = GetUnitY(source)
            Damage.source.z             = GetUnitZ(source)
            Damage.target.x             = GetUnitX(target)
            Damage.target.y             = GetUnitY(target)
            Damage.target.z             = GetUnitZ(target)
            Damage.source.id            = GetUnitUserData(source)
            Damage.target.id            = GetUnitUserData(target)
            Damage.source.handle        = GetHandleId(source)
            Damage.target.handle        = GetHandleId(target)
        end
    end
    
    onInit(function()
        for i = 1, 7 do
            after[i] = {}
            before[i] = {}
        end
        
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGING then
                Cache(GetEventDamageSource(), BlzGetEventDamageTarget(), BlzGetEventDamageType(), BlzGetEventAttackType())
                
                if Damage.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                    local i = GetHandleId(Damage.attacktype) + 1
                    local j = GetHandleId(Damage.damagetype) + 1
                    
                    if before[i][1] then
                        for k = 1, #before[i][1] do
                            before[i][1][k]()
                        end
                    end
                    
                    if before[1][j] then
                        for k = 1, #before[1][j] do
                            before[1][j][k]()
                        end
                    end
                    
                    if before[i][j] then
                        for k = 1, #before[i][j] do
                            before[i][j][k]()
                        end
                    end
                    
                    for k = 1, #damaging do
                        damaging[k]()
                    end
                end
            end
        end))
    
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGED then
                Cache(GetEventDamageSource(), BlzGetEventDamageTarget(), BlzGetEventDamageType(), BlzGetEventAttackType())
                
                if Damage.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                    local i = GetHandleId(Damage.attacktype) + 1
                    local j = GetHandleId(Damage.damagetype) + 1
                    
                    if after[i][1] then
                        for k = 1, #after[i][1] do
                            after[i][1][k]()
                        end
                    end
                    
                    if after[1][j] then
                        if Damage.isAttack and Evasion then
                            if not Evasion.evade then
                                for k = 1, #after[1][j] do
                                    after[1][j][k]()
                                end
                            end
                        else
                            for k = 1, #after[1][j] do
                                after[1][j][k]()
                            end
                        end
                    end
                    
                    if after[i][j] then
                        for k = 1, #after[i][j] do
                            after[i][j][k]()
                        end
                    end
                    
                    for k = 1, #damage do
                        damage[k]()
                    end
                end
            end
        end))
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function RegisterDamageEvent(attacktype, damagetype, code)
        if type(code) == "function" then
            local i = GetHandleId(attacktype) + 1
            local j = GetHandleId(damagetype) + 1
        
            if not after[i][j] then after[i][j] = {} end
            table.insert(after[i][j], code)
        end
    end
    
    function RegisterAttackDamageEvent(code)
        RegisterDamageEvent(nil, DAMAGE_TYPE_NORMAL, code)
    end
    
    function RegisterSpellDamageEvent(code)
        RegisterDamageEvent(ATTACK_TYPE_NORMAL, nil, code)
    end

    function RegisterAnyDamageEvent(code)
        if type(code) == "function" then
            table.insert(damage, code)
        end
    end
    
    function RegisterDamagingEvent(attacktype, damagetype, code)
        if type(code) == "function" then
            local i = GetHandleId(attacktype) + 1
            local j = GetHandleId(damagetype) + 1
        
            if not before[i][j] then before[i][j] = {} end
            table.insert(before[i][j], code)
        end
    end 

    function RegisterAttackDamagingEvent(code)
        RegisterDamagingEvent(nil, DAMAGE_TYPE_NORMAL, code)
    end
    
    function RegisterSpellDamagingEvent(code)
        RegisterDamagingEvent(ATTACK_TYPE_NORMAL, nil, code)
    end

    function RegisterAnyDamagingEvent(code)
        if type(code) == "function" then
            table.insert(damaging, code)
        end
    end
end