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
            set health = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNFireCrystalElement", "Health")
            set mana = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNItem_Gem_Aquamarine.blp", "Mana")
            set attackSpeed = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNGlove.blp", "Attack Speed")
            set movement = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "Movement")
            set spellPower = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNControlMagic", "Spell Power")
            set cooldown = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNSpin.blp", "Cooldown")
            set regeneration = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNTowerRegen.blp", "Regeneration")
            set consumable = ShopAddCategory(shop, "ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall", "Consumable")

            call ShopAddItem(shop, BootsOfSpeed.code, movement)
            call ShopAddItem(shop, AnkhOfReincarnation.code, consumable)
            call ShopAddItem(shop, PotionOfRestoration.code, consumable)
            call ShopAddItem(shop, MaskOfDeath.code, regeneration)
            call ShopAddItem(shop, CloakOfFlames.code, damage)
            call ShopAddItem(shop, CommomShield.code, armor)
            call ShopAddItem(shop, HeavyHammer.code, damage)
            call ShopAddItem(shop, AssassinsDagger.code, damage)
            call ShopAddItem(shop, IronAxe.code, damage)
            call ShopAddItem(shop, SimpleBow.code, agility)
            call ShopAddItem(shop, SummoningBook.code, spellPower + cooldown)
            call ShopAddItem(shop, Courier.code, consumable)
            call ShopAddItem(shop, LifeCrystal.code, health)
            call ShopAddItem(shop, ManaCrystal.code, mana)
            call ShopAddItem(shop, LifeEssenceCrystal.code, regeneration)
            call ShopAddItem(shop, CrystalRing.code, regeneration + spellPower)
            call ShopAddItem(shop, HomecomingStone.code, movement)
            call ShopAddItem(shop, BraceletOfIntelligence.code, intelligence)
            call ShopAddItem(shop, ClawsOfAgility.code, agility)
            call ShopAddItem(shop, GauntletOfStrength.code, strength)
            call ShopAddItem(shop, GlovesOfHaste.code, attackSpeed)
            call ShopAddItem(shop, Platemail.code, armor)
            call ShopAddItem(shop, RustySword.code, damage)
            call ShopAddItem(shop, OrbOfFire.code, damage)
            call ShopAddItem(shop, OrbOfFrost.code, damage)
            call ShopAddItem(shop, OrbOfLight.code, damage)
            call ShopAddItem(shop, OrbOfLightning.code, damage)
            call ShopAddItem(shop, OrbOfSands.code, damage)
            call ShopAddItem(shop, OrbOfSouls.code, damage + regeneration)
            call ShopAddItem(shop, OrbOfThorns.code, damage)
            call ShopAddItem(shop, OrbOfVenom.code, damage)
            call ShopAddItem(shop, OrbOfWater.code, damage)
            call ShopAddItem(shop, OrbOfWind.code, damage + movement)
            call ShopAddItem(shop, OrbOfDarkness.code, damage)
            call ShopAddItem(shop, SphereOfPower.code, spellPower)
            call ShopAddItem(shop, BootsOfTheBraves.code, movement + health + attackSpeed + cooldown)
            call ShopAddItem(shop, BootsOfAgility.code, movement + agility)
            call ShopAddItem(shop, BootsOfIntelligence.code, movement + intelligence)
            call ShopAddItem(shop, BootsOfStrength.code, movement + strength)
            call ShopAddItem(shop, BootsOfRestoration.code, movement + regeneration + health)
            call ShopAddItem(shop, BootsOfFlames.code, movement + damage)
            call ShopAddItem(shop, GoldenBoots.code, movement + regeneration + damage)
            call ShopAddItem(shop, HeavyBoots.code, movement + attackSpeed + damage)
            call ShopAddItem(shop, SilverBoots.code, movement + armor + health)
            call ShopAddItem(shop, BerserkerBoots.code, movement + attackSpeed + damage)
            call ShopAddItem(shop, RunicBoots.code, movement + health + mana + spellPower)
            call ShopAddItem(shop, GoldenSword.code, damage)
            call ShopAddItem(shop, GoldenPlatemail.code, armor + health)
            call ShopAddItem(shop, FusedLifeCrystals.code, health)
            call ShopAddItem(shop, InfusedManaCrystal.code, mana)
            call ShopAddItem(shop, ElementalShard.code, health + mana + regeneration)
            call ShopAddItem(shop, HardenedShield.code, health + armor)
            call ShopAddItem(shop, MaskOfMadness.code, regeneration)
            call ShopAddItem(shop, GlovesOfSpeed.code, attackSpeed)
            call ShopAddItem(shop, GlaiveScythe.code, agility + strength + intelligence)
            call ShopAddItem(shop, MageStick.code, spellPower + mana + regeneration)
            call ShopAddItem(shop, SorcererRing.code, mana + regeneration + spellPower)
            call ShopAddItem(shop, WarriorBlade.code, damage + attackSpeed)
            call ShopAddItem(shop, BlackNavaja.code, damage)
            call ShopAddItem(shop, OrcishAxe.code, damage)
            call ShopAddItem(shop, EnhancedHammer.code, damage)
            call ShopAddItem(shop, EmeraldShoulderPlate.code, health + strength)
            call ShopAddItem(shop, SteelArmor.code, health + armor)
            call ShopAddItem(shop, WarriorHelmet.code, strength + regeneration)
            call ShopAddItem(shop, SoulScyther.code, damage + strength + agility + intelligence)
            call ShopAddItem(shop, GlovesOfSilver.code, attackSpeed)
            call ShopAddItem(shop, WarriorShield.code, health + armor)
            call ShopAddItem(shop, MageStaff.code, spellPower + intelligence + health + regeneration)
            call ShopAddItem(shop, DemonicMask.code, damage + regeneration)
            call ShopAddItem(shop, MagmaHelmet.code, strength + regeneration)
            call ShopAddItem(shop, ChillingAxe.code, damage)
            call ShopAddItem(shop, HolyBow.code, damage + agility)
            call ShopAddItem(shop, LightningSpear.code, damage + attackSpeed)
            call ShopAddItem(shop, DesertRing.code, mana + regeneration + spellPower)
            call ShopAddItem(shop, SoulSword.code, damage + regeneration)
            call ShopAddItem(shop, NatureStaff.code, spellPower + intelligence + health)
            call ShopAddItem(shop, ToxicDagger.code, damage)
            call ShopAddItem(shop, OceanicMace.code, damage)
            call ShopAddItem(shop, WindSword.code, damage + movement)
            call ShopAddItem(shop, SphereOfFire.code, spellPower)
            call ShopAddItem(shop, SphereOfWater.code, spellPower)
            call ShopAddItem(shop, SphereOfNature.code, spellPower)
            call ShopAddItem(shop, SphereOfDivinity.code, spellPower)
            call ShopAddItem(shop, SphereOfLightning.code, spellPower)
            call ShopAddItem(shop, SphereOfDarkness.code, spellPower)
            call ShopAddItem(shop, SphereOfAir.code, spellPower)
            call ShopAddItem(shop, EternityStone.code, health + regeneration)
            call ShopAddItem(shop, FusionCrystal.code, health + mana + regeneration)
            call ShopAddItem(shop, WizardStone.code, health + mana + regeneration)
            call ShopAddItem(shop, AncientStone.code, health + mana + regeneration + spellPower)
            call ShopAddItem(shop, KnightBlade.code, damage + attackSpeed)
            call ShopAddItem(shop, RitualDagger.code, damage + regeneration)
            call ShopAddItem(shop, GiantsHammer.code, damage)
            call ShopAddItem(shop, GreedyAxe.code, damage)
            call ShopAddItem(shop, SaphireShoulderPlate.code, health + strength)
            call ShopAddItem(shop, FlamingArmor.code, health + armor)
            call ShopAddItem(shop, DragonHelmet.code, health + strength + regeneration)
            call ShopAddItem(shop, ReapersEdge.code, spellPower + strength + agility + intelligence)
            call ShopAddItem(shop, GlovesOfGold.code, attackSpeed)
            call ShopAddItem(shop, CommanderShield.code, armor + health)
            call ShopAddItem(shop, SorcererStaff.code, spellPower + health + intelligence + regeneration)
            call ShopAddItem(shop, BookOfFlames.code, spellPower + damage + intelligence)
            call ShopAddItem(shop, BookOfOceans.code, spellPower + intelligence + mana)
            call ShopAddItem(shop, BookOfNature.code, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, BookOfLight.code, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, BookOfChaos.code, spellPower + intelligence + health)
            call ShopAddItem(shop, BookOfIce.code, spellPower + intelligence + armor)
            call ShopAddItem(shop, HellishMask.code, damage + regeneration)
            call ShopAddItem(shop, EnflamedBow.code, damage + agility)
            call ShopAddItem(shop, RingOfConversion.code, mana + regeneration)
            call ShopAddItem(shop, AncientSphere.code, spellPower + mana + health + regeneration)
            call ShopAddItem(shop, LegendaryBladeI.code, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, TriedgeSword.code, damage)
            call ShopAddItem(shop, CrownOfRightouesness.code, mana + regeneration + spellPower)
            call ShopAddItem(shop, HeatingCloak.code, mana + health + damage)
            call ShopAddItem(shop, HammerOfNature.code, damage + strength + spellPower)
            call ShopAddItem(shop, ElementalSpin.code, regeneration + spellPower + intelligence)
            call ShopAddItem(shop, NecklaceOfVigor.code, health + mana + spellPower)
            call ShopAddItem(shop, ThundergodSpear.code, attackSpeed + damage + spellPower)
            call ShopAddItem(shop, WizardStaff.code, intelligence + regeneration + spellPower + health)
            call ShopAddItem(shop, PhilosopherStone.code, regeneration + mana + health)
            call ShopAddItem(shop, EntityScythe.code, spellPower + movement + agility + strength + intelligence)
            call ShopAddItem(shop, LegendaryBladeII.code, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, Doombringer.code, damage)
            call ShopAddItem(shop, DualDagger.code, damage + spellPower + regeneration)
            call ShopAddItem(shop, ApocalypticMask.code, damage + regeneration)
            call ShopAddItem(shop, RadiantHelmet.code, health + mana + strength + regeneration)
            call ShopAddItem(shop, JadenShoulderPlate.code, health + strength)
            call ShopAddItem(shop, MoonchantRing.code, health + mana + regeneration + intelligence)
            call ShopAddItem(shop, BloodbourneShield.code, health + armor)
            call ShopAddItem(shop, NatureGoddessStaff.code, spellPower + health + intelligence)
            call ShopAddItem(shop, PhoenixAxe.code, spellPower + damage)
            call ShopAddItem(shop, Weaver.code, mana + health + regeneration + spellPower + intelligence + cooldown)
            call ShopAddItem(shop, LegendaryBladeIII.code, damage + spellPower + attackSpeed)
            call ShopAddItem(shop, RedemptionSword.code, damage + spellPower)
            call ShopAddItem(shop, ElementalStone.code, mana + health + regeneration)
            call ShopAddItem(shop, SapphireHammer.code, damage + spellPower + strength)
            call ShopAddItem(shop, FireBow.code, damage + spellPower + agility)
            call ShopAddItem(shop, WarlockRing.code, health + spellPower + mana + regeneration + intelligence)
            call ShopAddItem(shop, PhantomSpear.code, attackSpeed + spellPower + damage + movement)
            call ShopAddItem(shop, MoonScyth.code, regeneration + spellPower + damage + movement + agility + strength + intelligence)
            call ShopAddItem(shop, HolyScepter.code, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, MagusOrb.code, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, WeaverII.code, mana + health + regeneration + spellPower + intelligence + cooldown)
            call ShopAddItem(shop, LegendaryBladeIV.code, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, SwordOfDomination.code, spellPower + damage)
            call ShopAddItem(shop, ArcTrinity.code, damage + regeneration)
            call ShopAddItem(shop, HolyHammer.code, spellPower + damage + strength + regeneration)
            call ShopAddItem(shop, GluttonousAxe.code, damage + regeneration)
            call ShopAddItem(shop, CrownOfGods.code, health + mana + regeneration + intelligence + spellPower)
            call ShopAddItem(shop, BlackArmor.code, health + armor)
            call ShopAddItem(shop, AngelicShield.code, health + armor)
            call ShopAddItem(shop, HelmetOfEternity.code, health + mana + regeneration + strength)
            call ShopAddItem(shop, ArcanaScepter.code, health + mana + regeneration + intelligence + spellPower)
            call ShopAddItem(shop, ElementalSphere.code, health + mana + regeneration + spellPower + damage)
            call ShopAddItem(shop, LegendaryBladeV.code, damage + spellPower + attackSpeed + movement)
            call ShopAddItem(shop, CrownOfIce.code, spellPower + damage + strength + agility + intelligence)
            call ShopAddItem(shop, GoldenHeart.code, health + armor)
            call ShopAddItem(shop, LightningSword.code, damage + attackSpeed)
            call ShopAddItem(shop, SakuraBlade.code, damage +  attackSpeed + movement)

            return 0
        endmethod

        private static method onInit takes nothing returns nothing
            call create('n000', 600, 0.75)
            call create('h006', 600, 0.75)
        endmethod
    endstruct
endscope