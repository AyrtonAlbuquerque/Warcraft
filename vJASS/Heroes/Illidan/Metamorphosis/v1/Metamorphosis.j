library Metamorphosis requires DamageInterface, Spell, Utilities, NewBonus, Fear, Modules
    /* ------------------------------------- Metamorphosis v1.5 ------------------------------------- */
    // Credits:
    //     BLazeKraze      - Icon
    //     Mythic          - Damnation Black model (edited by me)
    //     Henry           - Dark Illidan model from Warcraft Underground
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Metamorphosis ability
        private constant integer ABILITY     = 'Idn5'
        // The raw code of the Metamorphosis buff
        public  constant integer BUFF        = 'BEme'
        // The Metamorphosis lift off model
        private constant string  MODEL       = "Damnation Black.mdl"
        // The fear model
        private constant string  FEAR_MODEL  = "Fear.mdl"
        // The the fear attachment point
        private constant string  ATTACH_FEAR = "overhead"
    endglobals

    // The Metamorphosis AoE for Fear effect
    private function GetAoE takes integer level returns real
        return 500. + 0.*level
    endfunction

    // The Metamorphosis Fear Duration
    private function GetDuration takes unit source, integer level returns real
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        endif
    endfunction

    // The Metamorphosis Health Bonus
    private function GetBonusHealth takes unit source, integer level returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 100*level
        else
            return 50*level
        endif
    endfunction

    // The Metamorphosis Damage Bonus
    private function GetBonusDamage takes unit source, integer level returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 10*level
        else
            return 5*level
        endif
    endfunction

    // The Metamorphosis Omnivamp Bonus
    private function GetOmnivampBonus takes unit source, integer level returns real
        return 0.15 * level
    endfunction

    // The Movement Speed Bonus
    private function GetMovementSpeedBonus takes unit source, integer level returns real
        return 50. * level
    endfunction

    // Fear Filter
    private function FearFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Metamorphosis extends Spell
        private unit unit
        private group group
        private player player
        private integer level

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Illidan|r transforms into a powerful |cffffcc00Demon|r and gains |cffff0000" + N2S(50 * level, 0) + "|r bonus |cffff0000Health|r and |cffff0000" + N2S(5 * level, 0) + "|r bonus |cffff0000Damage|r for each enemy unit affected by his transformation (doubled for |cffffcc00Heroes|r). |cffffcc00Illidan|r also gains |cffffcc00" + N2S(GetOmnivampBonus(source, level) * 100, 0) + "%|r |cff8080ffOmnivamp|r, |cff00ff00" + N2S(GetMovementSpeedBonus(source, level), 0) + " Movement Speed|r and |cffffcc00Fly|r movement type while in his dark form. When lifting off and landing while transforming, all enemy units within |cffffcc00" + N2S(GetAoE(level), 0) + " AoE|r will be |cffffcc00Feared|r for |cffffcc005|r seconds (|cffffcc002|r for Heroes)."
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u
            local integer health = 0
            local integer damage = 0

            call DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit), 2))
            call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(level), null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if FearFilter(player, u) then
                        set health = health + GetBonusHealth(u, level)
                        set damage = damage + GetBonusDamage(u, level)

                        call FearUnit(unit, u, GetDuration(u, level), FEAR_MODEL, ATTACH_FEAR, false)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call LinkBonusToBuff(unit, BONUS_HEALTH, health, BUFF)
            call LinkBonusToBuff(unit, BONUS_DAMAGE, damage, BUFF)
            call LinkBonusToBuff(unit, BONUS_OMNIVAMP, GetOmnivampBonus(unit, level), BUFF)
            call LinkBonusToBuff(unit, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(unit, level), BUFF)
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set group = CreateGroup()
            set level = Spell.level
            set unit = Spell.source.unit
            set player = Spell.source.player

            call StartTimer(0.5, false, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary