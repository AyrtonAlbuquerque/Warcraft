scope HollowBow
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetMultishotChance takes nothing returns integer
        return 25
    endfunction

    private constant function GetChance takes nothing returns integer
        return 20
    endfunction

    private function GetDamage takes unit source, integer level returns real
        return 20 * level + (0.4 * (BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE)) + (0.2 * GetUnitBonus(source, BONUS_SPELL_POWER)))
    endfunction

    private function GetHeal takes unit source, integer level returns real
        return 0.05 * BlzGetUnitMaxHP(source)
    endfunction

    private function GetDuration takes unit source, integer level returns real
        return 5.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct SoulBite extends Missile
        private method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                call HollowBow.heal(target)
            endif

            return true
        endmethod
    endstruct
    
    struct HollowBow extends Item
        static constant integer code = 'I01O'
        private static constant integer ability = 'A003'
        private static thistype array array
        private static real array regen

        // Attributes
        real damage = 20
        real agility = 20
        real pierce = 0.3
        real armorPenetration = 5

        private unit unit
        private timer timer
        private integer key
        private effect effect
        private real duration
        private real remaining

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call DestroyEffect(effect)

            set unit = null
            set timer = null
            set effect = null
            set array[key] = 0
            set regen[key] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0020|r Agility\n+ |cffffcc0020|r Damage\n+ |cffffcc0030%|r True Strike\n+ |cffffcc005|r Armor Penetration\n\n|cff00ff00Passive|r: |cffffcc00Multishot|r: |cffffcc00Ranged|r units have a |cffffcc0025%|r chance on each attack to strike |cffffcc002|r additional targets.\n\n|cff00ff00Passive|r: |cffffcc00Soul Bite|r: Auto attacks have a |cffffcc0020%|r chance to steal a portion of the target soul, dealing |cff00ffff" + N2S(GetDamage(u, GetWidgetLevel(u)), 0) + " Magic|r damage and healing the attacker for |cffff0000" + N2S(GetHeal(u, GetWidgetLevel(u)), 0) + "|r (|cffffcc005%|r of its |cffff0000Maximum Health|r) over |cffffcc00" + N2S(GetDuration(u, GetWidgetLevel(u)), 0) + "|r seconds."
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real amount = regen[key] / (duration / 0.2)

            set remaining = remaining - 0.2

            if remaining > 0 then
                set regen[key] = regen[key] - amount

                call HealUnit(unit, unit, amount, HEALTH, false)
            else
                call destroy()
            endif
        endmethod

        static method heal takes unit source returns nothing
            local integer id = GetUnitUserData(source)
            local thistype this = array[id]

            if this == 0 then
                set this = thistype.allocate(0)
                set key = id
                set unit = source
                set timer = NewTimerEx(this)
                set duration = GetDuration(source, GetWidgetLevel(source))
                set effect = AddSpecialEffectTarget("Swirling Soul.mdl", source, "origin")
                set array[id] = this
            endif   

            set remaining = duration
            set regen[id] = regen[id] + GetHeal(source, GetWidgetLevel(source))

            call TimerStart(timer, 0.2, true, function thistype.onPeriod)
        endmethod

        private static method onDamage takes nothing returns nothing
            local SoulBite missile

            if UnitHasItemOfType(Damage.source.unit, code) and GetRandomInt(0, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, Damage.source.level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    set missile = SoulBite.create(Damage.target.x, Damage.target.y, 50, Damage.source.x, Damage.source.y, 50)
                    set missile.source = Damage.source.unit
                    set missile.target = Damage.source.unit
                    set missile.model = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl"
                    set missile.speed = 900
                    set missile.scale = 0.5
                    set missile.arc = GetRandomInt(0, 15) * bj_DEGTORAD
                    set missile.curve = GetRandomInt(0, 15) * bj_DEGTORAD

                    call missile.launch()
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", Damage.target.unit, "chest"))
                endif
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()

            if UnitHasItemOfType(source, code) and IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER) then
                if GetRandomInt(0, 100) <= GetMultishotChance() then
                    call UnitAddAbility(source, ability)
                else
                    call UnitRemoveAbility(source, ability)
                endif
            endif

            set source = null
        endmethod 

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), OrbOfLight.code, CurvedBow.code, RitualDagger.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope