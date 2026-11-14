scope RunicMatrix
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetBonusDamage takes integer level returns real
        return 10. + (2 * level)
    endfunction

    private function GetBonusSpellPower takes integer level returns real
        return 20. + (4 * level)
    endfunction

    private function GetBonusMovement takes integer level returns real
        return 20. + (1 * level)
    endfunction

    private function GetBonusAttackSpeed takes integer level returns real
        return 0.1 + (0.01 * level)
    endfunction

    private function GetBonusHealthRegen takes integer level returns real
        return 10. + (2 * level)
    endfunction

    private function GetBonusManaRegen takes integer level returns real
        return 5. + (1 * level)
    endfunction

    private constant function GetBonusDuration takes nothing returns real
        return 30.
    endfunction

    private constant function GetMarkDuration takes nothing returns real
        return 15.
    endfunction

    private constant function GetInterval takes nothing returns real
        return 3.
    endfunction

    private constant function GetDamageFactor takes nothing returns real
        return 0.15
    endfunction

    private constant function GetAoE takes nothing returns real
        return 1000.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct RunicMatrix extends Item
        static constant integer code = 'I01V'
        private static thistype array array
        private static thistype array marked

        // Attributes
        real mana = 600
        real health = 600
        real cooldownReduction = 0.2

        private unit unit
        private timer timer
        private Group group
        private integer type
        private effect effect
        private player player
        private integer index

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            
            if effect != null then
                set marked[index] = 0

                call DestroyEffect(effect)
            else
                set array[index] = 0

                call group.destroy()
            endif

            set unit = null
            set timer = null
            set effect = null
            set player = null

            call deallocate()
        endmethod

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00600|r Mana\n+ |cffffcc00600|r Health\n+ |cffffcc0020%|r Cooldown Reduction\n\n|cff00ff00Passive|r: |cffffcc00Rune Marking|r: Every |cffffcc00" + N2S(GetInterval(), 0) + "|r seconds |cffffcc00Rune Matrix|r will mark an enemy unit within |cffffcc00" + N2S(GetAoE(), 0) + " AoE|r with one out of |cffffcc006|r rune types. When an enemy holding |cffffcc00Rune Matrix|r kills a marked unit it will gain that rune effect for |cffffcc00" + N2S(GetBonusDuration(), 0) + "|r seconds. The mark lasts for |cffffcc00" + N2S(GetMarkDuration(), 0) + "|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Maked to Die|r: Marked units take |cffffcc00" + N2S(GetDamageFactor() * 100, 0) + "%|r more damage.\n\n|cffff0000Blood|r Rune: |cffff0000" + N2S(GetBonusDamage(GetWidgetLevel(u)), 0) + " Damage|r.\n|cff00ffffPower|r Rune: |cff00ffff" + N2S(GetBonusSpellPower(GetWidgetLevel(u)), 0) + " Spell Power|r.\n|cffd45e19Fire|r Rune: |cffffcc00" + N2S(GetBonusAttackSpeed(GetWidgetLevel(u)) * 100, 0) + "% Attack Speed|r.\n|cffffcc00Wind|r Rune: |cffffcc00" + N2S(GetBonusMovement(GetWidgetLevel(u)), 0) + " Movement Speed|r.\n|cff00ff00Soul|r Rune: |cff00ff00" + N2S(GetBonusHealthRegen(GetWidgetLevel(u)), 0) + " Health Regeneration|r.\n|cff00ffffAstral|r Rune: |cff00ffff" + N2S(GetBonusManaRegen(GetWidgetLevel(u)), 0) + " Mana Regeneration|r."
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local thistype self
            local integer id

            if UnitHasItemOfType(unit, code) then
                call group.clear()
                    .inRange(GetUnitX(unit), GetUnitY(unit), GetAoE())
                    .isAlive()
                    .enemyOf(player)
                    .isNot().ofType(UNIT_TYPE_STRUCTURE)
                    .orderBy(OrderBy.hero)
                    .thenBy(OrderBy.health)
                    .sort()

                if group.size > 0 then
                    loop
                        exitwhen group.unit == null
                            set id = GetUnitUserData(group.unit)

                            if marked[id] == 0 then
                                set self = thistype.allocate(0)
                                set self.index = id
                                set self.unit = group.unit
                                set self.type = GetRandomInt(1, 6)
                                set self.timer = NewTimerEx(self)
                                set marked[id] = self

                                if self.type == 1 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Blood_Small.mdl", self.unit, "overhead")
                                elseif self.type == 2 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdl", self.unit, "overhead")
                                elseif self.type == 3 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Wind_Small.mdl", self.unit, "overhead")
                                elseif self.type == 4 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Soul_Small.mdl", self.unit, "overhead")
                                elseif self.type == 5 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Astral_Small.mdl", self.unit, "overhead")
                                elseif self.type == 6 then
                                    set self.effect = AddSpecialEffectTarget("Sweep_Fire_Small.mdl", self.unit, "overhead")
                                endif

                                call TimerStart(self.timer, GetMarkDuration(), false, function thistype.onExpire)
                                exitwhen true
                            endif
                        call group.next()
                    endloop
                endif
            else
                call destroy()
            endif
        endmethod

        private method onPickup takes unit u, item i returns nothing
            set this = array[GetUnitUserData(u)]

            if this == 0 then
                set this = thistype.allocate(0)
                set unit = u
                set timer = NewTimerEx(this)
                set index = GetUnitUserData(u)
                set player = GetOwningPlayer(u)
                set group = Group.create()
                set array[index] = this

                call TimerStart(timer, GetInterval(), true, function thistype.onPeriod)
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local thistype this = marked[GetUnitUserData(GetTriggerUnit())]

            if this != 0 then
                if UnitHasItemOfType(source, code) then
                    if type == 1 then
                        call AddUnitBonusTimed(source, BONUS_DAMAGE, GetBonusDamage(GetWidgetLevel(source)), GetBonusDuration())
                    elseif type == 2 then
                        call AddUnitBonusTimed(source, BONUS_SPELL_POWER, GetBonusSpellPower(GetWidgetLevel(source)), GetBonusDuration())
                    elseif type == 3 then
                        call AddUnitBonusTimed(source, BONUS_MOVEMENT_SPEED, GetBonusMovement(GetWidgetLevel(source)), GetBonusDuration())
                    elseif type == 4 then
                        call AddUnitBonusTimed(source, BONUS_HEALTH_REGEN, GetBonusHealthRegen(GetWidgetLevel(source)), GetBonusDuration())
                    elseif type == 5 then
                        call AddUnitBonusTimed(source, BONUS_MANA_REGEN, GetBonusManaRegen(GetWidgetLevel(source)), GetBonusDuration())
                    elseif type == 6 then
                        call AddUnitBonusTimed(source, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(GetWidgetLevel(source)), GetBonusDuration())
                    endif
                endif

                call destroy()
            endif

            set source = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and marked[Damage.target.id] != 0 and Damage.damagetype != DAMAGE_TYPE_UNIVERSAL then
                set Damage.amount = Damage.amount * (1 + GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SpellbookOfWitchcraft.code, AncientStone.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterAnyDamagingEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope