scope Basher
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns integer
        return 20
    endfunction

    private function GetDamage takes unit source, integer level returns real
        return 15 * level + (0.5 * (BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE)) + (1 * GetHeroStr(source, true)))
    endfunction

    private function GetDamageFactor takes unit source, integer level returns real
        return 1.
    endfunction

    private function GetAoE takes unit source, integer level returns real
        return 350.
    endfunction

    private function GetDuration takes unit source, integer level returns real
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 1.
        else
            return 2.
        endif
    endfunction

    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Basher extends Item
        static constant integer code = 'I01P'

        // Attributes
        real damage = 20
        real strength = 20
        real attackSpeed = 0.25

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0020|r Damage\n+ |cffffcc0020|r Strength\n+ |cffffcc0025%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Bash|r: Auto attacks have a |cffffcc00" + N2S(GetChance(), 0) + "%|r chance to |cffffcc00Stun|r the target for |cffffcc002|r seconds (|cffffcc001|r for |cffffcc00Heroes|r) and deal |cff00ffff" + N2S(GetDamage(u, GetWidgetLevel(u)), 0) + " Magic|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Brutality|r: |cffffcc00Melee|r attacks against |cffffcc00Stunned|r units deal |cffffcc00" + N2S(GetDamageFactor(u, GetWidgetLevel(u)) * 100, 0) + "%|r of damage dealt to nearby enemy units within |cffffcc00" + N2S(GetAoE(u, GetWidgetLevel(u)), 0) + " AoE|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            local unit u
            local group g

            if UnitHasItemOfType(Damage.source.unit, code) then
                if IsUnitStunned(Damage.target.unit) then
                    set g = CreateGroup()

                    call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, GetAoE(Damage.source.unit, Damage.source.level), null)
                    call GroupRemoveUnit(g, Damage.target.unit)

                    if BlzGroupGetSize(g) > 0 then
                        loop
                            set u = FirstOfGroup(g)
                            exitwhen u == null
                                if DamageFilter(Damage.source.player, u) then
                                    if UnitDamageTarget(Damage.source.unit, u, Damage.amount * GetDamageFactor(Damage.source.unit, Damage.source.level), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, null) then
                                        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl", u, "chest"))
                                    endif
                                endif
                            call GroupRemoveUnit(g, u)
                        endloop
                    endif

                    call DestroyGroup(g)
                endif

                if GetRandomInt(0, 100) <= GetChance() then
                    if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, Damage.source.level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        set Damage.amount = Damage.amount + GetDamage(Damage.source.unit, Damage.source.level)
                        call StunUnit(Damage.source.unit, Damage.target.unit, GetDuration(Damage.target.unit, Damage.source.level), "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl", "overhead", false)
                        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", Damage.target.unit, "origin"))
                    endif
                endif
            endif

            set g = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), GlovesOfSteel.code, EnhancedHammer.code, GoliathBelt.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope