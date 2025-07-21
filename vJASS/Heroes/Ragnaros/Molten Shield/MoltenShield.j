library MoltenShield requires RegisterPlayerUnitEvent, Spell, DamageInterface, NewBonus
    /* --------------------- Molten Shield v1.6 by Chopinski -------------------- */
    // Credits:
    //     Power            - Shield model
    //     Mythic           - Explosion model
    //     Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Molten Shield Ability
        private constant integer    ABILITY           = 'A006'
        // The raw code of the Ragnaros unit in the editor
        private constant integer    RAGNAROS_ID       = 'H001'
        // The raw code of the buff used to link bonus
        private constant integer    BUFF_ID           = 'B001'
        // The GAIN_AT_LEVEL is greater than 0
        // ragnaros will gain molten shield at this level 
        private constant integer    GAIN_AT_LEVEL     = 20
        // The Explosion effect path
        private constant string     EXPLOSION_EFFECT  = "Damnation Orange.mdl"
        // The Explosion effect attachment point
        private constant string     ATTACH_POINT      = "origin"
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE       = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE       = DAMAGE_TYPE_FIRE
    endglobals

    private function GetDamage takes unit source, integer level, real stored returns real
        return stored + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The amount of movement speed the target of Molten Shield gains
    private function GetMovementBonus takes integer level returns integer
        return 100*level
    endfunction

    // The percentage of damage reduced to units with molten shield
    private function GetDamageFactor takes integer level returns real
        return 0.5
    endfunction

    // The damage area
    private function GetDamageAoe takes integer level returns real
        return 350. + 50*level
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct MoltenShield extends Spell
        private static real array stored

        private unit unit
        private integer id
        private integer level

        method destroy takes nothing returns nothing
            set unit = null
            set stored[id] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Upon cast engulfs the target in a |cffffcc00Molten shield|r that reduces all damage taken by |cffffcc00" + N2S(GetDamageFactor(level) * 100, 1) + "%|r and increases |cffffcc00Movement Speed|r by |cffffcc00" + N2S(GetMovementBonus(level), 0) + "|r for |cffffcc0010|r seconds. All damage reduced by |cffffcc00Molten Shield|r is stored and when depleated all damage stored is dealt as |cff00ffffMagic|r damage, dealing |cff00ffff" + N2S(GetDamage(source, level, stored[GetUnitUserData(source)]), 0) + " Magic|r damage to all enemy units within |cffffcc00" + N2S(GetDamageAoe(level), 0) + " AoE|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            if GetUnitAbilityLevel(unit, BUFF_ID) == 0 then
                if stored[id] > 0 then
                    call UnitDamageArea(unit, GetUnitX(unit), GetUnitY(unit), GetDamageAoe(level), GetDamage(unit, level, stored[id]), ATTACK_TYPE, DAMAGE_TYPE, false, false, false)
                endif

                call DestroyEffect(AddSpecialEffectTarget(EXPLOSION_EFFECT, unit, ATTACH_POINT))
                
                return false
            endif

            return true
        endmethod

        private method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(Spell.target.unit, BUFF_ID) == 0 then
                set this = thistype.allocate()
                set id = Spell.target.id
                set unit = Spell.target.unit
                set level = Spell.level

                call StartTimer(0.03125, true, this, -1)
                call LinkBonusToBuff(Spell.target.unit, BONUS_MOVEMENT_SPEED, GetMovementBonus(Spell.level), BUFF_ID)
            endif
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == RAGNAROS_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target.unit, BUFF_ID)

            if level > 0 and Damage.amount > 0 then
                set Damage.amount = Damage.amount * GetDamageFactor(level)
                set stored[Damage.target.id] = stored[Damage.target.id] + Damage.amount
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary