library ItemLink initializer Init requires Utilities, ItemToolTips, NewBonus, NewBonusUtils
    function LinkItem takes unit u, item i returns nothing
        local integer index   = GetUnitUserData(u)
        local integer id      = GetItemTypeId(i)
        local boolean courier = GetUnitTypeId(u) == 'n00J'

        if not courier then
            if id == 'I00A' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 25, i)
            elseif id == 'I01Y' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
            elseif id == 'I01J' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIfb\\AIfbTarget.mdl", "weapon")
            elseif id == 'I01L' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
            elseif id == 'I01X' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
            elseif id == 'I01N' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
            elseif id == 'I01V' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "SandOrb.mdl", "weapon")
            elseif id == 'I01O' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
            elseif id == 'I01W' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruption.mdl", "weapon")
            elseif id == 'I01K' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
            elseif id == 'I01M' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
            elseif id == 'I01P' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
            elseif id == 'I01A' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 24, i)
            elseif id == 'I01G' then
                call LinkBonusToItem(u, BONUS_HEALTH, 350, i)
            elseif id == 'I01Q' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
            elseif id == 'I01U' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 15, i)
                call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, 0.1, i)
            elseif id == 'I00O' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 10, i)
            elseif id == 'I00M' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 10, i)
            elseif id == 'I00Q' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 10, i)
            elseif id == 'I00Y' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
            elseif id == 'I00W' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.15, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
            elseif id == 'I009' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 150, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.15, i)
                call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, 0.15, i)
            elseif id == 'I010' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
            elseif id == 'I012' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 4, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
            elseif id == 'I014' then
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.15, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
            elseif id == 'I017' then
                call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 2, i)
            elseif id == 'I01D' then
                call LinkBonusToItem(u, BONUS_HEALTH, 225, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 3, i)
            elseif id == 'I00B' then
                call LinkBonusToItem(u, BONUS_HEALTH, 100, i)
            elseif id == 'I00L' then
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 2, i)
            elseif id == 'I00J' then
                call LinkBonusToItem(u, BONUS_MANA, 100, i)
            elseif id == 'I00U' then
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.05, i)
            elseif id == 'I01R' then
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 10, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
            elseif id == 'I00E' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 7, i)
            elseif id == 'I00F' then
                call LinkBonusToItem(u, BONUS_ARMOR, 2, i)
            elseif id == 'I00H' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 5, i)
            elseif id == 'I00I' then
                call LinkBonusToItem(u, BONUS_AGILITY, 5, i)
            elseif id == 'I01T' then
                call LinkBonusToItem(u, BONUS_AGILITY, 5, i)
            elseif id == 'I00G' then
                call LinkBonusToItem(u, BONUS_STRENGTH, 5, i)
            elseif id == 'I00K' then
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 1, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 10, i)
            elseif id == 'I00C' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.10, i)
            elseif id == 'I00T' then
                call LinkBonusToItem(u, BONUS_HEALTH, 175, i)
                call LinkBonusToItem(u, BONUS_MANA, 175, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 3, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 3, i)
            elseif id == 'I020' then //Berserker Boots
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 15, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 35, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.1, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
            elseif id == 'I022' then
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 75, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 150, i)
                call LinkBonusToItem(u, BONUS_MANA, 150, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I02D' then
                call LinkBonusToItem(u, BONUS_AGILITY, 7, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 7, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 7, i)
            elseif id == 'I02G' then //Mage Stick
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
                call LinkBonusToItem(u, BONUS_MANA, 150, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 1.5, i)
            elseif id == 'I02J' then
                call LinkBonusToItem(u, BONUS_MANA, 175, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 3, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
            elseif id == 'I02M' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.20, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
            elseif id == 'I02P' then
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 12, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I01S' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 10, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.20, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
            elseif id == 'I024' then
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.1, i)
            elseif id == 'I027' then
                call LinkBonusToItem(u, BONUS_MANA, 350, i)
            elseif id == 'I02A' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.25, i)
            elseif id == 'I02S' then //Orcish Axe
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 12, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.30, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 28, i)
            elseif id == 'I02V' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 12, i)
            elseif id == 'I02Y' then
                call LinkBonusToItem(u, BONUS_HEALTH, 375, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 8, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I031' then
                call LinkBonusToItem(u, BONUS_HEALTH, 500, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 4, i)
            elseif id == 'I034' then
                call LinkBonusToItem(u, BONUS_STRENGTH, 7, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I037' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 9, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 9, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 9, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 9, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I03A' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.5, i)
            elseif id == 'I03D' then
                call LinkBonusToItem(u, BONUS_HEALTH, 400, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 3, i)
            elseif id == 'I03G' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 25, i)
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.05, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 8, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 275, i)
            elseif id == 'I03J' then
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.12, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
            elseif id == 'I03M' then
                call LinkBonusToItem(u, BONUS_STRENGTH, 10, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 7, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I03P' then //Chilling Axe
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 15, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.35, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 35, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
            elseif id == 'I03S' then
                call LinkBonusToItem(u, BONUS_AGILITY, 7, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
            elseif id == 'I03V' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.55, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I03Y' then
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 4, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 25, i)
                call LinkBonusToItem(u, BONUS_MANA, 250, i)
            elseif id == 'I041' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 300, i)
                call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I044' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_PERCENT, 0.1, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 150, i)
            elseif id == 'I047' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 30, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04A' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 20, i)
                call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
            elseif id == 'I04D' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04G' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 30, i)
            elseif id == 'I04H' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04K' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04N' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04Q' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
            elseif id == 'I04T' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I04W' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I050' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I052' then
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 25, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I057' then
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                call LinkBonusToItem(u, BONUS_MANA, 5000, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05A' then
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 75, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 50, i)
                call LinkBonusToItem(u, BONUS_MANA, 7500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05D' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 150, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 20000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 100, i)
                call LinkBonusToItem(u, BONUS_MANA, 15000, i)
            elseif id == 'I05E' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
            elseif id == 'I05H' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 35, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 1.75, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05K' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 1, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.30, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 650, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05N' then
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 15, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.15, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05Q' then
                call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 150, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05T' then
                call LinkBonusToItem(u, BONUS_HEALTH, 18000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 10, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05W' then
                call LinkBonusToItem(u, BONUS_HEALTH, 7500, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 100, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 100, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I05Z' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 200, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 200, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 200, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I062' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.00, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I065' then
                call LinkBonusToItem(u, BONUS_HEALTH, 12000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 8, i)
            elseif id == 'I068' then
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.025, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 150, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I06B' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
            elseif id == 'I06E' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_MANA, 5000, i)
            elseif id == 'I06H' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 200, i)
            elseif id == 'I06K' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 200, i)
            elseif id == 'I06N' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
            elseif id == 'I055' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 10, i)
            elseif id == 'I06R' then
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.3, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
            elseif id == 'I06U' then
                call LinkBonusToItem(u, BONUS_AGILITY, 250, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                //call UnitAddAttackRange(u, 100)
            elseif id == 'I06X' then
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
            elseif id == 'I070' then
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 100, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 100, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 100, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I073' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
            elseif id == 'I076' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 10, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 1, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I079' then
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07C' then
                call LinkBonusToItem(u, BONUS_MANA, 5000, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07F' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 250, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07I' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 125, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 125, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07L' then
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07O' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07R' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.05, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 300, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07U' then
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 300, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I07X' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 375, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 375, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 375, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I080' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.00, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
            elseif id == 'I083' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 2, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I086' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 250, i)
                call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 25, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.25, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I089' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
            elseif id == 'I08C' then
                call LinkBonusToItem(u, BONUS_HEALTH, 20000, i)
                call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 500, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I08F' then
                call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I08I' then
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_MANA, 20000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 350, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I08L' then
                call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 15, i)
            elseif id == 'I08O' then
                call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_PERCENT, 0.2, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I08R' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 25, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 2.5, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I08U' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 250, i)
            elseif id == 'I08X' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1000, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I090' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 30, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 300, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I093' then
                call LinkBonusToItem(u, BONUS_HEALTH, 30000, i)
                call LinkBonusToItem(u, BONUS_MANA, 30000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 750, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I096' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I099' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 500, i)
            elseif id == 'I09C' then
                call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I09F' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.50, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 75, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I09I' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 500, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I09L' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1250, i)
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.1, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
            elseif id == 'I09O' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 500, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
            elseif id == 'I09R' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1000, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 20000, i)
                call LinkBonusToItem(u, BONUS_MANA, 20000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 300, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 300, i)
            elseif id == 'I09U' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.00, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1750, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1250, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I09X' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 35, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3.5, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
            elseif id == 'I0A0' then
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, -30, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
            elseif id == 'I0A3' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 750, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0A6' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 2250, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 4, i)
                call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0A9' then
                call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                call LinkBonusToItem(u, BONUS_MANA, 25000, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 750, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AC' then
                call LinkBonusToItem(u, BONUS_HEALTH, 40000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 15, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AF' then
                call LinkBonusToItem(u, BONUS_HEALTH, 50000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 20, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AI' then
                call LinkBonusToItem(u, BONUS_HEALTH, 30000, i)
                call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 1000, i)
                call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
            elseif id == 'I0AL' then
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 750, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1500, i)
                call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.25, i)
                call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                call LinkBonusToItem(u, BONUS_MANA, 15000, i)
            elseif id == 'I0AO' then
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 2000, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AR' then
                call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.50, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1500, i)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AU' then
                call LinkBonusToItem(u, BONUS_STRENGTH, 1000, i)
                call LinkBonusToItem(u, BONUS_INTELLIGENCE, 1000, i)
                call LinkBonusToItem(u, BONUS_AGILITY, 1000, i)
                call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 2000, i)
            elseif id == 'I0AV' then
                call LinkBonusToItem(u, BONUS_HEALTH, 50000, i)
                call LinkBonusToItem(u, BONUS_ARMOR, 50, i)
            elseif id == 'I0AY' then
                call LinkBonusToItem(u, BONUS_DAMAGE, 2500, i)
                call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) - 0.5, 0)
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            elseif id == 'I0AZ' then
                if not IsIllusion[index] then
                    call UpdateItemToolTip(u, i)
                endif
            endif
        endif
    endfunction

    private struct Item extends array
        static hashtable table = InitHashtable()

        static method hasItem takes unit u, integer id returns integer
            return LoadInteger(table, GetHandleId(u), id)
        endmethod

        static method onPickUp takes unit u, integer id returns nothing
            call SaveInteger(table, GetHandleId(u), id, LoadInteger(table, GetHandleId(u), id) + 1)
        endmethod

        static method onDrop takes nothing returns nothing
            local unit    u  = GetManipulatingUnit()
            local item    i  = GetManipulatedItem()
            local integer id = GetItemTypeId(i)

            call SaveInteger(table, GetHandleId(u), id, LoadInteger(table, GetHandleId(u), id) - 1)

            set u = null
            set i = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    function RegisterPickUp takes unit u, integer id returns nothing
        call Item.onPickUp(u, id)
    endfunction

    function UnitHasItemOfType takes unit u, integer id returns integer
        return Item.hasItem(u, id)
    endfunction

    private function OnPickUp takes nothing returns nothing
        local unit u = GetManipulatingUnit()
        local item i = GetManipulatedItem()

        call Item.onPickUp(u, GetItemTypeId(i))
        call LinkItem(u, i)

        set u = null
        set i = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddCondition(t, function OnPickUp)
    endfunction
endlibrary