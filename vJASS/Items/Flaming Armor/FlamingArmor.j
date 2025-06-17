scope FlamingArmor
    struct FlamingArmor extends Item
        static constant integer code = 'I05T'
        
        // Attributes
        real armor = 10
        real health = 18000

        private unit unit
        private effect effect
        private group group
        private player player

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set effect = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0018000|r Health\n+ |cffffcc0010|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0015%%|r.\n\n|cff00ff00Passive|r: |cffffcc00Guarding Flames|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff0080ff" + N2S(250, 0) + "|r |cff0080ffMagic|r damage."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            if UnitHasItemOfType(unit, code) then
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 400, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if IsUnitEnemy(u, player)  and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl", u, "chest"))
                            call UnitDamageTarget(unit, u, 250, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            
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
                set self.group = CreateGroup()
                set self.player = GetOwningPlayer(u)
                set self.effect = AddSpecialEffectTarget("EmberOrange.mdx", u, "chest")

                call StartTimer(1, true, self, id)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, code) then
                call BlzSetEventDamage(GetEventDamage()*0.85)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), CloakOfFlames.code, FusedLifeCrystals.code, SteelArmor.code, 0, 0)
        endmethod
    endstruct
endscope