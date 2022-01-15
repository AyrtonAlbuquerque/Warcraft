--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Missiles
    /* ---------------------- Odin Attack v1.2 by Chopinski --------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Odin Attack ability
    OdinAttack_ABILITY = FourCC('A007')
    -- The raw code of the Odin unit
    local ODIN         = FourCC('E001')
    -- The Missile model
    local MODEL        = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE        = 0.7
    -- The BulMissilelet speed
    local SPEED        = 1500.
    -- The Missile height offset
    local HEIGHT       = 100.
    -- The Odin weapons angle
    local ANGLE        = 45*bj_DEGTORAD
    -- The Odin weapons offset
    local OFFSET       = 125.

    -- The X coordinate starting point for the misisles. This exists so the missiles
    -- will come out of the odin model weapon barrels. i is the attack number.
    local function GetX(x, face, i)
        if i == 2 then -- right arm
            return x + OFFSET*Cos(face + ANGLE)
        else -- left
            return x + OFFSET*Cos(face - ANGLE)
        end
    end

    -- The Y coordinate starting point for the misisles. This exists so the missiles
    -- will come out of the odin model weapon barrels. i is the attack number.
    local function GetY(y, face, i)
        if i == 2 then -- right arm
            return y + OFFSET*Sin(face + ANGLE)
        else -- left
            return y + OFFSET*Sin(face - ANGLE)
        end
    end

    -- The Explosion AoE
    local function GetAoE(level)
        return 200. + 0.*level
    end

    -- The explosion damage
    local function GetDamage(level)
        return 125.*level
    end

    -- The numebr of rockets per attack per level
    local function GetMissileCount(level)
        return 2 + 0*level
    end

    -- The max attack aoe at which randomness can occur, by deafult its the aoe filed from the abiltiy.
    local function GetAttackAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, OdinAttack_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    OdinAttack = setmetatable({}, {})
    local mt = getmetatable(OdinAttack)
    mt.__index = mt
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function()
            local unit = GetAttacker()

            if GetUnitTypeId(unit) == ODIN then
                IssueTargetOrder(unit, "attack", GetTriggerUnit())
            end
        end)
        
        RegisterSpellEffectEvent(OdinAttack_ABILITY, function()
            local i = GetMissileCount(Spell.level)
            
            while i > 0 do
                local range = GetRandomRange(GetAttackAoE(Spell.source.unit, Spell.level))
                local face = GetUnitFacing(Spell.source.unit)*bj_DEGTORAD
                local x = GetX(Spell.source.x, face, i)
                local y = GetY(Spell.source.y, face, i)
                local offset = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) - OFFSET
                local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
                local this = Missiles:create(x, y, HEIGHT, x + offset*Cos(angle), y + offset*Sin(angle), 50)
                
                this:model(MODEL)
                this:scale(SCALE)
                this:speed(SPEED)
                this.source = Spell.source.unit
                this.owner = Spell.source.player
                this.damage = GetDamage(Spell.level)
                this.aoe = GetAoE(Spell.level)
                this.group = CreateGroup()

                this.onFinish = function()
                    GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                    for j = 0, BlzGroupGetSize(this.group) - 1 do
                        local unit = BlzGroupUnitAt(this.group, j)
                        if DamageFilter(this.owner, unit) then
                            UnitDamageTarget(this.source, unit, this.damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil)
                        end
                    end
                    DestroyGroup(this.group)

                    return true
                end

                this:launch()
                
                i = i - 1
            end
        end)
    end)
end