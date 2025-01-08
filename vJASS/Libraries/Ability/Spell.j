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

        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()

            set unit = u
            
            return this
        endmethod
    endstruct

    private module MSpell
        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.onCast)
        endmethod
    endmodule

    struct Spell extends array
        private static thistype key = 0
        readonly static location location = Location(0, 0)

        private real tx
        private real ty
        private integer spell
        private Unit sources
        private Unit targets

        method destroy takes nothing returns nothing
            call sources.destroy()
            call targets.destroy()

            set tx = 0
            set ty = 0
            set spell = 0
            set key = key - 1
        endmethod

        static method operator x takes nothing returns real
            return Spell.key.tx
        endmethod

        static method operator y takes nothing returns real
            return Spell.key.ty
        endmethod

        static method operator z takes nothing returns real
            call MoveLocation(location, x, y)

            if Spell.key.target.unit != null then
                return Spell.key.target.z
            else
                return GetLocationZ(location)
            endif
        endmethod

        static method operator id takes nothing returns integer
            return Spell.key.spell
        endmethod

        static method operator source takes nothing returns Unit
            return Spell.key.sources
        endmethod

        static method operator target takes nothing returns Unit
            return Spell.key.targets
        endmethod

        static method operator level takes nothing returns integer
            return GetUnitAbilityLevel(Spell.key.source.unit, id)
        endmethod

        static method operator ability takes nothing returns ability
            return BlzGetUnitAbility(Spell.key.source.unit, id)
        endmethod

        static method operator isAlly takes nothing returns boolean
            return IsUnitAlly(Spell.key.target.unit, Spell.key.source.player)
        endmethod

        static method operator isEnemy takes nothing returns boolean
            return IsUnitEnemy(Spell.key.target.unit, Spell.key.source.player)
        endmethod

        static method create takes nothing returns thistype
            local thistype this = key + 1

            set key = this
            set tx = GetSpellTargetX()
            set ty = GetSpellTargetY()
            set spell = GetSpellAbilityId()
            set sources = Unit.create(GetTriggerUnit())
            set targets = Unit.create(GetSpellTargetUnit())

            return this
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_CHANNEL then
                    set this = create()
                elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
                    set this = key
                    call destroy()
                endif
            endif
        endmethod

        implement MSpell

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function thistype.onCast)
        endmethod
    endstruct
endlibrary