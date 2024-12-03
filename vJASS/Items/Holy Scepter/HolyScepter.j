scope HolyScepter
    struct HolyScepter extends Item
        static constant integer code = 'I09L'

        // Attributes
        real manaRegen = 500
        real intelligence = 500
        real spellPowerFlat = 1250

        private static real array barrier
        
        private unit unit
        private effect effect
        private texttag texttag
        private integer index

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyTextTag(texttag)
            call super.destroy()

            set unit = null
            set effect = null
            set texttag = null
        endmethod

        private method onPeriod takes nothing returns boolean
            if barrier[index] > 0 then
                call SetTextTagText(texttag, R2I2S(barrier[index]), 0.015)
                call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                call SetTextTagColor(texttag, 255, 255, 255, 255)
                call SetTextTagPermanent(texttag, true)
            
                return true
            endif

            return false
        endmethod

        private static method onSpellDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this = GetTimerInstance(Damage.source.id)

            if damage > 0 then
                if UnitHasItemOfType(Damage.source.unit, code) then
                    if this == 0 then
                        set this = thistype.new()
                        set unit = Damage.source.unit
                        set effect = AddSpecialEffectTarget("DivineBarrier.mdx", Damage.source.unit, "origin")
                        set texttag = CreateTextTag()
                        set index = Damage.source.id

                        call StartTimer(0.03125, true, this, Damage.source.id)
                    endif

                    set barrier[index] = barrier[index] + damage*0.2
                endif
            endif
        endmethod  

        private static method onAttackDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 then
                if Damage.isEnemy and barrier[Damage.target.id] > 0 then
                    if damage > barrier[Damage.target.id] then
                        set damage = damage - barrier[Damage.target.id]
                        set barrier[Damage.target.id] = 0

                        call BlzSetEventDamage(damage)
                    else
                        set barrier[Damage.target.id] = barrier[Damage.target.id] - damage

                        call BlzSetEventDamage(0)
                    endif
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call thistype.allocate(code, WizardStaff.code, CrownOfRightouesness.code, 0, 0, 0)
        endmethod
    endstruct
endscope