library MirrorImage requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, TimerUtils, TimedHandles, Indexer optional Switch
    /* ---------------------- MirrorImage v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     Bribe            - SpellEffectEvent
    //     TriggerHappy     - TimedHandles
    //     Vexorian         - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Mirror Image ability
        private constant integer ABILITY       = 'A002'
        // The model that is used to identify the real Samuro
        private constant string  ID_MODEL      = "CloudAura.mdx"
        // The model that is used when a illusion dies
        private constant string  DEATH_EFFECT  = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
        // The raw code of the Mirror Image ability
        private constant player  PLAYER_EXTRA  = Player(bj_PLAYER_NEUTRAL_EXTRA)
        // You can use this to do some other stuff if you like
        boolean array IsIllusion
    endglobals

    // The expirience multiplyer value per illusion count
    private constant function GetBonusExp takes nothing returns real
        return 1.
    endfunction

    // The illusions duration. By default the object editor field value
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The dealt damage percentage. By default the object editor field value
    private function GetDamageDealt takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DAMAGE_DEALT_PERCENT_OMI2, level - 1)
    endfunction

    // The taken damage percentage. By default the object editor field value
    private function GetDamageTaken takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DAMAGE_TAKEN_PERCENT_OMI3, level - 1)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct MirrorImage
        static effect array effects
        static real   array dealt
        static real   array taken

        timer   t
        group   g
        integer idx
        integer level
        real    delay
        real    duration
        player  owner
        string  effect
        unit    source


        private static method CloneStats takes unit source, unit illusion returns nothing
            call SetHeroXP(illusion, GetHeroXP(source), false)
            call SetHeroStr(illusion, GetHeroStr(source, false), true)
            call SetHeroAgi(illusion, GetHeroAgi(source, false), true)
            call SetHeroInt(illusion, GetHeroInt(source, false), true)
            call BlzSetUnitMaxHP(illusion, BlzGetUnitMaxHP(source))
            call BlzSetUnitMaxMana(illusion, BlzGetUnitMaxMana(source))
            call BlzSetUnitBaseDamage(illusion, BlzGetUnitBaseDamage(source, 0), 0)
            call SetWidgetLife(illusion, GetWidgetLife(source))
            call SetUnitState(illusion, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA))
            call ModifyHeroSkillPoints(illusion, bj_MODIFYMETHOD_SET, 0)
        endmethod

        private static method mirror takes nothing returns nothing
            local thistype this   = GetTimerData(GetExpiredTimer())
            local real     facing = GetUnitFacing(source)
            local real     x      = GetUnitX(source)
            local real     y      = GetUnitY(source) 
            local integer  i      = 0
            local integer  index
            local unit     illusion
            
        
            loop
                exitwhen i >= level
                    set illusion          = CreateUnit(owner, GetUnitTypeId(source), x, y, facing)
                    set index             = GetUnitUserData(illusion)
                    set dealt[index]      = GetDamageDealt(source, level)
                    set taken[index]      = GetDamageTaken(source, level)  
                    set IsIllusion[index] = true

                    call CloneItems(source, illusion)
                    call CloneStats(source, illusion)
                    call UnitMirrorBonuses(source, illusion)
                    call SetUnitAbilityLevel(illusion, 'AInv', 2)
                    call UnitApplyTimedLife(illusion, 'BTLF', GetDuration(source, level))
                    call SetPlayerHandicapXP(owner, GetPlayerHandicapXP(owner) + GetBonusExp())
                    static if LIBRARY_Switch then
                        call UnitRemoveAbility(illusion, Switch_ABILITY)
                    endif
                set i = i + 1
            endloop

            call ReleaseTimer(t)
            set t         = null
            set g         = null
            set source    = null
            set owner     = null
            set illusion  = null
            call deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit     v
            local effect   e

            set t        = NewTimerEx(this)
            set g        = CreateGroup()
            set source   = Spell.source.unit
            set owner    = Spell.source.player
            set effect   = ID_MODEL
            set level    = Spell.level
            set delay    = BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_ANIMATION_DELAY, level - 1)
            set duration = GetDuration(source, level)
            set idx      = GetUnitUserData(source)
            set e        = effects[idx]
            
        
            call DestroyEffect(e)
            call GroupEnumUnitsOfPlayer(g, owner, null)
            loop
                set v = FirstOfGroup(g)
                exitwhen v == null
                    if GetUnitTypeId(v) == GetUnitTypeId(source) and IsIllusion[GetUnitUserData(v)] then
                        call ShowUnit(v, false)
                        call KillUnit(v)
                    endif
                call GroupRemoveUnit(g, v)
            endloop
            call DestroyGroup(g)
        
            if IsPlayerEnemy(GetLocalPlayer(), owner) then
                set effect = ".mdl"
            endif
        
            set e = AddSpecialEffectTarget(effect, source, "origin") 
            set effects[idx] = e
            call DestroyEffectTimed(e, duration)
            call TimerStart(t, delay, false, function thistype.mirror)

            set e = null
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer index  = GetUnitUserData(source)
            local integer level  = GetHeroLevel(source)
        
            if IsIllusion[index] then
                call ModifyHeroSkillPoints(source, bj_MODIFYMETHOD_SET, 0)
            endif
        
            set source = null
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
        
            if IsIllusion[Damage.source.id] and damage > 0 then
                call BlzSetEventDamage(damage * dealt[Damage.source.id])
            endif
        
            if IsIllusion[Damage.target.id] and damage > 0 then
                call BlzSetEventDamage(damage * taken[Damage.target.id])
            endif    
        endmethod

        static method onDeath takes nothing returns nothing
            local unit    killed = GetTriggerUnit()
            local player  owner  = GetOwningPlayer(killed)
            local integer index  = GetUnitUserData(killed)
            local integer j      = 0
            local item    i
        
            if IsIllusion[index] then
                loop
                    set i = UnitItemInSlot(killed, j)
                    if i != null then
                        call UnitRemoveItem(killed, i) // to trigger drop events
                        call RemoveItem(i)
                    endif
                    set j = j + 1
                    exitwhen j >= bj_MAX_INVENTORY
                endloop
                call DestroyEffect(AddSpecialEffect(DEATH_EFFECT, GetUnitX(killed), GetUnitY(killed)))
                call SetPlayerHandicapXP(owner, GetPlayerHandicapXP(owner) - GetBonusExp())
                call SetUnitOwner(killed, PLAYER_EXTRA, true)
                call ShowUnit(killed, false)
            endif
            
            set i      = null
            set killed = null
        endmethod

        static method onIndex takes nothing returns nothing
            local integer i = GetUnitUserData(GetIndexUnit())
            
            set IsIllusion[i] = false

            static if LIBRARY_CriticalStrike then
                set Critical.chance[i] = 0
                set Critical.multiplier[i] = 0
            endif

            static if LIBRARY_Evasion then
                set Evasion.evasion[i] = 0
                set Evasion.miss[i] = 0
                set Evasion.neverMiss[i] = 0
            endif

            static if LIBRARY_SpellPower then
                set SpellPower.flat[i] = 0
                set SpellPower.percent[i] = 0
            endif

            static if LIBRARY_LifeSteal then
                set LifeSteal.amount[i] = 0
            endif

            static if LIBRARY_SpellVamp then
                set SpellVamp.amount[i] = 0
            endif
        endmethod
        
        static method onPickup takes nothing returns nothing
            local item i
            local integer id
            
            if IsIllusion[GetUnitUserData(GetManipulatingUnit())] then
                set i = GetManipulatedItem()
                set id = GetItemTypeId(i)
                
                if id == 'ankh' then
                    call BlzItemRemoveAbility(i, 'AIrc')
                endif
                call BlzSetItemBooleanField(i, ITEM_BF_ACTIVELY_USED, false)
            endif
            
            set i = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterUnitIndexEvent(function thistype.onIndex)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct
endlibrary