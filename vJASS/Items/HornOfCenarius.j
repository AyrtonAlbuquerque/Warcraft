scope HornOfCenarius
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusSpellPower takes nothing returns real
        return 0.15
    endfunction

    private constant function GetBonusSpellVamp takes nothing returns real
        return 0.05
    endfunction

    private constant function GetAoE takes nothing returns real
        return 900.
    endfunction

    private constant function GetSpellPowerFactor takes nothing returns real
        return 1.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct HornOfCenarius extends Item
        static constant integer code = 'I01W'
        private static integer buff = 'B004'
        private static integer ability = 'A00A'
        private static real array bonus
        private static timer timer = CreateTimer()
        private static timer effect = CreateTimer()
        private static group group = CreateGroup()
        private static group sources = CreateGroup()

        // Attributes
        real tenacity = 0.2
        real spellPower = 65
        real intelligence = 25

        private static method onAura takes nothing returns nothing
            local integer size = BlzGroupGetSize(group)
            local integer i = 0
            local integer id
            local unit u

            if size > 0 then
                loop
                    exitwhen i == size
                        set u = BlzGroupUnitAt(group, i)
                        set id = GetUnitUserData(u)

                        if bonus[id] > 0 then
                            call AddUnitBonus(u, BONUS_SPELL_POWER, -bonus[id])
                        endif

                        if UnitAlive(u) and GetUnitAbilityLevel(u, buff) > 0 then
                            set bonus[id] = GetUnitBonus(u, BONUS_SPELL_POWER) * GetBonusSpellPower()

                            call AddUnitBonus(u, BONUS_SPELL_POWER, bonus[id])
                        else
                            call GroupRemoveUnit(group, u)

                            set i = i - 1
                            set bonus[id] = 0
                            set size = BlzGroupGetSize(group)
                        endif
                        
                    set i = i + 1
                endloop
            else
                call PauseTimer(effect)
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer size = BlzGroupGetSize(sources)
            local integer i = 0
            local unit source
            local group g
            local unit u

            if size > 0 then
                set g = CreateGroup()

                loop
                    exitwhen i == size
                        set source = BlzGroupUnitAt(sources, i)

                        if UnitAlive(source) then
                            call GroupEnumUnitsInRange(g, GetUnitX(source), GetUnitY(source), GetAoE() + 100, null)

                            loop
                                set u = FirstOfGroup(g)
                                exitwhen u == null
                                    if UnitAlive(u) and GetUnitAbilityLevel(u, buff) > 0 and not IsUnitInGroup(u, group) then
                                        call GroupAddUnit(group, u)
                                        call LinkBonusToBuff(u, BONUS_SPELL_VAMP, GetBonusSpellVamp(), buff)

                                        if BlzGroupGetSize(group) == 1 then
                                            call TimerStart(effect, 1, true, function thistype.onAura)
                                        endif
                                    endif
                                call GroupRemoveUnit(g, u)
                            endloop
                        endif
                        
                    set i = i + 1
                endloop

                call DestroyGroup(g)
            else
                call PauseTimer(timer)
            endif

            set g = null
            set u = null
            set source = null
        endmethod

        private method onPickup takes unit u, item i returns nothing
            if not IsUnitInGroup(u, sources) then
                call GroupAddUnit(sources, u)

                if BlzGroupGetSize(sources) == 1 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private method onDrop takes unit u, item i returns nothing
            if IsUnitInGroup(u, sources) and not UnitHasItemOfType(u, code) then
                call GroupRemoveUnit(sources, u) 
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local integer i = 0
            local unit u

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if IsPlayerAlly(Player(i), Spell.source.player) then
                        call GroupEnumUnitsOfPlayer(g, Player(i), null)

                        loop
                            set u = FirstOfGroup(g)
                            exitwhen u == null
                                if UnitAlive(u) and IsUnitType(u, UNIT_TYPE_HERO) then
                                    call AddUnitBonusTimed(u, BONUS_SPELL_POWER, GetUnitBonus(u, BONUS_SPELL_POWER) * GetSpellPowerFactor(), GetDuration())
                                    call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdl", u, "hand left"), GetDuration())
                                    call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdl", u, "hand right"), GetDuration())

                                    if u != Spell.source.unit then
                                        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl", u, "origin"))
                                    endif
                                endif
                            call GroupRemoveUnit(g, u)
                        endloop
                    endif
                set i = i + 1
            endloop

            call DestroyGroup(g)

            set g = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SphereOfPower.code, MageStaff.code, PrinceCrown.code, 0, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
        endmethod
    endstruct
endscope