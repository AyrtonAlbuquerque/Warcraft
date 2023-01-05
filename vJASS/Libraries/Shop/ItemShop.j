library ItemShop initializer Init requires TasItemShop
    struct Shop
        static constant integer unit = 'n000'
        static constant integer base = 'h006'

        /* ---------------------------------- Items --------------------------------- */
        static constant integer Boots_of_Speed              = 'I00A'
        static constant integer Ankh_of_Reincarnation       = 'I00N'
        static constant integer Potion_of_Restoration       = 'I00P'
        static constant integer Mask_of_Death               = 'I00U'
        static constant integer Cloak_of_Flames             = 'I00V'
        static constant integer Commom_Shield               = 'I016'
        static constant integer Heavy_Hammer                = 'I01Q'
        static constant integer Assassins_Dagger            = 'I01R'
        static constant integer Iron_Axe                    = 'I01S'
        static constant integer Simple_Bow                  = 'I01T'
        static constant integer Summoning_Book              = 'I01U'
        static constant integer Courier                     = 'I01Z'
        static constant integer Life_Crystal                = 'I00B'
        static constant integer Mana_Crystal                = 'I00J'
        static constant integer Life_Essence_Crystal        = 'I00L'
        static constant integer Crystal_Ring                = 'I00K'
        static constant integer Homecoming_Stone            = 'I00D'
        static constant integer Bracelet_of_Intelligence    = 'I00H'
        static constant integer Claws_of_Agility            = 'I00I'
        static constant integer Gauntlet_of_Strength        = 'I00G'
        static constant integer Gloves_of_Haste             = 'I00C'
        static constant integer Platemail                   = 'I00F'
        static constant integer Rusty_Sword                 = 'I00E'
        static constant integer Orb_of_Fire                 = 'I01J'
        static constant integer Orb_of_Frost                = 'I01L'
        static constant integer Orb_of_Light                = 'I01X'
        static constant integer Orb_of_Lightning            = 'I01N'
        static constant integer Orb_of_Sands                = 'I01V'
        static constant integer Orb_of_Souls                = 'I01O'
        static constant integer Orb_of_Thorns               = 'I01W'
        static constant integer Orb_of_Venom                = 'I01K'
        static constant integer Orb_of_Water                = 'I01M'
        static constant integer Orb_of_Wind                 = 'I01P'
        static constant integer Orb_of_Darkness             = 'I01Y'
        static constant integer Boots_of_the_Braves         = 'I009'
        static constant integer Boots_of_Agility            = 'I00O'
        static constant integer Boots_of_Intelligence       = 'I00Q'
        static constant integer Boots_of_Strength           = 'I00M'
        static constant integer Boots_of_Restoration        = 'I00Y'
        static constant integer Boots_of_Flames             = 'I010'
        static constant integer Golden_Boots                = 'I014'
        static constant integer Heavy_Boots                 = 'I00W'
        static constant integer Silver_Boots                = 'I012'
        static constant integer Berserker_Boots             = 'I020'
        static constant integer Runic_Boots                 = 'I022'
        static constant integer Golden_Sword                = 'I01A'
        static constant integer Golden_Platemail            = 'I01D'
        static constant integer Fused_Life_Crystals         = 'I01G'
        static constant integer Infused_Mana_Crystal        = 'I027'
        static constant integer Elemental_Shard             = 'I00T'
        static constant integer Hardened_Shield             = 'I017'
        static constant integer Mask_of_Madness             = 'I024'
        static constant integer Gloves_of_Speed             = 'I02A'
        static constant integer Glaive_Scythe               = 'I02D'
        static constant integer Mage_Stick                  = 'I02G'
        static constant integer Sorcerer_Ring               = 'I02J'
        static constant integer Warrior_Blade               = 'I02M'
        static constant integer Black_Navaja                = 'I02P'
        static constant integer Orcish_Axe                  = 'I02S'
        static constant integer Enhanced_Hammer             = 'I02V'
        static constant integer Emerald_Shoulder_Plate      = 'I02Y'
        static constant integer Steel_Armor                 = 'I031'
        static constant integer Warrior_Helmet              = 'I034'
        static constant integer Soul_Scyther                = 'I037'
        static constant integer Gloves_of_Silver            = 'I03A'
        static constant integer Warrior_Shield              = 'I03D'
        static constant integer Mage_Staff                  = 'I03G'
        static constant integer Demonic_Mask                = 'I03J'
        static constant integer Magma_Helmet                = 'I03M'
        static constant integer Chilling_Axe                = 'I03P'
        static constant integer Holy_Bow                    = 'I03S'
        static constant integer Lightning_Spear             = 'I03V'
        static constant integer Desert_Ring                 = 'I03Y'
        static constant integer Soul_Sword                  = 'I041'
        static constant integer Nature_Staff                = 'I044'
        static constant integer Toxic_Dagger                = 'I047'
        static constant integer Oceanic_Mace                = 'I04A'
        static constant integer Wind_Sword                  = 'I04D'
        static constant integer Sphere_of_Power             = 'I04G'
        static constant integer Sphere_of_Fire              = 'I04H'
        static constant integer Sphere_of_Water             = 'I04K'
        static constant integer Sphere_of_Nature            = 'I04N'
        static constant integer Sphere_of_Divinity          = 'I04Q'
        static constant integer Sphere_of_Lightning         = 'I04T'
        static constant integer Sphere_of_Darkness          = 'I04W'
        static constant integer Sphere_of_Air               = 'I050'
        static constant integer Eternity_Stone              = 'I052'
        static constant integer Fusion_Crystal              = 'I057'
        static constant integer Wizard_Stone                = 'I05A'
        static constant integer Knight_Blade                = 'I05K'
        static constant integer Ritual_Dagger               = 'I05N'
        static constant integer Giants_Hammer               = 'I05E'
        static constant integer Axe_of_the_Greedy           = 'I05H'
        static constant integer Saphire_Shoulder_Plate      = 'I05Q'
        static constant integer Flaming_Armor               = 'I05T'
        static constant integer Dragon_Helmet               = 'I05W'
        static constant integer Reapers_Edge                = 'I05Z'
        static constant integer Gloves_of_Gold              = 'I062'
        static constant integer Commanders_Shield           = 'I065'
        static constant integer Sorcerer_Staff              = 'I068'
        static constant integer Book_of_Flames              = 'I06B'
        static constant integer Book_of_Oceans              = 'I06E'
        static constant integer Book_of_Nature              = 'I06H'
        static constant integer Book_of_Light               = 'I06K'
        static constant integer Book_of_Chaos               = 'I06N'
        static constant integer Book_of_Ice                 = 'I055'
        static constant integer Hellish_Mask                = 'I06R'
        static constant integer Enflamed_Bow                = 'I06U'
        static constant integer Ring_of_Conversion          = 'I06X'
        static constant integer Ancient_Stone               = 'I05D'
        static constant integer Ancient_Sphere              = 'I070'
        static constant integer Legendary_Blade_I           = 'I073'
        static constant integer Triedge_Sword               = 'I076'
        static constant integer Crown_of_Righteousness      = 'I079'
        static constant integer Heating_Cloak               = 'I07C'
        static constant integer Hammer_of_Nature            = 'I07F'
        static constant integer Elemental_Spin              = 'I07I'
        static constant integer Necklace_of_Vigor           = 'I07L'
        static constant integer Thundergod_Spear            = 'I07O'
        static constant integer Wizard_Staff                = 'I07R'
        static constant integer Philosophers_Stone          = 'I07U'
        static constant integer Entity_Scythe               = 'I07X'
        static constant integer Legendary_Blade_II          = 'I080'
        static constant integer Doombringer                 = 'I083'
        static constant integer Dual_Elemental_Dagger       = 'I086'
        static constant integer Apocalyptic_Mask            = 'I089'
        static constant integer Radiant_Helmet              = 'I08C'
        static constant integer Jaden_Shoulder_Plate        = 'I08F'
        static constant integer Moonchant_Ring              = 'I08I'
        static constant integer Bloodbourne_Shield          = 'I08L'
        static constant integer Nature_Goddess_Staff        = 'I08O'
        static constant integer Phoenix_Axe                 = 'I08R'
        static constant integer Weaver_I                    = 'I08U'
        static constant integer Legendary_Blade_III         = 'I08X'
        static constant integer Redemption_Sword            = 'I090'
        static constant integer Elemental_Stone             = 'I093'
        static constant integer Sapphire_Hammer             = 'I096'
        static constant integer Fire_Bow                    = 'I099'
        static constant integer Warlock_Ring                = 'I09C'
        static constant integer Twin_Phantom_Spear          = 'I09F'
        static constant integer Red_Moon_Scyth              = 'I09I'
        static constant integer Holy_Scepter                = 'I09L'
        static constant integer Magus_Orb                   = 'I09O'
        static constant integer Weaver_II                   = 'I09R'
        static constant integer Legendary_Blade_IV          = 'I09U'
        static constant integer Sword_of_Domination         = 'I09X'
        static constant integer Arc_Trinity                 = 'I0A0'
        static constant integer Holy_Hammer                 = 'I0A3'
        static constant integer Gluttonous_Axe              = 'I0A6'
        static constant integer Crown_of_Gods               = 'I0A9'
        static constant integer Black_Armor                 = 'I0AC'
        static constant integer Angelic_Shield              = 'I0AF'
        static constant integer Helmet_of_Eternity          = 'I0AI'
        static constant integer Arcana_Scepter              = 'I0AL'
        static constant integer Elemental_Sphere            = 'I0AO'
        static constant integer Legendary_Blade_V           = 'I0AR'
        /* ----------------------------------- END ---------------------------------- */

        static method create takes nothing returns thistype
            local integer damage       = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNSteelMelee", "Damage")
            local integer armor        = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne", "Armor")
            local integer strength     = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower", "Strength")
            local integer agility      = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility", "Agility")
            local integer intelligence = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence", "Intelligence")
            local integer health       = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNFireCrystalElement", "Health")
            local integer hpRegen      = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNRegenerate", "Health Regeneration")
            local integer mana         = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNItem_Gem_Aquamarine.blp", "Mana")
            local integer manaRegen    = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNSobiMask", "Mana Regeneration")
            local integer orb          = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNOrbOfTheSun.blp", "Orb")
            local integer aura         = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNLionHorn", "Aura")
            local integer aoe          = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNCloakOfFlames.blp", "Area of Effect")
            local integer active       = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNStaffOfSilence", "Active")
            local integer spellPower   = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNControlMagic", "Spell Power")
            local integer cooldown     = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNMoonStone.blp", "Cooldown")
            local integer attackSpeed  = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNGlove.blp", "Attack Speed")
            local integer magicRes     = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNRunedBracers", "Magic Resistence")
            local integer consumable   = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall", "Consumable")
            local integer movement     = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "Movement")
            local integer critical     = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNCriticalStrike", "Critical")
            local integer lifeSteal    = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNVampiricAura", "Life Steal")
            local integer spellVamp    = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNIceShard.blp", "Spell Vamp")
            local integer evasion      = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNEvasion", "Evasion")
            local integer dot          = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNWallOfFire.blp", "Damage Over Time")
            local integer summoning    = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNAmuletOftheWild.blp", "Summoning")
            local integer courier      = TasItemShopAddCategory("ReplaceableTextures\\CommandButtons\\BTNChickenCritter.blp", "Courier")

            // Boots of Speed
            call TasItemShopAdd(Boots_of_Speed, movement)
            // Ankh of Reincarnation
            call TasItemShopAdd(Ankh_of_Reincarnation, consumable)
            // Potion of Restoration
            call TasItemShopAdd(Potion_of_Restoration, consumable + active)
            // Mask of Death
            call TasItemShopAdd(Mask_of_Death, lifeSteal)
            // Cloak of Flames
            call TasItemShopAdd(Cloak_of_Flames, aoe)
            // Commom Shield
            call TasItemShopAdd(Commom_Shield, armor)
            // Heavy Hammer
            call TasItemShopAdd(Heavy_Hammer, damage + aoe)
            // Assassin Dagger
            call TasItemShopAdd(Assassins_Dagger, damage + evasion)
            // Iron Axe
            call TasItemShopAdd(Iron_Axe, damage + critical)
            // Simple Bow
            call TasItemShopAdd(Simple_Bow, agility + aoe)
            // Summoning Book
            call TasItemShopAdd(Summoning_Book, active + summoning + spellPower + cooldown)
            // Courier
            call TasItemShopAdd(Courier, courier)
            // Life Crystal
            call TasItemShopAdd(Life_Crystal, health)
            // Mana Crystal
            call TasItemShopAdd(Mana_Crystal, mana)
            // Life Essence Crystal
            call TasItemShopAdd(Life_Essence_Crystal, hpRegen)
            // Crystal Ring
            call TasItemShopAdd(Crystal_Ring, manaRegen + spellPower)
            // Homecoming Stone
            call TasItemShopAdd(Homecoming_Stone, movement + active)
            // Bracelet of Intelligence
            call TasItemShopAdd(Bracelet_of_Intelligence, intelligence)
            // Claws of Agility
            call TasItemShopAdd(Claws_of_Agility, agility)
            // Gauntlet of Strength
            call TasItemShopAdd(Gauntlet_of_Strength, strength)
            // Gloves of Haste
            call TasItemShopAdd(Gloves_of_Haste, attackSpeed)
            // Platemail
            call TasItemShopAdd(Platemail, armor)
            // Rusty Sword
            call TasItemShopAdd(Rusty_Sword, damage)
            // Orb of Fire
            call TasItemShopAdd(Orb_of_Fire, damage + orb + aoe)
            // Orb of Frost
            call TasItemShopAdd(Orb_of_Frost, damage + orb)
            // Orb of Light
            call TasItemShopAdd(Orb_of_Light, damage + orb)
            // Orb of Lightning
            call TasItemShopAdd(Orb_of_Lightning, damage + orb)
            // Orb of Sands
            call TasItemShopAdd(Orb_of_Sands, damage + orb)
            // Orb of Souls
            call TasItemShopAdd(Orb_of_Souls, damage + orb + lifeSteal)
            // Orb of Thorns
            call TasItemShopAdd(Orb_of_Thorns, damage + orb)
            // Orb of Venom
            call TasItemShopAdd(Orb_of_Venom, damage + orb + dot)
            // Orb of Waters
            call TasItemShopAdd(Orb_of_Water, damage + orb + aoe)
            // Orb of Wind
            call TasItemShopAdd(Orb_of_Wind, damage + orb + movement)
            // Orb of Darkness
            call TasItemShopAdd(Orb_of_Darkness, damage + orb)
            // Sphere of Power
            call TasItemShopAdd(Sphere_of_Power, spellPower)
            // Boots of the Braves
            call TasItemShopAdd(Boots_of_the_Braves, movement + active + health + attackSpeed + cooldown)
            call TasItemFusionAdd4(Boots_of_the_Braves, Boots_of_Speed, Homecoming_Stone, Gloves_of_Haste, Life_Crystal)
            // Boots of Agility
            call TasItemShopAdd(Boots_of_Agility, movement + active + agility)
            call TasItemFusionAdd3(Boots_of_Agility, Boots_of_Speed, Claws_of_Agility, Homecoming_Stone)
            // Boots of Intelligence
            call TasItemShopAdd(Boots_of_Intelligence, movement + active + intelligence)
            call TasItemFusionAdd3(Boots_of_Intelligence, Boots_of_Speed, Bracelet_of_Intelligence, Homecoming_Stone)
            // Boots of Strength
            call TasItemShopAdd(Boots_of_Strength, movement + active + strength)
            call TasItemFusionAdd3(Boots_of_Strength, Boots_of_Speed, Gauntlet_of_Strength, Homecoming_Stone)
            // Boots of Restoration
            call TasItemShopAdd(Boots_of_Restoration, movement + active + hpRegen + health)
            call TasItemFusionAdd4(Boots_of_Restoration, Boots_of_Speed, Life_Crystal, Homecoming_Stone, Life_Essence_Crystal)
            // Boots of Flames
            call TasItemShopAdd(Boots_of_Flames, movement + active + aoe + damage)
            call TasItemFusionAdd3(Boots_of_Flames, Boots_of_Speed, Homecoming_Stone, Cloak_of_Flames)
            // Golden Boots
            call TasItemShopAdd(Golden_Boots, movement + active + lifeSteal + damage)
            call TasItemFusionAdd4(Golden_Boots, Boots_of_Speed, Homecoming_Stone, Rusty_Sword, Mask_of_Death)
            // Heavy Boots
            call TasItemShopAdd(Heavy_Boots, movement + active + attackSpeed + damage)
            call TasItemFusionAdd4(Heavy_Boots, Boots_of_Speed, Homecoming_Stone, Rusty_Sword, Gloves_of_Haste)
            // Silver Boots
            call TasItemShopAdd(Silver_Boots, movement + active + armor + health)
            call TasItemFusionAdd4(Silver_Boots, Boots_of_Speed, Homecoming_Stone, Platemail, Life_Crystal)
            // Berserker Boots
            call TasItemShopAdd(Berserker_Boots, movement + active + attackSpeed + damage + evasion)
            call TasItemFusionAdd4(Berserker_Boots, Boots_of_Speed, Gloves_of_Haste, Gloves_of_Haste, Assassins_Dagger)
            // Runic Boots
            call TasItemShopAdd(Runic_Boots, movement + active + health + mana + spellPower)
            call TasItemFusionAdd3(Runic_Boots, Boots_of_Speed, Life_Crystal, Mana_Crystal)
            // Golden Sword
            call TasItemShopAdd(Golden_Sword, damage)
            call TasItemFusionAdd3(Golden_Sword, Rusty_Sword, Rusty_Sword, Rusty_Sword)
            // Golden Platemail
            call TasItemShopAdd(Golden_Platemail, armor + health)
            call TasItemFusionAdd3(Golden_Platemail, Life_Crystal, Platemail, Platemail)
            // Fused Life Crystals
            call TasItemShopAdd(Fused_Life_Crystals, health)
            call TasItemFusionAdd3(Fused_Life_Crystals, Life_Crystal, Life_Crystal, Life_Crystal)
            // Infused Mana Crystal
            call TasItemShopAdd(Infused_Mana_Crystal, mana)
            call TasItemFusionAdd3(Infused_Mana_Crystal, Mana_Crystal, Mana_Crystal, Mana_Crystal)
            // Elemental Shard
            call TasItemShopAdd(Elemental_Shard, health + mana + hpRegen + manaRegen)
            call TasItemFusionAdd4(Elemental_Shard, Life_Crystal, Mana_Crystal, Life_Essence_Crystal, Crystal_Ring)
            // Hardened Shield
            call TasItemShopAdd(Hardened_Shield, health + armor)
            call TasItemFusionAdd3(Hardened_Shield, Commom_Shield, Life_Crystal, Platemail)
            // Mask of Madness
            call TasItemShopAdd(Mask_of_Madness, lifeSteal)
            call TasItemFusionAdd(Mask_of_Madness, Mask_of_Death)
            // Gloves of Speed
            call TasItemShopAdd(Gloves_of_Speed, attackSpeed)
            call TasItemFusionAdd2(Gloves_of_Speed, Gloves_of_Haste, Gloves_of_Haste)
            // Glaive Scythe
            call TasItemShopAdd(Glaive_Scythe, agility + strength + intelligence)
            call TasItemFusionAdd3(Glaive_Scythe, Bracelet_of_Intelligence, Gauntlet_of_Strength, Claws_of_Agility)
            // Mage Stick
            call TasItemShopAdd(Mage_Stick, spellPower + mana + manaRegen)
            call TasItemFusionAdd3(Mage_Stick, Mana_Crystal, Mana_Crystal, Crystal_Ring)
            // Sorcerer Ring
            call TasItemShopAdd(Sorcerer_Ring, mana + manaRegen + spellPower)
            call TasItemFusionAdd3(Sorcerer_Ring, Mana_Crystal, Crystal_Ring, Crystal_Ring)
            // Warrior Blade
            call TasItemShopAdd(Warrior_Blade, damage + attackSpeed)
            call TasItemFusionAdd2(Warrior_Blade, Golden_Sword, Gloves_of_Haste)
            // Black Navaja
            call TasItemShopAdd(Black_Navaja, damage + evasion)
            call TasItemFusionAdd3(Black_Navaja, Rusty_Sword, Rusty_Sword, Assassins_Dagger)
            // Orcish Axe
            call TasItemShopAdd(Orcish_Axe, damage + critical)
            call TasItemFusionAdd2(Orcish_Axe, Iron_Axe, Golden_Sword)
            // Enhanced Hammer
            call TasItemShopAdd(Enhanced_Hammer, damage + aoe)
            call TasItemFusionAdd3(Enhanced_Hammer, Rusty_Sword, Heavy_Hammer, Heavy_Hammer)
            // Emerald Shoulder Plate
            call TasItemShopAdd(Emerald_Shoulder_Plate, health + strength)
            call TasItemFusionAdd3(Emerald_Shoulder_Plate, Gauntlet_of_Strength, Gauntlet_of_Strength, Fused_Life_Crystals)
            // Steel Armor
            call TasItemShopAdd(Steel_Armor, health + armor)
            call TasItemFusionAdd2(Steel_Armor, Fused_Life_Crystals, Golden_Platemail)
            // Warrior Helmet
            call TasItemShopAdd(Warrior_Helmet, strength + hpRegen)
            call TasItemFusionAdd3(Warrior_Helmet, Gauntlet_of_Strength, Life_Essence_Crystal, Life_Essence_Crystal)
            // Soul Scyther
            call TasItemShopAdd(Soul_Scyther, damage + strength + agility + intelligence)
            call TasItemFusionAdd2(Soul_Scyther, Rusty_Sword, Glaive_Scythe)
            // Gloves of Silver
            call TasItemShopAdd(Gloves_of_Silver, attackSpeed)
            call TasItemFusionAdd2(Gloves_of_Silver, Gloves_of_Speed, Gloves_of_Speed)
            // Warrior Shield
            call TasItemShopAdd(Warrior_Shield, health + armor)
            call TasItemFusionAdd3(Warrior_Shield, Fused_Life_Crystals, Golden_Platemail, Hardened_Shield)
            // Mage Staff
            call TasItemShopAdd(Mage_Staff, spellPower + intelligence + health + spellVamp)
            call TasItemFusionAdd3(Mage_Staff, Bracelet_of_Intelligence, Fused_Life_Crystals, Mage_Stick)
            // Demonic Mask
            call TasItemShopAdd(Demonic_Mask, damage + lifeSteal)
            call TasItemFusionAdd3(Demonic_Mask, Orb_of_Darkness, Mask_of_Madness, Golden_Sword)
            // Magma Helmet
            call TasItemShopAdd(Magma_Helmet, strength + hpRegen)
            call TasItemFusionAdd2(Magma_Helmet, Orb_of_Fire, Warrior_Helmet)
            // Chilling Axe
            call TasItemShopAdd(Chilling_Axe, damage + critical)
            call TasItemFusionAdd2(Chilling_Axe, Orb_of_Frost, Orcish_Axe)
            // Holy Bow
            call TasItemShopAdd(Holy_Bow, damage + agility + aoe)
            call TasItemFusionAdd2(Holy_Bow, Orb_of_Light, Simple_Bow)
            // Lightning Spear
            call TasItemShopAdd(Lightning_Spear, damage + attackSpeed)
            call TasItemFusionAdd2(Lightning_Spear, Orb_of_Lightning, Gloves_of_Silver)
            // Desert Ring
            call TasItemShopAdd(Desert_Ring, mana + manaRegen + spellPower)
            call TasItemFusionAdd2(Desert_Ring, Orb_of_Sands, Sorcerer_Ring)
            // Soul Sword
            call TasItemShopAdd(Soul_Sword, damage + lifeSteal)
            call TasItemFusionAdd2(Soul_Sword, Orb_of_Souls, Golden_Sword)
            // Nature Staff
            call TasItemShopAdd(Nature_Staff, spellPower + intelligence + health + active)
            call TasItemFusionAdd2(Nature_Staff, Orb_of_Thorns, Mage_Staff)
            // Toxic Dagger
            call TasItemShopAdd(Toxic_Dagger, damage + dot)
            call TasItemFusionAdd2(Toxic_Dagger, Orb_of_Venom, Golden_Sword)
            // Oceanic Mace
            call TasItemShopAdd(Oceanic_Mace, damage + aoe)
            call TasItemFusionAdd2(Oceanic_Mace, Orb_of_Water, Enhanced_Hammer)
            // Wind Sword
            call TasItemShopAdd(Wind_Sword, damage + movement)
            call TasItemFusionAdd2(Wind_Sword, Orb_of_Wind, Golden_Sword)
            // Sphere of Fire
            call TasItemShopAdd(Sphere_of_Fire, spellPower)
            call TasItemFusionAdd2(Sphere_of_Fire, Orb_of_Fire, Sphere_of_Power)
            // Sphere of Water
            call TasItemShopAdd(Sphere_of_Water, spellPower)
            call TasItemFusionAdd2(Sphere_of_Water, Orb_of_Water, Sphere_of_Power)
            // Sphere of Nature
            call TasItemShopAdd(Sphere_of_Nature, spellPower)
            call TasItemFusionAdd2(Sphere_of_Nature, Orb_of_Thorns, Sphere_of_Power)
            // Sphere of Divinity
            call TasItemShopAdd(Sphere_of_Divinity, spellPower)
            call TasItemFusionAdd2(Sphere_of_Divinity, Orb_of_Light, Sphere_of_Power)
            // Sphere of Lightning
            call TasItemShopAdd(Sphere_of_Lightning, spellPower)
            call TasItemFusionAdd2(Sphere_of_Lightning, Orb_of_Lightning, Sphere_of_Power)
            // Sphere of Darkness
            call TasItemShopAdd(Sphere_of_Darkness, spellPower)
            call TasItemFusionAdd2(Sphere_of_Darkness, Orb_of_Darkness, Sphere_of_Power)
            // Sphere of Air
            call TasItemShopAdd(Sphere_of_Air, spellPower)
            call TasItemFusionAdd2(Sphere_of_Air, Orb_of_Wind, Sphere_of_Power)
            // Eternity Stone
            call TasItemShopAdd(Eternity_Stone, health + hpRegen)
            call TasItemFusionAdd2(Eternity_Stone, Fused_Life_Crystals, Life_Essence_Crystal)
            // Fusion Crystal
            call TasItemShopAdd(Fusion_Crystal, health + mana + hpRegen + manaRegen + active)
            call TasItemFusionAdd2(Fusion_Crystal, Fused_Life_Crystals, Infused_Mana_Crystal)
            // Wizard Stone
            call TasItemShopAdd(Wizard_Stone, health + mana + hpRegen + manaRegen)
            call TasItemFusionAdd(Wizard_Stone, Elemental_Shard)
            // Ancient Stone
            call TasItemShopAdd(Ancient_Stone, health + mana + manaRegen + hpRegen + spellPower)
            call TasItemFusionAdd(Ancient_Stone, Wizard_Stone)
            // Knight Blade
            call TasItemShopAdd(Knight_Blade, damage + critical + attackSpeed)
            call TasItemFusionAdd2(Knight_Blade, Warrior_Blade, Orcish_Axe)
            // Ritual Dagger
            call TasItemShopAdd(Ritual_Dagger, damage + evasion + lifeSteal)
            call TasItemFusionAdd2(Ritual_Dagger, Black_Navaja, Mask_of_Madness)
            // Giants Hammer
            call TasItemShopAdd(Giants_Hammer, damage + aoe)
            call TasItemFusionAdd(Giants_Hammer, Oceanic_Mace)
            // Axe of the Greedy
            call TasItemShopAdd(Axe_of_the_Greedy, damage + critical)
            call TasItemFusionAdd2(Axe_of_the_Greedy, Orcish_Axe, Orcish_Axe)
            // Saphire Shoulder Plate
            call TasItemShopAdd(Saphire_Shoulder_Plate, health + strength)
            call TasItemFusionAdd2(Saphire_Shoulder_Plate, Fused_Life_Crystals, Emerald_Shoulder_Plate)
            // Flaming Armor
            call TasItemShopAdd(Flaming_Armor, health + armor)
            call TasItemFusionAdd3(Flaming_Armor, Cloak_of_Flames, Fused_Life_Crystals, Steel_Armor)
            // Dragon Helmet
            call TasItemShopAdd(Dragon_Helmet, health + strength + hpRegen + active)
            call TasItemFusionAdd2(Dragon_Helmet, Warrior_Helmet, Eternity_Stone)
            // Reapers Edge
            call TasItemShopAdd(Reapers_Edge, spellPower + strength + agility + intelligence)
            call TasItemFusionAdd2(Reapers_Edge, Soul_Scyther, Sphere_of_Power)
            // Gloves of Gold
            call TasItemShopAdd(Gloves_of_Gold, attackSpeed)
            call TasItemFusionAdd2(Gloves_of_Gold, Gloves_of_Silver, Gloves_of_Silver)
            // Commanders Shield
            call TasItemShopAdd(Commanders_Shield, armor + health)
            call TasItemFusionAdd2(Commanders_Shield, Fused_Life_Crystals, Warrior_Shield)
            // Sorcerer Staff
            call TasItemShopAdd(Sorcerer_Staff, spellPower + health + intelligence + spellVamp)
            call TasItemFusionAdd2(Sorcerer_Staff, Mage_Staff, Sphere_of_Power)
            // Book of Flames
            call TasItemShopAdd(Book_of_Flames, spellPower + damage + intelligence + summoning + active)
            call TasItemFusionAdd2(Book_of_Flames, Summoning_Book, Sphere_of_Fire)
            // Book of Oceans
            call TasItemShopAdd(Book_of_Oceans, spellPower + intelligence + mana + summoning + active)
            call TasItemFusionAdd2(Book_of_Oceans, Summoning_Book, Sphere_of_Water)
            // Book of Nature
            call TasItemShopAdd(Book_of_Nature, spellPower + intelligence + hpRegen + summoning + active)
            call TasItemFusionAdd2(Book_of_Nature, Summoning_Book, Sphere_of_Nature)
            // Book of Light
            call TasItemShopAdd(Book_of_Light, spellPower + intelligence + manaRegen + summoning + active)
            call TasItemFusionAdd2(Book_of_Light, Summoning_Book, Sphere_of_Divinity)
            // Book of Chaos
            call TasItemShopAdd(Book_of_Chaos, spellPower + intelligence + health + summoning + active)
            call TasItemFusionAdd2(Book_of_Chaos, Summoning_Book, Sphere_of_Darkness)
            // Book of Ice
            call TasItemShopAdd(Book_of_Ice, spellPower + intelligence + armor + summoning + active)
            call TasItemFusionAdd2(Book_of_Ice, Summoning_Book, Sphere_of_Air)
            // Hellish Mask
            call TasItemShopAdd(Hellish_Mask, damage + lifeSteal)
            call TasItemFusionAdd2(Hellish_Mask, Demonic_Mask, Sphere_of_Darkness)
            // Enflamed Bow
            call TasItemShopAdd(Enflamed_Bow, damage + agility)
            call TasItemFusionAdd2(Enflamed_Bow, Holy_Bow, Sphere_of_Fire)
            // Ring of Conversion
            call TasItemShopAdd(Ring_of_Conversion, mana + manaRegen + hpRegen + active)
            call TasItemFusionAdd3(Ring_of_Conversion, Desert_Ring, Sphere_of_Power, Sphere_of_Power)
            // Ancient Sphere
            call TasItemShopAdd(Ancient_Sphere, spellPower + mana + health + manaRegen + hpRegen)
            call TasItemFusionAdd2(Ancient_Sphere, Sphere_of_Power, Ancient_Stone)
            // Legendary Blade I
            call TasItemShopAdd(Legendary_Blade_I, spellPower + damage + attackSpeed + dot)
            call TasItemFusionAdd2(Legendary_Blade_I, Warrior_Blade, Sphere_of_Fire)
            // Triedge Sword
            call TasItemShopAdd(Triedge_Sword, damage + critical)
            call TasItemFusionAdd2(Triedge_Sword, Orcish_Axe, Knight_Blade)
            // Crown of Righteousness
            call TasItemShopAdd(Crown_of_Righteousness, mana + manaRegen + spellPower + active)
            call TasItemFusionAdd2(Crown_of_Righteousness, Desert_Ring, Sphere_of_Divinity)
            // Heating Cloak
            call TasItemShopAdd(Heating_Cloak, mana + health + aoe)
            call TasItemFusionAdd3(Heating_Cloak, Orb_of_Fire, Orb_of_Frost, Cloak_of_Flames)
            // Hammer of Nature
            call TasItemShopAdd(Hammer_of_Nature, damage + strength + spellPower + aoe)
            call TasItemFusionAdd2(Hammer_of_Nature, Sphere_of_Nature, Giants_Hammer)
            // Elemental Spin
            call TasItemShopAdd(Elemental_Spin, manaRegen + hpRegen + spellPower + intelligence + aoe)
            call TasItemFusionAdd4(Elemental_Spin, Orb_of_Fire, Orb_of_Water, Orb_of_Venom, Orb_of_Light)
            // Necklace of Vigor
            call TasItemShopAdd(Necklace_of_Vigor, health + mana + spellPower)
            call TasItemFusionAdd(Necklace_of_Vigor, Ancient_Stone)
            // Thundergod Spear
            call TasItemShopAdd(Thundergod_Spear, attackSpeed + damage + spellPower)
            call TasItemFusionAdd2(Thundergod_Spear, Lightning_Spear, Sphere_of_Lightning)
            // Wizard Staff
            call TasItemShopAdd(Wizard_Staff, intelligence + manaRegen + spellPower + health + spellVamp)
            call TasItemFusionAdd2(Wizard_Staff, Sphere_of_Power, Sorcerer_Staff)
            // Philosophers Stone
            call TasItemShopAdd(Philosophers_Stone, hpRegen + mana + health)
            call TasItemFusionAdd2(Philosophers_Stone, Elemental_Shard, Ancient_Stone)
            // Entity Scythe
            call TasItemShopAdd(Entity_Scythe, spellPower + movement + agility + strength + intelligence)
            call TasItemFusionAdd2(Entity_Scythe, Soul_Sword, Reapers_Edge)
            // Legendary Blade II
            call TasItemShopAdd(Legendary_Blade_II, spellPower + damage + attackSpeed + dot)
            call TasItemFusionAdd2(Legendary_Blade_II, Sphere_of_Divinity, Legendary_Blade_I)
            // Doombringer
            call TasItemShopAdd(Doombringer, damage + critical + aoe)
            call TasItemFusionAdd2(Doombringer, Sphere_of_Fire, Triedge_Sword)
            // Dual Elemental Dagger
            call TasItemShopAdd(Dual_Elemental_Dagger, damage + spellPower + evasion + lifeSteal + active)
            call TasItemFusionAdd3(Dual_Elemental_Dagger, Ritual_Dagger, Sphere_of_Fire, Sphere_of_Water)
            // Apocalyptic Mask
            call TasItemShopAdd(Apocalyptic_Mask, damage + lifeSteal)
            call TasItemFusionAdd2(Apocalyptic_Mask, Hellish_Mask, Sphere_of_Darkness)
            // Radiant Helmet
            call TasItemShopAdd(Radiant_Helmet, health + mana + strength + hpRegen)
            call TasItemFusionAdd2(Radiant_Helmet, Dragon_Helmet, Philosophers_Stone)
            // Jaden Shoulder Plate
            call TasItemShopAdd(Jaden_Shoulder_Plate, health + strength)
            call TasItemFusionAdd2(Jaden_Shoulder_Plate, Emerald_Shoulder_Plate, Saphire_Shoulder_Plate)
            // Moonchant Ring
            call TasItemShopAdd(Moonchant_Ring, health + mana + manaRegen + intelligence + active)
            call TasItemFusionAdd2(Moonchant_Ring, Fusion_Crystal, Ring_of_Conversion)
            // Bloodborne Shield
            call TasItemShopAdd(Bloodbourne_Shield, health + armor)
            call TasItemFusionAdd2(Bloodbourne_Shield, Commanders_Shield, Philosophers_Stone)
            // Nature Goddess Staff
            call TasItemShopAdd(Nature_Goddess_Staff, spellPower + health + intelligence + active)
            call TasItemFusionAdd2(Nature_Goddess_Staff, Sphere_of_Nature, Nature_Staff)
            // Phoenix Axe
            call TasItemShopAdd(Phoenix_Axe, spellPower + damage + critical)
            call TasItemFusionAdd2(Phoenix_Axe, Sphere_of_Fire, Axe_of_the_Greedy)
            // Weaver I
            call TasItemShopAdd(Weaver_I, mana + health + manaRegen + hpRegen + spellPower + intelligence + cooldown + active)
            call TasItemFusionAdd2(Weaver_I, Book_of_Flames, Ancient_Sphere)
            call TasItemFusionAdd2(Weaver_I, Book_of_Oceans, Ancient_Sphere)
            call TasItemFusionAdd2(Weaver_I, Book_of_Nature, Ancient_Sphere)
            call TasItemFusionAdd2(Weaver_I, Book_of_Light, Ancient_Sphere)
            call TasItemFusionAdd2(Weaver_I, Book_of_Chaos, Ancient_Sphere)
            call TasItemFusionAdd2(Weaver_I, Book_of_Ice, Ancient_Sphere)
            // Legendary Blade III
            call TasItemShopAdd(Legendary_Blade_III, damage + spellPower + attackSpeed + dot)
            call TasItemFusionAdd2(Legendary_Blade_III, Sphere_of_Water, Legendary_Blade_II)
            // Redemption Sword
            call TasItemShopAdd(Redemption_Sword, damage + spellPower + critical + aoe)
            call TasItemFusionAdd2(Redemption_Sword, Sphere_of_Divinity, Doombringer)
            // Elemental Stone
            call TasItemShopAdd(Elemental_Stone, mana + health + manaRegen + hpRegen)
            call TasItemFusionAdd2(Elemental_Stone, Elemental_Shard, Philosophers_Stone)
            // Sapphire Hammer
            call TasItemShopAdd(Sapphire_Hammer, damage + spellPower + strength + aoe)
            call TasItemFusionAdd2(Sapphire_Hammer, Hammer_of_Nature, Saphire_Shoulder_Plate)
            // Fire Bow
            call TasItemShopAdd(Fire_Bow, damage + spellPower + agility + dot)
            call TasItemFusionAdd2(Fire_Bow, Sphere_of_Fire, Enflamed_Bow)
            // Warlock Ring
            call TasItemShopAdd(Warlock_Ring, health + spellPower + mana + manaRegen + intelligence)
            call TasItemFusionAdd2(Warlock_Ring, Sphere_of_Darkness, Moonchant_Ring)
            // Twin Phantom Spear
            call TasItemShopAdd(Twin_Phantom_Spear, attackSpeed + spellPower + damage + movement + active)
            call TasItemFusionAdd2(Twin_Phantom_Spear, Gloves_of_Gold, Thundergod_Spear)
            // Red Moon Scyth
            call TasItemShopAdd(Red_Moon_Scyth, lifeSteal + spellPower + damage + movement + agility + strength + intelligence)
            call TasItemFusionAdd2(Red_Moon_Scyth, Hellish_Mask, Entity_Scythe)
            // Holy Scepter
            call TasItemShopAdd(Holy_Scepter, spellPower + intelligence + manaRegen + spellVamp)
            call TasItemFusionAdd2(Holy_Scepter, Wizard_Staff, Crown_of_Righteousness)
            // Magus Orb
            call TasItemShopAdd(Magus_Orb, spellPower + intelligence + manaRegen + hpRegen)
            call TasItemFusionAdd2(Magus_Orb, Elemental_Spin, Ancient_Sphere)
            // Weaver II
            call TasItemShopAdd(Weaver_II, mana + health + manaRegen + hpRegen + spellPower + intelligence + cooldown + active)
            call TasItemFusionAdd(Weaver_II, Weaver_I)
            // Legendary Blade IV
            call TasItemShopAdd(Legendary_Blade_IV, spellPower + damage + attackSpeed + dot)
            call TasItemFusionAdd2(Legendary_Blade_IV, Sphere_of_Darkness, Legendary_Blade_III)
            // Sword of Domination
            call TasItemShopAdd(Sword_of_Domination, spellPower + damage + critical)
            call TasItemFusionAdd(Sword_of_Domination, Redemption_Sword)
            // Arc Trinity
            call TasItemShopAdd(Arc_Trinity, damage + critical + lifeSteal + spellVamp)
            call TasItemFusionAdd3(Arc_Trinity, Triedge_Sword, Triedge_Sword, Triedge_Sword)
            // Holy Hammer
            call TasItemShopAdd(Holy_Hammer, spellPower + damage + strength + aoe + hpRegen)
            call TasItemFusionAdd2(Holy_Hammer, Sphere_of_Divinity, Sapphire_Hammer)
            // Gluttonous Axe
            call TasItemShopAdd(Gluttonous_Axe, damage + lifeSteal + critical)
            call TasItemFusionAdd2(Gluttonous_Axe, Apocalyptic_Mask, Phoenix_Axe)
            // Crown of Gods
            call TasItemShopAdd(Crown_of_Gods, health + mana + manaRegen + intelligence + spellPower)
            call TasItemFusionAdd2(Crown_of_Gods, Crown_of_Righteousness, Warlock_Ring)
            // Black Armor
            call TasItemShopAdd(Black_Armor, health + armor)
            call TasItemFusionAdd2(Black_Armor, Sphere_of_Darkness, Flaming_Armor)
            // Angelic Shield
            call TasItemShopAdd(Angelic_Shield, health + armor + active)
            call TasItemFusionAdd2(Angelic_Shield, Sphere_of_Divinity, Bloodbourne_Shield)
            // Helmet of Eternity
            call TasItemShopAdd(Helmet_of_Eternity, health + mana + hpRegen + strength)
            call TasItemFusionAdd2(Helmet_of_Eternity, Eternity_Stone, Radiant_Helmet)
            // Arcana Scepter
            call TasItemShopAdd(Arcana_Scepter, health + mana + manaRegen + intelligence + spellPower + spellVamp)
            call TasItemFusionAdd2(Arcana_Scepter, Holy_Scepter, Ancient_Sphere)
            // Elemental Sphere
            call TasItemShopAdd(Elemental_Sphere, health + mana + manaRegen + hpRegen + spellPower + damage + evasion)
            call TasItemFusionAdd5(Elemental_Sphere, Sphere_of_Fire, Sphere_of_Water, Sphere_of_Nature, Sphere_of_Air, Sphere_of_Darkness)
            // Legendary Blade V
            call TasItemShopAdd(Legendary_Blade_V, damage + spellPower + attackSpeed + dot + movement)
            call TasItemFusionAdd2(Legendary_Blade_V, Sphere_of_Air, Legendary_Blade_IV)



            call TasItemShopCreateShop(unit, false, 1.0, 1.0, null)
            call TasItemShopCreateShop(base, false, 1.0, 1.0, null)
            return 0
        endmethod
    endstruct

    private function Init takes nothing returns nothing
        call Shop.create()
    endfunction
endlibrary