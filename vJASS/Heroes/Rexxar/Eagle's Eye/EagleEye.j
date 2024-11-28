library EagleEye requires SpellEffectEvent, PluginSpellEffect, Missiles, NewBonusUtils, TimerUtils
    /* ---------------------- Eagle's Eye v1.0 by Chopinksi --------------------- */
    // Credits: SkriK
    //     SkriK           - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    //     Vinz            - Blind and Death models
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY     = 'A004'
        // The missile model
        private constant string  MODEL       = "Eagle.mdl"
        // The missile scale
        private constant real    SCALE       = 0.6
        // The model used for the blind effect
        private constant string  BLIND_MODEL = "Burning Rage Red.mdl"
        // The blind model attachment point
        private constant string  ATTACH      = "overhead"
        // The model used when the eagle hits its target
        private constant string  DEATH_MODEL = "Ephemeral Slash Silver.mdl"
        // The death model scale
        private constant real    DEATH_SCALE = 1.5
        // The missile speed
        private constant real    SPEED       = 1200
        // The missile final height
        private constant real    HEIGHT      = 350
        // The eagle search period
        private constant real    PERIOD      = 0.5
    endglobals

    // The amount of vision granted while the missile travels and the aoe used to detect units
    private function GetVisionRange takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The amount of damage dealt when single target
    private function GetDamage takes unit source, integer level returns real
        return 100. + 50.*level
    endfunction

    //
    private function GetAoE takes unit source, integer level returns real
        return 250. + 50.*level
    endfunction

    // The amount of damage dealt when targeted at the ground
    private function GetAoEDamage takes unit source, integer level returns real
        return 50.*level
    endfunction

    // The amount of vision reduced
    private function GetVisionReduction takes unit source, integer level returns real
        return 1400. + 100.*level
    endfunction

    // The duration of the vision debuff
    private function GetReductionDuraiton takes unit source, integer level returns real
        return 5. + 0.*level
    endfunction

    // The duration that the ealge will stay in place searching
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The unit detection filter
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    // The unit damage filter
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct EagleEye extends Missiles
        timer timer
        group group
        real time
        real timeout
        real reduction
        real aoe
        integer level
        boolean targeted

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u

            if timeout > 0 then
                call GroupEnumUnitsInRange(group, x, y, vision, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(owner, u) then
                            call deflect(GetUnitX(u), GetUnitY(u), 50)
                            set target = u
                            call pause(false)
                            call ReleaseTimer(timer)
                            set u = null

                            exitwhen true
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
                set timeout = timeout - PERIOD
            else
                call ReleaseTimer(timer)
                call terminate()
            endif
        endmethod

        private method onFinish takes nothing returns boolean
            local unit u

            if target == null then
                set timer = NewTimerEx(this)
                set group = CreateGroup()

                call pause(true)
                call TimerStart(timer, PERIOD, true, function thistype.onExpire)

                return false
            else
                if targeted then
                    if UnitAlive(target) then
                        if UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            if UnitAlive(target) then
                                call AddUnitBonusTimed(target, BONUS_SIGHT_RANGE, -reduction, time)
                                call DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, target, ATTACH), time)
                            endif
                        endif
                    endif
                else
                    call GroupEnumUnitsInRange(group, x, y, aoe, null)
                    loop
                        set u = FirstOfGroup(group)
                        exitwhen u == null
                            if DamageFilter(owner, u) then
                                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                    if UnitAlive(u) then
                                        call AddUnitBonusTimed(u, BONUS_SIGHT_RANGE, -reduction, time)
                                        call DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, u, ATTACH), time)
                                    endif
                                endif
                            endif
                        call GroupRemoveUnit(group, u)
                    endloop
                    call DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, x, y, 50, DEATH_SCALE))
                endif
                call alpha(0)

                return true
            endif
        endmethod

        private method onRemove takes nothing returns nothing
            call DestroyGroup(group)
            set group = null
            set timer = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this
            
            if Spell.target.unit == null then
                set this = thistype.create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, HEIGHT)
                set targeted = false
                set aoe = GetAoE(Spell.source.unit, Spell.level)
                set damage = GetAoEDamage(Spell.source.unit, Spell.level)
            else
                set this = thistype.create(Spell.source.x, Spell.source.y, 50, Spell.target.x, Spell.target.y, 50)
                set targeted = true
                set target = Spell.target.unit
                set damage = GetDamage(Spell.source.unit, Spell.level)
            endif

            set model = MODEL
            set scale = SCALE
            set speed = SPEED
            set source = Spell.source.unit
            set owner = Spell.source.player
            set level = Spell.level
            set vision = GetVisionRange(source, level)
            set time = GetReductionDuraiton(source, level)
            set reduction = GetVisionReduction(source, level)
            set timeout = GetDuration(source, level)

            call launch()
        endmethod
    
        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary
