scope SakuraBlade
    struct SakuraBlade extends Item
        static constant integer code = 'I0AZ'
        static constant integer aura = 'A02G'
        static constant abilityreallevelfield field = ABILITY_RLF_ATTACK_DAMAGE_INCREASE_CAC1
    
        private static integer array bonus
    
        private unit unit
        private group group
        private player player
        private integer index

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(unit, aura)
            call DestroyGroup(group)

            set bonus[index] = 0
            set unit = null
            set group = null
            set player = null

			call super.destroy()
		endmethod
    
        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc001000|r Damage\n+ |cffffcc00100%%|r Movement Speed\n+ |cffffcc00400%%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Sakura Fall|r: |cffffcc00Movement Speed|r, |cffffcc00Attack Speed|r and |cffff0000Damage|r provided by Sakura Blade also affect allied units.|r\n\n|cff00ff00Passive|r: |cffffcc00Sakura Lamina|r: For every allied Hero within |cffffcc00800 AoE|r, the damage provided by |cffffcc00Sakura Blade|r is increased by |cffffcc00250|r.\n\nBonus Damage: |cffffcc00" + I2S(250*bonus[id]) + "|r")
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u
            local integer i = 0

			if UnitHasItemOfType(unit, code) then
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 850, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if u != unit and UnitAlive(u) and IsUnitType(u, UNIT_TYPE_HERO) and IsUnitAlly(u, player) then
                            set i = i + 1
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                if i != bonus[index] then
                    set bonus[index] = i

                    call BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, aura), field, 0, (1000 + 250*bonus[index]))
                    call IncUnitAbilityLevel(unit, aura)
                    call DecUnitAbilityLevel(unit, aura)
                endif

                return true
            endif

            return false
		endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self
    
            if not HasStartedTimer(id) then
                set self = thistype.new()
                set self.unit = u
                set self.index = id
                set self.group = CreateGroup()
                set self.player = GetOwningPlayer(u)

                call UnitAddAbility(u, aura)
                call BlzUnitHideAbility(u, aura, true)
                call StartTimer(0.25, true, self, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope