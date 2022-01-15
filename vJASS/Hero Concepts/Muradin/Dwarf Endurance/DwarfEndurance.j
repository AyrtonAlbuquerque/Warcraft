library DwarfEndurance requires RegisterPlayerUnitEvent, DamageInterface
    /* -------------------- Dwarf Endurance v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Magtheridon96  - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Dwarf Endurance ability
        private constant integer ABILITY        = 'A007'
        // The period at which health is restored
        private constant real    PERIOD         = 0.1
        // The model used
        private constant string  HEAL_EFFECT    = "GreenHeal.mdl"
        // The attachment point
        private constant string  ATTACH_POINT   = "origin"
    endglobals

    // The time necessary for muradin to not take damage until the ability activates
    private constant function GetCooldown takes nothing returns real
        return 4.
    endfunction

    // The heal per second
    private function GetHeal takes integer level returns real
        return 25. + 25.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DwarfEndurance
        static timer timer = CreateTimer()
        static integer array n
        static integer didx = -1
        static thistype array data

        unit    unit
        effect  effect
        integer idx
        real    count

        private method remove takes integer i returns integer
            call DestroyEffect(effect)

            set data[i] = data[didx]
            set didx    = didx - 1
            set n[idx]  = 0
            set unit    = null
            set effect  = null

            if didx == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  level
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > didx
                    set this = data[i]

                    set level = GetUnitAbilityLevel(unit, ABILITY)
                    if level > 0 then
                        if count == 0 then
                            if UnitAlive(unit) then
                                call SetWidgetLife(unit, GetWidgetLife(unit) + GetHeal(level)*PERIOD)
                            endif
                        else
                            set count = count - 1

                            if effect != null then
                                call DestroyEffect(effect)
                                set effect = null
                            endif

                            if count == 0 then
                                set effect = AddSpecialEffectTarget(HEAL_EFFECT, unit, ATTACH_POINT)
                            endif
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if GetUnitAbilityLevel(Damage.target.unit, ABILITY) > 0 then
                if n[Damage.target.id] != 0 then
                    set this  = n[Damage.target.id]
                    set count = GetCooldown()/PERIOD
                endif
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit     source = GetTriggerUnit()
            local boolean  skill  = GetLearnedSkill() == ABILITY
            local integer  index  = GetUnitUserData(source)
            local thistype this
        
            if skill and n[index] == 0 then
                set this       = thistype.allocate()
                set unit       = source
                set effect     = AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT)
                set idx        = index
                set count      = 0
                set didx       = didx + 1
                set data[didx] = this
                set n[index]   = this

                if didx == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                endif
            endif

            set source = null
        endmethod


        static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary