library DragonDash requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities
    /* ---------------------- Dragon Dash v1.1 by Chopinski --------------------- */
    // Credits:
    //     Zipfinator    - Icon
    //     Bribe         - SpellEffectEvent
    //     AZ            - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY        = 'A002'
        // The Model
        private constant string  MODEL          = "DDash.mdl"
        // The model scale
        private constant real    SCALE          = 1
        // The dash speed
        private constant real    SPEED          = 2000
        // The dash effect offset
        private constant real    OFFSET         = 100
        // The secondary model
        private constant string  WIND_MODEL     = "WindBlow.mdl"
        // The secondary attach point
        private constant string  ATTACH_POINT   = "origin"
    endglobals

    // The Dash distance
    private function GetDistance takes integer level returns real
         return 600. + 50.*level
    endfunction

    // The Cooldown Reduction per unit dashed through
    private function GetCooldownReduction takes integer level returns real
         return 0.5*level
    endfunction

    // The Dash collision
    private function GetCollision takes integer level returns real
        return 64. + 0.*level
    endfunction

    // The Dash unit filter.
    private function UnitFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DragonDash extends Missiles
        real reduction
        real theta
        effect dash
        effect wind
        
        method onPeriod takes nothing returns boolean
            call BlzSetSpecialEffectPosition(dash, x + OFFSET*Cos(theta), y + OFFSET*Sin(theta), z)
            call BlzSetSpecialEffectYaw(dash, effect.yaw)
            call SetUnitX(source, x)
            call SetUnitY(source, y)
            call BlzSetUnitFacingEx(source, effect.yaw*bj_RADTODEG)
            
            return false
        endmethod
        
        method onHit takes unit u returns boolean
            local real cooldown
            
            if UnitFilter(owner, u) then
                set cooldown = BlzGetUnitAbilityCooldownRemaining(source, ABILITY)
                if reduction >= cooldown then
                    call ResetUnitAbilityCooldown(source, ABILITY)
                else
                    call StartUnitAbilityCooldown(source, ABILITY, cooldown - reduction)
                endif
            endif
            
            return false
        endmethod
        
        method onPause takes nothing returns boolean
            return true
        endmethod
        
        method onRemove takes nothing returns nothing
            call IssueImmediateOrder(source, "stop")
            call SetUnitAnimation(source, "Stand")
            call DestroyEffect(wind)
            call DestroyEffect(dash)
            
            set wind = null
            set dash = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local real point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetDistance(Spell.level)
            local thistype this
            
            if point < distance then
                set distance = point
            endif
            
            set this = thistype.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*Cos(angle), Spell.source.y + distance*Sin(angle), 0)
            set speed = SPEED
            set theta = angle
            set owner = Spell.source.player
            set source = Spell.source.unit
            set collision = GetCollision(Spell.level)
            set reduction = GetCooldownReduction(Spell.level)
            set dash = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET*Cos(angle), Spell.source.y + OFFSET*Sin(angle), 0, SCALE)
            set wind = AddSpecialEffectTarget(WIND_MODEL, source, ATTACH_POINT)
            
            call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            call SetUnitAnimation(source, "Spell Channel")
            call launch()
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary