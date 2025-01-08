library FelBlast requires Ability, Periodic, Utilities optional FelBeam optional NewBonus
    /* ----------------------- Fel Blast v1.5 by Chopinski ---------------------- */
    // Credits:
    //     Mythic   - Nther Blast model
    //     san      - Miasma icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the fel blast ability
        private constant integer    ABILITY       = 'A002'
        // The amount of time it takes to do the damage
        private constant real       BLAST_DELAY   = 0.75
        // The blast model
        private constant string     BLAST_MODEL   = "NetherBlast.mdx"
        // The size of the blast model
        private constant real       BLAST_SCALE   = 1.
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE   = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt 
        private constant damagetype DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC
    endglobals

    // The damage amount of the blast
    private function GetDamage takes unit u, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. * level + GetHeroStr(u, true) * (1 + 0.25*level) + 0.5 * GetUnitBonus(u, BONUS_SPELL_POWER)
        else
            return 50. * level + GetHeroStr(u, true) * (1 + 0.25*level)
        endif
    endfunction

    // The damage area of effect. By default is the ability AoE field in the editor
    private function GetAoE takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The filter for units that will be damaged by the fel blast
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct FelBlast extends Ability
        private real x
        private real y
        private unit unit
        private real damage
        private real radius
        private real duration
        private player owner
        private integer armor

        method destroy takes nothing returns nothing
            set unit = null
            set owner = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Mannoroth|r blasts the target area with Fel Fire dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and cursing all enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r with |cffffcc00Fel Curse|r. When a unit affected by |cffffcc00Fel Curse|r dies, it will spawn a |cffffcc00Fel Beam|r to a random target within |cffffcc001000 AoE|r."
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u
            local group g
        
            set g = GetEnemyUnitsInRange(owner, x, y, radius, false, false)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        static if LIBRARY_FelBeam then
                            set FelBeam.source[GetUnitUserData(u)] = unit
                            set Curse.cursed[GetUnitUserData(u)] = true

                            call Curse.create(u, duration, armor)
                        endif

                        call UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)
            
            set g = null
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set unit = Spell.source.unit
            set owner  = Spell.source.player
            set damage = GetDamage(unit, Spell.level)
            set radius = GetAoE(unit, Spell.level)

            static if LIBRARY_FelBeam then
                set armor = FelBeam_GetArmorReduction(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
                set duration = FelBeam_GetCurseDuration(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
            endif
        
            call StartTimer(BLAST_DELAY, false, this, -1)
            call DestroyEffect(AddSpecialEffectEx(BLAST_MODEL, x, y, 0, BLAST_SCALE))
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary