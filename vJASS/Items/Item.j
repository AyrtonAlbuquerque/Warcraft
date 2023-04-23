library Item requires RegisterPlayerUnitEvent, Table, NewBonusUtils, Indexer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // Tooltip update period
        private constant real PERIOD = 1.
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private interface Events
        real damage = 0
        real armor = 0
        real agility = 0
        real strength = 0
        real intelligence = 0
        real health = 0
        real mana = 0
        real movementSpeed = 0
        real sightRange = 0
        real healthRegen = 0
        real manaRegen = 0
        real attackSpeed = 0
        real magicResistance = 0
        real evasionChance = 0
        real criticalDamage = 0
        real criticalChance = 0
        real lifeSteal = 0
        real missChance = 0
        real spellPowerFlat = 0
        real spellPowerPercent = 0
        real spellVamp = 0
        real cooldownReduction = 0
        real cooldownReductionFlat = 0
        real cooldownOffset = 0
        real tenacity = 0
        real tenacityFlat = 0
        real tenacityOffset = 0

        method onTooltip takes unit u, item i, integer id returns nothing defaults nothing
        method onPickup takes unit u, item i returns nothing defaults nothing
        method onDrop takes unit u, item i returns nothing defaults nothing
    endinterface

    struct Item extends Events
        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        private static Table table

        private unit unit
        private item item
        private integer id
        private thistype type

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            
            if not table.has(id) then
                set table[id] = this
            endif

            return this
        endmethod

        private method remove takes integer i returns integer
            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set item = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this
            local integer i = 0

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItem(unit, item) then
                        call type.onTooltip(unit, item, id)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onPickupItem takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local item i = GetManipulatedItem()
            local thistype this = table[GetItemTypeId(i)]
            local thistype self

            if this != 0 then
                call LinkBonusToItem(u, BONUS_DAMAGE, damage, i)
                call LinkBonusToItem(u, BONUS_ARMOR, armor, i)
                call LinkBonusToItem(u, BONUS_AGILITY, agility, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, strength, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, intelligence, i)
                call LinkBonusToItem(u, BONUS_HEALTH, health, i)
                call LinkBonusToItem(u, BONUS_MANA, mana, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, movementSpeed, i)
                call LinkBonusToItem(u, BONUS_SIGHT_RANGE, sightRange, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, healthRegen, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, manaRegen, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, attackSpeed, i)
                call LinkBonusToItem(u, BONUS_MAGIC_RESISTANCE, magicResistance, i)
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, evasionChance, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, criticalDamage, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, criticalChance, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, lifeSteal, i)
                call LinkBonusToItem(u, BONUS_MISS_CHANCE, missChance, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, spellPowerFlat, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_PERCENT, spellPowerPercent, i)
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, spellVamp, i)
                call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, cooldownReduction, i)
                call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION_FLAT, cooldownReductionFlat, i)
                call LinkBonusToItem(u, BONUS_COOLDOWN_OFFSET, cooldownOffset, i)
                call LinkBonusToItem(u, BONUS_TENACITY, tenacity, i)
                call LinkBonusToItem(u, BONUS_TENACITY_FLAT, tenacityFlat, i)
                call LinkBonusToItem(u, BONUS_TENACITY_OFFSET, tenacityOffset, i)

                if onTooltip.exists then
                    set self = thistype.allocate()
                    set self.unit = u
                    set self.item = i
                    set self.type = this
                    set self.id  = GetUnitUserData(u)
                    set key = key + 1
                    set array[key] = self

                    if key == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif

                if onPickup.exists then
                    call onPickup(u, i)
                endif
            endif

            set u = null
            set i = null
        endmethod

        private static method onDropItem takes nothing returns nothing
            local thistype this = table[GetItemTypeId(GetManipulatedItem())]

            if this != 0 then
                if onDrop.exists then
                    call onDrop(GetManipulatingUnit(), GetManipulatedItem())
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = Table.create()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickupItem) 
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDropItem) 
        endmethod
    endstruct
endlibrary
