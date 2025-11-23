scope HammerOfNature
    struct HammerOfNature extends Item
        static constant integer code = 'I07F'

        // Attributes
        real damage = 35
        real strength = 15
        real spellPower = 35

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
            call deallocate()

            set unit = null
            set effect = null
            set player = null
            set remaining[index] = remaining[index] - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0035|r Damage\n+ |cffffcc00350|r Spell Power\n+ |cffffcc0015|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00300 AoE|r, dealing |cffffcc0040%%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Force of Nature|r: Every |cffffcc00fifth|r attack a powerfull blow will damage the target for |cff00ffff" + N2S(200 + (10 * GetWidgetLevel(u)) + (0.2 * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage and create a |cffffcc00Pulsing Blast|r at the target location. The |cffffcc00Pulsing Blast|r heals all nearby allies and damages all nearby enemy units within |cffffcc00400 AoE|r  for |cff00ffff" + N2S(00 + (5 * GetWidgetLevel(u))  + (0.1 * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage / heal. If the blow kills the target, the damage / heal doubles as well as the amount of pulses. Max |cffffcc005|r pulsing blasts with |cffffcc005|r pulses.\n\nPulsing Blasts: |cffffcc00" + I2S(remaining[id]) + "|r"
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
            local real value
            local real heal

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and Damage.source.isMelee and not Damage.target.isStructure then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= 5 then
                    set attack[Damage.source.id] = 0
                    set heal = 100 + (5 * Damage.source.level) + (0.1 * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
                    set value = 200 + (10 * Damage.source.level) + (0.2 * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))

                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, value, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)

                    if remaining[Damage.source.id] < 5 then
                        set this = thistype.allocate(0)
                        set unit = Damage.source.unit
                        set x = Damage.target.x
                        set y = Damage.target.y
                        set effect = AddSpecialEffect("NatureExplosion.mdl", x, y)
                        set player = Damage.source.player
                        set index = Damage.source.id
                        set remaining[Damage.source.id] = remaining[Damage.source.id] + 1

                        if Damage.target.health < value then
                            set amount = 2 * heal
                            set pulses = 10
                        else
                            set amount = heal
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
            call RegisterItem(allocate(code), SphereOfNature.code, GiantsHammer.code, 0, 0, 0)
        endmethod
    endstruct
endscope