OnInit("OdinAttack", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Odin Attack v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Odin Attack ability
    OdinAttack_ABILITY = S2A('Tyc7')
    -- The raw code of the Odin unit
    local ODIN         = S2A('Odin')
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
    local function GetDamage(source, level)
        return 125. * level + 0.75 * GetUnitBonus(source, BONUS_DAMAGE)
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Attack = Class(Missile)

        function Attack:onFinish()
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.owner, u, self.damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil)
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)

            return true
        end
    end

    do
        OdinAttack = Class(Spell)

        function OdinAttack:onTooltip(source, level, ability)
            return "|cffffcc00Odin|r attacks shots |cffffcc00" .. N2S(GetMissileCount(level), 0) .. "|r rockets to a location nearby the primary target location, dealing |cffffcc00" .. N2S(GetDamage(source, level), 0) .. "|r damage to all nearby enemy units within |cffffcc00" .. N2S(GetAoE(level), 0) .. "|r AoE."
        end

        function OdinAttack:onCast()
            local count = GetMissileCount(Spell.level)
            local face = GetUnitFacing(Spell.source.unit) * bj_DEGTORAD
            local range = GetRandomRange(GetAttackAoE(Spell.source.unit, Spell.level))
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local offset = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) - OFFSET

            if count > 0 then
                for i = 0, count - 1 do
                    local x = GetX(Spell.source.x, face, i)
                    local y = GetY(Spell.source.y, face, i)
                    local attack = Attack.create(x, y, HEIGHT, x + offset*math.cos(angle), y + offset*math.sin(angle), 50)

                    attack.model = MODEL
                    attack.scale = SCALE
                    attack.speed = SPEED
                    attack.source = Spell.source.unit
                    attack.owner = Spell.source.player
                    attack.group = CreateGroup()
                    attack.aoe = GetAoE(Spell.level)
                    attack.damage = GetDamage(Spell.source.unit, Spell.level)

                    attack:launch()
                end
            end
        end

        function OdinAttack.onAttack()
            local source = GetAttacker()

            if GetUnitTypeId(source) == ODIN then
                IssueTargetOrder(source, "attack", GetTriggerUnit())
            end
        end

        function OdinAttack.onInit()
            RegisterSpell(OdinAttack.allocate(), OdinAttack_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, OdinAttack.onAttack)
        end
    end
end)