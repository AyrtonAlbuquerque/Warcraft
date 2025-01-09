library Spell requires RegisterPlayerUnitEvent
    private struct Unit
        private static location location = Location(0, 0)

        unit unit
        
        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod

        method operator x takes nothing returns real
            return GetUnitX(unit)
        endmethod

        method operator y takes nothing returns real
            return GetUnitY(unit)
        endmethod

        method operator z takes nothing returns real
            call MoveLocation(location, GetUnitX(unit), GetUnitY(unit))
            return GetUnitFlyHeight(unit) + GetLocationZ(location)
        endmethod

        method operator id takes nothing returns integer
            return GetUnitUserData(unit)
        endmethod

        method operator type takes nothing returns integer
            return GetUnitTypeId(unit)
        endmethod

        method operator handle takes nothing returns integer
            return GetHandleId(unit)
        endmethod

        method operator player takes nothing returns player
            return GetOwningPlayer(unit)
        endmethod

        method operator armor takes nothing returns real
            return BlzGetUnitArmor(unit)
        endmethod

        method operator mana takes nothing returns real
            return GetUnitState(unit, UNIT_STATE_MANA)
        endmethod

        method operator health takes nothing returns real
            return GetWidgetLife(unit)
        endmethod

        method operator agility takes nothing returns integer
            return GetHeroAgi(unit, true)
        endmethod

        method operator strength takes nothing returns integer
            return GetHeroStr(unit, true)
        endmethod

        method operator intelligence takes nothing returns integer
            return GetHeroInt(unit, true)
        endmethod

        method operator armortype takes nothing returns armortype
            return ConvertArmorType(BlzGetUnitIntegerField(unit, UNIT_IF_ARMOR_TYPE))
        endmethod

        method operator defensetype takes nothing returns defensetype
            return ConvertDefenseType(BlzGetUnitIntegerField(unit, UNIT_IF_DEFENSE_TYPE))
        endmethod

        method operator isHero takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_HERO)
        endmethod

        method operator isMelee takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MELEE_ATTACKER)
        endmethod

        method operator isRanged takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_RANGED_ATTACKER)
        endmethod

        method operator isSummoned takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_SUMMONED)
        endmethod

        method operator isStructure takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_STRUCTURE)
        endmethod

        method operator isMagicImmune takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
        endmethod

        static method create takes nothing returns thistype
            return thistype.allocate()
        endmethod
    endstruct

    private module MSpell
        private static method onInit takes nothing returns nothing
            set source = Unit.create()
            set target = Unit.create()
            
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.onCast)
        endmethod
    endmodule

    struct Spell extends array
        readonly static Unit source
        readonly static Unit target
        readonly static location location = Location(0, 0)

        static method operator x takes nothing returns real
            return GetSpellTargetX()
        endmethod

        static method operator y takes nothing returns real
            return GetSpellTargetY()
        endmethod

        static method operator z takes nothing returns real
            call MoveLocation(location, x, y)

            if target.unit != null then
                return target.z
            else
                return GetLocationZ(location)
            endif
        endmethod

        static method operator id takes nothing returns integer
            return GetSpellAbilityId()
        endmethod

        static method operator level takes nothing returns integer
            return GetUnitAbilityLevel(source.unit, id)
        endmethod

        static method operator ability takes nothing returns ability
            return BlzGetUnitAbility(source.unit, id)
        endmethod

        static method operator isAlly takes nothing returns boolean
            return IsUnitAlly(target.unit, source.player)
        endmethod

        static method operator isEnemy takes nothing returns boolean
            return IsUnitEnemy(target.unit, source.player)
        endmethod

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
                set source.unit = GetTriggerUnit()
                set target.unit = GetSpellTargetUnit()
            endif
        endmethod

        implement MSpell
    endstruct
endlibrary