scope HeatingCloak
    struct HeatingCloak extends Item
        static constant integer code = 'I07C'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static real array amount
        private static string array state
        private static string array cd
        private static boolean array check
        private static thistype array array

        private unit unit
        private item item
        private effect effect
        private group group
        private player player
        private string string
        private integer cooldown
        private integer index

        // Attributes
        real mana = 5000
        real health = 5000

        private method remove takes integer i returns integer
            call DestroyEffect(effect)
            call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCloakOfFrost.blp")

            set unit = null
            set item = null
            set effect = null
            set group = null
            set player = null
            set array[i] = array[key]
            set key = key - 1
            set check[index] = false

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc005000|r Health\n+ |cffffcc005000|r Mana\n\n|cff00ff00Passive|r: |cffffcc00Immolation|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff00ffff" + AbilitySpellDamageEx(amount[id], u) + " Magic|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Turn up the Heat|r: Every |cffffcc0060|r seconds |cffffcc00Heating Cloak|r charges up and the damage dealt by its immolation is increased by |cff00ffff500 Magic|r damage for |cffffcc0030|r seconds.\n\n" + state[id] + "|cffffcc00" + cd[id] + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local unit v
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItemOfType(unit, code) then
                        set cooldown = cooldown - 1
                        set group = CreateGroup()

                        if cooldown >= 30 then
                            set cd[index] = I2S(cooldown - 30)

                            if cooldown == 30 then
                                call DestroyEffect(effect)
                                call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCoD.blp")
                                set string = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl"
                                set amount[index] = 1000
                                set state[index] = "Remaining Burst Time: "
                                set effect = AddSpecialEffectTarget("EmberOrange.mdx", unit, "chest")
                            endif
                        else
                            set cd[index] = I2S(cooldown)

                            if cooldown == 0 then
                                call DestroyEffect(effect)
                                call BlzSetItemIconPath(item, "ReplaceableTextures\\CommandButtons\\BTNCloakOfFrost.blp")
                                set cooldown = 90
                                set string = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"
                                set amount[index] = 500
                                set state[index] = "Burst Cooldown: "
                                set effect = AddSpecialEffectTarget("EmberSnow.mdx", unit, "chest")
                            endif
                        endif

                        call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 400, null)

                        loop
                            set v = FirstOfGroup(group)
                            exitwhen v == null
                                if IsUnitEnemy(v, player)  and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                                    call DestroyEffect(AddSpecialEffectTarget(string, v, "chest"))
                                    call UnitDamageTarget(unit, v, amount[index], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                endif
                                call GroupRemoveUnit(group, v)
                        endloop

                        call DestroyGroup(group)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self

            if not check[id] then
                set self = thistype.new()
                set unit = u
                set item = i
                set effect = AddSpecialEffectTarget("EmberSnow.mdx", u, "chest")
                set string = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"
                set player = GetOwningPlayer(u)
                set index = id
                set cooldown = 90
                set key = key + 1
                set array[key] = self
                set check[id] = true
                set state[id] = "Burst Cooldown: "
                set cd[id] = I2S(cooldown - 30)
                set amount[id]   = 500

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod  

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, OrbOfFire.code, OrbOfFrost.code, CloakOfFlames.code, 0, 0)
        endmethod
    endstruct
endscope