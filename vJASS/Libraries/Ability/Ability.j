library Ability requires Spell, Table, RegisterPlayerUnitEvent
    private interface IAbility
        method onEnd takes nothing returns nothing defaults nothing
        method onCast takes nothing returns nothing defaults nothing
        method onStart takes nothing returns nothing defaults nothing
        method onFinish takes nothing returns nothing defaults nothing
        method onChannel takes nothing returns nothing defaults nothing
        method onLearn takes unit source, integer skill, integer level returns nothing defaults nothing
        method onTooltip takes unit source, integer level, ability spell returns string defaults null
    endinterface

    private module MAbility
        private static method onInit takes nothing returns nothing
            set struct = Table.create()
            set learned = HashTable.create()

            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLearning)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, function thistype.onStarting)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCasting)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function thistype.onEnding)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, function thistype.onFinishing)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.onChanneling)
        endmethod
    endmodule

    struct Ability extends IAbility
        private static Table struct
        private static HashTable learned
        private static integer key = -1
        private static thistype array array
        private static timer timer = CreateTimer()

        private unit unit
        private integer id
        private IAbility type
        private ability ability

        static method register takes IAbility spell, integer id returns nothing
            if id > 0 and spell != 0 then
                set struct[id] = spell
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local integer level
            local thistype this
            local string tooltip
        
            loop
                exitwhen i > key
                    set this = array[i]
                    set level = GetUnitAbilityLevel(unit, id)
                    
                    if level > 0 then
                        set tooltip = type.onTooltip(unit, level, ability)

                        call BlzSetAbilityExtendedTooltip(id, tooltip, level - 1)
                        call BlzSetAbilityStringLevelField(ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1, tooltip)
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
                    set spell.id = skill
                    set spell.unit = source
                    set spell.ability = BlzGetUnitAbility(source, skill)
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
            local thistype this = struct[Spell.id]
            local thistype spell
            local string tooltip

            if this != 0 then
                if onCast.exists then
                    call onCast()
                endif

                if onTooltip.exists then
                    set tooltip = onTooltip(Spell.source.unit, Spell.level, Spell.ability)

                    call BlzSetAbilityExtendedTooltip(Spell.id, tooltip, Spell.level - 1)
                    call BlzSetAbilityStringLevelField(Spell.ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, Spell.level - 1, tooltip)

                    if not learned[Spell.id].has(Spell.source.id) then
                        set spell = thistype.allocate()
                        set spell.type = this
                        set spell.id = Spell.id
                        set spell.unit = Spell.source.unit
                        set spell.ability = Spell.ability
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
            local thistype this = struct[Spell.id]

            if this != 0 then
                if onEnd.exists then
                    call onEnd()
                endif
            endif
        endmethod

        private static method onStarting takes nothing returns nothing
            local thistype this = struct[Spell.id]

            if this != 0 then
                if onStart.exists then
                    call onStart()
                endif
            endif
        endmethod

        private static method onFinishing takes nothing returns nothing
            local thistype this = struct[Spell.id]

            if this != 0 then
                if onFinish.exists then
                    call onFinish()
                endif
            endif
        endmethod

        private static method onChanneling takes nothing returns nothing
            local thistype this = struct[Spell.id]
            
            if this != 0 then
                if onChannel.exists then
                    call onChannel()
                endif
            endif
        endmethod

        implement MAbility
    endstruct

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterSpell takes IAbility spell, integer id returns nothing
        call Ability.register(spell, id)
    endfunction
endlibrary