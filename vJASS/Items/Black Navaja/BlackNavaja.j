scope BlackNavaja
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item = 'I02P'
	endmodule

    private constant function GetMaxLevel takes nothing returns integer
        return 10
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
    struct BlackNavaja extends Item
        implement Configuration

        real evasionChance = 12
        real damage = 25

        private static integer array gold

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0025|r Damage\n+ |cffffcc0010%|r Evasion\n\n|cff00ff00Passive|r: |cffffcc00Assassination:|r Every attack has |cffffcc0010%|r chance to instantly kill |cffffcc00non-Hero|r targets and increase bounty of killed enemy by |cffffcc0025 gold|r.\n\nGold Granted: |cffffcc00" + I2S(BlackNavaja.gold[id]) + "|r")
        endmethod

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and GetUnitLevel(Damage.target.unit) < GetMaxLevel() and not Damage.target.isStructure and Damage.isEnemy and GetRandomReal(1,100) <= GetChance() then    
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, 500000.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    if not UnitAlive(Damage.target.unit) then
                        set gold[Damage.source.id] = gold[Damage.source.id] + GetBonusGold()
                        call AddPlayerGold(Damage.source.player, GetBonusGold())
                        call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(GetBonusGold())), 1.0, 255, 215, 0, 255)
                    endif
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope