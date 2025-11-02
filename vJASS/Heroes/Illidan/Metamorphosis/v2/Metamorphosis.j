library Metamorphosis requires DamageInterface, Spell, Utilities, NewBonus, CrowdControl, Modules, SpellEffectEvent, Combat, TimerUtils
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
        // The raw code of the Metamorphosis tranformation ability
        public  constant integer MORPH       = 'Idn7'
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
        return 400. + 0.*level
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

    // The amount of in combat time required to transform
    private function GetInCombatTime takes integer level returns real
        return 10. - 0.*level
    endfunction

    // The transformation duration after leaving combat
    private function GetOutOfCombatDuration takes integer level returns real
        return 5. + 0.*level
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
        private real time
        private timer timer
        private group group
        private player player
        private integer level

        method destroy takes nothing returns nothing
            call deallocate()
            
            set unit = null
            set group = null
            set timer = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "After staying in combat for |cffffcc00" + N2S(GetInCombatTime(level), 0) + "|r seconds, |cffffcc00Illidan|r transforms into a powerful |cffffcc00Demon|r and gains |cffff0000" + N2S(50 * level, 0) + "|r bonus |cffff0000Health|r and |cffff0000" + N2S(5 * level, 0) + "|r bonus |cffff0000Damage|r for each enemy unit affected by his transformation (doubled for |cffffcc00Heroes|r). |cffffcc00Illidan|r also gains |cffffcc00" + N2S(GetOmnivampBonus(source, level) * 100, 0) + "%|r |cff8080ffOmnivamp|r, |cff00ff00" + N2S(GetMovementSpeedBonus(source, level), 0) + " Movement Speed|r and |cffffcc00Fly|r movement type while in his dark form. When lifting off and landing while transforming, all enemy units within |cffffcc00" + N2S(GetAoE(level), 0) + " AoE|r will be |cffffcc00Feared|r for |cffffcc005|r seconds (|cffffcc002|r for Heroes). |cffffcc00Illidan|r transforms back to his normal form |cffffcc00" + N2S(GetOutOfCombatDuration(level), 0) + "|r seconds after exiting combat."
        endmethod

        private method onExpire takes nothing returns nothing
            if GetUnitAbilityLevel(unit, BUFF) > 0 and not IsUnitInCombat(unit) then
                call IssueImmediateOrder(unit, "metamorphosis")
            endif
        endmethod

        private method onPeriod takes nothing returns boolean
            set time = time - 1

            if time <= 0 then
                if GetUnitAbilityLevel(unit, MORPH) == 0 then
                    call UnitAddAbility(unit, MORPH)
                    call UnitMakeAbilityPermanent(unit, true, MORPH)
                endif

                call IssueImmediateOrder(unit, "metamorphosis")
            endif

            return time > 0 and IsUnitInCombat(unit) and GetUnitAbilityLevel(unit, BUFF) == 0
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            if IsUnitInCombat(source) then
                set this = thistype.allocate()
                set unit = source
                set time = GetInCombatTime(level)

                call StartTimer(1, true, this, 0)
            endif
        endmethod

        private static method onApply takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer health = 0
            local integer damage = 0
            local unit u

            call DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit), 2))
            call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(level), null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if FearFilter(player, u) then
                        set health = health + GetBonusHealth(u, level)
                        set damage = damage + GetBonusDamage(u, level)

                        call FearUnit(u, GetDuration(u, level), FEAR_MODEL, ATTACH_FEAR, false)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call LinkBonusToBuff(unit, BONUS_HEALTH, health, BUFF)
            call LinkBonusToBuff(unit, BONUS_DAMAGE, damage, BUFF)
            call LinkBonusToBuff(unit, BONUS_OMNIVAMP, GetOmnivampBonus(unit, level), BUFF)
            call LinkBonusToBuff(unit, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(unit, level), BUFF)
            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call destroy()
        endmethod

        private static method onSpell takes nothing returns nothing
            local thistype this = thistype.allocate()

            set unit = Spell.source.unit
            set player = Spell.source.player
            set group = CreateGroup()
            set timer = NewTimerEx(this)
            set level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)

            call TimerStart(timer, 0.5, false, function thistype.onApply)
        endmethod

        private static method onEnter takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(GetCombatSourceUnit(), ABILITY) > 0 then
                set this = thistype.allocate()
                set unit = GetCombatSourceUnit()
                set time = GetInCombatTime(GetUnitAbilityLevel(unit, ABILITY))

                call StartTimer(1, true, this, 0)
            endif
        endmethod

        private static method onLeave takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(GetCombatSourceUnit(), MORPH) > 0 then
                set this = thistype.allocate()
                set unit = GetCombatSourceUnit()

                call StartTimer(GetOutOfCombatDuration(GetUnitAbilityLevel(unit, ABILITY)), false, this, -1)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterUnitEnterCombatEvent(function thistype.onEnter)
            call RegisterUnitLeaveCombatEvent(function thistype.onLeave)
            call RegisterSpellEffectEvent(MORPH, function thistype.onSpell)
        endmethod
    endstruct
endlibrary