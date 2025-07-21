library ManaOrb requires RegisterPlayerUnitEvent, Utilities, NewBonus, DamageInterface, Spell, Periodic
    /* ------------------------ Mana Orb v1.1 by Chopinski ---------------------- */
    // Credits:
    //     Darkfang             - Icon
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     General Frank        - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY        = 'A006'
        // The raw code of the level 1 buff
        private constant integer BUFF_1         = 'B002'
        // The raw code of the level 2 buff
        private constant integer BUFF_2         = 'B003'
        // The raw code of the level 3 buff
        private constant integer BUFF_3         = 'B004'
        // The raw code of the level 4 buff
        private constant integer BUFF_4         = 'B005'
        // The orb model
        private constant string  MODEL          = "OrbWaterX.mdl"
        // The orb model scale
        private constant real    SCALE          = 1.
        // The pickup effect model
        private constant string  EFFECT         = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        // The pickup effect model attach point
        private constant string  ATTACH         = "origin"
        // The update period
        private constant real    PERIOD         = 0.25
    endglobals

    // The orb duration
    private function GetDuratoin takes integer buffid returns real
        if buffid == BUFF_1 then
            return 20.
        elseif buffid == BUFF_2 then
            return 20.
        elseif buffid == BUFF_3 then
            return 20.
        else
            return 20.
        endif
    endfunction

    // The max mana bonus
    private function GetManaBonus takes integer buffid returns real
        if buffid == BUFF_1 then
            return 20.
        elseif buffid == BUFF_2 then
            return 30.
        elseif buffid == BUFF_3 then
            return 40.
        else
            return 50.
        endif
    endfunction

    // The chance to drop an orb
    private function GetDropChance takes unit target, integer buffid returns integer
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 100
        else
            if buffid == BUFF_1 then
                return 20
            elseif buffid == BUFF_2 then
                return 20
            elseif buffid == BUFF_3 then
                return 20
            else
                return 20
            endif
        endif
    endfunction

    // The orb pickup range
    private function GetPickupRange takes integer buffid returns real
        if buffid == BUFF_1 then
            return 100.
        elseif buffid == BUFF_2 then
            return 100.
        elseif buffid == BUFF_3 then
            return 100.
        else
            return 100.
        endif
    endfunction

    // The unit drop filter
    private function UnitDropFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    // The unit pickup filter
    private function UnitPickupFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitType(target, UNIT_TYPE_HERO) and IsUnitEnemy(target, owner)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ManaOrb extends Spell
        private static integer array buff

        private real x
        private real y
        private real bonus
        private real range
        private group group
        private player player
        private effect effect
        private real duration

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call deallocate()
            
            set group = null
            set player = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Enemy units that die within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r of |cffffcc00Jaina|r have a |cffffcc00" + N2S(20, 0) + "%|r chance to drop a |cff00ffffMana Orb|r. Enemy heroes always drop an orb. Whenever |cffffcc00Jaina|r or an allied |cffffcc00Hero|r comes near a |cff00ffffMana Orb|r they will collect it, gaining |cff00ffff" + N2S(10 + 10 * level, 0) + "|r maximum mana. The orb lingers for |cffffcc0020|r seconds before disappearing."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - PERIOD

            if duration > 0 then
                call GroupEnumUnitsInRange(group, x, y, range, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitPickupFilter(player, u) then
                            call AddUnitBonus(u, BONUS_MANA, bonus)
                            call DestroyEffect(AddSpecialEffectTarget(EFFECT, u, ATTACH))
                            
                            return false
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif

            set u = null

            return duration > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 then
                set buff[Damage.target.id] = 0
                
                if Damage.amount >= Damage.target.health and UnitDropFilter(Damage.target.unit) then
                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_4) then
                            set buff[Damage.target.id] = BUFF_4
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_3) then
                            set buff[Damage.target.id] = BUFF_3
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_2) then
                            set buff[Damage.target.id] = BUFF_2
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_1) then
                            set buff[Damage.target.id] = BUFF_1
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer id = GetUnitUserData(source)
            local thistype this
            
            if buff[id] != 0 then
                set this = thistype.allocate()
                set x = GetUnitX(source)
                set y = GetUnitY(source)
                set group = CreateGroup()
                set player = GetOwningPlayer(source)
                set effect = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
                set duration = GetDuratoin(buff[id])
                set range = GetPickupRange(buff[id])
                set bonus = GetManaBonus(buff[id])
                
                call StartTimer(PERIOD, true, this, -1)
            endif

            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary
