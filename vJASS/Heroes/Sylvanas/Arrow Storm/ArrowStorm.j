library ArrowStorm requires Spell, Utilities, Missiles, DamageInterface optional BlackArrow optional NewBonus
    /* ---------------------- ArrowStorm v1.5 by Chopinski ---------------------- */
    // Credits:
    //     Deathclaw24  - Arrow Storm Icon
    //     AZ           - Black Arrow model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Arrow Storm ability
        private constant integer    ABILITY           = 'Svn3'
        // The normal arrow model
        private constant string     ARROW_MODEL       = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
        // The cursed arrow model
        private constant string     CURSE_ARROW_MODEL = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"
        // The arrow size
        private constant real       ARROW_SCALE       = 1.
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
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. + 25.*level + 0.15 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25. + 25.*level
        endif
    endfunction

    // The Lauch AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The arrow impact AoE
    private function GetArrowAoE takes integer level returns real
        return 100.
    endfunction

    // The cooldown reduction per attack
    private function GetCooldownReduction takes unit source, integer level returns real
        return 1. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Arrow extends Missile
        real aoe
        real timeout
        integer level
        boolean curse
        integer ability

        private method onFinish takes nothing returns boolean
            local unit u
            local group g = CreateGroup()

            call GroupEnumUnitsInRange(g, x, y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if Filtered(owner, u) then
                        if UnitDamageTarget(source, u, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) and curse then
                            static if LIBRARY_BlackArrow then
                                call BlackArrow.curse(u, source, owner)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct ArrowStorm extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Sylvanas|r lauches |cffffcc00" + N2S(GetArrowCount(level), 0) + "|r arrows into the air that will land within |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r |cffffcc00AoE|r of targeted area in random spots, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to enemy units hitted. If |cffffcc00Black Arrows|r is active, |cffffcc00Arrow Storm|r will curse enemy units hit. Additionally, every auto attack reduces the cooldown of |cffffcc00Arrow Storm|r by |cffffcc001|r second."
        endmethod

        private method onCast takes nothing returns nothing
            local real radius
            local Arrow arrow
            local integer i = GetArrowCount(Spell.level)

            loop
                exitwhen i == 0
                    set radius = GetRandomRange(GetAoE(Spell.source.unit, Spell.level))
                    set arrow = Arrow.create(Spell.source.x, Spell.source.y, 85, GetRandomCoordInRange(Spell.x, radius, true), GetRandomCoordInRange(Spell.y, radius, false), 0)

                    set arrow.source = Spell.source.unit
                    set arrow.owner = Spell.source.player
                    set arrow.speed = ARROW_SPEED
                    set arrow.arc = ARROW_ARC * bj_DEGTORAD
                    set arrow.damage = GetDamage(Spell.source.unit, Spell.level)
                    set arrow.aoe = GetArrowAoE(Spell.level)

                    static if LIBRARY_BlackArrow then
                        if BlackArrow.active[GetUnitUserData(Spell.source.unit)] then
                            set arrow.level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                            set arrow.model = CURSE_ARROW_MODEL
                            set arrow.curse = arrow.level > 0
                            set arrow.ability = BlackArrow_BLACK_ARROW_CURSE
                            set arrow.timeout = BlackArrow_GetCurseDuration(arrow.level)
                        else    
                            set arrow.model = ARROW_MODEL
                            set arrow.curse = false
                        endif
                    else
                        set arrow.model = ARROW_MODEL
                        set arrow.curse = false
                    endif

                    set arrow.scale = ARROW_SCALE

                    call arrow.launch()
                set i = i - 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real cooldown
            local real reduction

            if Damage.isEnemy then
                set cooldown = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, ABILITY)
                set reduction = GetCooldownReduction(Damage.source.unit, GetUnitAbilityLevel(Damage.source.unit, ABILITY))

                if cooldown >= reduction then
                    call StartUnitAbilityCooldown(Damage.source.unit, ABILITY, cooldown - reduction)
                else
                    call ResetUnitAbilityCooldown(Damage.source.unit, ABILITY)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary