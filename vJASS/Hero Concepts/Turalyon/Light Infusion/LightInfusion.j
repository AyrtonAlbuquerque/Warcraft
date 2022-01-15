library LightInfusion requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Table, Utilities, NewBonus
    /* -------------------- Light Infusion v1.2 by Chopinski -------------------- */
    // Credits:
    //     NO-Bloody-Name  - Icon
    //     Bribe           - SpellEffectEvent, Table
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Divine Edict Effect
    //     JetFangInferno  - LightFlash effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Light Infusion ability
        private constant integer ABILITY     = 'A000'
        // The Light Infusion orb model
        private constant string  MODEL       = "LightOrb.mdl"
        // The Light Infusion orb scale
        private constant real    SCALE       = 1.
        // The Light Infusion orb death model
        private constant string  DEATH_MODEL = "LightFlash.mdl"
        // The Light Infusion death model scale
        private constant real    DEATH_SCALE = 0.5
        // The Light Infusion orbs offset
        private constant real    OFFSET      = 125.
        // The Light Infusion orb update period
        private constant real    PERIOD      = 0.05
    endglobals

    // The Light Infusion max number of charges
    private function GetMaxCharges takes integer level returns integer
        return 3 + 0*level
    endfunction

    // The Light Infusion health regen bonus per stack
    private function GetBonusRegen takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Light Infusion level up base on hero level
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15 or level == 20
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct LightInfusion
        readonly static integer array charges
        private static thistype array data
		private static integer 		  didx    = -1
        private static timer 		  timer   = CreateTimer()
        private static constant real  STEP    = 2.5*bj_DEGTORAD
        private static constant real  CIRCLE = 2*bj_PI
        private static thistype array n

        private unit    unit
        private real    angle
        private real    arc
        private real    bonus
        private integer index
        private Table   table

        private method remove takes integer i returns integer
            local integer j = 0

            loop
                exitwhen j >= GetMaxCharges(GetUnitAbilityLevel(unit, ABILITY))
                    call DestroyEffect(table.effect[j])
                set j = j + 1
            endloop
			call table.destroy()

			set data[i]        = data[didx]
			set didx 	       = didx - 1
			set charges[index] = 0
			set n[index]	   = 0
			set unit           = null

			if didx == -1 then
				call PauseTimer(timer)
			endif

			call deallocate()

			return i - 1
		endmethod

        private static method onPeriod takes nothing returns nothing
			local real     x
			local real     y
            local real 	   z
            local integer  i = 0
            local integer  j
			local thistype this
	
			loop
				exitwhen i > didx
					set this = data[i]
	
                    if charges[index] > 0 then
                        set angle = angle + STEP
                        set x = GetUnitX(unit)
						set y = GetUnitY(unit)
                        set z = GetUnitZ(unit) + 100
                        set j = 0
                        loop
                            exitwhen j >= charges[index]
                                call BlzSetSpecialEffectPosition(table.effect[j], x + OFFSET*Cos(angle + j*arc), y + OFFSET*Sin(angle + j*arc), z)
                            set j = j + 1
                        endloop
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
        endmethod
        
        static method consume takes integer i returns nothing
            local real x
            local real y
            local real z
            local thistype this

            if charges[i] > 0 and n[i] != 0 then
                set this = n[i]
                set charges[i] = charges[i] - 1
                set x = BlzGetLocalSpecialEffectX(table.effect[charges[i]])
                set y = BlzGetLocalSpecialEffectY(table.effect[charges[i]])
                set z = BlzGetLocalSpecialEffectZ(table.effect[charges[i]])
                if charges[i] > 0 then
                    set arc = CIRCLE/charges[i]
                endif

                call DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, x, y, z, DEATH_SCALE))
                call DestroyEffect(table.effect[charges[i]])
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -bonus)
                set bonus = charges[i]*GetBonusRegen(GetUnitAbilityLevel(unit, ABILITY))
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, bonus)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if charges[Spell.source.id] < GetMaxCharges(Spell.level) then
                if n[Spell.source.id] != 0 then
                    set this = n[Spell.source.id]
                else
                    set this       = thistype.allocate()
                    set unit       = Spell.source.unit
                    set table      = Table.create()
                    set index      = Spell.source.id
                    set angle      = 0.
                    set bonus      = 0.
                    set n[index]   = this
                    set didx       = didx + 1
                    set data[didx] = this

                    if didx == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif

                set table.effect[charges[index]] = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, Spell.source.z + 100, SCALE)
                set charges[index] = charges[index] + 1
                set arc = CIRCLE/charges[index]

                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -bonus)
                set bonus = charges[index]*GetBonusRegen(Spell.level)
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, bonus)
            else
                call ResetUnitAbilityCooldown(Spell.source.unit, Spell.id)
                call DisplayTextToPlayer(Spell.source.player, 0, 0, "Already at full stacks.")
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                call IncUnitAbilityLevel(source, ABILITY)
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary