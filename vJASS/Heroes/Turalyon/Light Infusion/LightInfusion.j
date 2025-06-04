library LightInfusion requires RegisterPlayerUnitEvent, Ability, Table, Utilities, NewBonus, Periodic
    /* -------------------- Light Infusion v1.3 by Chopinski -------------------- */
    // Credits:
    //     NO-Bloody-Name  - Icon
    //     Bribe           - Table
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
    struct LightInfusion extends Ability
        private static constant real CIRCLE = 2*bj_PI
        private static constant real STEP = 2.5*bj_DEGTORAD

        readonly static integer array charges

        private real arc
        private unit unit
        private real angle
        private real bonus
        private integer id
        private Table table

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i >= GetMaxCharges(GetUnitAbilityLevel(unit, ABILITY))
                    call DestroyEffect(table.effect[i])
                set i = i + 1
            endloop

			set charges[id] = 0
			set unit = null

            call table.destroy()
			call deallocate()
		endmethod
        
        static method consume takes integer i returns nothing
            local real x
            local real y
            local real z
            local thistype this = GetTimerInstance(i)

            if this != 0 and charges[i] > 0 then
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
                set bonus = charges[i] * GetBonusRegen(GetUnitAbilityLevel(unit, ABILITY))
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, bonus)
            endif
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer i = 0
	
			if charges[id] > 0 then
                set angle = angle + STEP

                loop
                    exitwhen i >= charges[id]
                        call BlzSetSpecialEffectPosition(table.effect[i], GetUnitX(unit) + OFFSET*Cos(angle + i*arc), GetUnitY(unit) + OFFSET*Sin(angle + i*arc), GetUnitZ(unit) + 100)
                    set i = i + 1
                endloop
            endif

            return charges[id] > 0
        endmethod

        private method onCast takes nothing returns nothing
            if charges[Spell.source.id] < GetMaxCharges(Spell.level) then
                set this = GetTimerInstance(Spell.source.id)

                if this == 0 then
                    set this = thistype.allocate()
                    set id = Spell.source.id
                    set unit = Spell.source.unit
                    set table = Table.create()
                    set angle = 0
                    set bonus = 0

                    call StartTimer(PERIOD, true, this, id)
                endif

                set table.effect[charges[id]] = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, Spell.source.z + 100, SCALE)
                set charges[id] = charges[id] + 1
                set arc = CIRCLE/charges[id]

                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -bonus)
                set bonus = charges[id] * GetBonusRegen(Spell.level)
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

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary