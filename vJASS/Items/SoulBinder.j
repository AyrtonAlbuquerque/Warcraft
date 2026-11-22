scope SoulBinder
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source, unit target, integer level returns real
        return (10 * level) + (0.2 * (BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE))) + (0.025 * BlzGetUnitMaxHP(target))
    endfunction

    private constant function GetArmorFactor takes nothing returns real
        return 0.25
    endfunction

    private constant function GetArmorPenetrationDuration takes nothing returns real
        return 5.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    private struct SoulFragment extends Missile
        private method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
            endif

            return true
        endmethod
    endstruct
    
    struct SoulBinder extends Item
        static constant integer code = 'I01Y'
        private static thistype array array
        private static thistype array bound

        // Attributes
        real damage = 40
        real evasion = 0.2
        real criticalChance = 0.15
        real criticalDamage = 0.25
        real armorPenetrationFlat = 8

        private unit unit
        private timer timer
        private group group
        private integer key
        private effect effect
        private boolean bounded

        method destroy takes nothing returns nothing
            local thistype self
            local unit u

            if group != null then
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if bounded then
                            set self = array[GetUnitUserData(u)]
                        else
                            set self = bound[GetUnitUserData(u)]
                        endif

                        if self != 0 then
                            if IsUnitInGroup(unit, self.group) then
                                call GroupRemoveUnit(self.group, unit)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                call DestroyGroup(group)
            endif

            if timer != null then
                call ReleaseTimer(timer)
            endif

            if bounded then
                set bound[key] = 0

                if effect != null then
                    call DestroyEffect(effect)
                endif
            else
                set array[key] = 0
            endif

            set unit = null
            set timer = null
            set group = null
            set effect = null
            set bounded = false

            call deallocate()
        endmethod

        private static method launch takes unit source, unit target, real damage, real x, real y, real z returns nothing
            local SoulFragment missile = SoulFragment.create(x, y, z, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + 60)

            set missile.source = source
            set missile.target = target
            set missile.model = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl"
            set missile.speed = 900
            set missile.scale = 0.5
            set missile.damage = damage
            set missile.arc = GetRandomInt(0, 15) * bj_DEGTORAD
            set missile.curve = GetRandomInt(-15, 15) * bj_DEGTORAD

            call missile.launch()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0040|r Damage\n+ |cffffcc0020%|r Evasion\n+ |cffffcc008|r Armor Penetration\n+ |cffffcc0015%|r Critical Chance\n+ |cffffcc0025%|r Critical Damage\n\n|cff00ff00Passive|r: |cffffcc00Soul Rip|r: When killing an enemy unit, gain |cffffcc00" + N2S(GetArmorFactor() * 100, 0) + "%|r of its |cff808080Armor|r as |cffffcc00Armor Penetration|r for |cffffcc00" + N2S(GetArmorPenetrationDuration(), 0) + "|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Soul Bind|r: Dealing |cffff0000Physical|r damage to an enemy unit binds it soul to other enemy units damaged by |cffffcc00Soul Binder|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds. When |cffffcc00Killing|r or hitting a |cffffcc00Critical Strike|r in a unit that is soul binded, shatter its soul dealing |cffffcc00" + N2S((10 * GetWidgetLevel(u)) + (0.2 * (BlzGetUnitBaseDamage(u, 0) + GetUnitBonus(u, BONUS_DAMAGE))), 0) + "|r + (|cffffcc002.5%|r of the target |cffff0000Max Health|r) |cffffcc00True|r damage to it and all binded enemies."
        endmethod

        private method onDrop takes unit u, item i returns nothing
            set this = array[GetUnitUserData(u)]

            if not UnitHasItemOfType(u, code) and this != 0 then
                call destroy()
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local thistype this = array[GetUnitUserData(source)]
            local thistype self = bound[GetUnitUserData(target)]
            local integer i = 0
            local integer size
            local real damage
            local unit u

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) and this != 0 and self != 0 then
                set size = BlzGroupGetSize(group)
                set damage = GetDamage(source, target, GetWidgetLevel(source))

                if size > 0 then
                    loop
                        exitwhen i == size
                            set u = BlzGroupUnitAt(group, i)

                            if u != target and UnitAlive(u) then
                                call launch(source, u, damage, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + 60)
                            endif
                        set i = i + 1
                    endloop
                endif

                if UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", target, "chest"))
                endif
            endif

            set u = null
            set source = null
            set target = null
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local unit target = GetTriggerUnit()
            local thistype this = array[GetUnitUserData(source)]
            local thistype self = bound[GetUnitUserData(target)]
            local integer i = 0
            local integer size
            local real damage
            local unit u

            if self != 0 then
                if this != 0 then
                    set size = BlzGroupGetSize(group)
                    set damage = GetDamage(source, target, GetWidgetLevel(source))

                    if size > 0 then
                        loop
                            exitwhen i == size
                                set u = BlzGroupUnitAt(group, i)

                                if u != target and UnitAlive(u) then
                                    call launch(source, u, damage, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + 60)
                                endif
                            set i = i + 1
                        endloop
                    endif
                endif

                call self.destroy()
            endif

            if UnitHasItemOfType(source, code) then
                call AddUnitBonusTimed(source, BONUS_ARMOR_PENETRATION_FLAT, R2I(BlzGetUnitArmor(target) * GetArmorFactor()), GetArmorPenetrationDuration())
            endif

            set u = null
            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.source.id]
            local thistype self = bound[Damage.target.id]

            if UnitAlive(Damage.target.unit) and UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set bounded = false
                    set unit = Damage.source.unit
                    set key = Damage.source.id
                    set group = CreateGroup()
                    set array[Damage.source.id] = this
                endif

                if self == 0 then
                    set self = thistype.allocate(0)
                    set self.bounded = true
                    set self.key = Damage.target.id
                    set self.unit = Damage.target.unit
                    set self.timer = NewTimerEx(self)
                    set self.group = CreateGroup()
                    set self.effect = AddSpecialEffectTarget("NecroBuff_Overhead.mdl", Damage.target.unit, "overhead")
                    set bound[Damage.target.id] = self
                endif

                if not IsUnitInGroup(Damage.target.unit, group) then
                    call GroupAddUnit(group, Damage.target.unit)
                endif

                if not IsUnitInGroup(Damage.source.unit, self.group) then
                    call GroupAddUnit(self.group, Damage.source.unit)
                endif

                call TimerStart(self.timer, GetDuration(), false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), RitualDagger.code, GreatAxe.code, 0, 0, 0)
        endmethod
    endstruct
endscope