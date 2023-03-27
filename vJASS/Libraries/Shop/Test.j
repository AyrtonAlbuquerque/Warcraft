scope Test
    private struct Test
        static method onInit takes nothing returns nothing
            local integer shop = 'ngme'

            local integer damage
            local integer armor
            local integer strength
            local integer agility
            local integer intelligence
            local integer mana_regeneration
            local integer aura
            local integer area_of_effect
            local integer spell_power
            local integer attack_speed
            local integer magic_resistence
            local integer movement_speed
            local integer evasion

            call CreateShop(shop, 600, 0.5)

            set damage = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSteelMelee", "Damage")
            set armor = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne", "Armor")
            set strength = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower", "Strength")
            set agility =  ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility", "Agility")
            set intelligence = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence", "Intelligence")
            set mana_regeneration = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSobiMask", "Mana Regeneration")
            set aura =  ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNLionHorn", "Aura")
            set area_of_effect = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNCloakOfFlames", "Area of Effect")
            set spell_power = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNStaffOfSilence", "Spell Power")
            set attack_speed = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNGlove", "Attack Speed")
            set magic_resistence = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNRunedBracers", "Magic Resistence")
            set movement_speed = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "Movement Speed")
            set evasion = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNEvasion", "Evasion")

            call ShopAddItem(shop, 'afac', damage)
            call ItemAddComponents('afac', 'spsh', 'ajen', 'bgst', 'belv', 'bspd')

            call ShopAddItem(shop, 'spsh', armor + strength)
            call ItemAddComponents('spsh', 'cnob', 'jdrn', 0, 0, 0)

            call ShopAddItem(shop, 'ajen', damage + agility + movement_speed)
            call ItemAddComponents('ajen', 'ratc', 'rat6', 0, 0, 0)

            call ShopAddItem(shop, 'bgst', spell_power + movement_speed)
            call ItemAddComponents('bgst', 'rat9', 'clfm', 'clsd', 0, 0)

            call ShopAddItem(shop, 'belv', intelligence + aura + attack_speed + area_of_effect)
            call ItemAddComponents('belv', 'crys', 'dsum', 'rst1', 'gcel', 0)

            call ShopAddItem(shop, 'bspd', evasion + movement_speed)
            call ItemAddComponents('bspd', 'hval', 'hcun', 'rhth', 'kpin', 'lgdh')

            call ShopAddItem(shop, 'cnob', aura)
            call ItemAddComponents('cnob', 'rat9', 'rat9', 'penr', 'penr', 0)

            call ShopAddItem(shop, 'ratc', mana_regeneration)
            call ItemAddComponents('ratc', 'rat9', 'sbch', 'ciri', 0, 0)

            call ShopAddItem(shop, 'rat6', mana_regeneration + aura + damage)
            call ItemAddComponents('rat6', 'rat9', 'sbch', 'ciri', 0, 0)

            call ShopAddItem(shop, 'clfm', armor + damage)
            call ItemAddComponents('clfm', 'rat9', 'ssil', 0, 0, 0)

            call ShopAddItem(shop, 'clsd', attack_speed + mana_regeneration + aura + movement_speed)
            call ItemAddComponents('clsd', 'rat9', 'rlif', 'rag1', 0, 0)

            call ShopAddItem(shop, 'crys', evasion + spell_power + area_of_effect)
            call ItemAddComponents('crys', 'rat9', 0, 0, 0, 0)


            call ShopAddItem(shop, 'dsum', magic_resistence + damage)
            call ItemAddComponents('dsum', 'rat9', 0, 0, 0, 0)


            call ShopAddItem(shop, 'rst1', spell_power + strength)
            call ItemAddComponents('rst1', 'rat9', 0, 0, 0, 0)


            call ShopAddItem(shop, 'gcel', strength)
            call ItemAddComponents('gcel', 'rat9', 0, 0, 0, 0)


            call ShopAddItem(shop, 'rat9', attack_speed + spell_power + mana_regeneration)
            call ShopAddItem(shop, 'hval', agility)
            call ShopAddItem(shop, 'hcun', intelligence)
            call ShopAddItem(shop, 'rhth', intelligence + agility + aura)
            call ShopAddItem(shop, 'kpin', agility + strength + area_of_effect)
            call ShopAddItem(shop, 'lgdh', armor + movement_speed + evasion)
            call ShopAddItem(shop, 'rin1', attack_speed + mana_regeneration + magic_resistence)
            call ShopAddItem(shop, 'mcou', movement_speed + agility + aura)
            call ShopAddItem(shop, 'odef', aura + area_of_effect)
            call ShopAddItem(shop, 'penr', aura)
            call ShopAddItem(shop, 'pmna', area_of_effect)
            call ShopAddItem(shop, 'prvt', spell_power)
            call ShopAddItem(shop, 'rde1', evasion)
            call ShopAddItem(shop, 'rde2', mana_regeneration)
            call ShopAddItem(shop, 'rde3', attack_speed)
            call ShopAddItem(shop, 'rlif', magic_resistence)
            call ShopAddItem(shop, 'ciri', armor)
            call ShopAddItem(shop, 'brac', armor + damage + agility)
            call ShopAddItem(shop, 'sbch', damage + strength + attack_speed)
            call ShopAddItem(shop, 'rag1', damage + armor + agility + strength + mana_regeneration)
            call ShopAddItem(shop, 'rwiz', area_of_effect + evasion + magic_resistence + attack_speed)
            call ShopAddItem(shop, 'ssil', aura + damage)
            call ShopAddItem(shop, 'stel', damage + agility + movement_speed)
            call ShopAddItem(shop, 'evtl', mana_regeneration + strength + movement_speed)
            call ShopAddItem(shop, 'lhst', intelligence + armor + movement_speed)
            call ShopAddItem(shop, 'ward', armor + aura + magic_resistence)
            call ShopAddItem(shop, 'wild', intelligence + movement_speed + attack_speed)
            call ShopAddItem(shop, 'ankh', spell_power + area_of_effect)
            call ShopAddItem(shop, 'fgsk', spell_power + damage)
            call ShopAddItem(shop, 'fgdg', mana_regeneration)
            call ShopAddItem(shop, 'whwd', armor + attack_speed)
            call ShopAddItem(shop, 'hlst', damage + agility + intelligence)
            call ShopAddItem(shop, 'shar', mana_regeneration + aura + area_of_effect)
            call ShopAddItem(shop, 'infs', agility + movement_speed)
            call ShopAddItem(shop, 'mnst', attack_speed + magic_resistence)
            call ShopAddItem(shop, 'pdi2', magic_resistence + evasion + strength)
            call ShopAddItem(shop, 'pdiv', strength + armor + magic_resistence)
            call ShopAddItem(shop, 'pghe', area_of_effect + spell_power + damage)
            call ShopAddItem(shop, 'pgma', area_of_effect + agility)
            call ShopAddItem(shop, 'pnvu', armor + intelligence)
            call ShopAddItem(shop, 'pomn', movement_speed + attack_speed + strength)
            call ShopAddItem(shop, 'pres', strength + aura)
            call ShopAddItem(shop, 'fgrd', agility + movement_speed)
            call ShopAddItem(shop, 'rej3', intelligence + spell_power)
            call ShopAddItem(shop, 'sand', spell_power + strength)
            call ShopAddItem(shop, 'sres', armor + spell_power)
            call ShopAddItem(shop, 'srrc', magic_resistence + aura)
            call ShopAddItem(shop, 'sror', evasion + agility)
            call ShopAddItem(shop, 'wswd', mana_regeneration + intelligence)
            call ShopAddItem(shop, 'fgfh', strength + armor)

            call ShopAddItem(shop, 'fgrg', intelligence + mana_regeneration + aura)
            call ShopAddItem(shop, 'totw', strength + agility + intelligence)
            call ShopAddItem(shop, 'will', armor + strength + agility)
            call ShopAddItem(shop, 'wlsd', area_of_effect + spell_power + attack_speed)
            call ShopAddItem(shop, 'woms', damage + armor + strength)
            call ShopAddItem(shop, 'wshs', strength)
            call ShopAddItem(shop, 'wcyc', agility)
            call ShopAddItem(shop, 'lmbr', armor)
            call ShopAddItem(shop, 'gfor', spell_power)
            call ShopAddItem(shop, 'gomn', mana_regeneration + spell_power + attack_speed)
            call ShopAddItem(shop, 'guvi', movement_speed + evasion)
            call ShopAddItem(shop, 'gold', evasion)
            call ShopAddItem(shop, 'manh', mana_regeneration + aura + area_of_effect)
            call ShopAddItem(shop, 'rdis', attack_speed)
            call ShopAddItem(shop, 'rhe3', magic_resistence)
            call ShopAddItem(shop, 'rma2', attack_speed + magic_resistence + movement_speed)
            call ShopAddItem(shop, 'rre2', damage)
            call ShopAddItem(shop, 'rhe2', agility + intelligence)
            call ShopAddItem(shop, 'rhe1', area_of_effect)
            call ShopAddItem(shop, 'rman', aura)
            call ShopAddItem(shop, 'rreb', movement_speed)
            call ShopAddItem(shop, 'rres', aura + area_of_effect)
            call ShopAddItem(shop, 'rsps', armor + magic_resistence)
            call ShopAddItem(shop, 'rspd', damage + magic_resistence + mana_regeneration)
            call ShopAddItem(shop, 'rspl', damage + evasion + attack_speed)
            call ShopAddItem(shop, 'rwat', damage + agility)
            call ShopAddItem(shop, 'tdex', strength + evasion + magic_resistence)
            call ShopAddItem(shop, 'tdx2', armor + mana_regeneration)
            call ShopAddItem(shop, 'texp', armor + magic_resistence + agility)
            call ShopAddItem(shop, 'tint', area_of_effect + magic_resistence + armor)
            call ShopAddItem(shop, 'tin2', area_of_effect + evasion + aura)
            call ShopAddItem(shop, 'tpow', aura + strength)
            call ShopAddItem(shop, 'tstr', aura + agility)
            call ShopAddItem(shop, 'tst2', aura + intelligence)
            call ShopAddItem(shop, 'ratf', strength + magic_resistence + mana_regeneration)
            call ShopAddItem(shop, 'ckng', 0)
            call ShopAddItem(shop, 'desc', attack_speed + movement_speed + evasion)
            call ShopAddItem(shop, 'modt', spell_power + strength)
            call ShopAddItem(shop, 'ofro', damage + armor + strength + agility + intelligence + mana_regeneration + aura + area_of_effect + spell_power + attack_speed + magic_resistence + movement_speed + evasion)
            call ShopAddItem(shop, 'rde4', spell_power + agility)
            call ShopAddItem(shop, 'tkno', spell_power + agility + intelligence + movement_speed)
        endmethod
    endstruct
endscope