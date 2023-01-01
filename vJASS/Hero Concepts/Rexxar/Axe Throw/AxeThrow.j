library AxeThrow requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, CrowdControl
    /* ----------------------- Axe Throw v1.1 by Chopinski ---------------------- */
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
        return 50. + 50.*level
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
    
        method onHit takes unit u returns boolean
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
        
        method onFinish takes nothing returns boolean
            if not deflected then
                set deflected = true
                call deflectTarget(source)
            endif
            
            return false
        endmethod
    
        private static method onCast takes nothing returns nothing
            local thistype this
            local integer i = GetAxeCount(Spell.level)
            local integer a = 1
            
            loop
                exitwhen i == 0
                    set this = thistype.create(Spell.source.x, Spell.source.y, 100, Spell.x, Spell.y, 100)
                    set model = MODEL
                    set scale = SCALE
                    set speed = SPEED
                    set deflected = false
                    set source = Spell.source.unit
                    set owner = Spell.source.player
                    set arc = GetArc(Spell.level)
                    set curve = a*GetCurve(Spell.level)
                    set collision = GetAoE(Spell.source.unit, Spell.level)
                    set damage = GetDamage(Spell.source.unit, Spell.level)
                    set slow = GetSlowAmount(Spell.level)
                    set time = GetSlowDuration(Spell.level)
                    set reduction = GetCooldownReduction(Spell.level)
                    set a = -a
                    
                    call launch()
                set i = i - 1
            endloop
        endmethod
    
        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary