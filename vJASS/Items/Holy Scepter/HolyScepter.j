scope HolyScepter
    struct HolyScepter extends Item
        static constant integer code = 'I09L'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        private static integer array struct
        private static real array barrier
        
        private unit unit
        private effect effect
        private texttag texttag
        private integer index

        // Attributes
        real manaRegen = 500
        real intelligence = 500
        real spellPowerFlat = 1250

        private method remove takes integer i returns integer
            call DestroyEffect(effect)
            call DestroyTextTag(texttag)

            set array[i] = array[key]
            set key = key - 1
            set struct[index] = 0
            set unit = null
            set effect = null
            set texttag = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if barrier[index] > 0 then
                        call SetTextTagText(texttag, R2I2S(barrier[index]), 0.015)
                        call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                        call SetTextTagColor(texttag, 255, 255, 255, 255)
                        call SetTextTagPermanent(texttag, true)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onSpellDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this

            if damage > 0 then
                if UnitHasItemOfType(Damage.source.unit, code) then
                    if struct[Damage.source.id] != 0 then
                        set this = struct[Damage.source.id]
                    else
                        set this = thistype.new()
                        set unit = Damage.source.unit
                        set effect = AddSpecialEffectTarget("DivineBarrier.mdx", Damage.source.unit, "origin")
                        set texttag = CreateTextTag()
                        set index = Damage.source.id
                        set key = key + 1
                        set array[key] = this
                        set struct[index] = this

                        if key == 0 then 
                            call TimerStart(timer, 0.03125, true, function thistype.onPeriod)
                        endif
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

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call thistype.allocate(code, WizardStaff.code, CrownOfRightouesness.code, 0, 0, 0)
        endmethod
    endstruct
endscope