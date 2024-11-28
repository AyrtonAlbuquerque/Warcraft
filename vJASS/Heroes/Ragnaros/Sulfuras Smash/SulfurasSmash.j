library SulfurasSmash requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Missiles, TimedHandles, Utilities, CrowdControl optional Sulfuras, optional Afterburner
    /* -------------------- Sulfuras Smash v1.6 by Chopinski -------------------- */
    // Credtis:
    //     Systemfre1       - Sulfuras model
    //     AZ               - crack model
    //     Blizzard         - icon (edited by me)
    //     Magtheridon96    - RegisterPlayerUnitEvent 
    //     Bribe            - SpellEffectEvent, UnitIndexer
    //     TriggerHappy     - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Sulfuras Smash ability
        private constant integer    ABILITY             = 'A005'
        // The landing time of the falling sulfuras
        private constant real       LANDING_TIME        = 1.25
        // The distance from the casting point from 
        // where the sulfuras spawns
        private constant real       LAUNCH_OFFSET       = 4500
        // The starting height of sufuras
        private constant real       START_HEIGHT        = 3000
        // Sufuras Model
        private constant string     SULFURAS_MODEL      = "Sulfuras.mdl"
        // Sulfuras Impact effect model
        private constant string     IMPACT_MODEL        = "Smash.mdl"
        // The stun model
        private constant string     STUN_MODEL          = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // the stun model attachment point
        private constant string     STUN_POINT          = "overhead"
        // Sufuras size
        private constant real       SULFURAS_SCALE      = 3.
        // Size of the impact model
        private constant real       IMPACT_SCALE        = 2.
        // How long will the impact model lasts
        private constant real       IMPACT_DURATION     = 10.
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
    endglobals

    // The stun time for units at the center of impact
    private function GetStunTime takes unit u returns real
        static if LIBRARY_Sulfuras then
            return 1 + 0.25*R2I(Sulfuras.stacks[GetUnitUserData(u)]*0.01)
        else
            return 1.5
        endif
    endfunction
    
    // The AoE for damage, by default is the AoE editor field of the ability
    private function GetNormalAoE takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The AoE for enemies in the center of impact that will be stunned and take doubled damage
    private function GetCenterAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // Ability impact damage
    private function GetDamage takes integer level returns real
        return 250.*level
    endfunction

    // Filter for units that will be damage on impact
    private function DamageFilter takes unit source, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, GetOwningPlayer(source)) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Hammer extends Missiles
        real stun
        real aoe
        integer level

        method onFinish takes nothing returns boolean
            local group g = CreateGroup()    
            local integer i = 0
            local integer j
            local unit v

            call GroupEnumUnitsInRange(g, x, y, GetNormalAoE(source, level), null)
            set j = BlzGroupGetSize(g)
            loop
                exitwhen i == j
                    set v = BlzGroupUnitAt(g, i)
                    if DamageFilter(source, v) then
                        if DistanceBetweenCoordinates(x, y, GetUnitX(v), GetUnitY(v)) <= aoe then
                            if UnitDamageTarget(source, v, 2*damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                                call StunUnit(v, stun, STUN_MODEL, STUN_POINT, false)
                            endif
                        else
                            call UnitDamageTarget(source, v, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                        endif
                    endif
                set i = i + 1
            endloop
            call DestroyEffectTimed(AddSpecialEffectEx(IMPACT_MODEL, x, y, 0, IMPACT_SCALE), IMPACT_DURATION)
            call DestroyGroup(g)
            
            static if LIBRARY_Afterburner then
                call Afterburn(x, y, source)
            endif

            set g   = null
            set v   = null

            return true
        endmethod
    endstruct

    private struct SulfurasSmash extends array
        private static method onCast takes nothing returns nothing
            local real a = AngleBetweenCoordinates(Spell.x, Spell.y, GetUnitX(Spell.source.unit), GetUnitY(Spell.source.unit))
            local Hammer sulfuras = Hammer.create(Spell.x + LAUNCH_OFFSET*Cos(a), Spell.y + LAUNCH_OFFSET*Sin(a), START_HEIGHT, Spell.x, Spell.y, 0)
            
            set sulfuras.model = SULFURAS_MODEL
            set sulfuras.scale = SULFURAS_SCALE
            set sulfuras.duration = LANDING_TIME
            set sulfuras.source = Spell.source.unit
            set sulfuras.level = Spell.level
            set sulfuras.damage = GetDamage(Spell.level)
            set sulfuras.owner = Spell.source.player
            set sulfuras.stun = GetStunTime(Spell.source.unit)
            set sulfuras.aoe = GetCenterAoE(Spell.level)

            call sulfuras.launch()
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary