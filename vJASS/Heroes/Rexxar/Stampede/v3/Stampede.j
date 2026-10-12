library Stampede requires Spell, Missiles, Utilities, Modules, Slow, RegisterPlayerUnitEvent optional NewBonus optional CooldownReduction
    /* ----------------------- Stampede v1.0 by Chopinski ----------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY                 = 'Rex5'
        // The missile model
        private constant string  MODEL                   = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
        // The missile scale
        private constant real    SCALE                   = 1.5
        // The missile speed
        private constant real    SPEED                   = 800
        // The slow model
        private constant string  SLOW_MODEL              = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        // The slow model attach point
        private constant string  SLOW_ATTACH             = "origin"
        // The slow damage model
        private constant string  DAMAGE_MODEL            = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        // The slow damage model attach point
        private constant string  DAMAGE_ATTACH           = "origin"
        // The time the player has to move the mouse before the spell starts
        private constant real    DRAG_AND_DROP_TIME      = 3.
        // Skill indicator model
        private constant string     INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
        // Indicator scaling
        private constant real       INDICATOR_SCALE      = 4
        // Indicator time scaling
        private constant real       INDICATOR_TIME_SCALE = 1.5
    endglobals

    // The amount of damage dealt when the lizard hits an enemy
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 750. * level + (0.3 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + ((1 + 0.25 * level) * GetUnitBonus(source, BONUS_DAMAGE))
        else
            return 750. * level
        endif
    endfunction

    // The slow amount
    private function GetSlow takes unit source, integer level returns real
        return 0.1 + 0.1 * level
    endfunction

    // The slow duration
    private function GetSlowDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The ability aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The lizard total distance
    private function GetRange takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction

    // The stack cooldown
    private function GetCooldown takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    endfunction

    // The lizard count (purely cosmetic)
    private function GetLizardCount takes unit source, integer level returns integer
        return 2 + 0 * level
    endfunction

    // The unit filter
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Lizard extends Missile
        real slow
        real slowDuration

        private method onUnit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SlowUnit(source, u, slow, slowDuration, SLOW_MODEL, SLOW_ATTACH, false)
                    call DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, u, DAMAGE_ATTACH))
                endif
            endif

            return false
        endmethod
    endstruct

    private struct Stampede extends Spell
        private static integer array charges
        private static thistype array struct

        private real x
        private real y
        private unit unit
        private integer id
        private real angle
        private integer type
        private boolean done
        private real timeout
        private effect effect
        private player player
        private integer level
        private boolean casting

        method destroy takes nothing returns nothing
            if type == 1 then
                if casting then
                    call DestroyEffectTimed(effect, 2)
                else
                    call DestroyEffect(effect)
                endif

                set struct[id] = 0
            endif

            set unit = null
            set effect = null
            set player = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r calls forth rampaging lizards to trample all enemy units in its path. The lizards will do |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage and slow any enemy unit in comes in contact with by |cffffcc00" + N2S(GetSlow(source, level) * 100, 0) + "%|r for |cffffcc00" + N2S(GetSlowDuration(source, level), 1) + "|r seconds. Stampede gains |cffffcc001|r stack every |cffffcc00" + N2S(GetCooldown(source, level), 0) + "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction.\n\nCharges: |cffffcc00" + I2S(charges[GetUnitUserData(source)]) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer flip = 1
            local integer row = 1
            local integer col = 1
            local integer i = 0
            local real range
            local boolean down
            local integer count
            local Lizard lizard

            if type == 0 then
                if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                    if charges[id] >= 0 then
                        set charges[id] = charges[id] + 1

                        call BlzEndUnitAbilityCooldown(unit, ABILITY)
                    endif
                else
                    set charges[id] = 0
                endif

                return GetUnitAbilityLevel(unit, ABILITY) > 0
            else
                set down = IsPlayerMouseButtonDown(player, MOUSE_BUTTON_TYPE_LEFT)

                if down then
                    set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                endif

                if not casting then
                    if down and not done then
                        call BlzSetSpecialEffectYaw(effect, angle)
                    elseif not down then
                        set done = true
                    endif

                    return true
                endif

                set timeout = timeout - 0.03

                if not down or timeout <= 0 then
                    set range = GetRange(unit, level)
                    set count = GetLizardCount(unit, level)
                    set lizard = Lizard.create(x, y, 0, x + range * Cos(angle), y + range * Sin(angle), 0)
                    set lizard.source = unit
                    set lizard.owner = player
                    set lizard.model = MODEL
                    set lizard.scale = SCALE
                    set lizard.speed = SPEED
                    set lizard.collision = GetAoE(unit, level)
                    set lizard.damage = GetDamage(unit, level)
                    set lizard.slow = GetSlow(unit, level)
                    set lizard.slowDuration = GetSlowDuration(unit, level)

                    if count > 0 then
                        loop
                            exitwhen i == count
                                call lizard.attach(MODEL, row * -150, col * flip * 150, 0, SCALE)

                                set flip = flip * -1

                                if i > 0 and ModuloInteger(i, 2) == 0 then
                                    set row = row + 1
                                    set col = col + 1
                                endif
                            set i = i + 1
                        endloop
                    endif

                    call lizard.launch()
                endif

                call BlzSetSpecialEffectYaw(effect, angle)

                return timeout > 0 and down
            endif
        endmethod

        private method onCast takes nothing returns nothing
            if struct[Spell.source.id] != 0 then
                set this = struct[Spell.source.id]

                if x != Spell.x or y != Spell.y then
                    call BlzSetSpecialEffectX(effect, Spell.x)
                    call BlzSetSpecialEffectY(effect, Spell.y)
                    call BlzSetSpecialEffectYaw(effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(player), GetPlayerMouseY(player)))
                endif

                set x = Spell.x
                set y = Spell.y
                set casting = true
                set level = Spell.level
                set timeout = DRAG_AND_DROP_TIME
            else
                set this = thistype.allocate()
                set type = 1
                set x = Spell.x
                set y = Spell.y
                set casting = true
                set level = Spell.level
                set id = Spell.source.id
                set unit = Spell.source.unit
                set player = Spell.source.player
                set timeout = DRAG_AND_DROP_TIME
                set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))

                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)

                call StartTimer(0.03, true, this, 0)
            endif

            if charges[Spell.source.id] > 0 then
                set charges[Spell.source.id] = charges[Spell.source.id] - 1

                if charges[Spell.source.id] > 0 then
                    call ResetUnitAbilityCooldown(Spell.source.unit, ABILITY)
                else
                    static if LIBRARY_CooldownReduction then
                        call CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, GetRemainingTime(GetTimerInstance(Spell.source.id)))
                    else
                        set Spell.cooldown = GetRemainingTime(GetTimerInstance(Spell.source.id))
                    endif
                endif
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id = GetUnitUserData(source)
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local thistype this = struct[id]
            local real range
            local string base
            local string order
            local real distance
            local ability skill
            
            if level > 0 then
                set skill = BlzGetUnitAbility(source, ABILITY)
                set order = OrderId2String(GetIssuedOrderId())
                set base = BlzGetAbilityStringLevelField(skill, ABILITY_SLF_BASE_ORDER_ID_NCL6, level - 1)
                set range = BlzGetAbilityRealLevelField(skill, ABILITY_RLF_CAST_RANGE, level - 1)
                set distance = DistanceBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetUnitX(source), GetUnitY(source))

                if order != base and this != 0 then
                    call destroy()
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if this != 0 then
                        call destroy()
                    endif

                    set this = thistype.allocate()
                    set type = 1
                    set done = false
                    set x = GetOrderPointX()
                    set y = GetOrderPointY()
                    set this.id = id
                    set casting = false
                    set this.level = level
                    set unit = source
                    set player = GetOwningPlayer(source)
                    set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                    set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                    set struct[id] = this

                    call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)
                    call BlzSetSpecialEffectYaw(effect, angle)

                    call StartTimer(0.03, true, this, 0)
                endif
            endif

            set source = null
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)

            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set this.id = id
                set this.type = 0
                set this.unit = source
                set charges[id] = 1
                
                call StartTimer(GetCooldown(source, level), true, this, id)
            else
                set this = GetTimerInstance(id)
                
                if this != 0 then
                    set charges[id] = charges[id] + 1
                    
                    call SetTimerPeriod(this, GetCooldown(source, level))
                    call BlzEndUnitAbilityCooldown(source, skill)
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary
