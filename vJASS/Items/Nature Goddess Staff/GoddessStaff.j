scope NatureGoddessStaff
    struct NatureGoddessStaff extends Item
        static constant integer code = 'I08O'
        static constant integer buff = 'B00Y'
        static constant integer ability = 'A018'
        static constant integer unittype = 'n00W'

        private static integer key = -1    
        private static thistype array array
        private static timer timer = CreateTimer()

        private unit unit
        private unit tornado
        private group group
        private player player
        private integer duration

        // Attributes
        real health = 10000
        real intelligence = 500
        real spellPowerPercent = 0.2

        private method remove takes integer i returns integer
            call DestroyGroup(group)

            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set tornado = null
            set group = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0020%|r Spell Damage\n+ |cffffcc00500|r Intelligence\n+ |cffffcc0010000|r Health\n\n|cff00ff00Passive|r: |cffffcc00Thorned Rose|r: Provides |cffffcc00Thorn Aura|r within |cffffcc00600 AoE|r that returns |cffffcc0035%|r of damage taken.\n\n|cff00ff00Active|r: |cffffcc00Nature's Wrath|r: Creates a |cffffcc00Nature Tornado|r that slows enemy units within |cffffcc00600 AoE|r and deals |cff00ffff" + AbilitySpellDamageEx(1000, u) + "Magic|r to enemy units within |cffffcc00400 AoE|r. When expired the |cffffcc00Nature Tornado|r explodes, healing all allies within |cffffcc00600 AoE|r for |cffffcc0020000|r |cffff0000Health|r and |cff00ffffMana|r and damaging enemies for |cffffcc0010000|r |cff808080Pure|r damage.\n\nLasts for 30 seconds.")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local unit v
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration > 0 then
                        call GroupEnumUnitsInRange(group, GetUnitX(tornado), GetUnitY(tornado), 400, null)

                        loop
                            set v = FirstOfGroup(group)
                            exitwhen v == null
                                if IsUnitEnemy(v, player)  and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", v, "origin"))
                                    call UnitDamageTarget(unit, v, 1000, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                endif
                            call GroupRemoveUnit(group, v)
                        endloop
                    else
                        set i = remove(i)
                    endif

                    set duration = duration - 1
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if GetUnitAbilityLevel(Damage.target.unit, buff) > 0 and damage > 0 then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, damage*0.35, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killed = GetTriggerUnit()
            local unit v
            local group g

            if GetUnitTypeId(killed) == unittype then
                set g = CreateGroup()

                call DestroyEffect(AddSpecialEffect("NatureExplosion_II.mdx", GetUnitX(killed), GetUnitY(killed)))
                call GroupEnumUnitsInRange(g, GetUnitX(killed), GetUnitY(killed), 600, null)

                loop
                    set v = FirstOfGroup(g)
                    exitwhen v == null
                        if IsUnitEnemy(v, GetOwningPlayer(killed))  and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                            call UnitDamageTarget(killed, v, 10000, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                        elseif IsUnitAlly(v, GetOwningPlayer(killed))  and UnitAlive(v) then 
                            call SetWidgetLife(v, GetWidgetLife(v) + 20000)
                            call AddUnitMana(v, 20000)
                        endif
                    call GroupRemoveUnit(g, v)
                endloop

                call DestroyGroup(g)
            endif

            set v = null
            set g = null
            set killed = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.new()

            set unit = Spell.source.unit
            set player = Spell.source.player
            set group = CreateGroup()
            set tornado = CreateUnit(player, unittype, Spell.x, Spell.y, GetUnitFacing(unit))
            set duration = 30
            set key = key + 1
            set array[key] = this

            call UnitApplyTimedLife(tornado, 'BTLF', 30)

            if key == 0 then
                call TimerStart(timer, 1, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, SphereOfNature.code, NatureStaff.code, 0, 0, 0)
        endmethod
    endstruct
endscope