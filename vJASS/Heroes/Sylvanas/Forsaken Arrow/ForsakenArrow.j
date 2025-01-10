library ForsekenArrow requires Ability, Utilities, Missiles, CrowdControl optional BlackArrow optional NewBonus
    /* ------------------------------------- Forseken Arrow v1.4 ------------------------------------ */
    // Credits:
    //     Bribe          - SpellEffectEvent
    //     Darkfang       - Icon
    //     AZ             - Arrow model
    //     JetFangInferno - Dark Nova model
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Screaming Banshees ability
        private constant integer    ABILITY         = 'A00K'
        // The missile model
        private constant string     MISSILE_MODEL   = "DeathShot.mdl"
        // The missile size
        private constant real       MISSILE_SCALE   = 0.8
        // The missile speed
        private constant real       MISSILE_SPEED   = 2000.
        // The Explosion model
        private constant string     EXPLOSION_MODEL = "DarkNova.mdl"
        // The Explosion size
        private constant real       EXPLOSION_SCALE = 0.5
        // The fear model
        private constant string     FEAR_MODEL      = "Fear.mdl"
        // The the fear attachment point
        private constant string     ATTACH_FEAR     = "overhead"
        // The attack type of the damage dealt
        private constant attacktype ATTACK_TYPE     = ATTACK_TYPE_NORMAL  
        // The damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC
    endglobals

    // The Explosion AoE
    private function GetAoE takes unit caster, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The duration of the Fear, Silence and Slow. By Defauklt its the field value in the abiltiy
    private function GetDuration takes unit caster, unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        endif
    endfunction

    // The slow amount
    private function GetSlow takes unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.5 + 0.*level
        else
            return 0.5 + 0.*level
        endif
    endfunction

    // The damage when passing through units
    private function GetCollisionDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 125 * level + (0.25 * level) * GetHeroAgi(source, true) + 0.25 * level * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 125 * level + (0.25 * level) * GetHeroAgi(source, true)
        endif
    endfunction

    // The damage when exploding
    private function GetExplosionDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 250 * level + (0.5 * level) * GetHeroAgi(source, true) + (0.25 + 0.25*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250 * level + (0.5 * level) * GetHeroAgi(source, true)
        endif
    endfunction

    // The missile collision size
    private function GetCollisionSize takes integer level returns real
        return 200. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Arrow extends Missiles
        real aoe
        integer level
        boolean curse
        real explosion
        integer ability
        real curse_duration
        integer curse_level

        private method onHit takes unit hit returns boolean
            if Filtered(owner, hit) then
                if UnitDamageTarget(source, hit, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) and curse then
                    static if LIBRARY_BlackArrow then
                        call BlackArrow.curse(hit, source, owner)
                    endif
                endif
            endif

            return false
        endmethod

        private method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local real duration
            local unit u

            call DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, x, y, z, EXPLOSION_SCALE))
            call GroupEnumUnitsInRange(g, x, y, aoe, null)
            
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if Filtered(owner, u) then
                        if UnitDamageTarget(source, u, explosion, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                            set duration = GetDuration(source, u, level)

                            static if LIBRARY_BlackArrow then
                                if curse then
                                    call BlackArrow.curse(u, source, owner)
                                endif
                            endif

                            call SilenceUnit(u, duration, null, null, false)
                            call FearUnit(u, duration, FEAR_MODEL, ATTACH_FEAR, false)
                            call SlowUnit(u, GetSlow(u, level), duration, null, null, false)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct ForsekenArrow extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Sylvanas|r shoots a |cffffcc00Forsaken Arrow|r at the targeted area. On its path any enemy unit that comes in contact with it gets cursed and takes |cff00ffff" + N2S(GetCollisionDamage(source, level), 0) + "|r |cff00ffffMagic|r damage. When it reaches its destination the |cffffcc00Forsaken Arrow|r explodes, dealing |cff00ffff" + N2S(GetExplosionDamage(source, level), 0) + "|r |cff00ffffMagic|r damage, |cffffcc00fearing, silencing and slowing|r all enemies whithin |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r AoE for |cffffcc005|r (|cffffcc002.5|r for Heroes) seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local Arrow arrow = Arrow.create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, 50)

            set arrow.speed = MISSILE_SPEED
            set arrow.model = MISSILE_MODEL
            set arrow.scale = MISSILE_SCALE
            set arrow.level = Spell.level
            set arrow.source = Spell.source.unit
            set arrow.owner = Spell.source.player
            set arrow.vision = 500
            set arrow.aoe = GetAoE(Spell.source.unit, Spell.level)
            set arrow.damage = GetCollisionDamage(Spell.source.unit, Spell.level)
            set arrow.collision = GetCollisionSize(Spell.level)
            set arrow.explosion = GetExplosionDamage(Spell.source.unit, Spell.level)

            static if LIBRARY_BlackArrow then
                set arrow.curse_level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                set arrow.curse = arrow.curse_level > 0
                set arrow.ability = BlackArrow_BLACK_ARROW_CURSE
                set arrow.curse_duration = BlackArrow_GetCurseDuration(arrow.curse_level)
            else
                set arrow.curse = false
            endif

            call arrow.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary