scope ThundergodSpear
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source, integer level returns real
        return 100 + (10. * level) + ((0.05 * level) * ((BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE)))) + (0.025 * level * GetUnitBonus(source, BONUS_SPELL_POWER))
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 500.
    endfunction

    private constant function GetBounces takes nothing returns integer
        return 5
    endfunction

    private constant function GetManaCost takes nothing returns real
        return 100.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ThundergodSpear extends Item
        static constant integer code = 'I024'
        static constant integer ability = 'A00C'
        private static boolean array active

        real damage = 40
        real pierce = 0.3
        real spellPower = 40
        real attackSpeed = 0.5

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0040|r Damage\n+ |cffffcc0040|r Spell Power\n+ |cffffcc0030%|r True Strike\n+ |cffffcc0050%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc00" + N2S(GetChance(), 0) + "%|r chance to release a chain lightning, dealing |cff00ffff" + N2S(GetDamage(u, GetWidgetLevel(u)), 0) + " Magic|r damage up to |cffffcc00" + N2S(GetBounces(), 0) + "|r nearby enemies.\n\n|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When activated |cffffcc00Thundergod Spear|r has |cffffcc00100%|r chance of triggering |cffffcc00Chain Lightning|r but every proc drains |cff8080ff" + N2S(GetManaCost(), 0) + " Mana|r."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if active[id] then
                call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear.blp")
            else
                call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear2.blp")
            endif
        endmethod

        private method onDrop takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            set active[id] = active[id] and UnitHasItemOfType(u, code)

            call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear2.blp")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.source.isStructure then
                if active[Damage.source.id] then
                    if Damage.source.mana >= GetManaCost() then
                        call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, Damage.source.level), GetAoE(), 0.2, 0.1, GetBounces(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "YENL", "Psionic Shot Yellow.mdl", "chest", false)
                        call AddUnitMana(Damage.source.unit, -GetManaCost())
                    else
                        set active[Damage.source.id] = false
                        call SetUnitItemTypeIconPath(Damage.source.unit, code, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear2.blp")
                    endif
                else
                    if GetRandomReal(0, 100) <= GetChance() then
                        call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, Damage.source.level), GetAoE(), 0.2, 0.1, GetBounces(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "BLNL", "Shock2HD.mdx", "origin", false)
                    endif
                endif
            endif
        endmethod
        
        private static method onCast takes nothing returns nothing
            set active[Spell.source.id] = not active[Spell.source.id]

            if active[Spell.source.id] then
                call SetUnitItemTypeIconPath(Spell.source.unit, code, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear.blp")
            else
                call SetUnitItemTypeIconPath(Spell.source.unit, code, "ReplaceableTextures\\CommandButtons\\BTNThunderSpear2.blp")
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterItem(allocate(code), MageStaff.code, WarriorBlade.code, LightningSpear.code, 0, 0)
        endmethod
    endstruct
endscope