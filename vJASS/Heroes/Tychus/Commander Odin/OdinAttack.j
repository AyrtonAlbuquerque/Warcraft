library OdinAttack requires RegisterPlayerUnitEvent, Ability, Missiles, Utilities, NewBonus
    /* ---------------------- Odin Attack v1.3 by Chopinski --------------------- */
    // Credits:
    //     a-ravlik        - Icon
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
    private function GetDamage takes unit source, integer level returns real
        return 125. * level + 0.75 * GetUnitBonus(source, BONUS_DAMAGE)
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
    private struct Attack extends Missiles
        real aoe
        group group

        private method onFinish takes nothing returns boolean
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
    endstruct

    private struct OdinAttack extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Odin|r attacks shots |cffffcc00" + N2S(GetMissileCount(level), 0) + "|r rockets to a location nearby the primary target location, dealing |cffffcc00" + N2S(GetDamage(source, level), 0) + "|r damage to all nearby enemy units within |cffffcc00" + N2S(GetAoE(level), 0) + "|r AoE."
        endmethod

        private method onCast takes nothing returns nothing
            local real x
            local real y
            local Attack attack
            local integer i = GetMissileCount(Spell.level)
            local real face = GetUnitFacing(Spell.source.unit) * bj_DEGTORAD
            local real range = GetRandomRange(GetAttackAoE(Spell.source.unit, Spell.level))
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real offset = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) - OFFSET

            if i > 0 then
                loop
                    exitwhen i <= 0
                        set x = GetX(Spell.source.x, face, i)
                        set y = GetY(Spell.source.y, face, i)
                        set attack = Attack.create(x, y, HEIGHT, x + offset*Cos(angle), y + offset*Sin(angle), 50)
                        set attack.model = MODEL
                        set attack.scale = SCALE
                        set attack.speed = SPEED
                        set attack.source = Spell.source.unit
                        set attack.owner = Spell.source.player
                        set attack.group = CreateGroup()
                        set attack.aoe = GetAoE(Spell.level)
                        set attack.damage = GetDamage(Spell.source.unit, Spell.level)

                        call attack.launch()
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
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
        endmethod
    endstruct
endlibrary