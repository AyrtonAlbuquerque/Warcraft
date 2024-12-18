library Ability requires Table, TimerUtils, RegisterPlayerUnitEvent, PluginSpellEffect
    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private interface IAbility
        method onCast takes nothing returns nothing defaults nothing
        method onLearn takes unit source, integer skill, integer level returns nothing defaults nothing
        method onTooltip takes unit source, integer level returns string defaults ""
    endinterface

    struct Ability extends IAbility
        private static Table struct
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

                call RegisterSpellEffectEvent(id, function thistype.onCasting)
            endif
        endmethod

        private method remove takes integer i returns integer
            set id = 0
            set type = 0
            set unit = null
            set ability = null
            set array[i] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
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
                        set tooltip = type.onTooltip(unit, level)

                        call BlzSetAbilityExtendedTooltip(id, tooltip, level - 1)
                        call BlzSetAbilityStringLevelField(ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1, tooltip)
                    else
                        set i = remove(i)
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
                    set spell.timer = NewTimerEx(spell)
                    set spell.id = skill
                    set spell.unit = source
                    set spell.ability = BlzGetUnitAbility(source, skill)
                    set key = key + 1
                    set array[key] = spell

                    if key == 0 then
                        call TimerStart(timer, 1, true, function thistype.onPeriod)
                    endif
                endif
            endif

            set source = null
        endmethod

        private static method onCasting takes nothing returns nothing
            local thistype this = struct[Spell.id]
            local string tooltip

            if this != 0 then
                if onCast.exists then
                    call onCast()
                endif

                if onTooltip.exists then
                    set tooltip = onTooltip(Spell.source.unit, Spell.level)

                    call BlzSetAbilityExtendedTooltip(Spell.id, tooltip, Spell.level - 1)
                    call BlzSetAbilityStringLevelField(Spell.ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, Spell.level - 1, tooltip)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set struct = Table.create()

            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLearning)
        endmethod
    endstruct

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterSpell takes IAbility spell, integer id returns nothing
        call Ability.register(spell, id)
    endfunction
endlibrary