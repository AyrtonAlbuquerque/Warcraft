OnInit("WaterElemental", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"

    -- --------------------------- Water Elemental v1.2 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY               = S2A('Jna0')
    -- The raw code of the Water Elemental unit
    WaterElemental_ELEMENTAL    = S2A('ujn0')
    -- The summon effect
    local MODEL                 = "WaterBurst.mdl"
    -- The summon effect scale
    local SCALE                 = 1

    -- The unit damage
    local function GetDamage(unit, level)
        return 30 + R2I(0.3 * GetUnitBonus(unit, BONUS_DAMAGE) + 0.3 * GetUnitBonus(unit, BONUS_SPELL_POWER))
    end

    -- The unit health
    local function GetHealth(unit, level)
        return 800 + R2I(0.3 * BlzGetUnitMaxHP(unit)) + R2I(1.5 + 0.5*level * GetUnitBonus(unit, BONUS_SPELL_POWER))
    end

    -- The unit armor
    local function GetArmor(unit, level)
        return 3. + GetUnitBonus(unit, BONUS_ARMOR)
    end

    -- The unit duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Elemental = Class()

        local array = {}

        Elemental:property("size", { get = function(self) return BlzGroupGetSize(self.group) end })

        function Elemental:destroy()
            for i = 0, self.size - 1 do
                array[BlzGroupUnitAt(self.group, i)] = nil
            end

            DestroyGroup(self.group)

            self.unit = nil
            self.group = nil
        end

        function Elemental:add(unit)
            array[unit] = self
            GroupAddUnit(self.group, unit)
        end

        function Elemental:command(target, x, y, order)
            if not target then
                if order == "stop" or order == "holdposition" then
                    GroupImmediateOrder(self.group, order)
                elseif order == "attackground" or order == "smart" or order == "move" or order == "attack" then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 300 * Cos(i*2*bj_PI/self.size), y + 300 * Sin(i*2*bj_PI/self.size))
                    end
                end
            else
                if order == "smart" or order == "move" or order == "attack" then
                    GroupTargetOrder(self.group, order, target)
                end
            end
        end

        function Elemental.owner(unit)
            local self = array[unit]

            if self then
                return self.unit
            else
                return nil
            end
        end

        function Elemental.create(unit)
            local self = Elemental.allocate()

            self.unit = unit
            self.group = CreateGroup()

            return self
        end

        function Elemental.onOrder()
            local unit = GetOrderedUnit()

            if GetUnitTypeId(unit) == WaterElemental_ELEMENTAL then
                if array[unit] then
                    local self = array[unit]
                    
                    if GetOrderTargetUnit() == unit then
                        if not IsUnitInGroup(unit, self.group) then
                            GroupAddUnit(self.group, unit)
                        end
                    else
                        if IsUnitSelected(unit, GetOwningPlayer(unit)) and IsUnitInGroup(unit, self.group) then
                            GroupRemoveUnit(self.group, unit)
                        end
                    end
                end
            end
        end

        function Elemental.onDeath()
            local unit = GetTriggerUnit()

            if GetUnitTypeId(unit) == WaterElemental_ELEMENTAL then
                if array[unit] then
                    local self = array[unit]

                    GroupRemoveUnit(self.group, unit)
                    array[unit] = nil
                end
            end
        end

        function Elemental.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, Elemental.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, Elemental.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, Elemental.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Elemental.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, Elemental.onOrder)
        end
    end

    do
        WaterElemental = Class(Spell)

        local array = {}

        function WaterElemental:destroy()
            self.elementals:destroy()
            array[self.unit] = nil
        end

        function WaterElemental:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r summon a |cffffcc00Water Elemental|r to aid her in combat. The |cffffcc00Water Elemental|r has |cffff0000" .. N2S(GetDamage(source, level), 0) .. "|r Attack Damage, |cffff0000" + N2S(GetHealth(source, level), 0) .. "|r |cffff0000Health|r and |cff808080" .. N2S(GetArmor(source, level), 0) .. "|r |cff808080Armor|r. By default the elementals shadow her movement and commands until any order is given. Ordering the elemental to follow |cffffcc00Jaina|r makes it shadow her again.\n\nLasts |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function WaterElemental:onCast()
            local angle = GetUnitFacing(Spell.source.unit)
            local unit = CreateUnit(Spell.source.player, WaterElemental_ELEMENTAL, Spell.source.x + 250 * math.cos(Deg2Rad(angle)), Spell.source.y + 250 * math.sin(Deg2Rad(angle)), angle)
            local this

            DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), 0, SCALE))

            if array[Spell.source.unit] then
                this = array[Spell.source.unit]
            else
                this = WaterElemental.allocate()
                this.unit = Spell.source.unit
                array[Spell.source.unit] = this
                this.elementals = Elemental.create(Spell.source.unit)
            end

            BlzSetUnitBaseDamage(unit, GetDamage(Spell.source.unit, Spell.level), 0)
            BlzSetUnitMaxHP(unit, GetHealth(Spell.source.unit, Spell.level))
            SetUnitLifePercentBJ(unit, 100)
            BlzSetUnitArmor(unit, GetArmor(Spell.source.unit, Spell.level))
            SetUnitAnimation(unit, "Birth")
            UnitApplyTimedLife(unit, S2A('BTLF'), GetDuration(Spell.source.unit, Spell.level))
            this.elementals:add(unit)
        end

        function WaterElemental.onDeindex()
            local self = array[GetIndexUnit()]

            if self then
                self:destroy()
            end
        end

        function WaterElemental.onOrder()
            local unit = GetOrderedUnit()
            local self = array[unit]

            if GetUnitAbilityLevel(unit, ABILITY) > 0 and self then
                self.elementals:command(GetOrderTargetUnit(), GetOrderPointX(), GetOrderPointY(), OrderId2String(GetIssuedOrderId()))
            end
        end

        function WaterElemental.onInit()
            RegisterSpell(WaterElemental.allocate(), ABILITY)
            RegisterUnitDeindexEvent(WaterElemental.onDeindex)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, WaterElemental.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, WaterElemental.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, WaterElemental.onOrder)
        end
    end
end)