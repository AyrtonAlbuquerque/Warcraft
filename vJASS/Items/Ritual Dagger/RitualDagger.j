scope RitualDagger
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item = 'I05N'
	endmodule

    private constant function GetChance takes nothing returns real
        return 10.
    endfunction

    private constant function GetUnitMaxLevel takes nothing returns integer
        return 10
    endfunction

    private constant function GetBonusGold takes nothing returns integer
        return 100
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.15
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct RitualDagger extends Item
        implement Configuration

        real damage = 30
        real evasionChance = 15
        real lifeSteal = 0.15

        private static integer array gold

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0030|r Damage\n+ |cffffcc0015%|r Evasion\n+ |cffffcc0015%|r Life Steal\n\n|cff00ff00Passive|r: |cffffcc00Assassination|r: Every attack has |cffffcc0010%|r chance to instantly kill|cffffcc00 non-Hero|r targets and increase bounty of killed enemy by |cffffcc00100 gold|r.\n\n|cff00ff00Passive|r: |cffffcc00Sacrifice|r: When an enemy unit is assassinated by this item effect, your Hero health is recovered by |cffffcc0015%|r of the target |cffffcc00max health|r.\n\nGold Granted: |cffffcc00" + I2S(RitualDagger.gold[id]) + "|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and GetRandomReal(1,100) <= GetChance() and GetUnitLevel(Damage.target.unit) < GetUnitMaxLevel() and not Damage.target.isStructure and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, 500000.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNKNOWN, null) then
                    if not UnitAlive(Damage.target.unit) then
                        set gold[Damage.source.id] = gold[Damage.source.id] + GetBonusGold()
                        call AddPlayerGold(Damage.source.player, GetBonusGold())
                        call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(GetBonusGold())), 1.0, 255, 215, 0, 255)
                        call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + BlzGetUnitMaxHP(Damage.target.unit)*GetHealthFactor())
                        call DestroyEffect(AddSpecialEffectTarget("FatalWoundV2.mdx", Damage.target.unit, "chest"))
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope