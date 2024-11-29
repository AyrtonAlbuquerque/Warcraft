scope DualDagger
    struct DualDagger extends Item
        static constant integer code = 'I086'
        static constant integer ability = 'A00Z'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        private static integer array amount
        private static boolean array state
        private static boolean array freeze
        private static integer array burn_instance
        private static integer array freeze_instance

        private unit source
        private unit target
        private effect effect
        private boolean burn
        private integer duration
        private integer sourceId
        private integer targetId

        // Attributes
        real damage = 500
        real evasionChance = 25
        real lifeSteal = 0.25
        real spellPowerFlat = 250

        private method remove takes integer i returns integer
            call DestroyEffect(effect)

            if burn then
                set burn_instance[targetId] = 0
            else
                set freeze_instance[targetId] = 0

                call UnitAddMoveSpeedBonus(target, 0.5, 0, 0)
                call AddUnitBonus(target, BONUS_ATTACK_SPEED, 0.50)
            endif

            set array[i] = array[key]
            set key = key - 1
            set source = null
            set target = null
            set effect = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00500|r Damage\n+ |cffffcc00250|r Spell Power\n+ |cffffcc0025%%|r Evasion\n+ |cffffcc0025%%|r Life Steal\n\n|cff00ff00Active|r: |cffffcc00Dual Wield|r: When used, the |cffffcc00Dual Elemental Dagger|r switch between |cffff0000Burning|r and |cff8080ffFreezing|r Mode.\n\n|cff00ff00Passive|r: |cffffcc00Burn or Freeze|r: When |cffffcc00Dual Elemental Dagger|r is in |cffff0000Burning|r mode, all attacked enemy units take |cff00ffff" + AbilitySpellDamageEx(amount[id], u) + " Magic|r damage per second for |cffffcc003|r seconds. When its in |cff8080ffFreezing|r mode, all attacked enemy units have theirs |cffffcc00Movement Speed and Attack Speed|r reduced by |cffffcc0050%%|r for |cffffcc005|r seconds.")
        endmethod

        private method onDrop takes unit u, item i returns nothing
            if GetItemTypeId(i) == code and not UnitHasItemOfType(u, code) then
                set state[GetUnitUserData(u)] = false  
                call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNBurningDagger.blp")
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
			local thistype this
	
			loop
				exitwhen i > key
                    set this = array[i]
                    
                    if duration > 0 then
                        if burn then
                            call UnitDamageTarget(source, target, amount[sourceId], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_FIRE, null)
                        endif
                    else
                        set i = remove(i)
                    endif

                    set duration = duration - 1
				set i = i + 1
			endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                set amount[Damage.source.id] = R2I(250 + GetUnitBonus(Damage.source.unit, BONUS_DAMAGE)*0.1)
                set freeze[Damage.source.id] = state[Damage.source.id]

                if freeze[Damage.source.id] then
                    if freeze_instance[Damage.target.id] != 0 then
                        set this = freeze_instance[Damage.target.id]
                    else
                        set this = thistype.new()
                        set source = Damage.source.unit
                        set target = Damage.target.unit
                        set targetId = Damage.target.id
                        set sourceId = Damage.source.id
                        set burn = false
                        set effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl", Damage.target.unit, "origin")
                        set key = key + 1
                        set array[key] = this
                        set freeze_instance[Damage.target.id] = this
        
                        call UnitAddMoveSpeedBonus(Damage.target.unit, -0.5, 0, 0)
                        call AddUnitBonus(Damage.target.unit, BONUS_ATTACK_SPEED, -0.50)

                        if key == 0 then
                            call TimerStart(timer, 1, true, function thistype.onPeriod)
                        endif
                    endif
        
                    set duration = 6
                else
                    if burn_instance[Damage.target.id] != 0 then
                        set this = burn_instance[Damage.target.id]
                    else
                        set this = thistype.new()
                        set source = Damage.source.unit
                        set target = Damage.target.unit
                        set targetId = Damage.target.id
                        set sourceId = Damage.source.id
                        set burn = true
                        set effect = AddSpecialEffectTarget("ImmolationRedDamage.mdx", Damage.target.unit, "origin")
                        set key = key + 1
                        set array[key] = this
                        set burn_instance[Damage.target.id] = this

                        if key == 0 then
                            call TimerStart(timer, 1, true, function thistype.onPeriod)
                        endif
                    endif
        
                    set duration = 4
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            if state[Spell.source.id] then
                set state[Spell.source.id] = false  
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNBurningDagger.blp")
            else
                set state[Spell.source.id] = true
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNChillingDagger.blp")
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call thistype.allocate(code, RitualDagger.code, SphereOfFire.code, SphereOfWater.code, 0, 0)
        endmethod   
    endstruct
endscope