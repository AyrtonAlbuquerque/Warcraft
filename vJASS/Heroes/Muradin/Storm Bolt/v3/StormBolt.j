library StormBolt requires Spell, Missiles, Indexer, Utilities, CrowdControl, Modules optional NewBonus
    /* --------------------------------------- Storm Bolt v1.6 -------------------------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Storm Bolt ability
        public  constant integer    ABILITY             = 'Mrd1'
        // The missile model
        private constant string     MISSILE_MODEL       = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
        // The missile size 
        private constant real       MISSILE_SCALE       = 1.15
        // The missile speed
        private constant real       MISSILE_SPEED       = 1250.
        // The model used when storm bolt deal bonus damage
        private constant string     DAMAGE_MODEL        = "ShockHD.mdl"
        // The attachment point of the bonus damage model
        private constant string     ATTACH_POINT        = "origin"
        // The extra eye candy model
        private constant string     EXTRA_MODEL         = "StormShock.mdl"
        // The model used when storm bolt slows a unit
        private constant string     SLOW_MODEL          = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
        // The attachment point of the slow model
        private constant string     SLOW_POINT          = "origin"
        // the hammer ground model
        private constant string     GROUND_MODEL        = "StaticShock.mdl"
        // the hammer ground model scale
        private constant real       GROUND_SCALE        = 1.0
        // The lightning effect model
        private constant string     LIGHTNING_MODEL     = "LightningShock.mdl"
        // The lightning effect scale
        private constant real       LIGHTNING_SCALE     = 1.0
    endglobals

    // The storm bolt damage
    public function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 100. + 100.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100. + 100.*level
        endif
    endfunction

    // The hammer duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    endfunction

    // The storm bolt AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // Hammer Pickup range
    private function GetPickupRange takes unit source, integer level returns real
        return 150. + 0.*level
    endfunction

    private function GetCooldownReduction takes unit source, integer level returns real
        return 0.5 + 0.1 * level
    endfunction

    // The storm bolt minimum travel distance
    private function GetMinimumDistance takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The storm bolt slow amount
    private function GetSlow takes integer level returns real
        return 0.1 + 0.1*level
    endfunction

    // The storm bolt slow duration
    private function GetSlowDuration takes integer level returns real
        return 2. + 0.*level
    endfunction

    // The Damage Filter units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Hammer extends Missile
        real slow
        integer level
        real slowDuration
        Effect attachment

        private method onUnit takes unit u returns boolean
            if DamageFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SlowUnit(u, slow, slowDuration, SLOW_MODEL, SLOW_POINT, false)
                    call DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, u, ATTACH_POINT))
                endif
            endif
            
            return false
        endmethod

        private method onFinish takes nothing returns boolean
            call pause(true)
            call detach(attachment)
            call StormBolt.create(this)

            set effect.pitch = Deg2Rad(60)

            return false
        endmethod
    endstruct

    struct StormBolt extends Spell
        private static List array lists

        private List list
        private Hammer hammer
        private real range
        private real duration
        private real reduction
        private effect effect
        
        method destroy takes nothing returns nothing
            call hammer.terminate()
            call list.remove(hammer)
            call DestroyEffect(effect)

            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 0.2

            if DistanceBetweenCoordinates(GetUnitX(hammer.source), GetUnitY(hammer.source), hammer.x, hammer.y) <= range then
                call BlzStartUnitAbilityCooldown(hammer.source, ABILITY, (1 - reduction) * BlzGetUnitAbilityCooldownRemaining(hammer.source, ABILITY))

                return false
            endif

            return duration > 0
        endmethod

        static method lightning takes unit source, real damage, real aoe returns nothing
            local List list = lists[GetUnitUserData(source)]
            local group g = CreateGroup()
            local Hammer hammer
            local List node
            local unit u

            if list != 0 then
                set node = list.next

                loop
                    exitwhen node == list
                        set hammer = Hammer(node.data)
                        
                        call GroupEnumUnitsInRange(g, hammer.x, hammer.y, aoe, null)

                        loop
                            set u = FirstOfGroup(g)
                            exitwhen u == null
                                if DamageFilter(hammer.owner, u) then
                                    call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                endif
                            call GroupRemoveUnit(g, u)
                        endloop

                        call DestroyEffect(AddSpecialEffectEx(LIGHTNING_MODEL, hammer.x, hammer.y, 0, LIGHTNING_SCALE))
                    set node = node.next
                endloop                
            endif

            call DestroyGroup(g)

            set g = null
        endmethod

        static method create takes Hammer hammer returns thistype
            local integer id = GetUnitUserData(hammer.source)
            local thistype this = thistype.allocate()
            local List list = lists[id]

            if list == 0 then
                set list = List.create()
                set lists[id] = list
            endif

            set .list = list
            set .hammer = hammer
            set range = GetPickupRange(hammer.source, hammer.level)
            set duration = GetDuration(hammer.source, hammer.level)
            set reduction = GetCooldownReduction(hammer.source, hammer.level)
            set effect = AddSpecialEffectEx(GROUND_MODEL, hammer.x, hammer.y, 0, GROUND_SCALE)

            call list.insert(hammer)
            call StartTimer(0.2, true, this, 0)

            return this
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Muradin|r throw his hammer towards a target location. On its way the hammer deals |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage and slows enemy units by |cffffcc00" + N2S(GetSlow(level) * 100, 0) + "%|r for |cffffcc00" + N2S(GetSlowDuration(level), 1) + "|r seconds. Upon reaching the destination the hammer stays in position for |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds and when casting |cffffcc00Thunder Clap|r a lightning will strike at the hammer position dealing the same amount of damage. Additionaly, if |cffffcc00Muradin|r comes in range of the hammer he will pick it up, restoring |cffffcc00" + N2S(GetCooldownReduction(source, level) * 100, 0) + "%|r of |cffffcc00Storm Bolt|r remaining cooldown"
        endmethod

        private method onCast takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetMinimumDistance(level)
            local Hammer hammer

            if DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) < distance then
                set hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.source.x + distance * Cos(angle), Spell.source.y + distance * Sin(angle), 60)
            else
                set hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)
            endif

            set hammer.source = Spell.source.unit
            set hammer.owner = Spell.source.player
            set hammer.model = MISSILE_MODEL
            set hammer.speed = MISSILE_SPEED
            set hammer.scale = MISSILE_SCALE
            set hammer.level = level
            set hammer.damage = GetDamage(Spell.source.unit, level)
            set hammer.collision = GetAoE(Spell.source.unit, level)
            set hammer.slow = GetSlow(level)
            set hammer.slowDuration = GetSlowDuration(level)
            set hammer.attachment = hammer.attach(EXTRA_MODEL, 0, 0, 0, MISSILE_SCALE)

            call hammer.launch()
        endmethod

        implement Periodic
        
        static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary