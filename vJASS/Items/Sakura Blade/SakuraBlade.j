scope SakuraBlade
    struct SakuraBlade extends Item
        static constant integer code = 'I0AZ'
        static constant integer aura = 'A02G'
        static constant abilityreallevelfield field = ABILITY_RLF_ATTACK_DAMAGE_INCREASE_CAC1
    
        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        private static integer array check
        private static integer array bonus
    
        private unit unit
        private group group
        private player player
        private integer index

        // Attributes
        real damage = 1000
    
        private method remove takes integer i returns integer
            call UnitRemoveAbility(unit, aura)
            call DestroyGroup(group)

            set array[i] = array[key]
            set key = key - 1
            set check[index] = 0
            set bonus[index] = 0
            set unit = null
            set group = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod
    
        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc001000|r Damage\n+ |cffffcc00100%%|r Movement Speed\n+ |cffffcc00400%%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Sakura Fall|r: |cffffcc00Movement Speed|r, |cffffcc00Attack Speed|r and |cffff0000Damage|r provided by Sakura Blade also affect allied units.|r\n\n|cff00ff00Passive|r: |cffffcc00Sakura Lamina|r: For every allied Hero within |cffffcc00800 AoE|r, the damage provided by |cffffcc00Sakura Blade|r is increased by |cffffcc00250|r.\n\nBonus Damage: |cffffcc00" + I2S(250*bonus[id]) + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local unit v
            local integer j = 0
            local integer i = 0
            local thistype this
            
            loop
                exitwhen i > key
                    set this = array[i]
    
                    if UnitHasItemOfType(unit, code) then
                        call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 850, null)

                        loop
                            set v = FirstOfGroup(group)
                            exitwhen v == null
                                if UnitAlive(v) and IsUnitType(v, UNIT_TYPE_HERO) and IsUnitAlly(v, player) then
                                    set j = j + 1
                                endif
                            call GroupRemoveUnit(group, v)
                        endloop
    
                        if j != bonus[index] then
                            set bonus[index] = j
                            call BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, aura), field, 0, (1000 + 250*bonus[index]))
                            call IncUnitAbilityLevel(unit, aura)
                            call DecUnitAbilityLevel(unit, aura)
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod
    
        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self
    
            set check[id] = check[id] + 1
    
            if check[id] == 1 then
                set self = thistype.new()
                set self.unit = u
                set self.index = id
                set self.group = CreateGroup()
                set self.player = GetOwningPlayer(u)
                set key = key + 1
                set array[key] = self

                call UnitAddAbility(u, aura)
                call BlzUnitHideAbility(u, aura, true)

                if key == 0 then
                    call TimerStart(timer, 0.25, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope