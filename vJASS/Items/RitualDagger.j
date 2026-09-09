scope RitualDagger
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetMaxLevel takes nothing returns integer
        return 5
    endfunction

    private constant function GetChance takes nothing returns real
        return 10.
    endfunction

    private constant function GetBonusGold takes nothing returns integer
        return 25
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct RitualDagger extends Item
        static constant integer code = 'I012'
        private static integer array gold

        // Attributes
        real damage = 15
        real evasion = 0.12
        real armorPenetrationFlat = 3

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0015|r Damage\n+ |cffffcc0012%|r Evasion\n+ |cffffcc003|r Armor Penetration\n\n|cff00ff00Passive|r: |cffffcc00Assassination:|r Every attack has |cffffcc00" + N2S(GetChance(), 0) + "%|r chance to instantly kill low level |cffffcc00non-Hero|r targets and increase their bounty by |cffffcc00" + I2S(GetBonusGold()) + " gold|r.\n\nGold Granted: |cffffcc00" + I2S(RitualDagger.gold[id]) + "|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and GetWidgetLevel(Damage.target.unit) <= GetMaxLevel() and not Damage.target.isStructure and Damage.isEnemy and GetRandomReal(0, 100) <= GetChance() then    
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, 500000.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    if not UnitAlive(Damage.target.unit) then
                        set gold[Damage.source.id] = gold[Damage.source.id] + GetBonusGold()

                        call AddPlayerGold(Damage.source.player, GetBonusGold())
                        call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(GetBonusGold())), 1.0, 255, 215, 0, 255)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), RustySword.code, RustySword.code, AssassinsDagger.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope