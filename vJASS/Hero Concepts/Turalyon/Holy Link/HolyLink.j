library HolyLink requires SpellEffectEvent, PluginSpellEffect, Utilities, DamageInterface, NewBonus, optional LightInfusion
    /* ----------------------- Holy Link v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Metal_Sonic     - Rejuvenation Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Holy Link ability
        private constant integer ABILITY       = 'A002'
        // The Holy Link Normal buff model
        private constant string  MODEL         = "Rejuvenation.mdl"
        // The Holy Link infused buff model
        private constant string  INFUSED_MODEL = "Rejuvenation.mdl"
        // The Holy Link lightning effect
        private constant string  LIGHTNING     = "HWSB"
        // The Holy Link model attachment point
        private constant string  ATTACH_POINT  = "chest"
        // The Holy Link update period
        private constant real    PERIOD        = 0.031250000
    endglobals

    // The Holy Link Health Regen bonus
    private function GetBonus takes unit source, integer level returns real
        local real base = 5. + 5.*level

        return (base + base*(1 - (GetUnitLifePercent(source)*0.01)))*PERIOD
    endfunction

    // The Holy Link Movement Speed bonus
    private function GetMovementBonus takes integer level, boolean infused returns integer
        if infused then
            return 50 + 0*level
        else
            return 0
        endif
    endfunction

    // The Holy Link break distance
    private function GetAoE takes integer level, boolean infused returns real
        if infused then
            return 1200. + 0.*level
        else
            return 800. + 0.*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HolyLink
        static thistype array n
        static integer  array reduce
        static thistype array data
		static integer 		  didx  = -1
        static timer 		  timer = CreateTimer()

        unit      unit
        unit      target
        integer   index
        integer   bonus
        effect    effect
        effect    self
        real      distance
        boolean   infused
        lightning lightning
        integer   count

        private method remove takes integer i returns integer
            call DestroyLightning(lightning)
            call DestroyEffect(effect)

            if infused then
                set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] - 1
                call DestroyEffect(self)
                call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -bonus)
                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, -bonus)
            endif

            set unit      = null
            set target    = null
            set lightning = null
            set effect    = null
            set self      = null
            set n[index]  = 0
			set data[i]   = data[didx]
			set didx 	  = didx - 1

			if didx == -1 then
				call PauseTimer(timer)
			endif

			call deallocate()

			return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local real     x
            local real     y
            local real     tx
            local real     ty
            local integer  level
			local thistype this
	
			loop
				exitwhen i > didx
					set this = data[i]
                    set x    = GetUnitX(unit)
                    set y    = GetUnitY(unit)
                    set tx   = GetUnitX(target)
                    set ty   = GetUnitY(target)

                    if DistanceBetweenCoordinates(x, y, tx, ty) <= distance and UnitAlive(target) and UnitAlive(unit) then
                        set level = GetUnitAbilityLevel(unit, ABILITY)

                        if infused then
                            call SetWidgetLife(unit, GetWidgetLife(unit) + GetBonus(unit, level))
                            call SetWidgetLife(target, GetWidgetLife(target) + GetBonus(target, level))
                        else
                            call SetWidgetLife(target, GetWidgetLife(target) + GetBonus(target, level))
                        endif

                        if count <= 28 then // This is here because reforged lightnings don't persist visually...
                            set count = count + 1
                            call MoveLightningEx(lightning, false, x, y, GetUnitZ(unit) + 30, tx, ty, GetUnitZ(target) + 30)
                        else
                            set count = 0
                            call DestroyLightning(lightning)
                            set lightning = AddLightningEx(LIGHTNING, false, x, y, GetUnitZ(unit) + 30, tx, ty, GetUnitZ(target) + 30)
                        endif
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
        endmethod

        private static method link takes unit source, unit target, integer index, integer level, boolean infused returns nothing
            local thistype this = thistype.allocate()

            set unit       = source
            set .target    = target
            set .index     = index
            set .infused   = infused
            set bonus      = GetMovementBonus(level, infused)
            set distance   = GetAoE(level, infused)
            set count      = 0
            set lightning  = AddLightningEx(LIGHTNING, false, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 30, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 30)
            set effect     = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
            set n[index]   = this
            set didx       = didx + 1
            set data[didx] = this

            if infused then
                set self  = AddSpecialEffectTarget(MODEL, source, ATTACH_POINT)
                set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] + 1
                call AddUnitBonus(source, BONUS_MOVEMENT_SPEED, bonus)
                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
            endif

            if didx == 0 then
                call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local integer  i = GetUnitUserData(Spell.target.unit)
            local thistype this

            if n[Spell.source.id] != 0 then // If a link already exists
                set this = n[Spell.source.id]

                if Spell.target.unit == target then // Trying to link with already linked target
                    static if LIBRARY_LightInfusion then
                        if infused then // Already Infused, reset
                            call ResetUnitAbilityCooldown(unit, Spell.id)
                        else
                            set infused  = LightInfusion.charges[index] > 0
                            set distance = GetAoE(Spell.level, infused)
                            set bonus    = GetMovementBonus(Spell.level, infused)

                            if infused then
                                set reduce[i] = reduce[i] + 1 
                                set self = AddSpecialEffectTarget(MODEL, unit, ATTACH_POINT)
                                call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, bonus)
                                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
                            endif
                            call LightInfusion.consume(index)
                        endif
                    else
                        call ResetUnitAbilityCooldown(unit, Spell.id)
                    endif
                else // Link exists but trying to link to another unit
                    call DestroyLightning(lightning)
                    call DestroyEffect(effect)

                    static if LIBRARY_LightInfusion then
                        if infused then // Clean up from previous linked unit
                            set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] - 1
                            call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -bonus)
                            call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, -bonus)
                            call DestroyEffect(self)
                        endif

                        // Set up for current linked unit
                        set unit      = Spell.source.unit
                        set target    = Spell.target.unit
                        set infused   = LightInfusion.charges[index] > 0
                        set bonus     = GetMovementBonus(Spell.level, infused)
                        set distance  = GetAoE(Spell.level, infused)
                        set count     = 0
                        set lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                        set effect    = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)

                        if infused then
                            set reduce[i] = reduce[i] + 1 
                            set self = AddSpecialEffectTarget(MODEL, unit, ATTACH_POINT)
                            call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, bonus)
                            call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
                        endif
                        call LightInfusion.consume(index)
                    else
                        set unit      = Spell.source.unit
                        set target    = Spell.target.unit
                        set infused   = false
                        set bonus     = GetMovementBonus(Spell.level, infused)
                        set distance  = GetAoE(Spell.level, infused)
                        set count     = 0
                        set lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                        set effect    = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
                    endif
                endif
            else // Create the link
                static if LIBRARY_LightInfusion then
                    call link(Spell.source.unit, Spell.target.unit, Spell.source.id, Spell.level, LightInfusion.charges[Spell.source.id] > 0)
                    call LightInfusion.consume(Spell.source.id)
                else
                    call link(Spell.source.unit, Spell.target.unit, Spell.source.id, Spell.level, false)
                endif
            endif
        endmethod

        static if LIBRARY_LightInfusion then
            private static method onDamage takes nothing returns nothing
                local real damage = GetEventDamage()

                if damage > 0 and reduce[Damage.target.id] > 0 then
                    call BlzSetEventDamage(damage*0.75)
                endif
            endmethod
        endif

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)

            static if LIBRARY_LightInfusion then
                call RegisterAnyDamageEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endlibrary