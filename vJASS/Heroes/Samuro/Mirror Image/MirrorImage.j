library MirrorImage requires RegisterPlayerUnitEvent, Spell, NewBonus, Periodic, TimedHandles, Indexer, Utilities
    /* ---------------------- MirrorImage v1.4 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     TriggerHappy     - TimedHandles
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
        return GetUnitAbilityLevel(source, CLONED_HERO) > 0 or IsUnitIllusion(source)
    endfunction

    // The expirience multiplyer value per illusion count
    private constant function GetBonusExp takes nothing returns real
        return 1.
    endfunction

    // The number of illusions created per level
    private function GetNumberOfIllusions takes integer level returns integer
        return MathRound(SquareRoot(I2R(level)))
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
    private struct MirrorImage extends Spell
        private static real array dealt
        private static real array taken
        private static group array group
        private static effect array effect
        private static integer array source

        private unit unit
        private real delay
        private integer id
        private player player
        private integer level
        private real duration
        private integer amount

        method destroy takes nothing returns nothing
            call deallocate()

            set unit = null
            set player = null
        endmethod

        private static method clone takes unit original, unit illusion returns nothing
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

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Confuses the enemy by creating |cffffcc00" + N2S(GetNumberOfIllusions(level), 0) + "|r illusion of |cffffcc00Samuro|r and dispelling all magic. In addition, |cffffcc00Samuro|r gains |cffffcc00" + N2S(GetBonusExp() * 100, 0) + "%|r more expirience from kills for each illusion alive.\n\nDeal |cffffcc00" + N2S(GetDamageDealt(source, level) * 100, 0) + "%|r of the damage and take |cffffcc00" + N2S(GetDamageTaken(source, level) * 100, 0) + "%|r more damage.\n\nLasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onExpire takes nothing returns nothing
            local integer index
            local unit illusion
            local integer i = 0
        
            loop
                exitwhen i >= amount
                    set illusion = CreateUnit(player, GetUnitTypeId(unit), GetUnitX(unit), GetUnitY(unit), GetUnitFacing(unit))
                    set index = GetUnitUserData(illusion)
                    set source[index] = id
                    set dealt[index] = GetDamageDealt(unit, level)
                    set taken[index] = GetDamageTaken(unit, level)  
                    
                    call GroupAddUnit(group[id], illusion)
                    call UnitRemoveAbility(illusion, 'AInv')
                    call UnitAddAbility(illusion, CLONE_INVENTORY)
                    call CloneItems(unit, illusion, true)
                    call UnitAddAbility(illusion, CLONED_HERO)
                    call clone(unit, illusion)
                    call UnitMirrorBonuses(unit, illusion)
                    call UnitApplyTimedLife(illusion, 'BTLF', duration)
                    call SetPlayerHandicapXP(player, GetPlayerHandicapXP(player) + GetBonusExp())

                    static if LIBRARY_Switch then
                        call UnitRemoveAbility(illusion, Switch_ABILITY)
                    endif

                    static if LIBRARY_Critical then
                        if GetUnitAbilityLevel(unit, Critical_ABILITY) > 0 then
                            call UnitAddAbility(illusion, Critical_ABILITY)
                            call SetUnitAbilityLevel(illusion, Critical_ABILITY, GetUnitAbilityLevel(unit, Critical_ABILITY))
                        endif
                    endif
                set i = i + 1
            endloop

            set illusion = null
        endmethod

        private method onCast takes nothing returns nothing
            local unit u
            local string model = ID_MODEL

            set this = thistype.allocate()
            set id = Spell.source.id
            set unit = Spell.source.unit
            set level = Spell.level
            set player = Spell.source.player
            set amount = GetNumberOfIllusions(level)
            set delay = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_ANIMATION_DELAY, level - 1)
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

            call StartTimer(delay, false, this, -1)
            call DestroyEffectTimed(effect[id], duration)
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit source = GetTriggerUnit()
        
            if IsUnitIllusionEx(source) then
                call ModifyHeroSkillPoints(source, bj_MODIFYMETHOD_SET, 0)
            endif
        
            set source = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if IsUnitIllusionEx(Damage.source.unit) and Damage.amount > 0 then
                set Damage.amount = Damage.amount * dealt[Damage.source.id]
            endif
        
            if IsUnitIllusionEx(Damage.target.unit) and Damage.amount > 0 then
                set Damage.amount = Damage.amount * taken[Damage.target.id]
            endif    
        endmethod

        private static method onDeath takes nothing returns nothing
            local item i
            local integer id
            local player owner
            local integer j = 0
            local unit killed = GetTriggerUnit()
        
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
                        call UnitRemoveItem(killed, i)
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

        private static method onIndex takes nothing returns nothing
            local unit u = GetIndexUnit()
            local integer id = GetUnitUserData(u)

            set source[id] = 0

            call SetUnitBonus(u, BONUS_LIFE_STEAL, 0)
            call SetUnitBonus(u, BONUS_SPELL_VAMP, 0)
            call SetUnitBonus(u, BONUS_MISS_CHANCE, 0)
            call SetUnitBonus(u, BONUS_SPELL_POWER, 0)
            call SetUnitBonus(u, BONUS_EVASION_CHANCE, 0)
            call SetUnitBonus(u, BONUS_CRITICAL_CHANCE, 0)
            call SetUnitBonus(u, BONUS_CRITICAL_DAMAGE, 0)
        endmethod

        private static method onDeindex takes nothing returns nothing
            local unit removed = GetIndexUnit()
            local integer id = GetUnitUserData(removed)

            if GetUnitAbilityLevel(removed, ABILITY) > 0 then
                call DestroyGroup(group[id])
                call DestroyEffect(effect[id])

                set group[id] = null
                set effect[id] = null
            endif
        endmethod
        
        private static method onPickup takes nothing returns nothing
            if IsUnitIllusionEx(GetManipulatingUnit()) then
                call UnitRemoveItem(GetManipulatingUnit(), GetManipulatedItem())
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterUnitIndexEvent(function thistype.onIndex)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterUnitDeindexEvent(function thistype.onDeindex)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct
endlibrary