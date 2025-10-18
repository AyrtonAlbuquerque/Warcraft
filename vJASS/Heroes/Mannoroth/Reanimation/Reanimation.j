library Reanimation requires RegisterPlayerUnitEvent, Spell, TimerUtils
    /* --------------------- Reanimation v1.5 by Chopinski -------------------- */
    // Credits:
    //     Henry         - Reanimated Mannoroth model
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     Vexorian      - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the reanimation ability
        private constant integer ABILITY                    = 'Mnr0'
        // The raw code of the reanimation metamorphosis 
        // ability that is used to change its model
        private constant integer REANIMATION_METAMORPHOSIS  = 'Mnr6'
        // The Reanimation buff
        private constant integer REANIMATION_BUFF           = 'BMn0'
        // The effect created on the gorund when mannoroth dies
        private constant string  MANNOROTH_SKELETON         = "Reanimation.mdl"
        // The size of the skeleton model
        private constant real    SKELETON_SCALE             = 0.4
    endglobals

    // The Ability Cooldown
    private function GetCooldown takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, REANIMATION_METAMORPHOSIS), ABILITY_RLF_COOLDOWN, level - 1)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Reanimate extends Spell
        private static boolean array reanimated

        private unit unit
        private real face
        private integer id
        private timer timer
        private effect effect
        private integer level
        private integer stage

        method destroy takes nothing returns nothing
            call BlzSetAbilityStringLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtons\\PASReanimation.blp")
            call IncUnitAbilityLevel(unit, ABILITY)
            call DecUnitAbilityLevel(unit, ABILITY)
            call ReleaseTimer(timer)
            call deallocate()

            set unit = null
            set timer = null
            set effect = null
            set reanimated[id] = false
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set stage = stage + 1

            if stage == 1 then
                call BlzPauseUnitEx(unit, false)
                call ShowUnit(unit, false)
                call SetUnitLifePercentBJ(unit, 100)
                call SetUnitManaPercentBJ(unit, 100)
                call IssueImmediateOrder(unit, "metamorphosis")
                call SetUnitInvulnerable(unit, true)
                call BlzPauseUnitEx(unit, true)
                set effect = AddSpecialEffect(MANNOROTH_SKELETON, GetUnitX(unit), GetUnitY(unit))
                call BlzSetSpecialEffectScale(effect, SKELETON_SCALE)
                call BlzSetSpecialEffectYaw(effect, face)
                call TimerStart(timer, 2, false, function thistype.onExpire)
            elseif stage == 2 then
                call BlzPlaySpecialEffect(effect, ANIM_TYPE_MORPH)
                call TimerStart(timer, 9, false, function thistype.onExpire)
            elseif stage == 3 then
                call BlzSetSpecialEffectZ(effect, 4000)
                call ShowUnit(unit, true)
                call BlzPauseUnitEx(unit, false)
                call SetUnitInvulnerable(unit, false)
                call DestroyEffect(effect)
                call TimerStart(timer, GetCooldown(unit, level) - 14, false, function thistype.onExpire)
            else
                call destroy()
            endif
        endmethod   

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)
            local thistype this
        
            if level > 0 and Damage.amount >= Damage.target.health and not reanimated[Damage.target.id] then
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set stage = 0
                set this.level = level
                set unit = Damage.target.unit
                set id = Damage.target.id
                set face = GetUnitFacing(Damage.target.unit) * bj_DEGTORAD
                set reanimated[id] = true
                set Damage.amount = 0

                call TimerStart(timer, 3, false, function thistype.onExpire)
                call BlzSetAbilityStringLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtonsDisabled\\DISPASReanimation.blp")
                call IncUnitAbilityLevel(unit, ABILITY)
                call DecUnitAbilityLevel(unit, ABILITY)
                call SetUnitInvulnerable(unit, true)
                call BlzPauseUnitEx(unit, true)
                call SetUnitAnimation(unit, "Death")
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary