scope NatureGoddessStaff
    struct NatureGoddessStaff extends Item
        static constant integer code = 'I08O'
        static constant integer ability = 'A018'
        static constant string lightning = "DRAL"
        static constant string effect = "Bloodborne_Defend.mdl"

        // Attributes
        real health = 400
        real spellPower = 100
        real intelligence = 20

        private unit unit
        private unit source
        private group group
        private real damage
        private player player
        private integer bounces

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set source = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00100|r Spell Power\n+ |cffffcc0020|r Intelligence\n+ |cffffcc00400|r Health\n\n|cff00ff00Passive|r: |cffffcc00Thorned Rose|r: |cff00ffffMagic|r damage dealt is amplified by |cffffcc0020%%|r.\n\n|cff00ff00Active|r: |cffffcc00Nature's Wrath|r: Creates |cff8080ffChain Lightning|r that bounces up to |cffffcc0010|r times between allied and enemy units, dealing |cff00ffff" + N2S((200 + 10 * GetWidgetLevel(u)) + (0.02 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage/heal."
        endmethod

        private method onPeriod takes nothing returns boolean
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsInRange(g, GetUnitX(unit), GetUnitY(unit), 500, null)
            call BlzGroupRemoveGroupFast(group, g)

            if BlzGroupGetSize(g) > 0 then
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                        if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            call GroupAddUnit(group, u)
                            call CreateLightningUnit2Unit(unit, u, 1, lightning)
                            call DestroyEffect(AddSpecialEffectTarget(effect, u, "origin"))

                            if IsUnitEnemy(u, player) then
                                call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                            else
                                call SetWidgetLife(u, GetWidgetLife(u) + damage)
                            endif

                            set unit = u
                            set bounces = bounces - 1

                            exitwhen true
                        endif
                    call GroupRemoveUnit(g, u)
                endloop

                call DestroyGroup(g)
            else
                return false
            endif

            set g = null

            return bounces > 0 and u != null
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 and UnitHasItemOfType(Damage.source.unit, code) then
                set Damage.amount = Damage.amount * 1.2
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate(0)

            set unit = Spell.target.unit
            set source = Spell.source.unit
            set player = Spell.source.player
            set group = CreateGroup()
            set bounces = 10
            set damage = (200 + 10 * Spell.source.level) + (0.02 * Spell.source.level * GetUnitBonus(Spell.source.unit, BONUS_SPELL_POWER))

            call CreateLightningUnit2Unit(Spell.source.unit, Spell.target.unit, 1, lightning)
            call DestroyEffect(AddSpecialEffectTarget(effect, Spell.target.unit, "origin"))
            call GroupAddUnit(group, Spell.target.unit)

            if Spell.isEnemy then
                call UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            else
                call SetWidgetLife(unit, GetWidgetLife(unit) + damage)
            endif

            call StartTimer(0.2, true, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamagingEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterItem(allocate(code), SphereOfNature.code, NatureStaff.code, 0, 0, 0)
        endmethod
    endstruct
endscope