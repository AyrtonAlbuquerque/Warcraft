library MoltenShield requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, DamageInterface, NewBonusUtils
    /* --------------------- Molten Shield v1.5 by Chopinski -------------------- */
    // Credits:
    //     Power            - Shield model
    //     Mythic           - Explosion model
    //     Magtheridon96    - RegisterPlayerUnitEvent 
    //     Bribe            - SpellEffectEvent
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
    private struct MoltenShield
        static timer          timer = CreateTimer()
        static real array     stored
        static integer        didx = -1
        static thistype array data

        unit    unit
        integer index
        integer level

        method remove takes integer i returns integer
            set data[i]       = data[didx]
            set didx          = didx - 1
            set stored[index] = 0
            set unit          = null

            if didx == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > didx
                    set this = data[i]

                    if GetUnitAbilityLevel(unit, BUFF_ID) == 0 then
                        if stored[index] > 0 then
                            call UnitDamageArea(unit, GetUnitX(unit), GetUnitY(unit), GetDamageAoe(level), stored[index], ATTACK_TYPE, DAMAGE_TYPE, false, false, false)
                        endif
                        call DestroyEffect(AddSpecialEffectTarget(EXPLOSION_EFFECT, unit, ATTACH_POINT))
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real    damage = GetEventDamage()
            local integer buffed = GetUnitAbilityLevel(Damage.target.unit, BUFF_ID)

            if buffed > 0 and damage > 0 then
                set damage = damage*GetDamageFactor(buffed)
                set stored[Damage.target.id] = stored[Damage.target.id] + damage
                call BlzSetEventDamage(damage)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(Spell.target.unit, BUFF_ID) == 0 then
                set this       = thistype.allocate()
                set unit       = Spell.target.unit
                set index      = Spell.target.id
                set level      = Spell.level
                set didx       = didx + 1
                set data[didx] = this

                call LinkBonusToBuff(Spell.target.unit, BONUS_MOVEMENT_SPEED, GetMovementBonus(Spell.level), BUFF_ID)

                if didx == 0 then
                    call TimerStart(timer, 0.03125000, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u
        
            if GAIN_AT_LEVEL > 0 then
                set u = GetTriggerUnit()
                if GetUnitTypeId(u) == RAGNAROS_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary