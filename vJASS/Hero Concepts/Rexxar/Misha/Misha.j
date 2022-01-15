library Misha requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonus, TimerUtils
    /* ------------------------- Misha v1.0 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY   = 'A000'
        // The raw code of the Misha unit
        public  constant integer MISHA     = 'n000'
    endglobals
    
    // The Misha Max Health
    private function GetMishaHealth takes unit source, integer level returns integer
        return 1500 + 500*level + R2I(BlzGetUnitMaxHP(source)*0.125*level)
    endfunction
    
    // The Misha Damage
    private function GetMishaDamage takes unit source, integer level returns integer
        return 25 + 25*level + R2I(GetUnitBonus(source, BONUS_DAMAGE)*0.5)
    endfunction
    
    // The Misha Armor
    private function GetMishaArmor takes unit source, integer level returns real
        return 1. + 1.*level + GetUnitBonus(source, BONUS_DAMAGE)*0.1*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Misha
        readonly static group array group
        readonly static integer array owner
        
        timer timer
        unit unit
        integer id
        integer level
        player player
    
        private static method onDeath takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer i = GetUnitUserData(source)
            local integer id = owner[i]
            
            if id != 0 then
                set owner[i] = 0
                call GroupRemoveUnit(group[id], source)
            endif
            
            set source = null
        endmethod
        
        private static method setup takes unit source, unit owner, integer level returns nothing
            local real r
            
            set r = GetUnitLifePercent(source)
            call BlzSetUnitMaxHP(source, GetMishaHealth(owner, level))
            call SetUnitLifePercentBJ(source, r)
            call BlzSetUnitBaseDamage(source, GetMishaDamage(owner, level), 0)
            call BlzSetUnitArmor(source, GetMishaArmor(owner, level))
        endmethod
        
        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local group g = CreateGroup()
            local unit u
            
            if group[id] == null then
                set group[id] = CreateGroup()
            endif
            
            call GroupClear(group[id])
            call GroupEnumUnitsOfPlayer(g, player, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) and GetUnitTypeId(u) == MISHA then
                        set owner[GetUnitUserData(u)] = id
                        call GroupAddUnit(group[id], u)
                        call setup(u, unit, level)
                    endif
                call GroupRemoveUnit(g, u)
            endloop
            call DestroyGroup(g)
            call ReleaseTimer(timer)
            call deallocate()
            
            set g = null
            set unit = null
            set timer = null
            set player = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            
            set timer = NewTimerEx(this)
            set id = Spell.source.id
            set unit = Spell.source.unit
            set level = Spell.level
            set player = Spell.source.player
            
            call TimerStart(timer, 0, false, function thistype.onExpire)
        endmethod
    
        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary