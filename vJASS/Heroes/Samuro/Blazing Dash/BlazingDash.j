library BlazingDash requires Spell, Missiles, Effect, Utilities, NewBonus
    /* --------------------- Blazing Dash v1.0 by Chopinski --------------------- */
    // Credits:
    //     Panda         - Icon
    //     AZ            - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        public constant integer  ABILITY    = 'Smr5'
        // The Model
        private constant string  MODEL      = "CriticalDash.mdl"
        // The model scale
        private constant real    SCALE      = 1
        // The dash speed
        private constant real    SPEED      = 5000
        // The dash effect offset
        private constant real    OFFSET     = 600
    endglobals

    // The Damage
    private function GetDamage takes unit source, integer level returns real
        return 375. * level + (1. * level * GetUnitBonus(source, BONUS_DAMAGE))
    endfunction

    // The Dash distance
    private function GetDistance takes unit source, integer level returns real
         return 800. + 200.*level
    endfunction

    // The Cooldown Reduction per unit dashed through
    private function GetCooldownReduction takes unit source, integer level returns real
         if IsUnitType(source, UNIT_TYPE_HERO) then
             return 0.2 + 0.*level
         else
             return 0.1 + 0.*level
         endif
    endfunction

    // The damage bonus
    private function GetBonusDamage takes unit source, integer level returns real
        return 25. * level
    endfunction

    // The crit chance bonus
    private function GetBonusCriticalChance takes unit source, integer level returns real
        return 0.1 * level
    endfunction

    // The crit damage bonus
    private function GetBonusCriticalDamage takes unit source, integer level returns real
        return 0.1 * level
    endfunction

    // The Bonus duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Dash AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Dash unit filter.
    private function UnitFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Dash extends Missile
        integer level
        real reduction
        real time
        
        private method onUnit takes unit u returns boolean
            if UnitFilter(owner, u) then
                set reduction = reduction + GetCooldownReduction(u, level)

                call UnitDamageTarget(source, u, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null)
            endif
            
            return false
        endmethod
        
        private method onPause takes nothing returns boolean
            return true
        endmethod
        
        private method onRemove takes nothing returns nothing
            local real cooldown = BlzGetUnitAbilityCooldownRemaining(source, ABILITY)
                
            if reduction >= 1 then
                call ResetUnitAbilityCooldown(source, ABILITY)
            else
                call StartUnitAbilityCooldown(source, ABILITY, cooldown - (cooldown * reduction))
            endif

            call IssueImmediateOrder(source, "stop")
            call SetUnitAnimation(source, "Stand Ready")
            call AddUnitBonusTimed(source, BONUS_DAMAGE, GetBonusDamage(source, level), time)
            call AddUnitBonusTimed(source, BONUS_CRITICAL_CHANCE, GetBonusCriticalChance(source, level), time)
            call AddUnitBonusTimed(source, BONUS_CRITICAL_DAMAGE, GetBonusCriticalDamage(source, level), time)
        endmethod
    endstruct

    private struct BlazingDash extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Samuro|r dashes up to |cffffcc00" + N2S(GetDistance(source, level), 0) + "|r range towards the targeted direction dealing |cffff0000" + N2S(GetDamage(source, level), 0) + " Physical|r damage to enemy units it comes in contact with and applies |cff8080ffOn Hit|r effects. Addtionally, after dashing |cffffcc00Samuro|r gains |cffff0000" + N2S(GetBonusDamage(source, level), 0) + " Damage|r, |cffffcc00" + N2S(GetBonusCriticalChance(source, level) * 100, 0) + "%|r |cffff0000Critical Chance|r and |cffffcc00" + N2S(GetBonusCriticalDamage(source, level) * 100, 0) + "%|r |cffff0000Critical Damage|r for |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds. For each enemy unit |cffffcc00Samuro|r pass trough, |cffffcc00Critical Dash|r cooldown is reduced by |cffffcc0010%|r (Doubled for Heroes)."
        endmethod
        
        private method onCast takes nothing returns nothing
            local real point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetDistance(Spell.source.unit, Spell.level)
            local Effect e = Effect.create(MODEL, Spell.source.x + OFFSET * Cos(angle), Spell.source.y + OFFSET * Sin(angle), 0, SCALE)
            local Dash dash
            
            if point < distance then
                set e.scale = SCALE * (point / distance)
                set e.x = Spell.source.x + OFFSET * (point / distance) * Cos(angle)
                set e.y = Spell.source.y + OFFSET * (point / distance) * Sin(angle)
                set distance = point
            endif
            
            set dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*Cos(angle), Spell.source.y + distance*Sin(angle), 0)
            set dash.speed = SPEED
            set dash.reduction = 0
            set dash.level = Spell.level
            set dash.owner = Spell.source.player
            set dash.unit = Spell.source.unit
            set dash.source = Spell.source.unit
            set dash.damage = GetDamage(Spell.source.unit, Spell.level)
            set dash.collision = GetAoE(Spell.source.unit, Spell.level)
            set dash.time = GetDuration(Spell.source.unit, Spell.level)
            set e.yaw = angle
            
            call dash.launch()
            call e.destroy()
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary