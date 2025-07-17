library NimbleDash requires Ability, Missiles, Utilities, CrowdControl, NewBonus, optional Metamorphosis, optional CooldownReduction
    /* ---------------------- Nimble Dash v1.0 by Chopinski --------------------- */
    // Credits:
    //     Blizzard - Icon
    //     AZ      - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        public constant integer  ABILITY = 'A005'
        // The Model
        private constant string  MODEL   = "Windwalk Necro Soul.mdl"
        // The dash speed
        private constant real    SPEED   = 1500
        // The slash Model
        private constant string  SLASH   = "Ephemeral Cut Jade.mdl"
        // The fear model
        private constant string  FEAR_MODEL  = "Fear.mdl"
        // The the fear attachment point
        private constant string  ATTACH_FEAR = "overhead"
    endglobals

    // The dash damage
    private function GetDamage takes unit source, integer level returns real
        return 50 + 50*level + (1.1 + 0.1*level)*GetHeroAgi(source, true)
    endfunction

    // The maximum Dash distance
    private function GetDistance takes unit source, integer level returns real
        static if LIBRARY_Metamorphosis then
            if GetUnitAbilityLevel(source, Metamorphosis_BUFF) > 0 then
                return 2 * (300. + 50.*level)
            else
                return 300. + 50.*level
            endif
        else
            return 300. + 50.*level
        endif
    endfunction

    // The passive Evasion bonus per level
    private function GetPassiveBonus takes integer level returns real
        return 0.05
    endfunction

    // The active Evasion bonus per level
    private function GetActiveBonus takes integer level returns real
        return 0.025*level
    endfunction

    // The evasion active bonus duration
    private function GetDuration takes unit source, integer level returns real
         return 15. + 0.*level
    endfunction

    // The Dash charges
    private function GetCharges takes unit source, integer level returns integer
        return 3
    endfunction

    // The Dash charge cooldown
    private function GetCooldown takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    endfunction

    // The evasion active bonus duration
    private function GetFearDuration takes unit source, integer level returns real
         return 0.5 + 0.*level
    endfunction

    // The Dash collision
    private function GetCollision takes integer level returns real
        return 150. + 0.*level
    endfunction

    // The Dash unit filter.
    private function UnitFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Dash extends Missiles
        real fear
        effect sfx

        private method onPeriod takes nothing returns boolean
            call SetUnitX(source, x)
            call SetUnitY(source, y)
            call BlzSetUnitFacingEx(source, effect.yaw*bj_RADTODEG)
            
            return false
        endmethod
        
        private method onHit takes unit u returns boolean
            static if LIBRARY_Metamorphosis then
                if IsUnitEnemy(u, owner) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null) then
                        call DestroyEffect(AddSpecialEffectTarget(SLASH, u, "chest"))
                        
                        if GetUnitAbilityLevel(source, Metamorphosis_BUFF) > 0 then
                            call FearUnit(u, fear, FEAR_MODEL, ATTACH_FEAR, true)
                        endif
                    endif
                endif
            else
                if IsUnitEnemy(u, owner) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null) then
                        call DestroyEffect(AddSpecialEffectTarget(SLASH, u, "chest"))
                    endif
                endif
            endif
            
            return false
        endmethod
        
        private method onPause takes nothing returns boolean
            return true
        endmethod
        
        private method onRemove takes nothing returns nothing
            call DestroyEffect(sfx)
            call SetUnitTimeScale(source, 1)

            set sfx = null
        endmethod
    endstruct

    private struct NimbleDash extends Ability
        private static integer array charges

        private unit unit
        private integer id

        method destroy takes nothing returns nothing
            set unit = null
            set charges[id] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Illidan|r dashes up to |cffffcc00" + N2S(GetDistance(source, level), 0) + "|r range towards the targeted direction, gaining |cffffcc00" + N2S(GetActiveBonus(level)*100, 1) + "%|r |cffff00ffEvasion|r for |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds and dealing |cffff0000" + N2S(GetDamage(source, level), 0) + " Physical|r damage when passing through enemy units. |cffffcc00Nimble Dash|r can stack up to |cffffcc00" + N2S(GetCharges(source, level), 0) + "|r charges. When in |cffffcc00Metamorphosis|r, the dash range is doubled |cffffcc00Fears|r enemy units for |cffffcc00" + N2S(GetFearDuration(source, level), 2) + "|r seconds. Additionally |cffffcc00Illidan|r has |cffffcc00" + N2S(GetPassiveBonus(level)*100*level, 0) + "%|r passively increased chance to avoid enemy attacks.\n\nCharges: " + N2S(charges[GetUnitUserData(source)], 0)
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(unit, ABILITY)

            if charges[id] < GetCharges(unit, level) and charges[id] >= 0 then
                set charges[id] = charges[id] + 1

                call BlzEndUnitAbilityCooldown(unit, ABILITY)
            endif

            return level > 0
        endmethod
        
        private method onCast takes nothing returns nothing
            local real point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetDistance(Spell.source.unit, Spell.level)
            local Dash dash

            if point < distance then
                set distance = point
            endif
            
            set dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*Cos(angle), Spell.source.y + distance*Sin(angle), 0)
            set dash.speed = SPEED
            set dash.owner = Spell.source.player
            set dash.source = Spell.source.unit
            set dash.damage = GetDamage(Spell.source.unit, Spell.level)
            set dash.collision = GetCollision(Spell.level)
            set dash.fear = GetFearDuration(Spell.source.unit, Spell.level)
            set dash.sfx = AddSpecialEffectTarget(MODEL, Spell.source.unit, "chest")

            if charges[Spell.source.id] > 0 then
                set charges[Spell.source.id] = charges[Spell.source.id] - 1

                if charges[Spell.source.id] >= 1 then
                    call ResetUnitAbilityCooldown(Spell.source.unit, ABILITY)
                else
                    static if LIBRARY_CooldownReduction then
                        call CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, GetRemainingTime(GetTimerInstance(Spell.source.id)))
                    else
                        call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, GetRemainingTime(GetTimerInstance(Spell.source.id)))
                        call IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                        call DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                    endif
                endif
            endif
            
            call SetUnitTimeScale(Spell.source.unit, 2)
            call AddUnitBonusTimed(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), GetDuration(Spell.source.unit, Spell.level))
            call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            call dash.launch()
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)

            call AddUnitBonus(source, BONUS_EVASION_CHANCE, GetPassiveBonus(level))

            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set this.id = id
                set this.unit = source
                set charges[id] = GetCharges(source, level)

                call StartTimer(GetCooldown(source, level), true, this, id)
            else
                call SetTimerPeriod(GetTimerInstance(id), GetCooldown(source, level))
            endif
        endmethod

        implement Periodic
        
        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary