scope HolySword
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source, integer level returns real
        return 50 + (2.5 * level) + (0.25 * (BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE))) + (0.25 * GetUnitBonus(source, BONUS_SPELL_POWER))
    endfunction

    private constant function GetRange takes nothing returns real
        return 600.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 150.
    endfunction

    private constant function GetHealFactor takes nothing returns real
        return 0.5
    endfunction

    private function GetAttacSpeedBonus takes unit source returns real
        if IsUnitType(source, UNIT_TYPE_HERO) or GetWidgetLevel(source) > 6 then
            return 0.15
        else
            return 0.05

        endif
    endfunction

    private constant function GetDuration takes nothing returns real
        return 3.
    endfunction

    private constant function GetAttackCount takes nothing returns integer
        return 4
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    private struct LightWave extends Missile
        method onUnit takes unit hit returns boolean
            if IsUnitEnemy(hit, owner) and UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call AddUnitBonusTimed(source, BONUS_ATTACK_SPEED, GetAttacSpeedBonus(hit), GetDuration())

                    if HealUnit(source, source, damage * GetHealFactor(), HEALTH, false) then
                        call DestroyEffect(AddSpecialEffectTarget("HolyLight2.mdl", hit, "origin"))
                    endif
                endif
            endif

            return false
        endmethod
    endstruct
    
    struct HolySword extends Item
        static constant integer code = 'I01X'
        static integer array attack

        real damage = 50
        real spellPower = 50
        real criticalChance = 0.2
        real criticalDamage = 0.4
        real armorPenetration = 0.2

        private static method launch takes unit source, unit target returns nothing
            local real x = GetUnitX(target)
            local real y = GetUnitY(target)
            local real z = GetUnitFlyHeight(target) + 60
            local real a = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local LightWave missile = LightWave.create(x, y, z, x + 600*Cos(a), y + 600*Sin(a), z)

            set missile.source = source
            set missile.model = "BladeBeamFinal.mdx"
            set missile.speed = 1200
            set missile.collision = 150
            set missile.owner = GetOwningPlayer(source)
            set missile.damage = GetDamage(source, GetWidgetLevel(source))

            call missile.launch()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0050|r Damage\n+ |cffffcc0050|r Spell Power\n+ |cffffcc0020%|r Critical Chance\n+ |cffffcc0040%|r Critical Damage\n+ |cffffcc0020%|r Armor Penetration\n\n|cff00ff00Passive|r: |cffffcc00Redemption Strike|r: Every |cffffcc00" + N2S(GetAttackCount(), 0) + "|r attacks or |cffffcc00Critical Strike|r creates a light wave that will travel from the attacked unit position damaging enemy units in its path for |cff00ffff" + N2S(GetDamage(u, GetWidgetLevel(u)), 0) + " Magic|r damage and will heal for |cffffcc00" + N2S(GetHealFactor() * 100, 0) + "%|r of the damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Religious Fervor|r: Every enemy unit hit by |cffffcc00Redemption Strike|r grants |cffffcc005% Attack Speed|r (|cffffcc0015%|r for |cffffcc00Heroes|r and |cffffcc00High-Level|r untis) for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds."
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) and attack[GetUnitUserData(source)] < (GetAttackCount() - 1) then
                call launch(source, target)
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= GetAttackCount() then
                    set attack[Damage.source.id] = 0
                    call launch(Damage.source.unit, Damage.target.unit)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), SphereOfPower.code, OrbOfLight.code, WarriorBlade.code, GreatAxe.code, 0)
        endmethod
    endstruct
endscope