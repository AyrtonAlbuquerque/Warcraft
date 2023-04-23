scope WarriorHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I034'
        static constant string effect = "PurpleSphere.mdx"
        static constant real period  = 1.
    endmodule

    private constant function GetCooldown takes nothing returns real
        return 90.
    endfunction
    
    private constant function GetDuration takes nothing returns real
        return 15.
    endfunction

    private constant function GetBonusRegen takes nothing returns real
        return 20.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WarriorHelmet extends Item
        implement Configuration
    
        real strength = 7
        real healthRegen = 5

        private static real array cooldown
        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()

        private integer id

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc007|r Strength\n+ |cffffcc005|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Overheal|r: When Hero's life drops below |cffffcc0050%|r, |cff00ff00Health Regeneration|r is increased by |cffffcc0020 Hp/s|r for |cffffcc0015|r seconds.\n\nCooldown: |cffffcc00" + R2I2S(WarriorHelmet.cooldown[id]) + "|r") 
        endmethod

        private method remove takes integer i returns integer
            set cooldown[id] = 0
            set array[i] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]
                    set cooldown[id] = cooldown[id] - 1
                    
                    if cooldown[id] <= 0 then
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, item) and GetWidgetLife(Damage.target.unit) < (BlzGetUnitMaxHP(Damage.target.unit)*GetHealthFactor()) and cooldown[Damage.target.id] == 0 then
                set this = thistype.allocate(item)
                set id = Damage.target.id 
                set key = key + 1
                set array[key] = this
                set cooldown[id] = GetCooldown()
                
                call AddUnitBonusTimed(Damage.target.unit, BONUS_HEALTH_REGEN, GetBonusRegen(), GetDuration())
                call DestroyEffectTimed(AddSpecialEffectTarget(effect, Damage.target.unit, "chest"), GetDuration())

                if key == 0 then
                    call TimerStart(timer, period, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope