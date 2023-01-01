library MirrorImage requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, TimerUtils, TimedHandles, Indexer
    /* ---------------------- MirrorImage v1.3 by Chopinski --------------------- */
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
        private constant integer ABILITY            = 'A002'
        // The raw code of the Cloned Hero ability
        private constant integer CLONED_HERO        = 'A007'
        // The raw code of the Cloned Inventory ability
        private constant integer CLONE_INVENTORY    = 'A008'
        // The model that is used to identify the real Samuro
        private constant string  ID_MODEL           = "CloudAura.mdx"
        // The model attchment point
        private constant string  ATTACH             = "origin"
        // The model that is used when a illusion dies
        private constant string  DEATH_EFFECT       = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
        // The player that will receive the dead illusion ownership
        private constant player  PLAYER_EXTRA       = Player(bj_PLAYER_NEUTRAL_EXTRA)
    endglobals

    // Use this function to also check if a unit is a illusion
    function IsUnitIllusionEx takes unit source returns boolean
        return GetUnitAbilityLevel(source, CLONED_HERO) > 0
    endfunction

    // The expirience multiplyer value per illusion count
    private constant function GetBonusExp takes nothing returns real
        return 1.
    endfunction

    // The number of illusions created per level
    private function GetNumberOfIllusions takes integer level returns integer
        return level
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
        static effect array effect
        static integer array source
        static group array group
        static real array dealt
        static real array taken

        timer timer
        unit unit
        player player
        integer id
        integer level
        integer amount
        real delay
        real duration

        private static method CloneStats takes unit original, unit illusion returns nothing
            call SetHeroXP(illusion, GetHeroXP(original), false)
            call SetHeroStr(illusion, GetHeroStr(original, false), true)
            call SetHeroAgi(illusion, GetHeroAgi(original, false), true)
            call SetHeroInt(illusion, GetHeroInt(original, false), true)
            call BlzSetUnitMaxHP(illusion, BlzGetUnitMaxHP(original))
            call BlzSetUnitMaxMana(illusion, BlzGetUnitMaxMana(original))
            call BlzSetUnitBaseDamage(illusion, BlzGetUnitBaseDamage(original, 0), 0)
            call SetWidgetLife(illusion, GetWidgetLife(original))
            call SetUnitState(illusion, UNIT_STATE_MANA, GetUnitState(original, UNIT_STATE_MANA))
            call ModifyHeroSkillPoints(illusion, bj_MODIFYMETHOD_SET, 0)
        endmethod

        private static method mirror takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real facing = GetUnitFacing(unit)
            local real x = GetUnitX(unit)
            local real y = GetUnitY(unit) 
            local integer i = 0
            local integer index
            local unit illusion
        
            loop
                exitwhen i >= amount
                    set illusion = CreateUnit(player, GetUnitTypeId(unit), x, y, facing)
                    set index = GetUnitUserData(illusion)
                    set source[index] = id
                    set dealt[index] = GetDamageDealt(unit, level)
                    set taken[index] = GetDamageTaken(unit, level)  
                    
                    call GroupAddUnit(group[id], illusion)
                    call UnitRemoveAbility(illusion, 'AInv')
                    call UnitAddAbility(illusion, CLONE_INVENTORY)
                    call CloneItems(unit, illusion, true)
                    call UnitAddAbility(illusion, CLONED_HERO)
                    call CloneStats(unit, illusion)
                    call UnitMirrorBonuses(unit, illusion)
                    call UnitApplyTimedLife(illusion, 'BTLF', duration)
                    call SetPlayerHandicapXP(player, GetPlayerHandicapXP(player) + GetBonusExp())

                    static if LIBRARY_Switch then
                        call UnitRemoveAbility(illusion, Switch_ABILITY)
                    endif
                set i = i + 1
            endloop

            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
            set unit = null
            set player = null
            set illusion = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local string model = ID_MODEL
            local unit u

            set timer = NewTimerEx(this)
            set unit = Spell.source.unit
            set player = Spell.source.player
            set id = Spell.source.id
            set level = Spell.level
            set amount = GetNumberOfIllusions(level)
            set delay = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_ANIMATION_DELAY, level - 1)
            set duration = GetDuration(unit, level)
            
            if group[id] == null then
                set group[id] = CreateGroup()
            endif

            call DestroyEffect(effect[id])
            loop
                set u = FirstOfGroup(group[id])
                exitwhen u == null
                    call ShowUnit(u, false)
                    call KillUnit(u)
                call GroupRemoveUnit(group[id], u)
            endloop
        
            if IsPlayerEnemy(GetLocalPlayer(), player) then
                set model = ".mdl"
            endif
        
            set effect[id] = AddSpecialEffectTarget(model, unit, ATTACH) 
            call DestroyEffectTimed(effect[id], duration)
            call TimerStart(timer, delay, false, function thistype.mirror)
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit source = GetTriggerUnit()
        
            if IsUnitIllusionEx(source) then
                call ModifyHeroSkillPoints(source, bj_MODIFYMETHOD_SET, 0)
            endif
        
            set source = null
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
        
            if IsUnitIllusionEx(Damage.source.unit) and damage > 0 then
                call BlzSetEventDamage(damage * dealt[Damage.source.id])
            endif
        
            if IsUnitIllusionEx(Damage.target.unit) and damage > 0 then
                call BlzSetEventDamage(damage * taken[Damage.target.id])
            endif    
        endmethod

        static method onDeath takes nothing returns nothing
            local unit killed = GetTriggerUnit()
            local player owner
            local integer j = 0
            local integer id
            local item i
        
            if IsUnitIllusionEx(killed) then
                set owner = GetOwningPlayer(killed)
                set id = source[GetUnitUserData(killed)]

                call GroupRemoveUnit(group[id], killed)

                if BlzGroupGetSize(group[id]) == 0 then
                    call DestroyEffect(effect[id])
                    set effect[id] = null
                endif

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
            
            set i = null
            set owner = null
            set killed = null
        endmethod

        static method onIndex takes nothing returns nothing
            local integer i = GetUnitUserData(GetIndexUnit())

            set source[i] = 0

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

        static method onDeindex takes nothing returns nothing
            local unit removed = GetIndexUnit()
            local integer id

            if GetUnitAbilityLevel(removed, ABILITY) > 0 then
                set id = GetUnitUserData(removed)

                call DestroyGroup(group[id])
                call DestroyEffect(effect[id])

                set group[id] = null
                set effect[id] = null
            endif
        endmethod
        
        static method onPickup takes nothing returns nothing
            if IsUnitIllusionEx(GetManipulatingUnit()) then
                call UnitRemoveItem(GetManipulatingUnit(), GetManipulatedItem())
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterUnitIndexEvent(function thistype.onIndex)
            call RegisterUnitDeindexEvent(function thistype.onDeindex)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct
endlibrary