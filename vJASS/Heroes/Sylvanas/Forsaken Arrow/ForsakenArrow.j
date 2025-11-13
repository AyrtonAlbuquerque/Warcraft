library ForsakenArrow requires Spell, Utilities, Missiles, CrowdControl, Modules optional BlackArrow optional NewBonus
    /* ------------------------------------- Forsaken Arrow v1.5 ------------------------------------ */
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
        private constant integer    ABILITY         = 'Svn5'
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
        // The Black Fire model
        private constant string     BURN_MODEL      = "BlackFire.mdl"
        // The Black Fire size
        private constant real       BURN_SCALE      = 0.75
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

    // The burn damage per second
    private function GetBurnDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. * level + (0.05 * level * GetUnitBonus(source, BONUS_SPELL_POWER))
        else
            return 25. * level
        endif
    endfunction

    // The burn duration
    private function GetBurnDuration takes unit source, integer level returns real
        return 4. + 2.*level
    endfunction

    // The burn interval
    private function GetBurnInterval takes integer level returns real
        return 1.0
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
    private struct BlackFire
        real x
        real y
        real aoe
        real damage
        real period
        real duration
        unit unit
        group group
        player player
        effect effect

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - period

            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if Filtered(player, u) then
                        call UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            return duration > 0
        endmethod

        static method create takes unit source, real x, real y, real damage, real aoe, real duration returns thistype
            local thistype this = thistype.allocate()

            set this.x = x
            set this.y = y
            set this.unit = source
            set this.aoe = aoe
            set this.damage = damage
            set this.duration = duration
            set this.group = CreateGroup()
            set this.player = GetOwningPlayer(source)
            set this.period = GetBurnInterval(GetUnitAbilityLevel(source, ABILITY))
            set this.effect = AddSpecialEffectEx(BURN_MODEL, x, y, 0, BURN_SCALE)

            call StartTimer(period, true, this, 0)

            return this
        endmethod

        implement Periodic
    endstruct
    
    private struct Arrow extends Missile
        real aoe
        integer level
        boolean curse
        real explosion
        integer ability
        integer tick = 0
        real curse_duration
        integer curse_level

        private method onPeriod takes nothing returns boolean
            set tick = tick + 1

            if tick == 4 then
                set tick = 0

                call BlackFire.create(source, x, y, GetBurnDamage(source, level), aoe, GetBurnDuration(source, level))
            endif

            return false
        endmethod

        private method onUnit takes unit hit returns boolean
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
            call BlackFire.create(source, x, y, GetBurnDamage(source, level), aoe, GetBurnDuration(source, level))

            set g = null

            return true
        endmethod
    endstruct

    private struct ForsakenArrow extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Sylvanas|r shoots a |cffffcc00Forsaken Arrow|r at the targeted area. On its path any enemy unit that comes in contact with it gets cursed and takes |cff00ffff" + N2S(GetCollisionDamage(source, level), 0) + "|r |cff00ffffMagic|r damage. The arrow also leaves a trail of |cffffcc00Black Fire|r that burns enemy units for |cffd45e19" + N2S(GetBurnDamage(source, level), 0) + " True|r damage per second for |cffffcc00" + N2S(GetBurnDuration(source, level), 1) + "|r seconds.  When it reaches its destination the |cffffcc00Forsaken Arrow|r explodes, dealing |cff00ffff" + N2S(GetExplosionDamage(source, level), 0) + "|r |cff00ffffMagic|r damage, |cffffcc00fearing, silencing and slowing|r all enemies whithin |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r AoE for |cffffcc005|r (|cffffcc002.5|r for Heroes) seconds."
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