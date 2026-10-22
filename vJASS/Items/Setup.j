scope Setup
    private struct Setup
        static method create takes integer shop, real aoe, real tax returns thistype
            local integer damage
            local integer armor
            local integer strength
            local integer agility
            local integer intelligence
            local integer health
            local integer mana
            local integer attackSpeed
            local integer movement
            local integer spellPower
            local integer cooldown
            local integer regeneration
            local integer consumable

            call CreateShop(shop, aoe, tax)

            set damage = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSteelMelee", "Damage")
            set armor = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne", "Armor")
            set strength = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower", "Strength")
            set agility = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility", "Agility")
            set intelligence = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence", "Intelligence")
            set health = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNHealthStone.blp", "Health")
            set mana = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNManaStone.blp", "Mana")
            set attackSpeed = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNGlove.blp", "Attack Speed")
            set movement = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "Movement")
            set spellPower = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNPriestAdept.blp", "Spell Power")
            set cooldown = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp", "Cooldown")
            set regeneration = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNScrollOfRegenerationGreen.blp", "Regeneration")
            set consumable = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall", "Consumable")

            call ShopAddItem(shop, PotionOfRestoration.code, consumable)
            call ShopAddItem(shop, BootsOfSpeed.code, movement)
            call ShopAddItem(shop, LifeCrystal.code, health)
            call ShopAddItem(shop, ManaCrystal.code, mana)
            call ShopAddItem(shop, HealingCrystal.code, regeneration)
            call ShopAddItem(shop, GlovesOfHaste.code, attackSpeed)
            call ShopAddItem(shop, BraceletOfIntelligence.code, intelligence)
            call ShopAddItem(shop, ClawsOfAgility.code, agility)
            call ShopAddItem(shop, GauntletOfStrength.code, strength)
            call ShopAddItem(shop, HomecomingOrb.code, movement)
            call ShopAddItem(shop, MageStick.code, spellPower)
            call ShopAddItem(shop, RustySword.code, damage)
            call ShopAddItem(shop, MaskOfDeath.code, regeneration)
            call ShopAddItem(shop, Platemail.code, armor)
            call ShopAddItem(shop, MantleOfResistance.code, armor)
            call ShopAddItem(shop, CommomShield.code, armor)
            call ShopAddItem(shop, CloakOfFlames.code, damage)
            call ShopAddItem(shop, AssassinsDagger.code, damage)
            call ShopAddItem(shop, IronAxe.code, damage)
            call ShopAddItem(shop, HeavyHammer.code, damage)
            call ShopAddItem(shop, SimpleBow.code, agility)
            call ShopAddItem(shop, SorcererRing.code, regeneration + spellPower)
            call ShopAddItem(shop, ScrollOfMastery.code, spellPower + cooldown)
            call ShopAddItem(shop, SphereOfPower.code, spellPower + regeneration)
            call ShopAddItem(shop, OrbOfFire.code, damage)
            call ShopAddItem(shop, OrbOfFrost.code, damage + movement)
            call ShopAddItem(shop, OrbOfLight.code, damage + regeneration)
            call ShopAddItem(shop, OrbOfVenom.code, damage)
            call ShopAddItem(shop, OrbOfLightning.code, damage)
            call ShopAddItem(shop, VitalityStone.code, regeneration)
            call ShopAddItem(shop, ElementalShard.code, health + mana + regeneration)
            call ShopAddItem(shop, GlovesOfSteel.code, attackSpeed + mana)
            call ShopAddItem(shop, BootsOfMastery.code, movement + agility + strength + intelligence)
            call ShopAddItem(shop, BootsOfWarriors.code, movement + regeneration + damage)
            call ShopAddItem(shop, BootsOfAssassins.code, movement + attackSpeed + damage)
            call ShopAddItem(shop, BootsOfSorcery.code, movement + mana + spellPower + cooldown)
            call ShopAddItem(shop, BootsOfBravery.code, movement + health + attackSpeed + cooldown)
            call ShopAddItem(shop, BootsOfDefenders.code, movement + health + armor)
            call ShopAddItem(shop, HunterScythe.code, agility + strength + intelligence)
            call ShopAddItem(shop, CurvedBow.code, damage + agility)
            call ShopAddItem(shop, EnhancedHammer.code, damage + strength)
            call ShopAddItem(shop, MageStaff.code, spellPower + intelligence + mana)
            call ShopAddItem(shop, WarriorHelmet.code, strength + regeneration)
            call ShopAddItem(shop, IronShield.code, health + armor)
            call ShopAddItem(shop, WarriorBlade.code, damage + attackSpeed)
            call ShopAddItem(shop, RitualDagger.code, damage)
            call ShopAddItem(shop, GreatAxe.code, damage)
            call ShopAddItem(shop, PrismaticRing.code, mana + spellPower + regeneration)
            call ShopAddItem(shop, SpellbookOfWitchcraft.code, intelligence + spellPower + cooldown)
            call ShopAddItem(shop, NoviceCloak.code, mana + armor + regeneration)
            call ShopAddItem(shop, SoldierChestPlate.code, health + armor)
            call ShopAddItem(shop, LightningSpear.code, damage + attackSpeed + spellPower)
            call ShopAddItem(shop, PrinceCrown.code, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, WizardStone.code, health + mana + spellPower + regeneration)

            return 0
        endmethod

        private static method onInit takes nothing returns nothing
            call create('shop', 800, 0.75)
            call create('base', 1000, 0.75)
        endmethod
    endstruct
endscope