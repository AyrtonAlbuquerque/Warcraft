library ForsekenArrow requires SpellEffectEvent, PluginSpellEffect, Utilities, Missiles, CrowdControl optional BlackArrow
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
        return level*GetHeroAgi(source, true)*0.5 + level*250
    endfunction

    // The damage when exploding
    private function GetExplosionDamage takes unit source, integer level returns real
        return level*GetHeroAgi(source, true)*0.5 + level*250
    endfunction

    // The missile collision size
    private function GetCollisionSize takes integer level returns real
        return 200. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and /*
            */ UnitAlive(target) and /*
            */ not IsUnitType(target, UNIT_TYPE_STRUCTURE) and /*
            */ not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct ForsekenArrow extends Missiles
        real exp_damage
        real aoe
        real curse_duration
        integer curse_level
        integer level
        integer ability
        boolean curse

        method onHit takes unit hit returns boolean
            if Filtered(owner, hit) then
                if UnitDamageTarget(source, hit, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) and curse then
                    static if LIBRARY_BlackArrow then
                        call BlackArrow.curse(hit, source, owner)
                    endif
                endif
            endif

            return false
        endmethod

        method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local integer i = 0
            local integer size
            local unit u
            local real duration

            call DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, x, y, z, EXPLOSION_SCALE))
            call GroupEnumUnitsInRange(g, x, y, aoe, null)
            set size = BlzGroupGetSize(g)
            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(g, i)

                    if Filtered(owner, u) then
                        if UnitDamageTarget(source, u, exp_damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                            set duration = GetDuration(source, u, level)

                            static if LIBRARY_BlackArrow then
                                if curse then
                                    call BlackArrow.curse(u, source, owner)
                                endif
                            endif

                            call FearUnit(u, duration, FEAR_MODEL, ATTACH_FEAR, false)
                            call SilenceUnit(u, duration, null, null, false)
                            call SlowUnit(u, GetSlow(u, level), duration, null, null, false)
                        endif
                    endif
                set i = i + 1
            endloop
            call DestroyGroup(g)

            set g = null
            set u = null

            return true
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, 50)

            set source = Spell.source.unit
            set speed = MISSILE_SPEED
            set model = MISSILE_MODEL
            set scale = MISSILE_SCALE
            set level = Spell.level
            set owner = Spell.source.player
            set vision = 500
            set aoe = GetAoE(Spell.source.unit, Spell.level)
            set damage = GetCollisionDamage(Spell.source.unit, Spell.level)
            set collision = GetCollisionSize(Spell.level)
            set exp_damage = GetExplosionDamage(Spell.source.unit, Spell.level)

            static if LIBRARY_BlackArrow then
                set curse_level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                set curse = curse_level > 0
                set ability = BlackArrow_BLACK_ARROW_CURSE
                set curse_duration = BlackArrow_GetCurseDuration(curse_level)
            else
                set curse = false
            endif

            call launch()
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary