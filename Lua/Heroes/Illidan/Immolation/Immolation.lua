OnInit("Immolation", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------ Immolation v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Immolation ability
    local ABILITY      = S2A('Idn2')
    -- The raw code of the Immolation buff
    local BUFF         = S2A('BId0')
    -- The immolation damage period
    local PERIOD       = 1.
    -- The immolation Damage model
    local MODEL        = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
    -- The immolation Damage model
    local ATTACH_POINT = "head"

    -- The immolation AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Immolation damage
    local function GetDamage(source, level)
        return 20. * level + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Immolation ardor reduction
    local function GetArmorReduction(level)
        return 1 + 0.*level
    end

    -- The Immolation armor debuff duration
    local function GetDuration(level)
        return 5. + 0.*level
    end

    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Immolation = Class(Spell)

        local array= {}

        function Immolation:destroy()
            DestroyGroup(self.group)
            
            array[self.unit] = nil

            self.unit = nil
            self.group = nil
            self.player = nil
        end

        function Immolation:onTooltip(unit, level, ability)
            return "Engulfs |cffffcc00Illidan|r in fel flames, dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" .. N2S(GetAoE(unit, level), 0) .. " AoE|r and shreding their armor by |cffffcc00" .. N2S(GetArmorReduction(level), 0) .. "|r every time they are affected by |cffffcc00Immolation|r for |cffffcc00" .. N2S(GetDuration(level), 0) .. "|r seconds.\n\nDrains mana until deactivated."
        end

        function Immolation.onOrder()
            local source = GetOrderedUnit()

            if GetIssuedOrderId() == 852177 and not array[source] then
                local self = Immolation.allocate()

                self.unit = source
                self.timer = CreateTimer()
                self.group = CreateGroup()
                self.player = GetOwningPlayer(source)
                array[source] = self

                LinkEffectToBuff(source, BUFF, "Ember Green.mdl", "chest")
                TimerStart(self.timer, PERIOD, true, function ()
                    local level = GetUnitAbilityLevel(self.unit, ABILITY)

                    if GetUnitAbilityLevel(self.unit, BUFF) > 0 then 
                        GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.unit, level), nil)

                        local u = FirstOfGroup(self.group)

                        while u do
                            if DamageFilter(self.player, u) then
                                if UnitDamageTarget(self.unit, u, GetDamage(self.unit, level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    DestroyEffect(AddSpecialEffectTarget(MODEL, u, ATTACH_POINT))
                                    AddUnitBonusTimed(u, BONUS_ARMOR, -GetArmorReduction(level), GetDuration(level))
                                end
                            end

                            GroupRemoveUnit(self.group, u)
                            u = FirstOfGroup(self.group)
                        end
                    else
                        self:destroy()
                    end
                end)
            end
        end

        function Immolation.onInit()
            RegisterSpell(Immolation.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, Immolation.onOrder)
        end
    end
end)