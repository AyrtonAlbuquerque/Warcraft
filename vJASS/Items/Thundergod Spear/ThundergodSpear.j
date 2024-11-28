scope ThundergodSpear
    struct ThundergodSpear extends Item
        static constant integer code = 'I07O'
        static constant integer ability = 'A00Y'
        private static boolean array fury

        real damage = 500
        real attackSpeed = 1.5
        real spellPowerFlat = 500

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00150%|r Attack Speed\n+ |cffffcc00500|r Damage\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%|r chance to release chain lightning, dealing |cff00ffff" + AbilitySpellDamageEx(500, u) + " Magical|r damage up to |cffffcc005|r nearby enemies.\n\n|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When activated |cffffcc00Thundergod Spear|r has |cffffcc00100%|r chance of creating a |cffffcc00Chain Lightning|r dealing |cff00ffff" + AbilitySpellDamageEx(2000, u) + " Magical|r damage up to |cffffcc005|r nearby enemies and drainning |cff8080ff500 Mana|r per proc.")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.source.isStructure then
                if fury[Damage.source.id] then
                    if GetUnitState(Damage.source.unit, UNIT_STATE_MANA) >= 500 then
                        call CreateChainLightning(Damage.source.unit, Damage.target.unit, 2000, 500, 0.2, 0.1, 5, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "YENL", "Psionic Shot Yellow.mdx", "chest", false)
                        call AddUnitMana(Damage.source.unit, -500)
                    else
                        set fury[Damage.source.id] = false
                        call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Damage.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNLightningFury.blp")
                    endif
                else
                    if GetRandomInt(1, 100) <= 20 then
                        call CreateChainLightning(Damage.source.unit, Damage.target.unit, 500, 500, 0.2, 0.1, 5, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "BLNL", "Shock2HD.mdx", "origin", false)
                    endif
                endif
            endif
        endmethod
        
        private static method onCast takes nothing returns nothing
            if fury[Spell.source.id] then
                set fury[Spell.source.id] = false  
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNLightningFury.blp")
            else
                set fury[Spell.source.id] = true
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNThundergod'sVigor.blp")
            endif
        endmethod

        private method onDrop takes unit u, item i returns nothing
            if GetItemTypeId(i) == code and not UnitHasItemOfType(u, code) then
                set fury[GetUnitUserData(u)] = false  
                call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNLightningFury.blp")
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call thistype.allocate(code, LightningSpear.code, SphereOfLightning.code, 0, 0, 0)
        endmethod
    endstruct
endscope