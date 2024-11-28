library ArrowStorm requires SpellEffectEvent, PluginSpellEffect, Utilities, Missiles, optional BlackArrow
    /* ---------------------- ArrowStorm v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Bribe        - SpellEffectEvent
    //     Deathclaw24  - Arrow Storm Icon
    //     AZ           - Black Arrow model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Arrow Storm ability
        private constant integer    ABILITY           = 'A00H'
        // The normal arrow model
        private constant string     ARROW_MODEL       = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
        // The cursed arrow model
        private constant string     CURSE_ARROW_MODEL = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"//"BlackArrow.mdl"
        // The arrow size
        private constant real       ARROW_SCALE       = 1.//3
        // The arrow speed
        private constant real       ARROW_SPEED       = 1500.
        // The arrow arc in degrees
        private constant real       ARROW_ARC         = 30.
        // The attack type of the damage dealt
        private constant attacktype ATTACK_TYPE       = ATTACK_TYPE_NORMAL  
        // The damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE       = DAMAGE_TYPE_MAGIC
    endglobals

    // The number of arrows launched per level
    private function GetArrowCount takes integer level returns integer
        return 20 + 5*level
    endfunction

    // The damage each arrow deals
    private function GetDamage takes integer level returns real
        return 25. + 25.*level
    endfunction

    // The Lauch AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The arrow impact AoE
    private function GetArrowAoE takes integer level returns real
        return 75.
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ArrowStorm extends Missiles
        integer level
        integer ability
        boolean curse
        real aoe
        real curse_duration

        method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local integer i = 0
            local real size
            local unit u

            call GroupEnumUnitsInRange(g, x, y, aoe, null)
            set size = BlzGroupGetSize(g)
            if size > 0 then
                loop
                    exitwhen i == size
                        set u = BlzGroupUnitAt(g, i)

                        if Filtered(owner, u) then
                            if UnitDamageTarget(source, u, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) and curse then
                                static if LIBRARY_BlackArrow then
                                    call BlackArrow.curse(u, source, owner)
                                endif
                            endif
                        endif
                    set i = i + 1
                endloop
            endif
            call DestroyGroup(g)

            set u = null
            set g = null

            return true
        endmethod

        private static method onCast takes nothing returns nothing
            local integer i = 0
            local integer count = GetArrowCount(Spell.level)
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real radius
            local thistype this

            loop
                exitwhen i == count
                    set radius = GetRandomRange(aoe)
                    set this = ArrowStorm.create(Spell.source.x, Spell.source.y, 85, GetRandomCoordInRange(Spell.x, radius, true), GetRandomCoordInRange(Spell.y, radius, false), 0)
                    set source = Spell.source.unit
                    set owner = Spell.source.player
                    set speed = ARROW_SPEED
                    set arc = ARROW_ARC
                    set damage = GetDamage(Spell.level)
                    set .aoe = GetArrowAoE(Spell.level)

                    static if LIBRARY_BlackArrow then
                        if BlackArrow.active[GetUnitUserData(Spell.source.unit)] then
                            set level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                            set model = CURSE_ARROW_MODEL
                            set curse = level > 0
                            set ability = BlackArrow_BLACK_ARROW_CURSE
                            set curse_duration = BlackArrow_GetCurseDuration(level)
                        else    
                            set model = ARROW_MODEL
                            set curse = false
                        endif
                    else
                        set model = ARROW_MODEL
                        set curse = false
                    endif

                    set scale  = ARROW_SCALE

                    call launch()
                set i = i + 1
            endloop
        endmethod   

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary