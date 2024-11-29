scope FlamingArmor
    struct FlamingArmor extends Item
        static constant integer code = 'I05T'
        
        private static timer timer = CreateTimer()
        private static boolean array check
        private static thistype array array
        private static integer key = -1

        private unit unit
        private effect effect
        private group group
        private player player
        private integer index

        // Attributes
        real armor = 10
        real health = 18000

        private method remove takes integer i returns integer
            call DestroyEffect(effect)
            call DestroyGroup(group)

            set array[i] = array[key]
            set key = key - 1
            set check[index] = false
            set unit = null
            set effect = null
            set group = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0018000|r Health\n+ |cffffcc0010|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0015%%|r.\n\n|cff00ff00Passive|r: |cffffcc00Guarding Flames|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff0080ff" + AbilitySpellDamageEx(250, u) + "|r |cff0080ffMagic|r damage.")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local unit v
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItemOfType(unit, code) then
                        call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 400, null)
                        loop
                            set v = FirstOfGroup(group)
                            exitwhen v == null
                                if IsUnitEnemy(v, player)  and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl", v, "chest"))
                                    call UnitDamageTarget(unit, v, 250, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                endif
                            call GroupRemoveUnit(group, v)
                        endloop
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, code) then
                call BlzSetEventDamage(GetEventDamage()*0.85)
            endif
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer idx = GetUnitUserData(u)
            local thistype self

            if not check[idx] then
                set self = thistype.new()
                set self.unit = u
                set self.effect = AddSpecialEffectTarget("EmberOrange.mdx", u, "chest")
                set self.player = GetOwningPlayer(u)
                set self.group = CreateGroup()
                set self.index = idx
                set key = key + 1
                set array[key] = self
                set check[idx] = true

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, CloakOfFlames.code, FusedLifeCrystals.code, SteelArmor.code, 0, 0)
        endmethod
    endstruct
endscope