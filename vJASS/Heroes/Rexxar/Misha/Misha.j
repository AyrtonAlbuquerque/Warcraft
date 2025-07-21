library Misha requires RegisterPlayerUnitEvent, Spell, NewBonus, Periodic, Utilities
    /* ------------------------- Misha v1.1 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard - Icon
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
    private function GetMishaHealth takes unit source, integer level returns real
        return 1500 + 500 * level + (0.125 * level) * BlzGetUnitMaxHP(source)
    endfunction
    
    // The Misha Damage
    private function GetMishaDamage takes unit source, integer level returns real
        return 25 + 25 * level + 0.5 * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction
    
    // The Misha Armor
    private function GetMishaArmor takes unit source, integer level returns real
        return 1. + 1. * level + (0.1 * level) * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Misha extends Spell
        readonly static group array group
        readonly static integer array owner
        
        private unit unit
        private integer id
        private integer level
        private player player
        
        method destroy takes nothing returns nothing
            set unit = null
            set player = null

            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r summons his companion |cffffcc00Misha|r to aid him in the battlefield. |cffffcc00Misha|r has |cffff0000" + N2S(GetMishaHealth(source, level), 0) + "|r |cffff0000Health|r, |cffff0000" + N2S(GetMishaDamage(source, level), 0) + "|r |cffff0000Damage|r and |cff808080" + N2S(GetMishaArmor(source, level), 0) + "|r |cff808080Armor|r."
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u
            local group g = CreateGroup()
            
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
                        call BlzSetUnitMaxHP(u, R2I(GetMishaHealth(unit, level)))
                        call SetUnitLifePercentBJ(u, 100)
                        call BlzSetUnitBaseDamage(u, R2I(GetMishaDamage(unit, level)), 0)
                        call BlzSetUnitArmor(u, GetMishaArmor(unit, level))
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
        endmethod
        
        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set id = Spell.source.id
            set unit = Spell.source.unit
            set level = Spell.level
            set player = Spell.source.player
            
            call StartTimer(0, false, this, -1)
        endmethod

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
    
        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary