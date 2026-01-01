OnInit("Misha", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- -------------------------------- Misha v1.2 by Chopinski -------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = S2A('Rex0')
    -- The raw code of the Misha unit
    Misha_MISHA   = S2A('rex0')

    -- The Misha Max Health
    local function GetMishaHealth(unit, level)
        return 1500 + 500 * level + (0.125 * level) * BlzGetUnitMaxHP(unit)
    end

    -- The Misha Damage
    local function GetMishaDamage(unit, level)
        return 25 + 25 * level + 0.5 * GetUnitBonus(unit, BONUS_DAMAGE)
    end

    -- The Misha Armor
    local function GetMishaArmor(unit, level)
        return 1. + 1. * level + (0.1 * level) * GetUnitBonus(unit, BONUS_DAMAGE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Misha = Class(Spell)

        local array = {}
        local owner = {}
        local creating = false

        Misha.group = {}

        function Misha:destroy()
            self.unit = nil
            self.player = nil
        end

        function Misha:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r summons his companion |cffffcc00Misha|r to aid him in the battlefield. |cffffcc00Misha|r has |cffff0000" .. N2S(GetMishaHealth(source, level), 0) .. "|r |cffff0000Health|r, |cffff0000" .. N2S(GetMishaDamage(source, level), 0) .. "|r |cffff0000Damage|r and |cff808080" .. N2S(GetMishaArmor(source, level), 0) .. "|r |cff808080Armor|r."
        end

        function Misha:onCast()
            local this = { destroy = Misha.destroy }
            
            this.unit = Spell.source.unit
            this.level = Spell.level
            this.player = Spell.source.player

            TimerStart(CreateTimer(), 0, false, function ()
                local g = CreateGroup()
                
                if not Misha.group[this.unit] then
                    Misha.group[this.unit] = CreateGroup()
                end
                
                GroupClear(Misha.group[this.unit])
                GroupEnumUnitsOfPlayer(g, this.player, nil)

                local u = FirstOfGroup(g)

                while u do
                    if UnitAlive(u) and GetUnitTypeId(u) == Misha_MISHA then
                        creating = true
                        owner[u] = this.unit

                        GroupAddUnit(Misha.group[this.unit], u)
                        BlzSetUnitMaxHP(u, R2I(GetMishaHealth(this.unit, this.level)))
                        SetUnitLifePercentBJ(u, 100)
                        BlzSetUnitBaseDamage(u, R2I(GetMishaDamage(this.unit, this.level)), 0)
                        BlzSetUnitArmor(u, GetMishaArmor(this.unit, this.level))

                        if not array[GetPlayerId(this.player)] then
                            array[GetPlayerId(this.player)] = {}
                        end

                        for i = 0, 5 do
                            if array[GetPlayerId(this.player)][i] and array[GetPlayerId(this.player)][i] ~= 0 then
                                UnitAddItemToSlotById(u, array[GetPlayerId(this.player)][i], i)
                            end
                        end

                        creating = false
                    end

                    GroupRemoveUnit(g, u)
                    u = FirstOfGroup(g)
                end

                DestroyGroup(g)
                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function Misha.onDeath()
            local source = GetTriggerUnit()
            local id = owner[source]
            
            if id then
                owner[source] = nil

                GroupRemoveUnit(Misha.group[id], source)

                for i = 0, 5 do
                    RemoveItem(UnitItemInSlot(source, i))
                end
            end
        end

        function Misha.onPickup()
            local unit = GetManipulatingUnit()
            local id = GetPlayerId(GetOwningPlayer(unit))

            if GetUnitTypeId(unit) == Misha_MISHA and not creating then
                for i = 0, 5 do
                    array[id][i] = GetItemTypeId(UnitItemInSlot(unit, i))
                end
            end
        end

        function Misha.onDrop()
            local removed = false
            local unit = GetManipulatingUnit()
            local id = GetPlayerId(GetOwningPlayer(unit))

            if GetUnitTypeId(unit) == Misha_MISHA and UnitAlive(unit) and not creating then
                for i = 0, 5 do
                    if not removed and GetItemTypeId(UnitItemInSlot(unit, i)) == GetItemTypeId(GetManipulatedItem()) then
                        removed = true
                        array[id][i] = nil
                    else
                        
                        array[id][i] = GetItemTypeId(UnitItemInSlot(unit, i))
                    end
                end
            end
        end

        function Misha.onInit()
            RegisterSpell(Misha.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, Misha.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, Misha.onDrop)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, Misha.onPickup)
        end
    end
end)