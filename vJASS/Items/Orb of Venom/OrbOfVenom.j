scope OrbOfVenom
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfVenom extends Item
        static constant integer code = 'I01K'
        static constant string effect = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl"
        static constant real period = 1.
        
        private static thistype array array
    
        private timer timer
        private unit unit
        private unit source
        private integer key
        private real duration

        // Attributes
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if duration > 0 then
                set duration = duration - period
                
                if UnitDamageTarget(source, unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffect(AddSpecialEffectTarget(effect, unit, "origin"))
                endif
            else
                call ReleaseTimer(timer)
                call super.destroy()
                
                set array[key] = 0
                set timer = null
                set unit = null
                set source = null
            endif
        endmethod
    
        private static method onDamage takes nothing returns nothing
            local thistype this
            
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                if array[Damage.target.id] != 0 then
                    set this = array[Damage.target.id]
                else
                    set this = thistype.new()
                    set timer = NewTimerEx(this)
                    set unit = Damage.target.unit
                    set source = Damage.source.unit
                    set key = Damage.target.id
                    set array[key] = this
                    
                    call TimerStart(timer, period, true, function thistype.onPeriod)
                endif

                set duration = GetDuration()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope