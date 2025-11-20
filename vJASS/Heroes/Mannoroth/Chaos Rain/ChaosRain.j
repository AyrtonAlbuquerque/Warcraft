library ChaosRain requires Missiles, Spell, Utilities, Modules, CrowdControl optional NewBonus
    /* --------------------- Chaos Rain v1.6 by Chopinski ---------------------- */
    // Credits:
    //     KILLCIED, Mr Goblin - icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Chaos Rain ability
        private constant integer ABILITY        = 'Mnr5'
        // The raw code of the Infernal unitu
        private constant integer INFERNAL       = 'umn1'
        // The raw code of the Infernal Fire ability
        private constant integer INFERNAL_FIRE  = 'MnrB'
        // The starting height of the missile
        private constant integer START_HEIGHT   = 1500
        // The starting offset of the missile
        private constant integer START_OFFSET   = 3000
        // The landing time of the falling missile
        private constant real LANDING_TIME      = 1
        //the missile model
        private constant string MISSILE_MODEL   = "Units\\Demon\\Infernal\\InfernalBirth.mdl"
        // The Missile scale
        private constant real MISSILE_SCALE     = 1
        // The stun model
        private constant string STUN_MODEL      = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attach point
        private constant string POINT           = "overhead"
    endglobals

    // The amount of damage dealt when the missile lands
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 250 * level + (0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250. * level
        endif
    endfunction

    // The amount of damage Infernal Fire deals per second
    private function GetInfernalFireDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50 * level + (0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        endif
    endfunction

    // The max range that a missile can spawn
    // By default it is the ability Area of Effect Field value
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The impact aoe
    private function GetDamageAoE takes unit source, integer level returns real
        return 200. + 0.*level
    endfunction

    // The amount of meteors spawned
    private function GetCount takes unit source, integer level returns integer
        return 10 + 20*level
    endfunction

    // The meteor spawn interval
    private function GetInterval takes unit source, integer level returns real
        return 0.15 - 0.*level
    endfunction

    // The stun duration
    private function GetStunDuration takes unit source, integer level returns real
        return 1. + 0.*level
    endfunction

    // The chance of a meteor to spawn a infernal
    private function GetChance takes unit source, integer level returns real
        return 0.05 + 0.05*level
    endfunction

    // The infernal duration
    private function GetInfernalDuration takes unit source, integer level returns real
        return 60. + 0.*level
    endfunction

    // The infernal damage
    private function GetInfernalDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50 * level + (0.1 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER) + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 50. * level
        endif
    endfunction

    // The infernal health
    private function GetInfernalHealth takes unit source, integer level returns real
        return 1000 * level + (0.4 + 0.2*level) * BlzGetUnitMaxHP(source)
    endfunction

    //The infernal Armor
    private function GetInfernalArmor takes unit source, integer level returns real
        return 5. * level + BlzGetUnitArmor(source)
    endfunction

    // The damage filter
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Meteor extends Missile
        real stun
        integer level

        private method onDestructable takes destructable d returns boolean
            call KillDestructable(d)

            return false
        endmethod

        private method onFinish takes nothing returns boolean
            local unit u
            local group g = CreateGroup()

            if GetRandomReal(0, 1) <= GetChance(source, level) then
                set u = CreateUnit(owner, INFERNAL, x, y, 0)

                call SetUnitAnimation(u, "Birth")
                call QueueUnitAnimation(u, "Stand")
                call BlzSetUnitBaseDamage(u, R2I(GetInfernalDamage(source, level)), 0)
                call BlzSetUnitMaxHP(u, R2I(GetInfernalHealth(source, level)))
                call BlzSetUnitArmor(u, GetInfernalArmor(source, level))
                call SetUnitLifePercentBJ(u, 100)
                call BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, INFERNAL_FIRE), ABILITY_RLF_DAMAGE_PER_INTERVAL, 0, GetInfernalFireDamage(source, level))
                call BlzUnitDisableAbility(u, INFERNAL_FIRE, true, true)
                call BlzUnitDisableAbility(u, INFERNAL_FIRE, false, false)

                if GetInfernalDuration(source, level) > 0 then
                    call UnitApplyTimedLife(u, 'BTLF', GetInfernalDuration(source, level))
                endif
            endif

            call GroupEnumUnitsInRange(g, x, y, collision, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            call StunUnit(u, stun, STUN_MODEL, POINT, false)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct ChaosRain extends Spell
        private real x
        private real y
        private unit unit
        private real angle
        private real range
        private real count
        private integer level

        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Mannoroth|r conjures a |cffffcc00Chaos Rain|r from the skies. Each meteor deals |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage and stuns enemy units within |cffffcc00" + N2S(GetDamageAoE(source, level), 0) + " AoE|r for |cffffcc00" + N2S(GetStunDuration(source, level), 1) + "|r second. Additionally, each meteor has a |cffffcc00" + N2S(GetChance(source, level)*100, 0) + "%|r chance to spawn an |cffffcc00Infernal|r. The |cffffcc00Infernal|r has |cffff0000" + N2S(GetInfernalDamage(source, level), 0) + " Damage|r, |cff00ff00" + N2S(GetInfernalHealth(source, level), 0) + " Health|r and |cffc0c0c0" + N2S(GetInfernalArmor(source, level), 0) + " Armor|r. Lasts for |cffffcc00" + N2S(GetInfernalDuration(source, level), 1) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real theta
            local real radius                                              
            local Meteor meteor

            set count = count - 1
            set theta = 2*bj_PI*GetRandomReal(0, 1)
            set radius = GetRandomRange(range)
            set x = .x + radius*Cos(theta)
            set y = .y + radius*Sin(theta)
            set meteor = Meteor.create(x + START_OFFSET*Cos(angle), y + START_OFFSET*Sin(angle), START_HEIGHT, x, y, 0)
            set meteor.source = unit
            set meteor.level = level
            set meteor.model = MISSILE_MODEL
            set meteor.scale = MISSILE_SCALE
            set meteor.duration = LANDING_TIME
            set meteor.collideZ = true
            set meteor.owner = GetOwningPlayer(unit)
            set meteor.stun = GetStunDuration(unit, level)
            set meteor.damage = GetDamage(unit, level)
            set meteor.collision = GetDamageAoE(unit, level)

            call meteor.launch()
            
            return count > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set angle = AngleBetweenCoordinates(Spell.x, Spell.y, Spell.source.x, Spell.source.y)
            set range = GetAoE(Spell.source.unit, Spell.level)
            set count = GetCount(Spell.source.unit, Spell.level)

            call StartTimer(GetInterval(Spell.source.unit, Spell.level), true, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary
