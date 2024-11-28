scope SoulSword
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamage takes nothing returns real
        return 20.
    endfunction

    private constant function GetHeal takes nothing returns real
        return 10.
    endfunction

    private constant function GetBonus takes nothing returns real
        return 0.2
    endfunction

    private constant function GetHeroBonus takes nothing returns real
        return 2.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SoulSword extends Item
        static constant integer code = 'I041'
        readonly static real array bonus

        real damage = 20

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0020|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Soul Steal|r: Every attack heals |cff00ff00" + R2SW(GetHeal() + SoulSword.bonus[id], 1, 1) + "|r Health and deals |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) +"|r bonus |cff0080ffMagic |rdamage. Killing an enemy unit, increases the on attack heal by |cffffcc000.2|r. Hero kills increases on attack heal by |cffffcc002|r.")
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                call UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (GetHeal() + bonus[Damage.source.id])))
                call ArcingTextTag.create(("|cff32cd32" + "+" + I2S(R2I(GetHeal() + bonus[Damage.source.id]))), Damage.source.unit)
                call DestroyEffect(AddSpecialEffectTarget("SpellVampTarget.mdx", Damage.source.unit, "origin"))
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed = GetTriggerUnit()
            local integer i  = GetUnitUserData(killer)

            if UnitHasItemOfType(killer, code) then
                if IsUnitType(killed, UNIT_TYPE_HERO) then
                    set bonus[i] = bonus[i] + GetHeroBonus()
                else
                    set bonus[i] = bonus[i] + GetBonus()
                endif
            endif

            set killer = null
            set killed = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, OrbOfSouls.code, GoldenSword.code, 0, 0, 0)
        endmethod
    endstruct
endscope