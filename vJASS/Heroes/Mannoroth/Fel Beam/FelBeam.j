library FelBeam requires Missiles, Spell, Modules, NewBonus, Utilities
    /* ----------------------- Fel Beam v1.6 by Chopinski ----------------------- */
    // Credits:
    //     BPower    - Missile Library
    //     AZ        - Fel Beam model
    //     nGy       - Haunt model
    //     The Panda - ToxicBeam icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fel Beam ability
        public constant integer     ABILITY       = 'Mnr2'
        // The beam inicial z offset
        private constant real       START_HEIGHT  = 60
        // The beam final z offset
        private constant real       END_HEIGHT    = 60
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
    private function GetDamage takes unit source, integer level returns real
        return 100. * level + (0.8 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
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
        readonly static boolean array cursed

        private unit unit
        private integer id
        private integer armor
        private real duration
        private effect effect

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call AddUnitBonus(unit, BONUS_ARMOR, armor)

            set unit = null
            set effect = null
            set cursed[id] = false

            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 0.5

            return duration > 0 and UnitAlive(unit)
        endmethod

        static method create takes unit target, real duration, integer amount returns thistype
            local integer i = GetUnitUserData(target)
            local thistype this = GetTimerInstance(i)

            if this == 0 then
                set this = thistype.allocate()
                set id = i
                set unit = target
                set armor = amount
                set effect = AddSpecialEffectTarget(CURSE_MODEL, target, CURSE_ATTACH)

                call StartTimer(0.5, true, this, i)
                call AddUnitBonus(target, BONUS_ARMOR, -amount)
            endif

            set this.duration = duration

            return this
        endmethod

        implement Periodic
    endstruct

    struct Beam extends Missile
        integer id
        integer armor
        real curse_duration

        private method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                set Curse.cursed[id] = true

                if UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                    call Curse.create(target, curse_duration, armor)
                endif
            endif

            return true
        endmethod
    endstruct

    struct FelBeam extends Spell
        static unit array source

        static method launch takes Beam beam, unit caster, unit target, integer level returns nothing
            set beam.source = caster
            set beam.target = target
            set beam.model = MISSILE_MODEL
            set beam.scale = MISSILE_SCALE
            set beam.speed = MISSILE_SPEED
            set beam.id = GetUnitUserData(target)
            set beam.damage = GetDamage(caster, level)
            set beam.owner = GetOwningPlayer(caster)
            set beam.armor = GetArmorReduction(level)
            set beam.curse_duration = GetCurseDuration(level)
            set source[beam.id] = caster

            call beam.launch()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Mannoroth|r launch at the target unit a |cffffcc00Fel Beam|r, that apply |cffffcc00Fel Curse|r and deals |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage. The cursed unit have it's armor reduced by |cffffcc00" + N2S(GetArmorReduction(level), 0) + "|r and if it dies under the effect of |cffffcc00Fel Curse|r curse, another |cffffcc00Fel Beam|r will spawn from it's location and seek a nearby enemy unit within |cffffcc00" + N2S(GetSearchRange(level), 0) + " AoE|r.\n\nLast for |cffffcc00" + N2S(GetCurseDuration(level), 1) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local Beam beam = Beam.create(Spell.source.x, Spell.source.y, START_HEIGHT, Spell.target.x, Spell.target.y, END_HEIGHT)
            
            call launch(beam, Spell.source.unit, Spell.target.unit, Spell.level)
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killed = GetTriggerUnit()
            local integer id = GetUnitUserData(killed)
            local unit caster = source[id]
            local real x
            local real y
            local real z
            local unit u
            local group g
            local Beam beam
            local integer level
        
            if Curse.cursed[id] then
                if source[id] == null then
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
                    set u = GroupPickRandomUnit(g)
                    set beam = Beam.create(x, y, z, GetUnitX(u), GetUnitY(u), END_HEIGHT)

                    call launch(beam, caster, u, level)
                endif

                call DestroyGroup(g)

                set source[id] = null
                set Curse.cursed[id] = false
            endif
        
            set g = null
            set u = null
            set killed = null
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary