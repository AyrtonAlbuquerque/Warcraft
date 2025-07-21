library WaterShield requires RegisterPlayerUnitEvent, Spell, DamageInterface, Missiles, Utilities, Periodic optional NewBonus
    /* --------------------- Water Shield v1.2 by Chopinski --------------------- */
    // Credits:
    //     Darkfang        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY                = 'A002'
        // The shield model
        private constant string  MODEL                  = "WaterShield.mdl"
        // The shield attachement point
        private constant string  ATTACH                 = "origin"
        // The explosion model
        private constant string  EXPLOSION_MODEL        = "LivingTide.mdl"
        // The scale of the explosion model
        private constant real    EXPLOSION_SCALE        = 0.6
        // The water bolt model
        private constant string  BOLT_MODEL             = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
        // The water bolt scal
        private constant real    BOLT_SCALE             = 1.
        // The water bolt speed
        private constant real    BOLT_SPEED             = 1000.
    endglobals

    // The shield amount
    private function GetAmount takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 100.*level + (0.5 + 0.5*level) * GetHeroInt(source, true) + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100.*level + (0.5 + 0.5*level) * GetHeroInt(source, true)
        endif
    endfunction

    // The water bolt damage
    private function GetBoltDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. + 25.*level + 0.15 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25. + 25.*level
        endif
    endfunction

    // The range at which units can be selected by water bolt
    private function GetAoE takes unit source, integer level returns real
        return 400. + 0.*level
    endfunction

    // The aoe of the explosion when there is a remaining shield amount
    private function GetExplosionAoE takes unit source, integer level returns real
        return 400. + 0.*level
    endfunction

    // The angle in degrees at which units can be selected
    private function GetAngle takes unit source, integer level returns real
        return 90. + 0.*level
    endfunction

    // The Shield duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The unit filter
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WaterBolt extends Missiles
        method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif

            return true
        endmethod
    endstruct
    
    private struct WaterShield extends Spell
        private static effect array effect
        private static thistype array defense
        private static thistype array offense

        private real aoe
        private real angle
        private real amount
        private integer id
        private unit source
        private unit target
        private group group
        private player player
        private integer level
        private boolean defensive

        method destroy takes nothing returns nothing
            if defensive then
                set defense[id] = 0

                if offense[id] == 0 then
                    call DestroyEffect(effect[id])
                    set effect[id] = null
                endif
            else
                set offense[id] = 0

                if defense[id] == 0  then   
                    call DestroyEffect(effect[id])
                    set effect[id] = null
                endif
            endif

            call DestroyGroup(group)
            call deallocate()

            set group = null
            set source = null
            set target = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Jaina|r can cast |cffffcc00Water Shield|r in an ally or enemy unit. When targeting an ally, the |cffffcc00Water Shield|r blocks |cff00ffff" + N2S(GetAmount(source, level), 0) + "|r damage and if the shield last it's whole duration it will explode, dealing the remaining shield amount as |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" + N2S(GetExplosionAoE(source, level), 0) + " AoE|r. When targeting an enemy unit, all attacks to the targeted unit will splash water bolts to enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r in a |cffffcc00" + N2S(GetAngle(source, level), 0) + "|r degrees angle behind the target unit from the direction of the attack, dealing |cff00ffff" + N2S(GetBoltDamage(source, level), 0) + "|r |cff00ffffMagic|r damage.\n\nLasts for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u

            if defensive and amount > 0 then
                call GroupEnumUnitsInRange(group, GetUnitX(target), GetUnitY(target), aoe, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) then
                            call UnitDamageTarget(source, u, amount, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                call DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, GetUnitX(target), GetUnitY(target), 0, EXPLOSION_SCALE))
            endif
        endmethod

        private method onCast takes nothing returns nothing
            if effect[Spell.target.id] == null then
                set effect[Spell.target.id] = AddSpecialEffectTarget(MODEL, Spell.target.unit, ATTACH)
            endif

            if Spell.isEnemy then
                if offense[Spell.target.id] != 0 then
                    set this = offense[Spell.target.id]
                else
                    set this = thistype.allocate()
                    set id = Spell.target.id
                    set target = Spell.target.unit
                    set group = CreateGroup()
                    set defensive = false
                    set offense[id] = this
                endif

                set source = Spell.source.unit
                set player = Spell.source.player
                set level = Spell.level
                set amount = GetBoltDamage(source, level)
                set angle = GetAngle(source, level)
                set aoe = GetAoE(source, level)
            else
                if defense[Spell.target.id] != 0 then
                    set this = defense[Spell.target.id]
                else
                    set this = thistype.allocate()
                    set id = Spell.target.id
                    set target = Spell.target.unit
                    set group = CreateGroup()
                    set defensive = true
                    set amount = 0
                    set defense[id] = this
                endif

                set source = Spell.source.unit
                set player = Spell.source.player
                set level = Spell.level
                set amount = amount + GetAmount(source, level)
                set aoe = GetExplosionAoE(source, level)
            endif

            call StartTimer(GetDuration(source, level), false, this, -1)
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = defense[Damage.target.id]

            if Damage.amount > 0 and this != 0 then
                if Damage.amount <= amount then
                    set amount = amount - Damage.amount
                    set Damage.amount = 0
                else
                    set Damage.amount = Damage.amount - amount
                    set amount = 0

                    call destroy()
                endif
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit u
            local WaterBolt bolt
            local thistype this = offense[Damage.target.id]

            if Damage.isEnemy and this != 0 then
                call GroupEnumUnitsInRange(group, Damage.target.x, Damage.target.y, aoe, null)
                call GroupRemoveUnit(group, Damage.target.unit)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) and IsUnitInCone(u, Damage.target.x, Damage.target.y, aoe, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y)*bj_RADTODEG, angle) then
                            set bolt = WaterBolt.create(Damage.target.x, Damage.target.y, 50, GetUnitX(u), GetUnitY(u), 50)
                            
                            set bolt.target = u
                            set bolt.source = source
                            set bolt.model = BOLT_MODEL
                            set bolt.speed = BOLT_SPEED
                            set bolt.scale = BOLT_SCALE
                            set bolt.damage = amount

                            call bolt.launch()
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local integer id = GetUnitUserData(GetTriggerUnit())
            local thistype this

            if defense[id] != 0 then
                set this = defense[id]
                call destroy()
            endif

            if offense[id] != 0 then
                set this = offense[id]
                call destroy()
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttack)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary