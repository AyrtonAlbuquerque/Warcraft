library FelBlast requires SpellEffectEvent, PluginSpellEffect, TimerUtils, Utilities optional FelBeam
    /* ----------------------- Fel Blast v1.4 by Chopinski ---------------------- */
    // Credits:
    //     Vexorian - TimerUtils Library
    //     Bribe    - SpellEffectEvent
    //     Mythic   - Nther Blast model
    //     san      - Miasma icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the fel blast ability
        private constant integer    ABILITY       = 'A002'
        // The amount of time it takes to do the damage
        private constant real       BLAST_DELAY   = 0.75
        // The blast model
        private constant string     BLAST_MODEL   = "NetherBlast.mdx"
        // The size of the blast model
        private constant real       BLAST_SCALE   = 1.
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE   = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt 
        private constant damagetype DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC
    endglobals

    // The damage amount of the blast
    private function GetDamage takes unit u, integer level returns real
        return 50.*level + GetHeroStr(u, true)*(1 + 0.25*level)
    endfunction

    // The damage area of effect. By default is the ability AoE field in the editor
    private function GetAoE takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The filter for units that will be damaged by the fel blast
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct FelBlast
        unit    unit
        real    x
        real    y
        real    damage
        real    radius
        real    duration
        player  owner
        integer armor
        timer   timer

        private static method onBlast takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local group    g
            local unit     v
        
            set g = GetEnemyUnitsInRange(owner, x, y, radius, false, false)
            loop
                set v = FirstOfGroup(g)
                exitwhen v == null
                    if DamageFilter(owner, v) then
                        static if LIBRARY_FelBeam then
                            set FelBeam.source[GetUnitUserData(v)] = unit
                            set Curse.cursed[GetUnitUserData(v)]   = true
                            call Curse.create(v, duration, armor)
                        endif
                        call UnitDamageTarget(unit, v, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                    endif
                call GroupRemoveUnit(g, v)
            endloop
            call DestroyGroup(g)
            call ReleaseTimer(timer)
            
            set g     = null
            set timer = null
            set unit  = null
            set owner = null

            call deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer  = NewTimerEx(this)
            set unit   = Spell.source.unit
            set x      = Spell.x
            set y      = Spell.y
            set owner  = Spell.source.player
            set damage = GetDamage(unit, Spell.level)
            set radius = GetAoE(unit, Spell.level)

            static if LIBRARY_FelBeam then
                set armor    = FelBeam_GetArmorReduction(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
                set duration = FelBeam_GetCurseDuration(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
            endif
        
            call DestroyEffect(AddSpecialEffectEx(BLAST_MODEL, x, y, 0, BLAST_SCALE))
            call TimerStart(timer, BLAST_DELAY, false, function thistype.onBlast)
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary