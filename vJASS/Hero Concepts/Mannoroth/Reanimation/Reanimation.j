library Reanimation requires RegisterPlayerUnitEvent, TimerUtils
    /* --------------------- Reanimation v1.4 by Chopinski -------------------- */
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
        private constant integer ABILITY                   = 'A005'
        // The raw code of the Mannoroth unit in the editor
        private constant integer MANNOROTH_ID              = 'N000'
        // The raw code of the reanimation metamorphosis 
        // ability that is used to change its model
        private constant integer REANIMATION_METAMORPHOSIS = 'A006'
        // The GAIN_AT_LEVEL is greater than 0
        // Mannoroth will gain reanimation at this level 
        private constant integer GAIN_AT_LEVEL             = 20
        // The effect created on the gorund when mannoroth
        // dies
        private constant string  MANNOROTH_SKELETON        = "Mannorothemerdg.mdl"
        // The size of the skeleton model
        private constant real    SKELETON_SCALE            = 0.4
    endglobals

    // The Ability Cooldown
    private function GetCooldown takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, REANIMATION_METAMORPHOSIS), ABILITY_RLF_COOLDOWN, level - 1)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Reanimate
        static boolean array Reanimated
        static trigger       trigger = CreateTrigger()

        timer   timer
        unit    unit
        effect  effect
        integer level
        integer index
        integer stage
        real    face

        static method onExpire takes nothing returns nothing
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
                set Reanimated[index] = false
                call ReleaseTimer(timer)
                call BlzSetAbilityStringLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtons\\PASReanimation.blp")
                call IncUnitAbilityLevel(unit, ABILITY)
                call DecUnitAbilityLevel(unit, ABILITY)
                set timer  = null
                set unit   = null
                set effect = null
                call deallocate()
            endif
        endmethod   

        private static method onDamage takes nothing returns nothing
            local unit     target = BlzGetEventDamageTarget()
            local real     damage = GetEventDamage()
            local integer  index  = GetUnitUserData(target)
            local integer  level  = GetUnitAbilityLevel(target, ABILITY)
            local thistype this
            
        
            if level > 0 and damage >= GetWidgetLife(target) and not Reanimated[index] then
                set this              = thistype.allocate()
                set .timer            = NewTimerEx(this)
                set .unit             = target
                set .level            = level
                set .index            = index
                set .stage            = 0
                set .face             = GetUnitFacing(target)*bj_DEGTORAD
                set Reanimated[index] = true
                call TimerStart(timer, 3, false, function thistype.onExpire)
        
                call BlzSetAbilityStringLevelField(BlzGetUnitAbility(target, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtonsDisabled\\DISPASReanimation.blp")
                call IncUnitAbilityLevel(target, ABILITY)
                call DecUnitAbilityLevel(target, ABILITY)
                call SetUnitInvulnerable(target, true)
                call BlzSetEventDamage(0)
                call BlzPauseUnitEx(target, true)
                call SetUnitAnimation(target, "Death")
            endif
        
            set target = null
        endmethod

        static method onLevel takes nothing returns nothing
            local unit u 

            if GAIN_AT_LEVEL > 0 then
                set u = GetTriggerUnit()
                if GetUnitTypeId(u) == MANNOROTH_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary