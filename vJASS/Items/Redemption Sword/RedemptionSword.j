scope RedemptionSword
    private struct LightWave extends Missile
        method onUnit takes unit hit returns boolean
            if IsUnitEnemy(hit, owner) and UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffect(AddSpecialEffectTarget("HolyLight_2.mdx", hit, "origin"))
                    call SetWidgetLife(source, GetWidgetLife(source) + damage)
                endif
            endif

            return false
        endmethod
    endstruct
    
    struct RedemptionSword extends Item
        static constant integer code = 'I090'
        static integer array bonus
        static integer array attack

        real damage = 80
        real spellPower = 60
        real criticalChance = 0.3
        real criticalDamage = 0.3

        private static method launch takes unit source, unit target, real damage returns nothing
            local real x = GetUnitX(target)
            local real y = GetUnitY(target)
            local real z = GetUnitFlyHeight(target) + 60
            local real a = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local LightWave missile = LightWave.create(x, y, z, x + 600*Cos(a), y + 600*Sin(a), z)

            set missile.source = source
            set missile.damage = damage
            set missile.model = "BladeBeamFinal.mdx"
            set missile.speed = 1200
            set missile.collision = 150
            set missile.owner = GetOwningPlayer(source)

            call missile.launch()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0080|r Damage\n+ |cffffcc0060|r Spell Power\n+ |cffffcc0030%%|r Critical Chance\n+ |cffffcc0030%%|r Critical Damage\n\n|cff00ff00Passive|r: |cffffcc00Redemption Strike|r: Every |cffffcc00fourth|r attack or |cffffcc00Critical Strike|r a light wave will travel from attacked unit postion damaging enemy units in its path for |cff00ffff" + N2S(50 + 2.5 * GetWidgetLevel(u) + 0.25 * GetUnitBonus(u, BONUS_DAMAGE), 0) + " Magic|r damage and will heal your Hero for the same amount for every units damaged."
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                call launch(source, target, bonus[GetUnitUserData(source)])
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = 50 + 2.5 * Damage.source.level + 0.25 * GetUnitBonus(Damage.source.unit, BONUS_DAMAGE)

            set bonus[Damage.source.id] = R2I(damage)

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= 4 then
                    set attack[Damage.source.id] = 0
                    call launch(Damage.source.unit, Damage.target.unit, damage)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), SphereOfDivinity.code, Doombringer.code, 0, 0, 0)
        endmethod
    endstruct
endscope