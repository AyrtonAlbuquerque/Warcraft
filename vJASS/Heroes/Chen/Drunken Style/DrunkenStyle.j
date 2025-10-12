library DrunkenStyle requires Spell, Utilities, Missiles, MouseUtils, NewBonus, CrowdControl, Modules
    /* --------------------- Drunken Style v1.5 by Chopinski -------------------- */
    // Credits:
    //     Blizzard - Icon
    //     Vexorian - MouseUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Drunken Style Ability
        private constant integer ABILITY = 'Chn7'
        // The Drunken Style knockback model
        private constant string  MODEL   = "WindBlow.mdl"
        // The Drunken Style knockback attach point
        private constant string  ATTACH  = "origin"
    endglobals

    // The Drunken Style dash duration
    private function GetDuration takes integer level returns real
        return 0.25
    endfunction

    // The Drunken Style dash distance
    private function GetDistance takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Drunken Style dash type reset time
    private function GetResetTime takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Drunken Style knockback distance
    private function GetKnockDistance takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Drunken Style knockback duration
    private function GetKnockDuration takes integer level returns real
        return 0.25 + 0.*level
    endfunction

    // The Drunken Style collison per dash type
    private function GetCollision takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The Drunken Style dash cone at which damage can be applyed in degrees
    private function GetDamageCone takes integer dashType returns real
        if dashType == 1 then
            return 180.
        elseif dashType == 2 then
            return 360.
        elseif dashType == 3 then
            return 30.
        else
            return 180.
        endif
    endfunction

    // The Drunken Style dash damage
    private function GetDamage takes unit source, integer level returns real
        return 25. * level + (0.25 + 0.25*level) * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction

    // The Drunken Style Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Dash extends Missile
        real fov
        real face
        real centerX
        real centerY
        real distance
        real knockback

        private method onPeriod takes nothing returns boolean
            return not UnitAlive(source)
        endmethod

        private method onUnit takes unit hit returns boolean
            if IsUnitInCone(hit, centerX, centerY, collision, face, fov) then
                if DamageFilter(owner, hit) then
                    if UnitDamageTarget(source, hit, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH) then
                        call KnockbackUnit(hit, AngleBetweenCoordinates(x, y, GetUnitX(hit), GetUnitY(hit)), distance, knockback, MODEL, ATTACH, true, true, false, true)
                    endif
                endif
            endif

            return false
        endmethod

        private method onRemove takes nothing returns nothing
            call BlzUnitInterruptAttack(source)
            call SetUnitTimeScale(source, 1)
            call IssueImmediateOrder(source, "stop")
            call QueueUnitAnimation(source, "Stand Ready")
        endmethod
    endstruct
    
    private struct DrunkenStyle extends Spell
        private static integer array type

        private integer id

        method destroy takes nothing returns nothing
            set type[id] = 0
            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Chen|r performs a series of |cffffcc003|r attacks in sequence, |cffffcc00Swing|r, |cffffcc00Kick|r and |cffffcc00Swipe|r, dashing a short distance towards the cursor in each attack, dealing |cffff0000" + N2S(GetDamage(source, level), 0) + "|r |cffff0000Physical|r damage and knocking back enemy units in range. Every cast performs one attack of the sequence. The sequence resets after |cffffcc00" + N2S(GetResetTime(level), 1) + "|r seconds if left uncasted. If |cffffcc00Chen|r performs all attacks, |cffffcc00Drunken Style|r goes into cooldown. All attacks can hit |cffffcc00Critical Strikes|r and/or |cffffcc00Miss|r.\n\n|cffffcc00Swing|r  knocks back enemy units in a wide angle in front of |cffffcc00Chen|r.\n\n|cffffcc00Kick|r knocks back enemy units directly in front of |cffffcc00Chen|r.\n\n|cffffcc00Swipe|r knocks back enemy units all around |cffffcc00Chen|r."
        endmethod

        private method onCast takes nothing returns nothing
            local real distance = GetDistance(Spell.level)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player))
            local Dash dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * Cos(angle), Spell.source.y + distance * Sin(angle), 0)
            
            set this = GetTimerInstance(Spell.source.id)

            if this == 0 then
                set this = thistype.allocate()
                set id = Spell.source.id
            endif

            set type[id] = type[id] + 1

            if type[id] == 1 then
                call StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                call SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif type[id] == 2 then
                call StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                call SetUnitAnimationByIndex(Spell.source.unit, 23)
            else
                set type[id] = 0
                call SetUnitAnimationByIndex(Spell.source.unit, 17)
            endif

            set dash.model = MODEL
            set dash.type = type[id]
            set dash.face = angle * bj_RADTODEG
            set dash.source = Spell.source.unit
            set dash.unit = Spell.source.unit
            set dash.owner = Spell.source.player
            set dash.centerX = Spell.source.x
            set dash.centerY = Spell.source.y
            set dash.damage = GetDamage(Spell.source.unit, Spell.level)
            set dash.duration = GetDuration(Spell.level)
            set dash.collision = GetCollision(type[id])
            set dash.fov = GetDamageCone(type[id])
            set dash.distance = GetKnockDistance(Spell.level)
            set dash.knockback = GetKnockDuration(Spell.level)

            call dash.launch()
            call BlzUnitInterruptAttack(Spell.source.unit)
            call SetUnitTimeScale(Spell.source.unit, 1.75)
            call StartTimer(GetResetTime(Spell.level), false, this, id)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary