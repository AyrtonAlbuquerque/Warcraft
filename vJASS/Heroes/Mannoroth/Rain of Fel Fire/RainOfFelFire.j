library RainOfFelFire requires Missiles, SpellEffectEvent, PluginSpellEffect, Utilities
    /* ------------------- Rain of Fel Fire v1.4 by Chopinski ------------------- */
    // Credits:
    //     The Panda - InfernalShower icon
    //     Mythic    - Rain of Fire model
    //     Bribe     - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        //the raw code of the Rain of Fel Fire ability
        private constant integer    ABILITY            = 'A000'
        //the starting height of the missile
        private constant integer    START_HEIGHT       = 2000
        // The landing time of the falling misisle
        private constant real       LANDING_TIME       = 1.
        // The impact radius of the missile that will damage units.
        private constant real       IMPACT_RADIUS      = 120.
        //the missile model
        private constant string     MISSILE_MODEL      = "FelRain.mdx"
        //the dot model
        private constant string     DOT_MODEL          = "BurnLarge.mdx"
        //the dot attachment point
        private constant string     DOT_ATTACH         = "origin"
        // The Attack type of the damage dealt on imapact (Spell)
        private constant attacktype IMPACT_ATTACK_TYPE = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt on impact
        private constant damagetype IMPACT_DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        // The Attack type of the damage over time
        private constant attacktype DOT_ATTACK_TYPE    = ATTACK_TYPE_HERO
        // The Damage type of the damage over time
        private constant damagetype DOT_DAMAGE_TYPE    = DAMAGE_TYPE_UNIVERSAL
    endglobals

    // How long the spell will last
    private function GetDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The interval at which the rain of fire meteors spwan
    private function GetInterval takes integer level returns real
        return 0.2 + 0.*level
    endfunction

    // The max range that a rain of fel fire missile can spawn
    // By default it is the ability Area of Effect Field value
    private function GetRange takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The amount of damage dealt when the missile lands
    private function GetImpactDamage takes integer level returns real
        return 25.*level
    endfunction

    // The amount of damage over time dealt to units in range of the impact area
    private function GetDoTDamage takes integer level returns real
        return 5.*level
    endfunction

    // How long the dot will last
    private function GetDoTDuration takes integer level returns real
        return 4. + 0.*level
    endfunction

    // The interval at which the dot effect will do damage
    private function GetDoTInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // Filter for the units that will be damaged on impact and get DoT
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoT
        static timer timer = CreateTimer()
        static integer array n
        //Dynamic Indexing
        static integer didx = -1
        static thistype array data

        unit    source
        unit    target
        real    damage
        real    ticks
        real    decrement
        integer index
        effect  effect

        method remove takes integer i returns integer
            call DestroyEffect(effect)

            set data[i]  = data[didx]
            set didx     = didx - 1
            set n[index] = 0
            set source   = null
            set target   = null
            set effect   = null

            if didx == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > didx
                    set this = data[i]

                    if ticks > 0 then
                        if UnitAlive(target) then
                            call UnitDamageTarget(source, target, damage, true, false, DOT_ATTACK_TYPE, DOT_DAMAGE_TYPE, null)
                        else
                            set ticks = 0
                        endif
                    else
                        set i = remove(i)
                    endif
                    set ticks = ticks - decrement
                set i = i + 1
            endloop
        endmethod

        static method create takes unit src, unit tgt, real dmg, integer lvl returns thistype
            local integer  idx = GetUnitUserData(tgt)
            local thistype this
            
            if n[idx] != 0 then
                set this       = n[idx]
            else
                set this       = thistype.allocate()
                set source     = src
                set target     = tgt
                set damage     = dmg
                set effect     = AddSpecialEffectTarget(DOT_MODEL, tgt, DOT_ATTACH)
                set index      = idx
                set didx       = didx + 1
                set data[didx] = this
                set n[idx]     = this

                if didx == 0 then
                    call TimerStart(timer, GetDoTInterval(lvl), true, function thistype.onPeriod)
                endif
            endif

            if GetDoTInterval(lvl) > 0 then
                set ticks     = GetDoTDuration(lvl)/GetDoTInterval(lvl)
                set decrement = GetDoTInterval(lvl)
            else
                set ticks     = GetDoTDuration(lvl)
                set decrement = 1.
            endif

            return this
        endmethod
    endstruct

    private struct Meteor extends Missiles
        integer level

        method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local unit  u

            call GroupEnumUnitsInRange(g, x, y, IMPACT_RADIUS, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, IMPACT_ATTACK_TYPE, IMPACT_DAMAGE_TYPE, null) then
                            call DoT.create(source, u, GetDoTDamage(level), level)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop
            call DestroyGroup(g)

            set g = null
            return true
        endmethod
    endstruct

    private struct FelFire
        static thistype array data
        static timer          timer = CreateTimer()
        static integer        didx  = -1

        unit    unit
        real    x
        real    y
        real    duration
        integer level

        method remove takes integer i returns integer
            set data[i] = data[didx]
            set didx    = didx - 1
            set unit    = null

            if didx == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this
            local real theta
            local real radius
            local real x
            local real y                                              
            local Meteor meteor

            loop
                exitwhen i > didx
                    set this = data[i]

                    if duration > 0 then
                        set theta    = 2*bj_PI*GetRandomReal(0, 1)
                        set radius   = GetRandomRange(GetRange(unit, level))
                        set x        = .x + radius*Cos(theta)
                        set y        = .y + radius*Sin(theta)  
                        set meteor   = Meteor.create(x, y, START_HEIGHT, x, y, 20)

                        set meteor.damage   = GetImpactDamage(level)
                        set meteor.model    = MISSILE_MODEL
                        set meteor.source   = unit
                        set meteor.owner    = GetOwningPlayer(unit)
                        set meteor.level    = level
                        set meteor.duration = LANDING_TIME

                        call meteor.launch()
                    else
                        set i = remove(i)
                    endif
                    set duration = duration - GetInterval(level)
                set i = i + 1
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set unit       = Spell.source.unit
            set level      = Spell.level
            set duration   = GetDuration(Spell.level)
            set x          = Spell.x
            set y          = Spell.y
            set didx       = didx + 1
            set data[didx] = this

            if didx == 0 then
                call TimerStart(timer, GetInterval(Spell.level), true, function thistype.onPeriod)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary