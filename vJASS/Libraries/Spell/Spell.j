library Spell requires Table, RegisterPlayerUnitEvent
    private interface ISpell
        method onEnd takes nothing returns nothing defaults nothing
        method onCast takes nothing returns nothing defaults nothing
        method onStart takes nothing returns nothing defaults nothing
        method onFinish takes nothing returns nothing defaults nothing
        method onChannel takes nothing returns nothing defaults nothing
        method onLearn takes unit source, integer skill, integer level returns nothing defaults nothing
        method onTooltip takes unit source, integer level, ability spell returns string defaults null
    endinterface

    struct Spell extends ISpell
        private static Table struct
        private static HashTable learned
        private static integer key = -1
        private static thistype array array
        private static timer timer = CreateTimer()
        private static Unit sources
        private static Unit targets
        private static location location = Location(0, 0)

        private unit unit
        private integer code
        private ISpell type
        private ability abil

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

        static method operator source takes nothing returns Unit
            return sources
        endmethod

        static method operator source= takes unit value returns nothing
            set sources.unit = value
        endmethod

        static method operator target takes nothing returns Unit
            return targets
        endmethod

        static method operator target= takes unit value returns nothing
            set targets.unit = value
        endmethod

        static method operator aoe takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)
        endmethod

        static method operator aoe= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1, value)
        endmethod

        static method operator cost takes nothing returns integer
            return BlzGetAbilityIntegerLevelField(ability, ABILITY_ILF_MANA_COST, level - 1)
        endmethod
        
        static method operator cost= takes integer value returns nothing
            call BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_MANA_COST, level - 1, value)
        endmethod

        static method operator castRange takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, level - 1)
        endmethod

        static method operator castRange= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, level - 1, value)
        endmethod

        static method operator castTime takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_CASTING_TIME, level - 1)
        endmethod

        static method operator castTime= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CASTING_TIME, level - 1, value)
        endmethod

        static method operator cooldown takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_COOLDOWN, level - 1)
        endmethod

        static method operator cooldown= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_COOLDOWN, level - 1, value)
        endmethod

        static method operator duration takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, level - 1)
        endmethod

        static method operator duration= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, level - 1, value)
        endmethod

        static method operator durationHero takes nothing returns real
            return BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, level - 1)
        endmethod

        static method operator durationHero= takes real value returns nothing
            call BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, level - 1, value)
        endmethod

        static method operator tooltip takes nothing returns string
            return BlzGetAbilityStringLevelField(ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1)
        endmethod

        static method operator tooltip= takes string value returns nothing
            call BlzSetAbilityStringLevelField(ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1, value)
        endmethod

        static method operator isAlly takes nothing returns boolean
            return IsUnitAlly(target.unit, source.player)
        endmethod

        static method operator isEnemy takes nothing returns boolean
            return IsUnitEnemy(target.unit, source.player)
        endmethod

        private static method setup takes unit src, unit tgt returns nothing
            if GetUnitAbilityLevel(src, 'Aloc') == 0 then
                set source = src
                set target = tgt
            endif
        endmethod

        static method register takes ISpell spell, integer id returns nothing
            if id > 0 and spell != 0 then
                set struct[id] = spell
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local integer level
            local thistype this
        
            loop
                exitwhen i > key
                    set this = array[i]
                    set level = GetUnitAbilityLevel(unit, code)
                    
                    if level > 0 then
                        call BlzSetAbilityStringLevelField(abil, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1, type.onTooltip(unit, level, abil))
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onLearning takes nothing returns nothing
            local unit source = GetLearningUnit()
            local integer skill = GetLearnedSkill()
            local integer level = GetUnitAbilityLevel(source, skill)
            local thistype this = struct[skill]
            local thistype spell

            if this != 0 then
                if onLearn.exists then
                    call onLearn(source, skill, level)
                endif

                if onTooltip.exists and level == 1 then
                    set spell = thistype.allocate()
                    set spell.type = this
                    set spell.code = skill
                    set spell.unit = source
                    set spell.abil = BlzGetUnitAbility(source, skill)
                    set key = key + 1
                    set array[key] = spell
                    set learned[skill][GetUnitUserData(source)] = 1

                    if key == 0 then
                        call TimerStart(timer, 1, true, function thistype.onPeriod)
                    endif
                endif
            endif

            set source = null
        endmethod

        private static method onCasting takes nothing returns nothing
            local thistype this = struct[id]
            local thistype spell

            call setup(GetTriggerUnit(), GetSpellTargetUnit())

            if this != 0 then
                if onCast.exists then
                    call onCast()
                endif

                if onTooltip.exists then
                    set Spell.tooltip = onTooltip(Spell.source.unit, Spell.level, Spell.ability)

                    if not learned[Spell.id].has(Spell.source.id) then
                        set spell = thistype.allocate()
                        set spell.type = this
                        set spell.code = Spell.id
                        set spell.unit = Spell.source.unit
                        set spell.abil = Spell.ability
                        set key = key + 1
                        set array[key] = spell
                        set learned[Spell.id][Spell.source.id] = 1

                        if key == 0 then
                            call TimerStart(timer, 1, true, function thistype.onPeriod)
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onEnding takes nothing returns nothing
            local thistype this = struct[id]

            call setup(GetTriggerUnit(), GetSpellTargetUnit())

            if this != 0 then
                if onEnd.exists then
                    call onEnd()
                endif
            endif
        endmethod

        private static method onStarting takes nothing returns nothing
            local thistype this = struct[id]

            call setup(GetTriggerUnit(), GetSpellTargetUnit())

            if this != 0 then
                if onStart.exists then
                    call onStart()
                endif
            endif
        endmethod

        private static method onFinishing takes nothing returns nothing
            local thistype this = struct[id]

            call setup(GetTriggerUnit(), GetSpellTargetUnit())

            if this != 0 then
                if onFinish.exists then
                    call onFinish()
                endif
            endif
        endmethod

        private static method onChanneling takes nothing returns nothing
            local thistype this = struct[id]

            call setup(GetTriggerUnit(), GetSpellTargetUnit())

            if this != 0 then
                if onChannel.exists then
                    call onChannel()
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set struct = Table.create()
            set sources = Unit.create(null)
            set targets = Unit.create(null)
            set learned = HashTable.create()

            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLearning)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, function thistype.onStarting)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCasting)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function thistype.onEnding)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, function thistype.onFinishing)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.onChanneling)
        endmethod
    endstruct

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterSpell takes ISpell spell, integer id returns nothing
        call Spell.register(spell, id)
    endfunction
endlibrary