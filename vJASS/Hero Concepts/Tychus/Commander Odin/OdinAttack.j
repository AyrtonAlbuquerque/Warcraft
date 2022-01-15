library OdinAttack requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Missiles, Utilities
    /* ---------------------- Odin Attack v1.2 by Chopinski --------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Odin Attack ability
        public  constant integer ABILITY = 'A007'
        // The raw code of the Odin unit
        private constant integer ODIN    = 'E001'
        // The Missile model
        private constant string  MODEL   = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE   = 0.7
        // The BulMissilelet speed
        private constant real    SPEED   = 1500.
        // The Missile height offset
        private constant real    HEIGHT  = 100.
        // The Odin weapons angle
        private constant real    ANGLE   = 45*bj_DEGTORAD
        // The Odin weapons offset
        private constant real    OFFSET  = 125.
    endglobals

    // The X coordinate starting point for the misisles. This exists so the missiles
    // will come out of the odin model weapon barrels. i is the attack number.
    private function GetX takes real x, real face, integer i returns real
        if i == 2 then // right arm
            return x + OFFSET*Cos(face + ANGLE)
        else // left
            return x + OFFSET*Cos(face - ANGLE)
        endif
    endfunction

    // The Y coordinate starting point for the misisles. This exists so the missiles
    // will come out of the odin model weapon barrels. i is the attack number.
    private function GetY takes real y, real face, integer i returns real
        if i == 2 then // right arm
            return y + OFFSET*Sin(face + ANGLE)
        else // left
            return y + OFFSET*Sin(face - ANGLE)
        endif
    endfunction

    // The Explosion AoE
    private function GetAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The explosion damage
    private function GetDamage takes integer level returns real
        return 125.*level
    endfunction

    // The numebr of rockets per attack per level
    private function GetMissileCount takes integer level returns integer
        return 2 + 0*level
    endfunction

    // The max attack aoe at which randomness can occur, by deafult its the aoe filed from the abiltiy.
    private function GetAttackAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct OdinAttack extends Missiles
        real  aoe
        group group

        method onFinish takes nothing returns boolean
            local unit u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null)
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call DestroyGroup(group)

            set group = null
            return true
        endmethod

        private static method onCast takes nothing returns nothing
            local integer  i = GetMissileCount(Spell.level)
            local real     range
            local real     face
            local real     angle
            local real     offset
            local real     x
            local real     y
            local thistype this

            if i > 0 then
                set range = GetRandomRange(GetAttackAoE(Spell.source.unit, Spell.level))
                set face  = GetUnitFacing(Spell.source.unit)*bj_DEGTORAD
                loop
                    exitwhen i <= 0
                        set x      = GetX(Spell.source.x, face, i)
                        set y      = GetY(Spell.source.y, face, i)
                        set offset = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) - OFFSET
                        set angle  = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
                        set this   = thistype.create(x, y, HEIGHT, x + offset*Cos(angle), y + offset*Sin(angle), 50)
                        set model  = MODEL
                        set scale  = SCALE
                        set speed  = SPEED
                        set source = Spell.source.unit
                        set owner  = Spell.source.player
                        set damage = GetDamage(Spell.level)
                        set aoe    = GetAoE(Spell.level)
                        set group  = CreateGroup()

                        call launch()
                    set i = i - 1
                endloop
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()

            if GetUnitTypeId(source) == ODIN then
                call IssueTargetOrder(source, "attack", GetTriggerUnit())
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary