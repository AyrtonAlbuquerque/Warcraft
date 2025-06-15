library DragonDash requires Ability, Missiles, Utilities
    /* ---------------------- Dragon Dash v1.2 by Chopinski --------------------- */
    // Credits:
    //     Zipfinator    - Icon
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
    private struct Dash extends Missiles
        real theta
        effect dash
        effect wind
        real reduction
        
        private method onPeriod takes nothing returns boolean
            call BlzSetSpecialEffectPosition(dash, x + OFFSET*Cos(theta), y + OFFSET*Sin(theta), z)
            call BlzSetSpecialEffectYaw(dash, effect.yaw)
            call SetUnitX(source, x)
            call SetUnitY(source, y)
            call BlzSetUnitFacingEx(source, effect.yaw*bj_RADTODEG)
            
            return false
        endmethod
        
        private method onHit takes unit u returns boolean
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
        
        private method onPause takes nothing returns boolean
            return true
        endmethod
        
        private method onRemove takes nothing returns nothing
            call IssueImmediateOrder(source, "stop")
            call SetUnitAnimation(source, "Stand")
            call DestroyEffect(wind)
            call DestroyEffect(dash)
            
            set wind = null
            set dash = null
        endmethod
    endstruct

    private struct DragonDash extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r dashes up to |cffffcc00" + N2S(GetDistance(level), 0) + "|r range towards the targeted direction and with no collision. For each enemy unit |cffffcc00Yu'lon|r pass trough, |cffffcc00Dragon Dash|r cooldown is reduced by |cffffcc00" + N2S(GetCooldownReduction(level), 1) + "|r second."
        endmethod
        
        private method onCast takes nothing returns nothing
            local real point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetDistance(Spell.level)
            local Dash dash
            
            if point < distance then
                set distance = point
            endif
            
            set dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*Cos(angle), Spell.source.y + distance*Sin(angle), 0)
            set dash.speed = SPEED
            set dash.theta = angle
            set dash.owner = Spell.source.player
            set dash.source = Spell.source.unit
            set dash.collision = GetCollision(Spell.level)
            set dash.reduction = GetCooldownReduction(Spell.level)
            set dash.dash = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET*Cos(angle), Spell.source.y + OFFSET*Sin(angle), 0, SCALE)
            set dash.wind = AddSpecialEffectTarget(WIND_MODEL, dash.source, ATTACH_POINT)
            
            call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            call SetUnitAnimation(dash.source, "Spell Channel")
            call dash.launch()
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary