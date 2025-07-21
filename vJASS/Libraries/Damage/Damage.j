library DamageInterface requires Table, Unit
    /* --------------------------- DamageInterface v3.0 by Chopinski --------------------------- */
    // Allows for easy registration of specific damage type events like on attack
    // damage or on spell damage, etc...
    /* ------------------------------------------ END ------------------------------------------ */

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterAttackDamageEvent takes code c returns nothing
        call Damage.register(null, DAMAGE_TYPE_NORMAL, c, true)
    endfunction
    
    function RegisterSpellDamageEvent takes code c returns nothing
        call Damage.register(ATTACK_TYPE_NORMAL, null, c, true)
    endfunction

    function RegisterDamageEvent takes attacktype attack, damagetype damage, code c returns nothing
        call Damage.register(attack, damage, c, true)
    endfunction

    function RegisterAnyDamageEvent takes code c returns nothing
        call TriggerAddCondition(Damage.anyAfter, Filter(c))
    endfunction

    function RegisterAttackDamagingEvent takes code c returns nothing
        call Damage.register(null, DAMAGE_TYPE_NORMAL, c, false)
    endfunction
    
    function RegisterSpellDamagingEvent takes code c returns nothing
        call Damage.register(ATTACK_TYPE_NORMAL, null, c, false)
    endfunction

    function RegisterDamagingEvent takes attacktype attack, damagetype damage, code c returns nothing
        call Damage.register(attack, damage, c, false)
    endfunction 

    function RegisterAnyDamagingEvent takes code c returns nothing
        call TriggerAddCondition(Damage.anyBefore, Filter(c))
    endfunction

    function RegisterDamageConfigurationEvent takes code c returns nothing
        call TriggerAddCondition(Damage.configuration, Filter(c))
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Damage extends array
        private static trigger damaged = CreateTrigger()
        private static trigger damaging = CreateTrigger()
        readonly static trigger anyAfter = CreateTrigger()
        readonly static trigger anyBefore = CreateTrigger()
        readonly static trigger configuration = CreateTrigger()

        private static HashTable after
        private static HashTable before
        private static thistype key = 0

        private Unit sources
        private Unit targets
        private real damage
        private real predamage
        private unit newSource
        private unit newTarget
        private boolean skip
        private attacktype attackType
        private damagetype damageType
        private weapontype weaponType

        method destroy takes nothing returns nothing
            call sources.destroy()
            call targets.destroy()

            set damage = 0
            set skip = false
            set predamage = 0
            set newSource = null
            set newTarget = null
            set attackType = null
            set damageType = null
            set weaponType = null
            set key = key - 1
        endmethod

        static method operator source takes nothing returns Unit
            return Damage.key.sources
        endmethod

        static method operator source= takes unit value returns nothing
            set Damage.key.newSource = value
        endmethod

        static method operator target takes nothing returns Unit
            return Damage.key.targets
        endmethod

        static method operator target= takes unit value returns nothing
            set Damage.key.newTarget = value
        endmethod

        static method operator amount takes nothing returns real
            return Damage.key.damage
        endmethod

        static method operator amount= takes real value returns nothing
            set Damage.key.damage = value
            call BlzSetEventDamage(value)
        endmethod

        static method operator process takes nothing returns boolean
            return not Damage.key.skip
        endmethod

        static method operator process= takes boolean flag returns nothing
            set Damage.key.skip = not flag
        endmethod

        static method operator premitigation takes nothing returns real
            return Damage.key.predamage
        endmethod

        static method operator damagetype takes nothing returns damagetype
            return Damage.key.damageType
        endmethod

        static method operator damagetype= takes damagetype value returns nothing
            set Damage.key.damageType = value
            call BlzSetEventDamageType(value)
        endmethod

        static method operator attacktype takes nothing returns attacktype
            return Damage.key.attackType
        endmethod

        static method operator attacktype= takes attacktype value returns nothing
            set Damage.key.attackType = value
            call BlzSetEventAttackType(value)
        endmethod

        static method operator weapontype takes nothing returns weapontype
            return Damage.key.weaponType
        endmethod

        static method operator weapontype= takes weapontype value returns nothing
            set Damage.key.weaponType = value
            call BlzSetEventWeaponType(value)
        endmethod

        static method operator isAlly takes nothing returns boolean
            return IsUnitAlly(Damage.key.target.unit, Damage.key.source.player)
        endmethod

        static method operator isEnemy takes nothing returns boolean
            return IsUnitEnemy(Damage.key.target.unit, Damage.key.source.player)
        endmethod

        static method operator isSpell takes nothing returns boolean
            return attacktype == ATTACK_TYPE_NORMAL
        endmethod

        static method operator isAttack takes nothing returns boolean
            return damagetype == DAMAGE_TYPE_NORMAL or BlzGetEventIsAttack()
        endmethod

        static method register takes attacktype attack, damagetype damage, code c, boolean posmitigation returns nothing
            local integer i = GetHandleId(attack)
            local integer j = GetHandleId(damage)

            if posmitigation then
                if not after[i].trigger.has(j) then
                    set after[i].trigger[j] = CreateTrigger()
                endif
                
                call TriggerAddCondition(after[i].trigger[j], Filter(c))
            else
                if not before[i].trigger.has(j) then
                    set before[i].trigger[j] = CreateTrigger()
                endif

                call TriggerAddCondition(before[i].trigger[j], Filter(c))
            endif
        endmethod

        static method create takes nothing returns thistype
            local thistype this = key + 1

            set key = this
            set skip = false
            set newSource = null
            set newTarget = null
            set predamage = 0
            set damage = GetEventDamage()
            set sources = Unit.create(GetEventDamageSource())
            set targets = Unit.create(BlzGetEventDamageTarget())
            set attackType = BlzGetEventAttackType()
            set damageType = BlzGetEventDamageType()
            set weaponType = BlzGetEventWeaponType()

            call TriggerEvaluate(configuration)

            return this
        endmethod

        private static method onDamaging takes nothing returns nothing
            local thistype this = create()
            local integer i
            local integer j

            if not skip then
                if damagetype != DAMAGE_TYPE_UNKNOWN then
                    set i = GetHandleId(attacktype)
                    set j = GetHandleId(damagetype)

                    if before[i].trigger.has(0) then
                        call TriggerEvaluate(before[i].trigger[0])
                    endif

                    if before[0].trigger.has(j) then
                        call TriggerEvaluate(before[0].trigger[j])
                    endif
                    
                    if before[i].trigger.has(j) then
                        call TriggerEvaluate(before[i].trigger[j])
                    endif
                endif

                call TriggerEvaluate(anyBefore)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = key
            local integer i
            local integer j

            set predamage = damage
            set damage = GetEventDamage()

            if not skip then
                if damagetype != DAMAGE_TYPE_UNKNOWN then
                    set i = GetHandleId(attacktype)
                    set j = GetHandleId(damagetype)

                    if after[i].trigger.has(0) then
                        call TriggerEvaluate(after[i].trigger[0])
                    endif

                    if after[0].trigger.has(j) then
                        call TriggerEvaluate(after[0].trigger[j])
                    endif
                    
                    if after[i].trigger.has(j) then
                        call TriggerEvaluate(after[i].trigger[j])
                    endif
                endif

                call TriggerEvaluate(anyAfter)
                call BlzSetEventDamage(damage)

                if newSource != null or newTarget != null then
                    if newSource != null then
                        set source.unit = newSource
                    endif

                    if newTarget != null then
                        set target.unit = newTarget
                    endif

                    call BlzSetEventDamage(0)
                    call UnitDamageTarget(source.unit, target.unit, amount, false, false, attacktype, damagetype, weapontype)
                endif
            endif

            call destroy()
        endmethod

        private static method onInit takes nothing returns nothing
            set after = HashTable.create()
            set before = HashTable.create()

            call TriggerRegisterAnyUnitEventBJ(damaged, EVENT_PLAYER_UNIT_DAMAGED)
            call TriggerAddCondition(damaged, Condition(function thistype.onDamage))

            call TriggerRegisterAnyUnitEventBJ(damaging, EVENT_PLAYER_UNIT_DAMAGING)
            call TriggerAddCondition(damaging, Condition(function thistype.onDamaging))
        endmethod
    endstruct
endlibrary