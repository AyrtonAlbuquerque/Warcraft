library WaterElemental requires Spell, NewBonus, Indexer, Utilities
    /* -------------------- Water Elemental v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY   = 'Jna0'
        // The raw code of the Water Elemental unit
        public  constant integer ELEMENTAL = 'ujn0'
        // The summon effect
        private constant string MODEL      = "WaterBurst.mdl"
        // The summon effect scale
        private constant real SCALE        = 1.
    endglobals

    // The unit damage
    private function GetDamage takes unit source, integer level returns integer
        return 30 + R2I(0.3 * GetUnitBonus(source, BONUS_DAMAGE) + 0.3 * GetUnitBonus(source, BONUS_SPELL_POWER))
    endfunction

    // The unit health
    private function GetHealth takes unit source, integer level returns integer
        return 600 + R2I(0.4 * BlzGetUnitMaxHP(source))
    endfunction

    // The unit armor
    private function GetArmor takes unit source, integer level returns real
        return 1. + GetUnitBonus(source, BONUS_ARMOR)
    endfunction

    // The unit duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Elemental
        private static thistype array struct

        private unit unit
        private group group

        method operator size takes nothing returns integer
            return BlzGroupGetSize(group)
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == size
                    set struct[GetUnitUserData(BlzGroupUnitAt(group, i))] = 0
                set i = i + 1
            endloop

            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
        endmethod

        method add takes unit u returns nothing
            set struct[GetUnitUserData(u)] = this
            call GroupAddUnit(group, u)
        endmethod

        method command takes unit target, real x, real y, string order returns nothing
            local integer i = 0
            
            if target == null then
                if order == "stop" or order == "holdposition" then
                    call GroupImmediateOrder(group, order)
                elseif order == "attackground" or order == "smart" or order == "move" or order == "attack" then
                    loop
                        exitwhen i == size
                            call IssuePointOrder(BlzGroupUnitAt(group, i), order, x + 300 * Cos(i*2*bj_PI/size), y + 300 * Sin(i*2*bj_PI/size))
                        set i = i + 1
                    endloop
                endif
            else
                if order == "smart" or order == "move" or order == "attack" then
                    call GroupTargetOrder(group, order, target)
                endif
            endif
        endmethod

        static method owner takes integer id returns unit
            local thistype this = struct[id]

            if this != 0 then
                return unit
            else
                return null
            endif
        endmethod

        static method create takes unit source returns thistype
            local thistype this = thistype.allocate()

            set unit = source
            set group = CreateGroup()

            return this
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id
            local thistype this

            if GetUnitTypeId(source) == ELEMENTAL then
                set id = GetUnitUserData(source)

                if struct[id] != 0 then
                    set this = struct[id]
                    
                    if GetOrderTargetUnit() == unit then
                        if not IsUnitInGroup(source, group) then
                            call GroupAddUnit(group, source)
                        endif
                    else
                        if IsUnitSelected(source, GetOwningPlayer(source)) and IsUnitInGroup(source, group) then
                            call GroupRemoveUnit(group, source)
                        endif
                    endif
                endif
            endif

            set source = null
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer id
            local thistype this

            if GetUnitTypeId(source) == ELEMENTAL then
                set id = GetUnitUserData(source)

                if struct[id] != 0 then
                    set this = struct[id]
                    call GroupRemoveUnit(group, source)
                    set struct[id] = 0
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
    
    private struct WaterElemental extends Spell
        private static thistype array struct

        private integer id
        private Elemental elementals

        method destroy takes nothing returns nothing
            call elementals.destroy()
            call deallocate()

            set struct[id] = 0
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Jaina|r summon a |cffffcc00Water Elemental|r to aid her in combat. The |cffffcc00Water Elemental|r has |cffff0000" + N2S(GetDamage(source, level), 0) + "|r Attack Damage, |cffff0000" + N2S(GetHealth(source, level), 0) + "|r |cffff0000Health|r and |cff808080" + N2S(GetArmor(source, level), 0) + "|r |cff808080Armor|r. By default the elementals shadow her movement and commands until any order is given. Ordering the elemental to follow |cffffcc00Jaina|r makes it shadow her again.\n\nLasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local real angle = GetUnitFacing(Spell.source.unit)
            local unit u = CreateUnit(Spell.source.player, ELEMENTAL, Spell.source.x + 250 * Cos(Deg2Rad(angle)), Spell.source.y + 250 * Sin(Deg2Rad(angle)), angle)

            call DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(u), GetUnitY(u), 0, SCALE))

            if struct[Spell.source.id] != 0 then
                set this = struct[Spell.source.id]
            else
                set this = thistype.allocate()
                set struct[Spell.source.id] = this
                set elementals = Elemental.create(Spell.source.unit)
            endif

            call BlzSetUnitBaseDamage(u, GetDamage(Spell.source.unit, Spell.level), 0)
            call BlzSetUnitMaxHP(u, GetHealth(Spell.source.unit, Spell.level))
            call SetUnitLifePercentBJ(u, 100)
            call BlzSetUnitArmor(u, GetArmor(Spell.source.unit, Spell.level))
            call SetUnitAnimation(u, "Birth")
            call UnitApplyTimedLife(u, 'BTLF', GetDuration(Spell.source.unit, Spell.level))
            call elementals.add(u)

            set u = null
        endmethod

        private static method onDeindex takes nothing returns nothing
            local thistype this = struct[GetUnitUserData(GetIndexUnit())]

            if this != 0 then
                call destroy()
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local thistype this = struct[GetUnitUserData(source)]

            if GetUnitAbilityLevel(source, ABILITY) > 0 and this != 0 then
                call elementals.command(GetOrderTargetUnit(), GetOrderPointX(), GetOrderPointY(), OrderId2String(GetIssuedOrderId()))
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterUnitDeindexEvent(function thistype.onDeindex)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary