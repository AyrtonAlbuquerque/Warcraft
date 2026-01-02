OnInit("HolyUnity", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------ Holy unity v1.4 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
     -- The raw code of the Holy Unity Ability
    local ABILITY       = S2A('Trl8')
    -- The raw code of the Turalyon unit in the editor
    local TURALYON_ID   = S2A('Trln')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Turalyon will gain Holy Unity at this level 
    local GAIN_AT_LEVEL = 20
    -- The Holy Unity update period
    local PERIOD        = 0.3

    -- The Holy Unity AoE
    local function GetAoE(unit, level)
        return 500. + 0.*level
    end

    -- The Holy Unity bonus per unit type
    local function GetBonus(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 5 + 0*level
        else
            return 2 + 0*level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        HolyUnity = Class(Spell)

        function HolyUnity:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.player = nil
            self.ability = nil
        end

        function HolyUnity:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r gains |cffffcc002|r (|cffffcc005|r for |cffffcc00Heroes|r) |cffff0000Strength|r for every allied unit within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r."
        end

        function HolyUnity.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == TURALYON_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    local self = { destroy = HolyUnity.destroy }

                    self.unit = unit
                    self.timer = CreateTimer()
                    self.group = CreateGroup()
                    self.player = GetOwningPlayer(unit)

                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)

                    self.ability = BlzGetUnitAbility(unit, ABILITY)

                    TimerStart(self.timer, PERIOD, true, function ()
                        local bonus = 0
                        local level = GetUnitAbilityLevel(self.unit, ABILITY)

                        if level > 0 then
                            GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.unit, level), nil)
                            GroupRemoveUnit(self.group, self.unit)

                            local u = FirstOfGroup(self.group)

                            while u do
                                if UnitAlive(u) and IsUnitAlly(u, self.player) then
                                    bonus = bonus + GetBonus(u, level)
                                end

                                GroupRemoveUnit(self.group, u)
                                u = FirstOfGroup(self.group)
                            end

                            BlzSetAbilityIntegerLevelField(self.ability, ABILITY_ILF_STRENGTH_BONUS_ISTR, level - 1, bonus)
                            IncUnitAbilityLevel(self.unit, ABILITY)
                            DecUnitAbilityLevel(self.unit, ABILITY)
                        else
                            self:destroy()
                        end
                    end)
                end
            end
        end

        function HolyUnity.onInit()
            RegisterSpell(HolyUnity.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, HolyUnity.onLevelUp)
        end
    end
end)