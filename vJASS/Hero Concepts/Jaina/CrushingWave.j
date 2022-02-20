library CrushingWave requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities optional WaterElemental
    /* --------------------- Crushing Wave v1.0 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY   = 'A001'
        // The Wave model
        private constant string MODEL      = "LivingTide.mdl"
        // The Wave speed 
        private constant real SPEED        = 1250
        // The wave model scale
        private constant real SCALE        = 0.8
    endglobals

    // The wave damage
    private function GetDamage takes unit source, integer level returns real
        return 50. + 50.*level
    endfunction

    // The Wave collision
    private function GetCollision takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The water elemental search range
    private function GetAoE takes unit source, integer level returns real
        return 1000. + 0.*level
    endfunction

    // The wave travel distance
    private function GetTravelDistance takes unit source, integer level returns real
        return 1000. + 0.*level
    endfunction

    // The Wave slow amount
    private function GetSlowAmount takes unit source, integer level returns real
        return 0.1 + 0.1*level
    endfunction

    // The Slow duration
    private function GetSlowDuration takes unit source, integer level returns real
        return 1. + 0.25*level
    endfunction

    // The damae filter
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Wave extends Missiles
        unit unit
        real slow
        real timeout

        method onPeriod takes nothing returns boolean
            if unit != null then
                call SetUnitX(unit, x)
                call SetUnitY(unit, y)
            endif

            return false
        endmethod

        method onHit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SlowUnit(u, slow, timeout)
                endif
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            if unit != null then
                call PauseUnit(unit, false)
                call SetUnitAnimation(unit, "Stand")
                call SetUnitInvulnerable(unit, false)
            endif

            set unit = null
        endmethod
    endstruct

    private struct CrushingWave extends array
        private static method launch takes real x, real y, real z, real tx, real ty, real tz, unit source, player owner, integer level, unit elemental returns nothing
            local Wave wave = Wave.create(x, y, z, tx, ty, tz)
            
            set wave.model = MODEL
            set wave.scale = SCALE
            set wave.speed = SPEED
            set wave.source = source
            set wave.owner = owner
            set wave.unit = elemental
            set wave.damage = GetDamage(source, level)
            set wave.collision = GetCollision(source, level)
            set wave.slow = GetSlowAmount(source, level)
            set wave.timeout = GetSlowDuration(source, level)

            if elemental != null then
                call BlzSetUnitFacingEx(elemental, AngleBetweenCoordinates(x, y, tx, ty)*bj_RADTODEG)
                call PauseUnit(elemental, true)
                call SetUnitAnimationByIndex(elemental, 8)
                call SetUnitInvulnerable(elemental, true)
            endif

            call wave.launch()
        endmethod

        private static method onCast takes nothing returns nothing
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real offset = GetTravelDistance(Spell.source.unit, Spell.level)
            local group g
            local unit u

            call launch(Spell.source.x, Spell.source.y, 0, Spell.source.x + offset*Cos(angle), Spell.source.y + offset*Sin(angle), 0, Spell.source.unit, Spell.source.player, Spell.level, null)
            
            static if LIBRARY_WaterElemental then
                set g = CreateGroup()
                
                call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                        if UnitAlive(u) and GetUnitTypeId(u) == WaterElemental_ELEMENTAL then
                            if Elemental.owner(GetUnitUserData(u)) == Spell.source.unit then
                                call launch(GetUnitX(u), GetUnitY(u), 0, Spell.x, Spell.y, 0, Spell.source.unit, Spell.source.player, Spell.level, u)
                            endif
                        endif
                    call GroupRemoveUnit(g, u)
                endloop
                call DestroyGroup(g)
            endif

            set u = null
            set g = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary