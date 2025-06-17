scope HeatingCloak
    struct HeatingCloak extends Item
        static constant integer code = 'I07C'

        // Attributes
        real mana = 5000
        real health = 5000

        private static real array amount
        private static string array state
        private static string array cd

        private unit unit
        private item item
        private effect effect
        private group group
        private player player
        private string string
        private integer cooldown
        private integer index

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCloakOfFrost.blp")
            call deallocate()

            set unit = null
            set item = null
            set effect = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc005000|r Health\n+ |cffffcc005000|r Mana\n\n|cff00ff00Passive|r: |cffffcc00Immolation|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff00ffff" + N2S(amount[id], 0) + " Magic|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Turn up the Heat|r: Every |cffffcc0060|r seconds |cffffcc00Heating Cloak|r charges up and the damage dealt by its immolation is increased by |cff00ffff500 Magic|r damage for |cffffcc0030|r seconds.\n\n" + state[id] + "|cffffcc00" + cd[id] + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u
            
            if UnitHasItemOfType(unit, code) then
                set cooldown = cooldown - 1
                set group = CreateGroup()

                if cooldown >= 30 then
                    set cd[index] = I2S(cooldown - 30)

                    if cooldown == 30 then
                        call DestroyEffect(effect)
                        call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCoD.blp")
                        set string = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl"
                        set amount[index] = 1000
                        set state[index] = "Remaining Burst Time: "
                        set effect = AddSpecialEffectTarget("EmberOrange.mdx", unit, "chest")
                    endif
                else
                    set cd[index] = I2S(cooldown)

                    if cooldown == 0 then
                        call DestroyEffect(effect)
                        call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCloakOfFrost.blp")
                        set cooldown = 90
                        set string = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"
                        set amount[index] = 500
                        set state[index] = "Burst Cooldown: "
                        set effect = AddSpecialEffectTarget("EmberSnow.mdx", unit, "chest")
                    endif
                endif

                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 400, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if IsUnitEnemy(u, player)  and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            call DestroyEffect(AddSpecialEffectTarget(string, u, "chest"))
                            call UnitDamageTarget(unit, u, amount[index], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                call DestroyGroup(group)
            
                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self

            if not HasStartedTimer(id) then
                set self = thistype.allocate(0)
                set self.unit = u
                set self.item = i
                set self.effect = AddSpecialEffectTarget("EmberSnow.mdx", u, "chest")
                set self.string = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"
                set self.player = GetOwningPlayer(u)
                set self.index = id
                set self.cooldown = 90
                set state[id] = "Burst Cooldown: "
                set cd[id] = I2S(self.cooldown - 30)
                set amount[id]   = 500

                call StartTimer(1, true, self, id)
            endif
        endmethod  

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), OrbOfFire.code, OrbOfFrost.code, CloakOfFlames.code, 0, 0)
        endmethod
    endstruct
endscope