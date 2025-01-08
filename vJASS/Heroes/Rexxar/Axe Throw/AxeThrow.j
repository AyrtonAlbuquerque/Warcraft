library AxeThrow requires Ability, Missiles, Utilities, CrowdControl optional NewBonus
    /* ----------------------- Axe Throw v1.2 by Chopinski ---------------------- */
    // Credits:
    //     -Berz-          - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY   = 'A001'
        // The missile model
        private constant string  MODEL     = "Abilities\\Weapons\\RexxarMissile\\RexxarMissile.mdl"
        // The missile scale
        private constant real    SCALE     = 1.2
        // The missile speed
        private constant real    SPEED     = 1200
        // The missile hit model
        private constant string  HIT_MODEL = "Objects\\Spawnmodels\\Orc\\Orcblood\\OrdBloodWyvernRider.mdl"
        // The hit model attachment point
        private constant string  ATTACH    = "origin"
    endglobals
    
    // The number of axes
    private function GetAxeCount takes integer level returns integer
        return 2 + 0*level
    endfunction
    
    // The missile curve
    private function GetCurve takes integer level returns real
        return 10. + 0.*level
    endfunction
    
    // The missile arc
    private function GetArc takes integer level returns real
        return 0. + 0.*level
    endfunction
    
    // The missile collision size
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction
    
    // The missile damage
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. + 50. * level + 0.8 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50. * level
        endif
    endfunction
    
    // The slow amount
    private function GetSlowAmount takes integer level returns real
        return 0.1 + 0.1*level
    endfunction
    
    // The slow duration
    private function GetSlowDuration takes integer level returns real
        return 2. + 0.*level
    endfunction
    
    // The cooldown reduction when killing units
    private function GetCooldownReduction takes integer level returns real
        return 0.5 + 0.*level
    endfunction
    
    // The Damage Filter units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Axe extends Missiles
        real slow
        real time
        real reduction
        boolean deflected
    
        private method onHit takes unit u returns boolean
            if UnitAlive(u) then
                if DamageFilter(owner, u) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, u, ATTACH))
                        if not UnitAlive(u) then
                            call StartUnitAbilityCooldown(source, ABILITY, BlzGetUnitAbilityCooldownRemaining(source, ABILITY) - reduction)
                        else
                            call SlowUnit(u, slow, time, null, null, false)
                        endif
                    endif
                endif
            endif
            
            return false
        endmethod
        
        private method onFinish takes nothing returns boolean
            if not deflected then
                set deflected = true
                call deflectTarget(source)
            endif
            
            return false
        endmethod
    endstruct

    private struct AxeThrow extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r thow his axes in an arc, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and slowing enemy units hit by |cffffcc00" + N2S(GetSlowAmount(level) * 100, 0) + "%|r for |cffffcc00" + N2S(GetSlowDuration(level), 1) + "|r seconds. Upon reacinhg the targeted destination, the axes return to |cffffcc00Rexxar|r. Every unit killed by the axes reduces cooldown by |cffffcc00" + N2S(GetCooldownReduction(level), 1) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local integer i = GetAxeCount(Spell.level)
            local integer a = 1
            local Axe axe
            
            loop
                exitwhen i == 0
                    set axe = Axe.create(Spell.source.x, Spell.source.y, 100, Spell.x, Spell.y, 100)
                    set axe.model = MODEL
                    set axe.scale = SCALE
                    set axe.speed = SPEED
                    set axe.deflected = false
                    set axe.source = Spell.source.unit
                    set axe.owner = Spell.source.player
                    set axe.arc = GetArc(Spell.level)
                    set axe.curve = a*GetCurve(Spell.level)
                    set axe.collision = GetAoE(Spell.source.unit, Spell.level)
                    set axe.damage = GetDamage(Spell.source.unit, Spell.level)
                    set axe.slow = GetSlowAmount(Spell.level)
                    set axe.time = GetSlowDuration(Spell.level)
                    set axe.reduction = GetCooldownReduction(Spell.level)
                    set a = -a
                    
                    call axe.launch()
                set i = i - 1
            endloop
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary