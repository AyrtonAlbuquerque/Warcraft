library ScreamingBanshees requires SpellEffectEvent, PluginSpellEffect, NewBonusUtils, Missiles, Utilities
    /* ------------------ Screaming Banshees v1.2 by Chopinski ------------------ */
    // Credits:
    //     Bribe        - SpellEffectEvent
    //     4eNNightmare - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Screaming Banshees ability
        private constant integer ABILITY       = 'A00I'
        // The raw code of the Screaming Banshees Teleport ability
        private constant integer TELEPORT      = 'A00J'
        // The missile model
        private constant string  MISSILE_MODEL = "Abilities\\Spells\\Undead\\Possession\\PossessionTarget.mdl"
        // The missile size
        private constant real    MISSILE_SCALE = 1.25
        // The missile speed
        private constant real    MISSILE_SPEED = 750.
        // The hit model
        private constant string  HIT_MODEL     = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
        // The attachment point
        private constant string  ATTACH_POINT  = "origin"
    endglobals

    // The misisle max distance
    private function GetDistance takes integer level returns real
        return 800. + 100.*level
    endfunction

    // The armor reductoin duration
    private function GetDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The amount of armor reduced when passing through units
    private function GetArmorReduction takes integer level returns integer
        return 2 + 2*level
    endfunction

    // The missile collision size
    private function GetCollisionSize takes integer level returns real
        return 100. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and /*
            */ UnitAlive(target) and /*
            */ not IsUnitType(target, UNIT_TYPE_STRUCTURE) and /*
            */ not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ScreamingBanshees extends Missiles
        private static thistype array n

        integer idx
        integer armor
        real    dur
        boolean finish

        method onPeriod takes nothing returns boolean
            return finish
        endmethod

        method onHit takes unit hit returns boolean
            if Filtered(owner, hit) then
                call DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, hit, ATTACH_POINT))
                call AddUnitBonusTimed(hit, BONUS_ARMOR, -armor, dur)
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            call UnitRemoveAbility(source, TELEPORT)
            call BlzUnitHideAbility(source, ABILITY, false)
        endmethod

        private static method onCast takes nothing returns nothing
            local real     a    = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real     r    = GetDistance(Spell.level)
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 50, Spell.source.x + r*Cos(a), Spell.source.y + r*Sin(a), 50)

            set source    = Spell.source.unit
            set owner     = Spell.source.player
            set speed     = MISSILE_SPEED
            set model     = MISSILE_MODEL
            set scale     = MISSILE_SCALE
            set collision = GetCollisionSize(Spell.level)
            set armor     = GetArmorReduction(Spell.level)
            set dur       = GetDuration(Spell.level)
            set idx       = Spell.source.id
            set finish    = false
            set n[idx]    = this

            call UnitAddAbility(Spell.source.unit, TELEPORT)
            call BlzUnitHideAbility(Spell.source.unit, ABILITY, true)
            call launch()
        endmethod  
        
        private static method onRecast takes nothing returns nothing
            local thistype this

            if n[Spell.source.id] != 0 then
                set this = n[Spell.source.id]
                call SetUnitX(Spell.source.unit, x)
                call SetUnitY(Spell.source.unit, y)
                set finish = true
                set n[Spell.source.id] = 0
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterSpellEffectEvent(TELEPORT, function thistype.onRecast)
        endmethod
    endstruct
endlibrary