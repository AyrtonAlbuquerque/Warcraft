scope HammerOfNature
    struct HammerOfNature extends Item
        static constant integer code = 'I07F'

        // Attributes
        real damage = 500
        real strength = 250
        real spellPower = 250

        private static integer array attack
        private static integer array remaining

        private real x
        private real y
        private unit unit
        private real amount
        private effect effect
        private player player
        private integer index
        private integer pulses

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call super.destroy()

            set unit = null
            set effect = null
            set player = null
            set remaining[index] = remaining[index] - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Damage\n+ |cffffcc00250|r Spell Power\n+ |cffffcc00250|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00300 AoE|r, dealing |cffffcc0040%%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Force of Nature|r: Every |cffffcc00fifth|r attack a powerfull blow will damage the target for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and create a |cffffcc00Pulsing Blast|r at the target location. The |cffffcc00Pulsing Blast|r heals all nearby allies and damages all nearby enemy units within |cffffcc00400 AoE|r  for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage / |cff00ff001000|r heal. If the blow kills the target, the damage / heal doubles as well as the amount of pulses. Max |cffffcc005|r pulsing blasts with |cffffcc005|r pulses.\n\nPulsing Blasts: |cffffcc00" + I2S(remaining[id]) + "|r")
        endmethod

        private method onPeriod takes nothing returns boolean
            set pulses = pulses - 1
            
            if pulses > 0 then
                call BlzPlaySpecialEffect(effect, ANIM_TYPE_BIRTH)
                call HealArea(player, x, y, 400, amount, "GreenHeal.mdl", "chest")
                call UnitDamageArea(unit, x, y, 400, amount, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, false, false, false)
            endif

            return pulses > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and Damage.source.isMelee and not Damage.target.isStructure then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= 5 then
                    set attack[Damage.source.id] = 0

                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, 1000, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)

                    if remaining[Damage.source.id] < 5 then
                        set this = thistype.new()
                        set unit = Damage.source.unit
                        set x = Damage.target.x
                        set y = Damage.target.y
                        set effect = AddSpecialEffect("NatureExplosion.mdl", x, y)
                        set player = Damage.source.player
                        set index = Damage.source.id
                        set remaining[Damage.source.id] = remaining[Damage.source.id] + 1

                        if GetSpellDamage(1000, Damage.source.unit) > GetWidgetLife(Damage.target.unit) then
                            set amount = 2000
                            set pulses = 10
                        else
                            set amount = 1000
                            set pulses = 5
                        endif

                        call StartTimer(1, true, this, -1)
                    endif
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SphereOfNature.code, GiantsHammer.code, 0, 0, 0)
        endmethod
    endstruct
endscope