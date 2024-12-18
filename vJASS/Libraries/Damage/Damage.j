library DamageInterface requires Table
    /* --------------------------- DamageInterface v3.0 by Chopinski --------------------------- */
    // Allows for easy registration of specific damage type events like on attack
    // damage or on spell damage, etc...
    /* ------------------------------------------ END ------------------------------------------ */
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // Set to true to enable evasion system
        private constant boolean USE_EVASION = true
        // If true will use armor and magic penetration. This makes armor type differentiation irrelevant
        private constant boolean USE_PENETRATION = true
        // Armor effectiveness. overwrites the default when USE_PENETRATION is true
        private constant real ARMOR_MULTIPLIER = 0.06
        // Magic resistance effectiveness. overwrites the default when USE_PENETRATION is true
        private constant real MAGIC_MULTIPLIER = 0.06
        // Heroes base magic resistance, which with the current formula equates to aproximately 24% magic resistance
        private constant real BASE_HERO_MAGIC_RESISTANCE = 5
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    /* ----------------------------------------- Damage ---------------------------------------- */
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

    /* ---------------------------------------- Evasion ---------------------------------------- */
    function RegisterEvasionEvent takes code c returns nothing
        call Evasion.register(c)
    endfunction

    function GetMissingUnit takes nothing returns unit
        return Evasion.source.unit
    endfunction

    function GetEvadingUnit takes nothing returns unit
        return Evasion.target.unit
    endfunction

    function GetEvadedDamage takes nothing returns real
        return Evasion.damage
    endfunction

    function GetUnitEvasionChance takes unit u returns real
        return Evasion.getEvasionChance(u)
    endfunction

    function GetUnitMissChance takes unit u returns real
        return Evasion.getMissChance(u)
    endfunction

    function SetUnitEvasionChance takes unit u, real chance returns real
        return Evasion.setEvasionChance(u, chance)
    endfunction

    function SetUnitMissChance takes unit u, real chance returns real
        return Evasion.setMissChance(u, chance)
    endfunction

    function UnitAddEvasionChance takes unit u, real chance returns real
        return Evasion.setEvasionChance(u, Evasion.getEvasionChance(u) + chance)
    endfunction

    function UnitAddMissChance takes unit u, real chance returns real
        return Evasion.setMissChance(u, Evasion.getMissChance(u) + chance)
    endfunction

    function MakeUnitNeverMiss takes unit u, boolean flag returns nothing
        if flag then
            set Evasion.pierce[GetUnitUserData(u)] = Evasion.pierce[GetUnitUserData(u)] + 1
        else
            set Evasion.pierce[GetUnitUserData(u)] = Evasion.pierce[GetUnitUserData(u)] - 1
        endif
    endfunction

    function DoUnitNeverMiss takes unit u returns boolean
        return Evasion.pierce[GetUnitUserData(u)] > 0
    endfunction
    
    /* ---------------------------------------- Critical --------------------------------------- */
    function RegisterCriticalStrikeEvent takes code c returns nothing
        call Critical.register(c)
    endfunction

    function GetCriticalSource takes nothing returns unit
        return Critical.source.unit
    endfunction

    function GetCriticalTarget takes nothing returns unit
        return Critical.target.unit
    endfunction

    function GetCriticalDamage takes nothing returns real
        return Critical.damage
    endfunction

    function GetUnitCriticalChance takes unit u returns real
        return Critical.getChance(u)
    endfunction

    function GetUnitCriticalMultiplier takes unit u returns real
        return Critical.getMultiplier(u)
    endfunction

    function SetUnitCriticalChance takes unit u, real value returns real
        return Critical.setChance(u, value)
    endfunction

    function SetUnitCriticalMultiplier takes unit u, real value returns real
        return Critical.setMultiplier(u, value)
    endfunction

    function SetCriticalEventDamage takes real newValue returns nothing
        set Critical.damage = newValue
    endfunction

    function UnitAddCriticalStrike takes unit u, real chance, real multiplier returns nothing
        call Critical.add(u, chance, multiplier)
    endfunction

    /* ------------------------------------ Magic Resistance ----------------------------------- */
    function GetUnitMagicResistance takes unit u returns real
        return MagicResistance.get(u)
    endfunction

    function SetUnitMagicResistance takes unit u, real value returns real
        return MagicResistance.Set(u, value)
    endfunction

    function UnitAddMagicResistance takes unit u, real value returns real
        return MagicResistance.Set(u, MagicResistance.get(u) + value)
    endfunction

    /* ----------------------------------- Armor Penetration ----------------------------------- */
    function GetUnitArmorPenetration takes unit u, boolean flat returns real
        return ArmorPenetration.get(u, flat)
    endfunction

    function SetUnitArmorPenetration takes unit u, real value, boolean flat returns real
        return ArmorPenetration.Set(u, value, flat)
    endfunction

    function UnitAddArmorPenetration takes unit u, real value, boolean flat returns real
        return ArmorPenetration.Set(u, ArmorPenetration.get(u, flat) + value, flat)
    endfunction
    
    function GetArmorReduction takes unit source, unit target returns real
        local real armor = BlzGetUnitArmor(target) - GetUnitArmorPenetration(source, true)

        if armor > 0 then
            set armor = armor * (1 - GetUnitArmorPenetration(source, false))
        endif

        return (armor * ARMOR_MULTIPLIER) / (1 + (armor * ARMOR_MULTIPLIER))
    endfunction

    /* ----------------------------------- Magic Penetration ----------------------------------- */
    function GetUnitMagicPenetration takes unit u, boolean flat returns real
        return MagicPenetration.get(u, flat)
    endfunction

    function SetUnitMagicPenetration takes unit u, real value, boolean flat returns real
        return MagicPenetration.Set(u, value, flat)
    endfunction

    function UnitAddMagicPenetration takes unit u, real value, boolean flat returns real
        return MagicPenetration.Set(u, MagicPenetration.get(u, flat) + value, flat)
    endfunction

    function GetMagicReduction takes unit source, unit target returns real
        local real magic = GetUnitMagicResistance(target) - GetUnitMagicPenetration(source, true)

        if magic > 0 then
            set magic = magic * (1 - GetUnitMagicPenetration(source, false))
        endif

        return (magic * MAGIC_MULTIPLIER) / (1 + (magic * MAGIC_MULTIPLIER))
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Unit
        private static location location = Location(0, 0)

        unit unit
        
        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod

        method operator x takes nothing returns real
            return GetUnitX(unit)
        endmethod

        method operator y takes nothing returns real
            return GetUnitY(unit)
        endmethod

        method operator z takes nothing returns real
            call MoveLocation(location, GetUnitX(unit), GetUnitY(unit))
            return GetUnitFlyHeight(unit) + GetLocationZ(location)
        endmethod

        method operator id takes nothing returns integer
            return GetUnitUserData(unit)
        endmethod

        method operator type takes nothing returns integer
            return GetUnitTypeId(unit)
        endmethod

        method operator handle takes nothing returns integer
            return GetHandleId(unit)
        endmethod

        method operator player takes nothing returns player
            return GetOwningPlayer(unit)
        endmethod

        method operator armor takes nothing returns real
            return BlzGetUnitArmor(unit)
        endmethod

        method operator mana takes nothing returns real
            return GetUnitState(unit, UNIT_STATE_MANA)
        endmethod

        method operator health takes nothing returns real
            return GetWidgetLife(unit)
        endmethod

        method operator agility takes nothing returns integer
            return GetHeroAgi(unit, true)
        endmethod

        method operator strength takes nothing returns integer
            return GetHeroStr(unit, true)
        endmethod

        method operator intelligence takes nothing returns integer
            return GetHeroInt(unit, true)
        endmethod

        method operator armortype takes nothing returns armortype
            return ConvertArmorType(BlzGetUnitIntegerField(unit, UNIT_IF_ARMOR_TYPE))
        endmethod

        method operator defensetype takes nothing returns defensetype
            return ConvertDefenseType(BlzGetUnitIntegerField(unit, UNIT_IF_DEFENSE_TYPE))
        endmethod

        method operator isHero takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_HERO)
        endmethod

        method operator isMelee takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MELEE_ATTACKER)
        endmethod

        method operator isRanged takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_RANGED_ATTACKER)
        endmethod

        method operator isSummoned takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_SUMMONED)
        endmethod

        method operator isStructure takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_STRUCTURE)
        endmethod

        method operator isMagicImmune takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
        endmethod

        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()

            set unit = u

            return this
        endmethod
    endstruct

    struct Damage extends array
        private static trigger damaged = CreateTrigger()
        private static trigger damaging = CreateTrigger()
        readonly static trigger anyAfter = CreateTrigger()
        readonly static trigger anyBefore = CreateTrigger()

        private static HashTable after
        private static HashTable before
        private static thistype key = 0

        private Unit sources
        private Unit targets
        private real damage
        private boolean evade
        private attacktype attackType
        private damagetype damageType
        private weapontype weaponType

        method destroy takes nothing returns nothing
            call sources.destroy()
            call targets.destroy()

            set damage = 0
            set evade = false
            set attackType = null
            set damageType = null
            set weaponType = null
            set key = key - 1
        endmethod

        static method operator source takes nothing returns Unit
            return Damage.key.sources
        endmethod

        static method operator target takes nothing returns Unit
            return Damage.key.targets
        endmethod

        static method operator amount takes nothing returns real
            return Damage.key.damage
        endmethod

        static method operator amount= takes real value returns nothing
            set Damage.key.damage = value
            call BlzSetEventDamage(value)
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
            set evade = false
            set damage = GetEventDamage()
            set sources = Unit.create(GetEventDamageSource())
            set targets = Unit.create(BlzGetEventDamageTarget())
            set attackType = BlzGetEventAttackType()
            set damageType = BlzGetEventDamageType()
            set weaponType = BlzGetEventWeaponType()

            static if USE_EVASION then
                if isAttack then
                    set evade = Evasion.evade
                endif
            endif

            return this
        endmethod

        private static method onDamaging takes nothing returns nothing
            local integer i
            local integer j
            local thistype this = create()

            if damagetype != DAMAGE_TYPE_UNKNOWN then
                set i = GetHandleId(attacktype)
                set j = GetHandleId(damagetype)

                if before[i].trigger.has(0) then
                    call TriggerEvaluate(before[i].trigger[0])
                endif

                if not evade then
                    if before[0].trigger.has(j) then
                        call TriggerEvaluate(before[0].trigger[j])
                    endif
                endif
                
                if before[i].trigger.has(j) then
                    call TriggerEvaluate(before[i].trigger[j])
                endif
            endif

            call TriggerEvaluate(anyBefore)
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer i
            local integer j
            local thistype this = key
            local real premitigation = damage

            set damage = GetEventDamage()

            if damagetype != DAMAGE_TYPE_UNKNOWN then
                set i = GetHandleId(attacktype)
                set j = GetHandleId(damagetype)

                if isSpell then
                    static if USE_PENETRATION then
                        set amount = premitigation * (1 - GetMagicReduction(source.unit, target.unit))
                    endif

                    if after[i].trigger.has(0) then
                        call TriggerEvaluate(after[i].trigger[0])
                    endif
                endif

                if isAttack and not evade then
                    static if USE_PENETRATION then
                        set amount = premitigation * (1 - GetArmorReduction(source.unit, target.unit))
                    endif

                    if after[0].trigger.has(j) then
                        call TriggerEvaluate(after[0].trigger[j])
                    endif
                endif
                
                if after[i].trigger.has(j) then
                    call TriggerEvaluate(after[i].trigger[j])
                endif
            endif

            call TriggerEvaluate(anyAfter)
            call BlzSetEventDamage(damage)
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

    struct Evasion
        readonly static Unit source
        readonly static Unit target
        readonly static real damage
        readonly static real array miss
        readonly static real array evasion
        readonly static integer array pierce
        readonly static trigger trigger = CreateTrigger()

        static method getEvasionChance takes unit u returns real
            return evasion[GetUnitUserData(u)]
        endmethod

        static method getMissChance takes unit u returns real
            return miss[GetUnitUserData(u)]
        endmethod

        static method setEvasionChance takes unit u, real value returns real
            set evasion[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setMissChance takes unit u, real value returns real
            set miss[GetUnitUserData(u)] = value

            return value
        endmethod

        static method register takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        static method operator evade takes nothing returns boolean
            local texttag text
            local boolean should = false

            if Damage.amount > 0 and not (pierce[Damage.source.id] > 0) then
                set text = CreateTextTag()
                set should = GetRandomReal(0, 1) <= evasion[Damage.target.id] or GetRandomReal(0, 1) <= miss[Damage.source.id]

                if should then
                    set source = Damage.source
                    set target = Damage.target
                    set damage = Damage.amount
                    set Damage.amount = 0
                    set Damage.weapontype = WEAPON_TYPE_WHOKNOWS

                    call TriggerEvaluate(trigger)
                    call SetTextTagText(text, "miss", 0.016)
                    call SetTextTagPosUnit(text, source.unit, 0)
                    call SetTextTagColor(text, 255, 0, 0, 255)
                    call SetTextTagLifespan(text, 1.5)
                    call SetTextTagVelocity(text, 0.0, 0.0355)
                    call SetTextTagPermanent(text, false)

                    set damage = 0
                    set source = 0
                    set target = 0
                endif
            endif

            set text = null

            return should
        endmethod
    endstruct

    struct Critical
        readonly static Unit source
        readonly static Unit target
        readonly static real array chance
        readonly static real array multiplier
        readonly static trigger trigger = CreateTrigger()

        static real damage

        static method getChance takes unit u returns real
            return chance[GetUnitUserData(u)]
        endmethod

        static method getMultiplier takes unit u returns real
            return multiplier[GetUnitUserData(u)]
        endmethod

        static method setChance takes unit u, real value returns real
            set chance[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setMultiplier takes unit u, real value returns real
            set multiplier[GetUnitUserData(u)] = value

            return value
        endmethod

        static method add takes unit u, real chance, real multuplier returns nothing
            call setChance(u, getChance(u) + chance)
            call setMultiplier(u, getMultiplier(u) + multuplier)
        endmethod

        static method register takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        private static method onDamage takes nothing returns nothing
            local texttag text

            if Damage.amount > 0 and GetRandomReal(0, 1) <= chance[Damage.source.id] and Damage.isEnemy and not Damage.target.isStructure and multiplier[Damage.source.id] > 0 then                
                set source = Damage.source
                set target = Damage.target
                set damage = Damage.amount * (1 + multiplier[Damage.source.id])
                set Damage.amount = damage

                call TriggerEvaluate(trigger)

                if damage > 0 then
                    set text = CreateTextTag()

                    call SetTextTagText(text, (I2S(R2I(damage)) + "!"), 0.016)
                    call SetTextTagPosUnit(text, target.unit, 0)
                    call SetTextTagColor(text, 255, 0, 0, 255)
                    call SetTextTagLifespan(text, 1.5)
                    call SetTextTagVelocity(text, 0.0, 0.0355)
                    call SetTextTagPermanent(text, false)
                endif

                set damage = 0
                set source = 0
                set target = 0
            endif

            set text = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamagingEvent(function thistype.onDamage)
        endmethod
    endstruct

    struct ArmorPenetration
        readonly static real array flat
        readonly static real array percent

        static method get takes unit u, boolean isFlat returns real
            if isFlat then
                return flat[GetUnitUserData(u)]
            else
                return percent[GetUnitUserData(u)]
            endif
        endmethod

        static method Set takes unit u, real value, boolean isFlat returns real
            if isFlat then
                set flat[GetUnitUserData(u)] = value
            else
                set percent[GetUnitUserData(u)] = value
            endif

            return value
        endmethod
    endstruct

    struct MagicPenetration
        readonly static real array flat
        readonly static real array percent

        static method get takes unit u, boolean isFlat returns real
            if isFlat then
                return flat[GetUnitUserData(u)]
            else
                return percent[GetUnitUserData(u)]
            endif
        endmethod

        static method Set takes unit u, real value, boolean isFlat returns real
            if isFlat then
                set flat[GetUnitUserData(u)] = value
            else
                set percent[GetUnitUserData(u)] = value
            endif

            return value
        endmethod
    endstruct

    struct MagicResistance
        private static boolean array check
        readonly static real array resistance

        static method get takes unit u returns real
            local integer id = GetUnitUserData(u)

            if IsUnitType(u, UNIT_TYPE_HERO) and not check[id] then
                set check[id] = true
                set resistance[id] = resistance[id] + BASE_HERO_MAGIC_RESISTANCE
            endif

            return resistance[GetUnitUserData(u)]
        endmethod

        static method Set takes unit u, real value returns real
            set resistance[GetUnitUserData(u)] = value

            return value
        endmethod
    endstruct
endlibrary