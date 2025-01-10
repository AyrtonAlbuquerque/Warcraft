library ScreamingBanshees requires Ability, NewBonus, Missiles, Utilities
    /* ------------------ Screaming Banshees v1.3 by Chopinski ------------------ */
    // Credits:
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
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Banshee extends Missiles
        real timeout
        integer armor

        private method onHit takes unit hit returns boolean
            if Filtered(owner, hit) then
                call DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, hit, ATTACH_POINT))
                call AddUnitBonusTimed(hit, BONUS_ARMOR, -armor, timeout)
            endif

            return false
        endmethod

        private method onRemove takes nothing returns nothing
            call UnitRemoveAbility(source, TELEPORT)
            call BlzUnitHideAbility(source, ABILITY, false)
        endmethod
    endstruct

    private struct ScreamingBanshees extends Ability
        private static Banshee array array

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Sylvanas|r releases |cffffcc00Screaming Banshees|r in the target direction. The banshees travel |cffffcc00" + N2S(GetDistance(level), 0) + "|r distance and when passing through an enemy unit it reduces its |cff808080Armor|r by |cff808080" + N2S(GetArmorReduction(level), 0) + "|r for |cffffcc00" + N2S(GetDuration(level), 0) + "|r seconds. |cffffcc00Sylvanas|r can reactivate the ability to teleport to the banshees position."
        endmethod

        private method onCast takes nothing returns nothing
            local real angle
            local real distance
            local Banshee banshee

            if Spell.id == ABILITY then
                set distance = GetDistance(Spell.level)
                set angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
                set banshee = Banshee.create(Spell.source.x, Spell.source.y, 50, Spell.source.x + distance * Cos(angle), Spell.source.y + distance * Sin(angle), 50)

                set banshee.source = Spell.source.unit
                set banshee.owner = Spell.source.player
                set banshee.speed = MISSILE_SPEED
                set banshee.model = MISSILE_MODEL
                set banshee.scale = MISSILE_SCALE
                set banshee.collision = GetCollisionSize(Spell.level)
                set banshee.armor = GetArmorReduction(Spell.level)
                set banshee.timeout = GetDuration(Spell.level)
                set array[Spell.source.id] = banshee

                call UnitAddAbility(Spell.source.unit, TELEPORT)
                call BlzUnitHideAbility(Spell.source.unit, ABILITY, true)
                call banshee.launch()
            else
                set banshee = array[Spell.source.id]

                if banshee != 0 then
                    call SetUnitX(banshee.source, banshee.x)
                    call SetUnitY(banshee.source, banshee.y)
                    call IssueImmediateOrder(banshee.source, "stop")
                    call banshee.terminate()
                    set array[Spell.source.id] = 0
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpell(thistype.allocate(), TELEPORT)
        endmethod
    endstruct
endlibrary