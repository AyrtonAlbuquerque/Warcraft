library FelBeam requires Missiles, SpellEffectEvent, PluginSpellEffect, NewBonus, Utilities
    /* ----------------------- Fel Beam v1.4 by Chopinski ----------------------- */
    // Credits:
    //     BPower    - Missile Library
    //     Bribe     - SpellEffectEvent
    //     AZ        - Fel Beam model
    //     nGy       - Haunt model
    //     The Panda - ToxicBeam icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Rain of Fel Fire ability
        public constant integer     ABILITY       = 'A001'
        // The beam inicial z offset
        private constant real       START_HEIGHT  = 60
        // The beam final z offset
        private constant real       END_HEIGHT    = 60
        // The landing time of the falling misisle
        private constant real       LANDING_TIME  = 1.5
        // The impact radius of the missile that will damage units.
        private constant real       IMPACT_RADIUS = 120.
        // The missile model
        private constant string     MISSILE_MODEL = "Fel_Beam.mdx"
        // The size of the fel beam
        private constant real       MISSILE_SCALE = 0.5
        // The beam missile speed
        private constant real       MISSILE_SPEED = 1250
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE   = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt 
        private constant damagetype DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC
        // The curse model
        private constant string     CURSE_MODEL   = "FelCurse.mdx"
        // The curse attachment point
        private constant string     CURSE_ATTACH  = "chest"
    endglobals

    // The search range of units after a cursed unit dies
    private function GetSearchRange takes integer level returns real
        return 1000. + 0.*level
    endfunction

    // The damage amount
    private function GetDamage takes integer level returns real
        return 50. * (level*level -2*level + 2)
    endfunction

    // The amount of armor reduced
    public function GetArmorReduction takes integer level returns integer
        return level + 1
    endfunction

    // How long the curse lasts
    public function GetCurseDuration takes integer level returns real
        return 15. + 0.*level
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Curse
        static timer timer = CreateTimer()
        static integer array n
        static boolean array cursed
        //Dynamic Indexing
        static integer didx = -1
        static thistype array data

        unit    unit
        integer armor
        integer index
        real    ticks
        effect  effect

        method remove takes integer i returns integer
            call DestroyEffect(effect)
            call AddUnitBonus(unit, BONUS_ARMOR, armor)

            set data[i]       = data[didx]
            set didx          = didx - 1
            set cursed[index] = false
            set n[index]      = 0
            set unit          = null
            set effect        = null

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

                    if ticks <= 0 or not UnitAlive(unit) then
                        set i = remove(i)
                    endif
                    set ticks = ticks - 0.5
                set i = i + 1
            endloop
        endmethod

        static method create takes unit target, real duration, integer amount returns thistype
            local integer  idx = GetUnitUserData(target)
            local thistype this

            if n[idx] != 0 then
                set this       = n[idx]
            else
                set this       = thistype.allocate()
                set unit       = target
                set armor      = amount
                set effect     = AddSpecialEffectTarget(CURSE_MODEL, target, CURSE_ATTACH)
                set index      = idx
                set didx       = didx + 1
                set data[didx] = this
                set n[idx]     = this

                call AddUnitBonus(target, BONUS_ARMOR, -amount)
                if didx == 0 then
                    call TimerStart(timer, 0.5, true, function thistype.onPeriod)
                endif
            endif

            if duration >= 0.5 then
                set ticks = duration
            else
                set ticks = 0.
            endif

            return this
        endmethod
    endstruct

    struct Beam extends Missiles
        integer armor
        integer index
        real    curse_duration

        method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                set Curse.cursed[index] = true
                if UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                    call Curse.create(target, curse_duration, armor)
                endif
            endif

            return true
        endmethod
    endstruct

    struct FelBeam
        static unit array source

        static method launch takes Beam beam, unit caster, unit target, integer level returns nothing
            set beam.source         = caster
            set beam.target         = target
            set beam.model          = MISSILE_MODEL
            set beam.scale          = MISSILE_SCALE
            set beam.speed          = MISSILE_SPEED
            set beam.damage         = GetDamage(level)
            set beam.owner          = GetOwningPlayer(caster)
            set beam.armor          = GetArmorReduction(level)
            set beam.curse_duration = GetCurseDuration(level)
            set beam.index          = GetUnitUserData(target)
            set source[beam.index]  = caster

            call beam.launch()
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit    killed = GetTriggerUnit()
            local integer index  = GetUnitUserData(killed)
            local unit    caster = source[index]
            local integer level
            local real    x
            local real    y
            local real    z
            local group   g
            local unit    v
            local Beam    beam
        
            if Curse.cursed[index] then
                if source[index] == null then
                    set caster = GetKillingUnit()
                    set level  = 1
                else
                    set level = GetUnitAbilityLevel(caster, ABILITY)
                endif
        
                set x = GetUnitX(killed)
                set y = GetUnitY(killed)
                set z = GetUnitFlyHeight(killed) + START_HEIGHT
                set g = GetEnemyUnitsInRange(GetOwningPlayer(caster), x, y, GetSearchRange(level), false, false)
                if BlzGroupGetSize(g) > 0 then
                    set v    = GroupPickRandomUnit(g)
                    set beam = Beam.create(x, y, z, GetUnitX(v), GetUnitY(v), END_HEIGHT)
                    call launch(beam, caster, v, level)
                endif
                call DestroyGroup(g)
                set source[index]       = null
                set Curse.cursed[index] = false
            endif
        
            set g      = null
            set v      = null
            set killed = null
            set caster = null
        endmethod

        private static method onCast takes nothing returns nothing
            local Beam beam = Beam.create(Spell.source.x, Spell.source.y, START_HEIGHT, Spell.target.x, Spell.target.y, END_HEIGHT)
            
            call launch(beam, Spell.source.unit, Spell.target.unit, Spell.level)
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary