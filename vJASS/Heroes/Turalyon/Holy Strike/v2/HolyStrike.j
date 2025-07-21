library HolyStrike requires DamageInterface, Spell, NewBonus
    /* ---------------------- Holy Strike v1.3 by Chopinski --------------------- */
    // Credits:
    //     AbstractCreativity - Icon
    //     Bribe              - SpellEffectEvent
    //     Blizzard           - Healing Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Holy Strike ablity
        private constant integer ABILITY      = 'A003'
        // The Holy Strike level 1 buff
        private constant integer BUFF_1       = 'B001'
        // The Holy Strike level 2 buff
        private constant integer BUFF_2       = 'B002'
        // The Holy Strike level 3 buff
        private constant integer BUFF_3       = 'B003'
        // The Holy Strike level 4 buff
        private constant integer BUFF_4       = 'B004'
        // The Holy Strike heal model
        private constant string  MODEL        = "HolyStrike.mdl"
        // The Holy Strike heal attchment point
        private constant string  ATTACH_POINT = "origin"
    endglobals

    // The Holy Strike Heal
    private function GetHeal takes integer level, boolean isRanged returns real
        local real heal = 10.*level

        if isRanged then
            set heal = heal/2
        endif

        return heal
    endfunction

    // The Holy Strike bonus strength per unit type
    private function GetBonus takes unit source, integer level returns integer 
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5 + 0*level
        else
            return 2 + 0*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HolyStrike extends Spell
        private unit unit
        private real aoe
        private group group
        private integer level
        private integer bonus
        private player player
        private ability ability

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
            set ability = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r provides to all nearby allied units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r the ability to |cffffcc00Holy Strike|r, healing |cffffcc00" + N2S(GetHeal(level, false), 0) + "|r health with every auto attack. Healing halved for ranged attacks. In addition |cffffcc00Turalyon|r gains |cffffcc002|r (|cffffcc005|r for |cffffcc00Heroes|r) |cffff0000Strength|r for every allied unit in range."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            call AddUnitBonus(unit, BONUS_STRENGTH, -bonus)
            call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), aoe, null)
            call GroupRemoveUnit(group, unit)

            set bonus = 0

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if UnitAlive(u) and IsUnitAlly(u, player) then
                        set bonus = bonus + GetBonus(u, level)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call AddUnitBonus(unit, BONUS_STRENGTH, bonus)

            return level > 0
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)

            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set bonus = 0
                set unit = source
                set this.level = level
                set group = CreateGroup()
                set player = GetOwningPlayer(source)
                set ability = BlzGetUnitAbility(source, skill)
                set aoe = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)

                call StartTimer(0.3, true, this, id)
            else
                set this = GetTimerInstance(id)
                set this.level = level
                set aoe = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.isEnemy then
                if GetUnitAbilityLevel(Damage.source.unit, BUFF_4) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(4, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_3) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(3, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_2) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(2, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_1) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(1, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                endif
            endif
        endmethod

        implement Periodic
        
        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary