library Shops requires Shop, RegisterPlayerUnitEvent, Utilities, NewBonus, NewBonusUtils, Indexer optional MirrorImage
    struct Shops
        static constant integer BOOTS_OF_SPEED              = 'I00A'
        static constant integer ANKH_OF_REINCARNATION       = 'I00N'
        static constant integer POTION_OF_RESTORATION       = 'I00P'
        static constant integer MASK_OF_DEATH               = 'I00U'
        static constant integer CLOAK_OF_FLAMES             = 'I00V'
        static constant integer COMMOM_SHIELD               = 'I016'
        static constant integer HEAVY_HAMMER                = 'I01Q'
        static constant integer ASSASSINS_DAGGER            = 'I01R'
        static constant integer IRON_AXE                    = 'I01S'
        static constant integer SIMPLE_BOW                  = 'I01T'
        static constant integer SUMMONING_BOOK              = 'I01U'
        static constant integer COURIER                     = 'I01Z'
        static constant integer LIFE_CRYSTAL                = 'I00B'
        static constant integer MANA_CRYSTAL                = 'I00J'
        static constant integer LIFE_ESSENCE_CRYSTAL        = 'I00L'
        static constant integer CRYSTAL_RING                = 'I00K'
        static constant integer HOMECOMING_STONE            = 'I00D'
        static constant integer BRACELET_OF_INTELLIGENCE    = 'I00H'
        static constant integer CLAWS_OF_AGILITY            = 'I00I'
        static constant integer GAUNTLET_OF_STRENGTH        = 'I00G'
        static constant integer GLOVES_OF_HASTE             = 'I00C'
        static constant integer PLATEMAIL                   = 'I00F'
        static constant integer RUSTY_SWORD                 = 'I00E'
        static constant integer ORB_OF_FIRE                 = 'I01J'
        static constant integer ORB_OF_FROST                = 'I01L'
        static constant integer ORB_OF_LIGHT                = 'I01X'
        static constant integer ORB_OF_LIGHTNING            = 'I01N'
        static constant integer ORB_OF_SANDS                = 'I01V'
        static constant integer ORB_OF_SOULS                = 'I01O'
        static constant integer ORB_OF_THORNS               = 'I01W'
        static constant integer ORB_OF_VENOM                = 'I01K'
        static constant integer ORB_OF_WATER                = 'I01M'
        static constant integer ORB_OF_WIND                 = 'I01P'
        static constant integer ORB_OF_DARKNESS             = 'I01Y'
        static constant integer BOOTS_OF_THE_BRAVES         = 'I009'
        static constant integer BOOTS_OF_AGILITY            = 'I00O'
        static constant integer BOOTS_OF_INTELLIGENCE       = 'I00Q'
        static constant integer BOOTS_OF_STRENGTH           = 'I00M'
        static constant integer BOOTS_OF_RESTORATION        = 'I00Y'
        static constant integer BOOTS_OF_FLAMES             = 'I010'
        static constant integer GOLDEN_BOOTS                = 'I014'
        static constant integer HEAVY_BOOTS                 = 'I00W'
        static constant integer SILVER_BOOTS                = 'I012'
        static constant integer BERSERKER_BOOTS             = 'I020'
        static constant integer RUNIC_BOOTS                 = 'I022'
        static constant integer GOLDEN_SWORD                = 'I01A'
        static constant integer GOLDEN_PLATEMAIL            = 'I01D'
        static constant integer FUSED_LIFE_CRYSTALS         = 'I01G'
        static constant integer INFUSED_MANA_CRYSTAL        = 'I027'
        static constant integer ELEMENTAL_SHARD             = 'I00T'
        static constant integer HARDENED_SHIELD             = 'I017'
        static constant integer MASK_OF_MADNESS             = 'I024'
        static constant integer GLOVES_OF_SPEED             = 'I02A'
        static constant integer GLAIVE_SCYTHE               = 'I02D'
        static constant integer MAGE_STICK                  = 'I02G'
        static constant integer SORCERER_RING               = 'I02J'
        static constant integer WARRIOR_BLADE               = 'I02M'
        static constant integer BLACK_NAVAJA                = 'I02P'
        static constant integer ORCISH_AXE                  = 'I02S'
        static constant integer ENHANCED_HAMMER             = 'I02V'
        static constant integer EMERALD_SHOULDER_PLATE      = 'I02Y'
        static constant integer STEEL_ARMOR                 = 'I031'
        static constant integer WARRIOR_HELMET              = 'I034'
        static constant integer SOUL_SCYTHER                = 'I037'
        static constant integer GLOVES_OF_SILVER            = 'I03A'
        static constant integer WARRIOR_SHIELD              = 'I03D'
        static constant integer MAGE_STAFF                  = 'I03G'
        static constant integer DEMONIC_MASK                = 'I03J'
        static constant integer MAGMA_HELMET                = 'I03M'
        static constant integer CHILLING_AXE                = 'I03P'
        static constant integer HOLY_BOW                    = 'I03S'
        static constant integer LIGHTNING_SPEAR             = 'I03V'
        static constant integer DESERT_RING                 = 'I03Y'
        static constant integer SOUL_SWORD                  = 'I041'
        static constant integer NATURE_STAFF                = 'I044'
        static constant integer TOXIC_DAGGER                = 'I047'
        static constant integer OCEANIC_MACE                = 'I04A'
        static constant integer WIND_SWORD                  = 'I04D'
        static constant integer SPHERE_OF_POWER             = 'I04G'
        static constant integer SPHERE_OF_FIRE              = 'I04H'
        static constant integer SPHERE_OF_WATER             = 'I04K'
        static constant integer SPHERE_OF_NATURE            = 'I04N'
        static constant integer SPHERE_OF_DIVINITY          = 'I04Q'
        static constant integer SPHERE_OF_LIGHTNING         = 'I04T'
        static constant integer SPHERE_OF_DARKNESS          = 'I04W'
        static constant integer SPHERE_OF_AIR               = 'I050'
        static constant integer ETERNITY_STONE              = 'I052'
        static constant integer FUSION_CRYSTAL              = 'I057'
        static constant integer WIZARD_STONE                = 'I05A'
        static constant integer KNIGHT_BLADE                = 'I05K'
        static constant integer RITUAL_DAGGER               = 'I05N'
        static constant integer GIANTS_HAMMER               = 'I05E'
        static constant integer AXE_OF_THE_GREEDY           = 'I05H'
        static constant integer SAPHIRE_SHOULDER_PLATE      = 'I05Q'
        static constant integer FLAMING_ARMOR               = 'I05T'
        static constant integer DRAGON_HELMET               = 'I05W'
        static constant integer REAPERS_EDGE                = 'I05Z'
        static constant integer GLOVES_OF_GOLD              = 'I062'
        static constant integer COMMANDERS_SHIELD           = 'I065'
        static constant integer SORCERER_STAFF              = 'I068'
        static constant integer BOOK_OF_FLAMES              = 'I06B'
        static constant integer BOOK_OF_OCEANS              = 'I06E'
        static constant integer BOOK_OF_NATURE              = 'I06H'
        static constant integer BOOK_OF_LIGHT               = 'I06K'
        static constant integer BOOK_OF_CHAOS               = 'I06N'
        static constant integer BOOK_OF_ICE                 = 'I055'
        static constant integer HELLISH_MASK                = 'I06R'
        static constant integer ENFLAMED_BOW                = 'I06U'
        static constant integer RING_OF_CONVERSION          = 'I06X'
        static constant integer ANCIENT_STONE               = 'I05D'
        static constant integer ANCIENT_SPHERE              = 'I070'
        static constant integer LEGENDARY_BLADE_I           = 'I073'
        static constant integer TRIEDGE_SWORD               = 'I076'
        static constant integer CROWN_OF_RIGHTEOUSNESS      = 'I079'
        static constant integer HEATING_CLOAK               = 'I07C'
        static constant integer HAMMER_OF_NATURE            = 'I07F'
        static constant integer ELEMENTAL_SPIN              = 'I07I'
        static constant integer NECKLACE_OF_VIGOR           = 'I07L'
        static constant integer THUNDERGOD_SPEAR            = 'I07O'
        static constant integer WIZARD_STAFF                = 'I07R'
        static constant integer PHILOSOPHERS_STONE          = 'I07U'
        static constant integer ENTITY_SCYTHE               = 'I07X'
        static constant integer LEGENDARY_BLADE_II          = 'I080'
        static constant integer DOOMBRINGER                 = 'I083'
        static constant integer DUAL_ELEMENTAL_DAGGER       = 'I086'
        static constant integer APOCALYPTIC_MASK            = 'I089'
        static constant integer RADIANT_HELMET              = 'I08C'
        static constant integer JADEN_SHOULDER_PLATE        = 'I08F'
        static constant integer MOONCHANT_RING              = 'I08I'
        static constant integer BLOODBOURNE_SHIELD          = 'I08L'
        static constant integer NATURE_GODDESS_STAFF        = 'I08O'
        static constant integer PHOENIX_AXE                 = 'I08R'
        static constant integer WEAVER_I                    = 'I08U'
        static constant integer LEGENDARY_BLADE_III         = 'I08X'
        static constant integer REDEMPTION_SWORD            = 'I090'
        static constant integer ELEMENTAL_STONE             = 'I093'
        static constant integer SAPPHIRE_HAMMER             = 'I096'
        static constant integer FIRE_BOW                    = 'I099'
        static constant integer WARLOCK_RING                = 'I09C'
        static constant integer TWIN_PHANTOM_SPEAR          = 'I09F'
        static constant integer RED_MOON_SCYTH              = 'I09I'
        static constant integer HOLY_SCEPTER                = 'I09L'
        static constant integer MAGUS_ORB                   = 'I09O'
        static constant integer WEAVER_II                   = 'I09R'
        static constant integer LEGENDARY_BLADE_IV          = 'I09U'
        static constant integer SWORD_OF_DOMINATION         = 'I09X'
        static constant integer ARC_TRINITY                 = 'I0A0'
        static constant integer HOLY_HAMMER                 = 'I0A3'
        static constant integer GLUTTONOUS_AXE              = 'I0A6'
        static constant integer CROWN_OF_GODS               = 'I0A9'
        static constant integer BLACK_ARMOR                 = 'I0AC'
        static constant integer ANGELIC_SHIELD              = 'I0AF'
        static constant integer HELMET_OF_ETERNITY          = 'I0AI'
        static constant integer ARCANA_SCEPTER              = 'I0AL'
        static constant integer ELEMENTAL_SPHERE            = 'I0AO'
        static constant integer LEGENDARY_BLADE_V           = 'I0AR'
        static constant integer CROWN_OF_ICE                = 'I0AU'
        static constant integer GOLDEN_HEART                = 'I0AV'
        static constant integer LIGHTNING_SWORD             = 'I0AY'
        static constant integer SAKURA_BLADE                = 'I0AZ'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array

        private unit unit
        private item item
        private integer id
        private integer index

        private method remove takes integer i returns integer
            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set item = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method update takes unit u, item i returns nothing
            local thistype this = thistype.allocate()

            set unit = u
            set item = i
            set id  = GetItemTypeId(i)
            set index = GetUnitUserData(u)
            set key = key + 1
            set array[key] = this

            if key == 0 then
                call TimerStart(timer, 1, true, function thistype.onPeriod)
            endif
        endmethod

        private static method configure takes nothing returns nothing
            call ItemAddComponents(BOOTS_OF_THE_BRAVES, BOOTS_OF_SPEED, HOMECOMING_STONE, GLOVES_OF_HASTE, LIFE_CRYSTAL, 0)
            call ItemAddComponents(BOOTS_OF_AGILITY, BOOTS_OF_SPEED, CLAWS_OF_AGILITY, HOMECOMING_STONE, 0, 0)
            call ItemAddComponents(BOOTS_OF_INTELLIGENCE, BOOTS_OF_SPEED, BRACELET_OF_INTELLIGENCE, HOMECOMING_STONE, 0, 0)
            call ItemAddComponents(BOOTS_OF_STRENGTH, BOOTS_OF_SPEED, GAUNTLET_OF_STRENGTH, HOMECOMING_STONE, 0, 0)
            call ItemAddComponents(BOOTS_OF_RESTORATION, BOOTS_OF_SPEED, LIFE_CRYSTAL, HOMECOMING_STONE, LIFE_ESSENCE_CRYSTAL, 0)
            call ItemAddComponents(BOOTS_OF_FLAMES, BOOTS_OF_SPEED, HOMECOMING_STONE, CLOAK_OF_FLAMES, 0, 0)
            call ItemAddComponents(GOLDEN_BOOTS, BOOTS_OF_SPEED, HOMECOMING_STONE, RUSTY_SWORD, MASK_OF_DEATH, 0)
            call ItemAddComponents(HEAVY_BOOTS, BOOTS_OF_SPEED, HOMECOMING_STONE, RUSTY_SWORD, GLOVES_OF_HASTE, 0)
            call ItemAddComponents(SILVER_BOOTS, BOOTS_OF_SPEED, HOMECOMING_STONE, PLATEMAIL, LIFE_CRYSTAL, 0)
            call ItemAddComponents(BERSERKER_BOOTS, BOOTS_OF_SPEED, GLOVES_OF_HASTE, GLOVES_OF_HASTE, ASSASSINS_DAGGER, 0)
            call ItemAddComponents(RUNIC_BOOTS, BOOTS_OF_SPEED, LIFE_CRYSTAL, MANA_CRYSTAL, 0, 0)
            call ItemAddComponents(GOLDEN_SWORD, RUSTY_SWORD, RUSTY_SWORD, RUSTY_SWORD, 0,  0)
            call ItemAddComponents(GOLDEN_PLATEMAIL, LIFE_CRYSTAL, PLATEMAIL, PLATEMAIL, 0, 0)
            call ItemAddComponents(FUSED_LIFE_CRYSTALS, LIFE_CRYSTAL, LIFE_CRYSTAL, LIFE_CRYSTAL, 0, 0)
            call ItemAddComponents(INFUSED_MANA_CRYSTAL, MANA_CRYSTAL, MANA_CRYSTAL, MANA_CRYSTAL, 0, 0)
            call ItemAddComponents(ELEMENTAL_SHARD, LIFE_CRYSTAL, MANA_CRYSTAL, LIFE_ESSENCE_CRYSTAL, CRYSTAL_RING, 0)
            call ItemAddComponents(HARDENED_SHIELD, COMMOM_SHIELD, LIFE_CRYSTAL, PLATEMAIL, 0, 0)
            call ItemAddComponents(MASK_OF_MADNESS, MASK_OF_DEATH, 0, 0, 0, 0)
            call ItemAddComponents(GLOVES_OF_SPEED, GLOVES_OF_HASTE, GLOVES_OF_HASTE, 0, 0, 0)
            call ItemAddComponents(GLAIVE_SCYTHE, BRACELET_OF_INTELLIGENCE, GAUNTLET_OF_STRENGTH, CLAWS_OF_AGILITY, 0, 0)
            call ItemAddComponents(MAGE_STICK, MANA_CRYSTAL, MANA_CRYSTAL, CRYSTAL_RING, 0, 0)
            call ItemAddComponents(SORCERER_RING, MANA_CRYSTAL, CRYSTAL_RING, CRYSTAL_RING, 0, 0)
            call ItemAddComponents(WARRIOR_BLADE, GOLDEN_SWORD, GLOVES_OF_HASTE, 0, 0, 0)
            call ItemAddComponents(BLACK_NAVAJA, RUSTY_SWORD, RUSTY_SWORD, ASSASSINS_DAGGER, 0, 0)
            call ItemAddComponents(ORCISH_AXE, IRON_AXE, GOLDEN_SWORD, 0, 0, 0)
            call ItemAddComponents(ENHANCED_HAMMER, RUSTY_SWORD, HEAVY_HAMMER, HEAVY_HAMMER, 0, 0)
            call ItemAddComponents(EMERALD_SHOULDER_PLATE, GAUNTLET_OF_STRENGTH, GAUNTLET_OF_STRENGTH, FUSED_LIFE_CRYSTALS, 0, 0)
            call ItemAddComponents(STEEL_ARMOR, FUSED_LIFE_CRYSTALS, GOLDEN_PLATEMAIL, 0, 0, 0)
            call ItemAddComponents(WARRIOR_HELMET, GAUNTLET_OF_STRENGTH, LIFE_ESSENCE_CRYSTAL, LIFE_ESSENCE_CRYSTAL, 0, 0)
            call ItemAddComponents(SOUL_SCYTHER, RUSTY_SWORD, GLAIVE_SCYTHE, 0, 0, 0)
            call ItemAddComponents(GLOVES_OF_SILVER, GLOVES_OF_SPEED, GLOVES_OF_SPEED, 0, 0, 0)
            call ItemAddComponents(WARRIOR_SHIELD, GOLDEN_PLATEMAIL, HARDENED_SHIELD, 0, 0, 0)
            call ItemAddComponents(MAGE_STAFF, BRACELET_OF_INTELLIGENCE, FUSED_LIFE_CRYSTALS, MAGE_STICK, 0, 0)
            call ItemAddComponents(DEMONIC_MASK, ORB_OF_DARKNESS, MASK_OF_MADNESS, GOLDEN_SWORD, 0, 0)
            call ItemAddComponents(MAGMA_HELMET, ORB_OF_FIRE, WARRIOR_HELMET, 0, 0, 0)
            call ItemAddComponents(CHILLING_AXE, ORB_OF_FROST, ORCISH_AXE, 0, 0, 0)
            call ItemAddComponents(HOLY_BOW, ORB_OF_LIGHT, SIMPLE_BOW, 0, 0, 0)
            call ItemAddComponents(LIGHTNING_SPEAR, ORB_OF_LIGHTNING, GLOVES_OF_SILVER, 0, 0, 0)
            call ItemAddComponents(DESERT_RING, ORB_OF_SANDS, SORCERER_RING, 0, 0 ,0)
            call ItemAddComponents(SOUL_SWORD, ORB_OF_SOULS, GOLDEN_SWORD, 0, 0, 0)
            call ItemAddComponents(NATURE_STAFF, ORB_OF_THORNS, MAGE_STAFF, 0, 0, 0)
            call ItemAddComponents(TOXIC_DAGGER, ORB_OF_VENOM, GOLDEN_SWORD, 0, 0 ,0)
            call ItemAddComponents(OCEANIC_MACE, ORB_OF_WATER, ENHANCED_HAMMER, 0, 0, 0)
            call ItemAddComponents(WIND_SWORD, ORB_OF_WIND, GOLDEN_SWORD, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_FIRE, ORB_OF_FIRE, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_WATER, ORB_OF_WATER, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_NATURE, ORB_OF_THORNS, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_DIVINITY, ORB_OF_LIGHT, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_LIGHTNING, ORB_OF_LIGHTNING, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_DARKNESS, ORB_OF_DARKNESS, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(SPHERE_OF_AIR, ORB_OF_WIND, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(ETERNITY_STONE, FUSED_LIFE_CRYSTALS, LIFE_ESSENCE_CRYSTAL, 0, 0, 0)
            call ItemAddComponents(FUSION_CRYSTAL, FUSED_LIFE_CRYSTALS, INFUSED_MANA_CRYSTAL, 0, 0, 0)
            call ItemAddComponents(WIZARD_STONE, ELEMENTAL_SHARD, 0, 0, 0, 0)
            call ItemAddComponents(ANCIENT_STONE, WIZARD_STONE, 0, 0, 0, 0)
            call ItemAddComponents(KNIGHT_BLADE, WARRIOR_BLADE, ORCISH_AXE, 0, 0, 0)
            call ItemAddComponents(RITUAL_DAGGER, BLACK_NAVAJA, MASK_OF_MADNESS, 0, 0, 0)
            call ItemAddComponents(GIANTS_HAMMER, OCEANIC_MACE, 0, 0, 0, 0)
            call ItemAddComponents(AXE_OF_THE_GREEDY, ORCISH_AXE, ORCISH_AXE, 0, 0, 0)
            call ItemAddComponents(SAPHIRE_SHOULDER_PLATE, FUSED_LIFE_CRYSTALS, EMERALD_SHOULDER_PLATE, 0, 0, 0)
            call ItemAddComponents(FLAMING_ARMOR, CLOAK_OF_FLAMES, FUSED_LIFE_CRYSTALS, STEEL_ARMOR, 0, 0)
            call ItemAddComponents(DRAGON_HELMET, WARRIOR_HELMET, ETERNITY_STONE, 0, 0, 0)
            call ItemAddComponents(REAPERS_EDGE, SOUL_SCYTHER, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(GLOVES_OF_GOLD, GLOVES_OF_SILVER, GLOVES_OF_SILVER, 0, 0, 0)
            call ItemAddComponents(COMMANDERS_SHIELD, FUSED_LIFE_CRYSTALS, WARRIOR_SHIELD, 0, 0, 0)
            call ItemAddComponents(SORCERER_STAFF, MAGE_STAFF, SPHERE_OF_POWER, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_FLAMES, SUMMONING_BOOK, SPHERE_OF_FIRE, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_OCEANS, SUMMONING_BOOK, SPHERE_OF_WATER, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_NATURE, SUMMONING_BOOK, SPHERE_OF_NATURE, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_LIGHT, SUMMONING_BOOK, SPHERE_OF_DIVINITY, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_CHAOS, SUMMONING_BOOK, SPHERE_OF_DARKNESS, 0, 0, 0)
            call ItemAddComponents(BOOK_OF_ICE, SUMMONING_BOOK, SPHERE_OF_AIR, 0, 0, 0)
            call ItemAddComponents(HELLISH_MASK, DEMONIC_MASK, SPHERE_OF_DARKNESS, 0, 0, 0)
            call ItemAddComponents(ENFLAMED_BOW, HOLY_BOW, SPHERE_OF_FIRE, 0, 0, 0)
            call ItemAddComponents(RING_OF_CONVERSION, DESERT_RING, SPHERE_OF_POWER, SPHERE_OF_POWER, 0, 0)
            call ItemAddComponents(ANCIENT_SPHERE, SPHERE_OF_POWER, ANCIENT_STONE, 0, 0, 0)
            call ItemAddComponents(LEGENDARY_BLADE_I, WARRIOR_BLADE, SPHERE_OF_FIRE, 0, 0, 0)
            call ItemAddComponents(TRIEDGE_SWORD, ORCISH_AXE, KNIGHT_BLADE, 0, 0, 0)
            call ItemAddComponents(CROWN_OF_RIGHTEOUSNESS, DESERT_RING, SPHERE_OF_DIVINITY, 0, 0, 0)
            call ItemAddComponents(HEATING_CLOAK, ORB_OF_FIRE, ORB_OF_FROST, CLOAK_OF_FLAMES, 0, 0)
            call ItemAddComponents(HAMMER_OF_NATURE, SPHERE_OF_NATURE, GIANTS_HAMMER, 0, 0, 0)
            call ItemAddComponents(ELEMENTAL_SPIN, ORB_OF_FIRE, ORB_OF_WATER, ORB_OF_VENOM, ORB_OF_LIGHT, 0)
            call ItemAddComponents(NECKLACE_OF_VIGOR, ANCIENT_STONE, 0, 0, 0, 0)
            call ItemAddComponents(THUNDERGOD_SPEAR, LIGHTNING_SPEAR, SPHERE_OF_LIGHTNING, 0, 0, 0)
            call ItemAddComponents(WIZARD_STAFF, SPHERE_OF_POWER, SORCERER_STAFF, 0, 0, 0)
            call ItemAddComponents(PHILOSOPHERS_STONE, ELEMENTAL_SHARD, ANCIENT_STONE, 0, 0, 0)
            call ItemAddComponents(ENTITY_SCYTHE, SOUL_SWORD, REAPERS_EDGE, 0, 0, 0)
            call ItemAddComponents(LEGENDARY_BLADE_II, SPHERE_OF_DIVINITY, LEGENDARY_BLADE_I, 0, 0, 0)
            call ItemAddComponents(DOOMBRINGER, SPHERE_OF_FIRE, TRIEDGE_SWORD, 0, 0, 0)
            call ItemAddComponents(DUAL_ELEMENTAL_DAGGER, RITUAL_DAGGER, SPHERE_OF_FIRE, SPHERE_OF_WATER, 0, 0)
            call ItemAddComponents(APOCALYPTIC_MASK, HELLISH_MASK, SPHERE_OF_DARKNESS, 0, 0, 0)
            call ItemAddComponents(RADIANT_HELMET, DRAGON_HELMET, PHILOSOPHERS_STONE, 0, 0, 0)
            call ItemAddComponents(JADEN_SHOULDER_PLATE, EMERALD_SHOULDER_PLATE, SAPHIRE_SHOULDER_PLATE, 0, 0, 0)
            call ItemAddComponents(MOONCHANT_RING, FUSION_CRYSTAL, RING_OF_CONVERSION, 0, 0, 0)
            call ItemAddComponents(BLOODBOURNE_SHIELD, COMMANDERS_SHIELD, PHILOSOPHERS_STONE, 0, 0, 0)
            call ItemAddComponents(NATURE_GODDESS_STAFF, SPHERE_OF_NATURE, NATURE_STAFF, 0, 0, 0)
            call ItemAddComponents(PHOENIX_AXE, SPHERE_OF_FIRE, AXE_OF_THE_GREEDY, 0, 0, 0)
            call ItemAddComponents(WEAVER_I, BOOK_OF_CHAOS, ANCIENT_SPHERE, 0, 0, 0)
            call ItemAddComponents(LEGENDARY_BLADE_III, SPHERE_OF_WATER, LEGENDARY_BLADE_II, 0, 0, 0)
            call ItemAddComponents(REDEMPTION_SWORD, SPHERE_OF_DIVINITY, DOOMBRINGER, 0, 0, 0)
            call ItemAddComponents(ELEMENTAL_STONE, ELEMENTAL_SHARD, PHILOSOPHERS_STONE, 0, 0, 0)
            call ItemAddComponents(SAPPHIRE_HAMMER, HAMMER_OF_NATURE, SAPHIRE_SHOULDER_PLATE, 0, 0, 0)
            call ItemAddComponents(FIRE_BOW, SPHERE_OF_FIRE, ENFLAMED_BOW, 0, 0, 0)
            call ItemAddComponents(WARLOCK_RING, SPHERE_OF_DARKNESS, MOONCHANT_RING, 0, 0, 0)
            call ItemAddComponents(TWIN_PHANTOM_SPEAR, GLOVES_OF_GOLD, THUNDERGOD_SPEAR, 0, 0, 0)
            call ItemAddComponents(RED_MOON_SCYTH, HELLISH_MASK, ENTITY_SCYTHE, 0, 0, 0)
            call ItemAddComponents(HOLY_SCEPTER, WIZARD_STAFF, CROWN_OF_RIGHTEOUSNESS, 0, 0, 0)
            call ItemAddComponents(MAGUS_ORB, ELEMENTAL_SPIN, ANCIENT_SPHERE, 0, 0, 0)
            call ItemAddComponents(WEAVER_II, WEAVER_I, 0, 0, 0, 0)
            call ItemAddComponents(LEGENDARY_BLADE_IV, SPHERE_OF_DARKNESS, LEGENDARY_BLADE_III, 0, 0, 0)
            call ItemAddComponents(SWORD_OF_DOMINATION, REDEMPTION_SWORD, 0, 0, 0, 0)
            call ItemAddComponents(ARC_TRINITY, TRIEDGE_SWORD, TRIEDGE_SWORD, TRIEDGE_SWORD, 0, 0)
            call ItemAddComponents(HOLY_HAMMER, SPHERE_OF_DIVINITY, SAPPHIRE_HAMMER, 0, 0, 0)
            call ItemAddComponents(GLUTTONOUS_AXE, APOCALYPTIC_MASK, PHOENIX_AXE, 0, 0, 0)
            call ItemAddComponents(CROWN_OF_GODS, CROWN_OF_RIGHTEOUSNESS, WARLOCK_RING, 0, 0, 0)
            call ItemAddComponents(BLACK_ARMOR, SPHERE_OF_DARKNESS, FLAMING_ARMOR, 0, 0, 0)
            call ItemAddComponents(ANGELIC_SHIELD, SPHERE_OF_DIVINITY, BLOODBOURNE_SHIELD, 0, 0, 0)
            call ItemAddComponents(HELMET_OF_ETERNITY, ETERNITY_STONE, RADIANT_HELMET, 0, 0, 0)
            call ItemAddComponents(ARCANA_SCEPTER, HOLY_SCEPTER, ANCIENT_SPHERE, 0, 0, 0)
            call ItemAddComponents(ELEMENTAL_SPHERE, SPHERE_OF_FIRE, SPHERE_OF_WATER, SPHERE_OF_NATURE, SPHERE_OF_AIR, SPHERE_OF_DARKNESS)
            call ItemAddComponents(LEGENDARY_BLADE_V, SPHERE_OF_AIR, LEGENDARY_BLADE_IV, 0, 0, 0)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this
            local integer i = 0

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItem(unit, item) then
                        if id == REAPERS_EDGE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00200|r All Stats\n+ |cffffcc00400|r Spell Power\n\n|cff00ff00Passive|r|cffffcc00: Soul Reaper|r: Every |cffffcc002|r enemy units killed, |cffff0000Strength|r,|cff00ff00 Agility |rand |cff00ffffIntelligence|r are increased by |cffffcc001|r and|cff008080 Spell Power|r is incresed by |cffffcc000.5|r permanently. Killing a enemy Hero increases all stats by |cffffcc0020|r and|cff008080 Spell Power|r by|cffffcc00 5|r.\n\nSpell Power Bonus: |cff008080" + R2SW(ReapersEdge.spell[index], 1, 1) + "|r\nStats Bonus: |cffffcc00" + I2S(ReapersEdge.stats[index]) + "|r")
                        elseif id == AXE_OF_THE_GREEDY then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0045|r Damage\n+ |cffffcc0025%|r Critical Strike Chance\n+ |cffffcc00100%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Pillage|r: After hitting a critical strike, for the next |cffffcc003 |rseconds, the Hero gains |cffffcc0050% |rAttack Speed bonus and every attack grants |cffffcc00Gold |requal to |cffffcc002.5% (25% against Heroes)|r of the damage dealt.\n\nGold Granted: |cffffcc00" + I2S(GreedyAxe.gold[index]) + "|r")
                        elseif id == BLACK_NAVAJA then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0025|r Damage\n+ |cffffcc0010%|r Evasion\n\n|cff00ff00Passive|r: |cffffcc00Assassination:|r Every attack has |cffffcc0010%|r chance to instantly kill |cffffcc00non-Hero|r targets and increase bounty of killed enemy by |cffffcc00250 gold|r.\n\nGold Granted: |cffffcc00" + I2S(BlackNavaja.gold[index]) + "|r")
                        elseif id == BOOTS_OF_FLAMES then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010|r Damage\n+ |cffffcc0050|r Movement Speed\n\n|cff80ff00Active:|r |cffffcc001000|r Range Blink.\n\n|cff80ff00Passive:|r Every second all enemy units within |cffffcc00300 AoE|r take |cff00ffff" + AbilitySpellDamageEx(20, unit) + " Magic|r damage.\n\nReaching level |cff80ff0015|r with this Boots in inventory grants |cffff800025 All Stats|r.")
                        elseif id == DRAGON_HELMET then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00100|r Strength\n+ |cffffcc00100|r Health Regeneration\n+ |cffffcc007500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Dragon Endurance|r: Every|cffffcc00 5|r units killed wilhe this item is equipped grants |cffffcc001|r bonus |cff00ff00Health Regeneration|r permanently. |cffffcc00Hero|r kills grants |cffffcc005|r bonus|cff00ff00 health regeneration|r.\n\n|cff00ff00Active|r: |cffffcc00Dragon's Bless|r: When activated, the |cff00ff00Health Regeneration|r granted by this item passive effect is|cffffcc00 doubled|r for |cffffcc0020|r seconds.\n\n90 seconds cooldown.\n\nHealth Regeneration Bonus: |cff00ff00" + R2SW(DragonHelmet.bonus[index], 1, 1) + "|r")
                        elseif id == EMERALD_SHOULDER_PLATE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00375|r Health\n+ |cffffcc008|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Arm:|r Every attack taken has |cffffcc0010%|r chance to increase Hero |cffff0000Strength|r by |cffffcc001|r for 15 seconds.\n\nCurrent Strength Bonus: |cffff0000" + I2S(EmeraldPlate.bonus[index]) + "|r")
                        elseif id == ETERNITY_STONE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc00500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Eternal Youth|r: When killing a unit |cff00ff00Heatlh Regeneration|r is increased by |cffffcc000.5|r and |cffff0000Maximum Health|r is increased by |cffffcc005|r for |cffffcc0030|r seconds.\n\nHeath Bonus: |cffff0000" + I2S(EternityStone.health[index]) + "|r\nHealth Regeneration Bonus: |cff00ff00" + R2SW(EternityStone.regen[index], 1, 1) + "|r")
                        elseif id == FUSION_CRYSTAL then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Mana\n+ |cffffcc00500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Charge|r: When killing a unit the number of charges of Fusion Crystal are increased by |cffffcc001|r.\n\n|cff00ff00Active|r: |cffffcc00Energy Release|r: When activated, all charges are consumed and for |cffffcc0010|r seconds, |cffff0000Health|r and |cff80ffffMana|r Regeneration are increased by |cffffcc00" + R2SW(0.5 * FusionCrystal.charges[index],1 , 1) + "|r.\n\n90 seconds Cooldown\n\nCharges: |cffffcc00" + I2S(FusionCrystal.charges[index]) + "|r")
                        elseif id == GLOVES_OF_GOLD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:\n+ |cffffcc00200%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Hand of Midas|r: Every attack has|cffffcc00 1%|r chance to turn|cffff0000 non-Hero|r targets into a pile of |cffffcc00Gold|r equivalent to their|cffff0000 Maximum Health|r.|r\n\nGold Granted: |cffffcc00" + I2S(GlovesOfGold.gold[index]) + "|r")
                        elseif id == KNIGHT_BLADE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0040|r Damage\n+ |cffffcc0025%|r Attack Speed\n+ |cffffcc0020%|r Critical Strike Chance\n+ |cffffcc0050%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Critical Frenzy|r: After hitting a critical strike your Hero damage is increased by |cffffcc005% (10% against Heroes)|r of the damage dealt by the critical strike for |cffffcc005|r seconds. Max |cffffcc0060|r bonus damage.\n\nDamage Bonus: |cffffcc00" + I2S(KnightBlade.bonus[index]) + "|r")
                        elseif id == MAGMA_HELMET then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010|r Strength\n+ |cffffcc007|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Purifying Flames:|r When your Hero's life drops below |cffffcc0025%|r, |cff00ff00health regeneration|r is increased by |cffffcc0030 hp/s|r and all enemy units within |cffffcc00300|r AoE takes |cff00ffff" + AbilitySpellDamageEx(20, unit) +" Magic|r damage per second. Lasts |cffffcc0020|r seconds.\n\nCooldown: |cffffcc00" + I2S(MagmaHelmet.cooldown[index]) + "|r")
                        elseif id == RITUAL_DAGGER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0030|r Damage\n+ |cffffcc0015%|r Evasion\n+ |cffffcc0015%|r Life Steal\n\n|cff00ff00Passive|r: |cffffcc00Assassination|r: Every attack has |cffffcc0010%|r chance to instantly kill|cffffcc00 non-Hero|r targets and increase bounty of killed enemy by |cffffcc00100 gold|r.\n\n|cff00ff00Passive|r: |cffffcc00Sacrifice|r: When an enemy unit is assassinated by this item effect, your Hero health is recovered by |cffffcc0015%|r of the target |cffffcc00max health|r.\n\nGold Granted: |cffffcc00" + I2S(RitualDagger.gold[index]) + "|r")
                        elseif id == RUNIC_BOOTS then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r \n+ |cffffcc00150|r Health \n+ |cffffcc00150|r Mana \n+ |cffffcc0020|r Spell Power \n+ |cffffcc0075|r Movement Speed \n\n|cff80ff00Active:|r|cffffcc00 Restoration: |rHeals Health and Mana for |cffffcc00" + I2S(50 * GetHeroLevel(unit)) + "|r. \n\nReaching level |cff80ff0015 |rgrants |cffff800025 All Stats|r. \n\n10 seconds cooldown.")
                        elseif id == SAPHIRE_SHOULDER_PLATE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0015000|r Health\n+ |cffffcc00150|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Will|r: Every attack taken has |cffffcc0010%|r chance to increase Hero |cffff0000Strength|r and |cff00ff00Agility|r by |cffffcc0010|r for 30 seconds.\n\nCurrent Strength Bonus: |cffff0000" + I2S(SaphirePlate.strength[index]) + "|r\nCurrent Agility Bonus: |cff00ff00" + I2S(SaphirePlate.agility[index]) + "|r")
                        elseif id == SOUL_SCYTHER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010|r All Stats\n+ |cffffcc0010|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Soul Eater:|r Every |cffffcc0010|r enemy units killed, |cffff0000Strength|r, |cff00ff00Agility|r and |cff00ffffIntelligence|r are increased by |cffffcc001|r permanently. Killing a enemy Hero increases all stats by |cffffcc002|r.\n\nStats Bonus: |cffffcc00" + I2S(SoulScyther.bonus[index]) + "|r")
                        elseif id == SOUL_SWORD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0020|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Soul Steal|r: Every attack heals |cff00ff00" + R2SW(10.0 + SoulSword.bonus[index], 0, 0) + "|r Health and deals |cff0080ff" + AbilitySpellDamageEx(20, unit) +"|r bonus |cff0080ffMagic |rdamage. Killing an enemy unit, increases the on attack heal by |cffffcc000.2|r. Hero kills increases on attack heal by |cffffcc002|r.")
                        elseif id == FLAMING_ARMOR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0018000|r Health\n+ |cffffcc0010|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0015%|r.\n\n|cff00ff00Passive|r: |cffffcc00Guarding Flames|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff0080ff" + AbilitySpellDamageEx(250, unit) + "|r |cff0080ffMagic|r damage.")
                        elseif id == LIGHTNING_SPEAR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0055%|r Attack Speed\n+ |cffffcc0015|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%|r chance to release chain lightning, dealing |cff00ffff" + AbilitySpellDamageEx(25, unit) + " Magic|r damage up to |cffffcc004|r nearby enemies.")
                        elseif id == SPHERE_OF_AIR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500 |rSpell Power\n\n|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc00200% |rAttack Speed and |cffffcc0040% |rMovement Speed bonus.\n\n|cff00ff00Passive|r: |cffffcc00Gale|r: Attacks have |cffffcc0020%|r chance to knockback the target and all enemy units behind it within |cffffcc00400 |rAoE for |cffffcc00200 |runits over |cffffcc000.5|r seconds and dealing |cff0080ff" + AbilitySpellDamageEx(500, unit) + "|r bonus |cff0080ffMagic|r damage.")
                        elseif id == SPHERE_OF_DARKNESS then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Dark Curse|r: Every attack has |cffffcc0030%|r chance to Deal |cff0080ff" + AbilitySpellDamageEx(1000, unit) + "|r |cff0080ffMagic|r damage and cast |cffffcc00Dark Curse|r in the target, reducing its armor and all aliied units within |cffffcc00600|r AoE by |cffffcc0010|r.\n\nLasts for 10 seconds.")
                        elseif id == SPHERE_OF_FIRE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage |ris amplified by |cffffcc0018%.|r\n\n|cff00ff00Passive|r: |cffffcc00Flying Flames|r: Engulfs the Hero with flames, releasing flaming bolts to random enemy units within |cffffcc00600|r AoE every |cffffcc001|r second, dealing |cff0080ff" + AbilitySpellDamageEx(500, unit) + "|r |cff0080ffMagic|r damage on impact and setting the target on fire, dealing |cff0080ff" + AbilitySpellDamageEx(250, unit) + "|r |cff0080ffMagic|r damage per second.\n\nLasts for 10 seconds (4 on Heroes).")
                        elseif id == SPHERE_OF_LIGHTNING then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Thunder Bolt|r: Every attack has |cffffcc0020%|r to call down thunder bolts on the target and up to |cffffcc004|r nearby enemy units within |cffffcc00500|r AoE, dealing |cff0080ff" + AbilitySpellDamageEx(1000, unit) + "|r |cff0080ffMagic|r damage.")
                        elseif id == SPHERE_OF_NATURE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Thorned Armor|r: When receiving physical damage, returns 25% of the damage taken.\n\n|cff00ff00Passive|r: |cffffcc00Overgrowth|r: Every attack has |cffffcc0020%|r chance to entangle the target, dealing |cff0080ff" + AbilitySpellDamageEx(500, unit) + "|r |cff0080ffMagic|r damage per second for |cffffcc0010|r seconds (|cffffcc003 for Heroes|r). If the entangled unit dies, the entanglement will spread to the |cffffcc002|r nearest targets.")
                        elseif id == SPHERE_OF_WATER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage|r is amplified by |cffffcc0018%.|r\n\n|cff00ff00Passive|r: |cffffcc00Water Bubble|r: Every attack has |cffffcc0025%|r chance to surronds the target in a water bubble. Attacking units affected by Water Bubble causes the bubble to splash bolts of water to enemy units behind the target, dealing |cff0080ff" + AbilitySpellDamageEx(500, unit) + "|r |cff0080fffMagic|r damage.\n\nLasts for 5 seconds.")
                        elseif id == TOXIC_DAGGER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0030|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Toxic Blade|r: Attacking enemies poison them dealing |cff0080ff" + AbilitySpellDamageEx(20, unit) + " Magic|r damage per second.\n\nLasts for 5 seconds.")
                        elseif id == WIND_SWORD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00300|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc0020%|r Attack Speed and |cffffcc008%|r Movement Speed bonus.\n\n|cff00ff00Passive|r: |cffffcc00Wind Blow|r: Attacks have |cffffcc0020%|r chance to knockback the target |cffffcc00200|r units over |cffffcc000.5|r seconds and deal |cff00ffff" + AbilitySpellDamageEx(25, unit) + " Magic|r damage.")
                        elseif id == WIZARD_STONE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00250|r Health\n+ |cffffcc00250|r Mana\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc005|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Magical Growth|r: Every time you cast an |cffffcc00active|r spell, the number of charges of Wizard Stone are increased by |cffffcc001|r and your Hero |cff0080ffSpell Power|r is increased by |cffffcc001|r. When the number of charges reach |cffffcc0050|r, the Wizard Stone transforms into |cffffcc00Ancient Stone|r, |cffffcc00doubling|r all the stats given and granting an extra |cffffcc0050|r |cff0080ffSpell Power|r.\n\nCharges: |cffffcc00" + I2S(WizardStone.table[GetHandleId(item)].integer[0]) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(WizardStone.table[GetHandleId(item)].integer[1]) + "|r")
                        elseif id == SORCERER_STAFF then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00500|r Spell Power\n+ |cffffcc00150|r Intelligence\n+ |cffffcc005000|r Health\n\n|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff0000ffMagical|r damage, heals for |cffffcc002.5%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Sorcerer Trait|r: After casting an ability, |cff0000ffSpell Power|r is increased by |cffffcc00250|r for |cffffcc0015|r seconds.\n\nCurrent Spell Power Bonus: |cff0080ff" + R2I2S(SorcererStaff.bonus[index]) + "|r")
                        elseif id == WARRIOR_HELMET then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc007|r Strength\n+ |cffffcc005|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Overheal|r: When Hero's life drops below |cffffcc0050%|r, |cff00ff00Health Regeneration|r is increased by |cffffcc0020 Hp/s|r for |cffffcc0015|r seconds.\n\nCooldown: |cffffcc00" + I2S(WarriorHelmet.cooldown[index]) + "|r")
                        elseif id == ANCIENT_SPHERE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Health\n+ |cffffcc0010000|r Mana\n+ |cffffcc00100|r Spell Power\n+ |cffffcc00100|r Health Regeneration\n+ |cffffcc00100|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Infused Enlightenment|r: Every |cffffcc0045|r seconds your Hero gains permanently |cffffcc001000|r Health, |cffffcc001000|r Mana, |cffffcc0010|r Spell Power, |cffffcc0010|r Health Regeneration and |cffffcc0010|r Mana Regeneration.\n\nHealth Bonus: |cffff0000" + I2S(AncientSphere.hp[index]) + "|r\nMana Bonus: |cff0000ff" + I2S(AncientSphere.mp[index]) + "|r\nHealth Regen Bonus: |cff00ff00" + I2S(AncientSphere.hr[index]) + "|r\nMana Regen Bonus: |cff00ffff"  + I2S(AncientSphere.mr[index]) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(AncientSphere.sp[index]) + "|r")
                        // elseif id == TRIEDGE_SWORD then
                        //     call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001000|r Damage\n+ |cffffcc0010%|r Critical Strike Chance\n+ |cffffcc00100%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Critical Mass|r: After hitting a critical strike |cffffcc00Triedge|r gains |cffffcc003|r stacks, increasing damage by |cffffcc00250|r, Criticial Strike Chance by |cffffcc002%|r and Critical Strike Damage by |cffffcc0010%|r per stack. Attacking an enemy unit consumes 1 stack. Max |cffffcc0010|r stacks.\n\nStacks: |cffffcc00" + I2S(TriedgeSword.stacks[index]) + "|r\nBonus Damage: |cffffcc00" + I2S(TriedgeSword.damage[index]) + "|r\nBonus Critical Strike Chance: |cffffcc00" + I2S(TriedgeSword.bonusChance[index]) + "%|r\nBonus Critical Strike Damage: |cffffcc00" + I2S(TriedgeSword.bonusDamage[index]) + "%|r")
                        elseif id == CROWN_OF_RIGHTEOUSNESS then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Mana\n+ |cffffcc00250|r Mana Regeneration\n+ |cffffcc00600|r Spell Power\n\n|cff00ff00Acitve|r: |cffffcc00Light Shield|r: When activated, creates a light barrier around the Hero, blocking up to |cffffcc00" + R2I2S(5000 + (5 * GetUnitSpellPowerFlat(unit))) + "|r damage or until its duration is over. Lasts |cffffcc0030|r seconds.")
                        elseif id == HEATING_CLOAK then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc005000|r Health\n+ |cffffcc005000|r Mana\n\n|cff00ff00Passive|r: |cffffcc00Immolation|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff00ffff" + AbilitySpellDamageEx(HeatingCloak.damage[index], unit) + " Magic|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Turn up the Heat|r: Every |cffffcc0060|r seconds |cffffcc00Heating Cloak|r charges up and the damage dealt by its immolation is increased by |cff00ffff500 Magic|r damage for |cffffcc0030|r seconds.\n\n" + HeatingCloak.state[index] + "|cffffcc00" + HeatingCloak.cd[index] + "|r")
                        elseif id == HAMMER_OF_NATURE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Damage\n+ |cffffcc00250|r Spell Power\n+ |cffffcc00250|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00300 AoE|r, dealing |cffffcc0040%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Force of Nature|r: Every |cffffcc00fifth|r attack a powerfull blow will damage the target for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and create a |cffffcc00Pulsing Blast|r at the target location. The |cffffcc00Pulsing Blast|r heals all nearby allies and damages all nearby enemy units within |cffffcc00400 AoE|r  for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage / |cff00ff001000|r heal. If the blow kills the target, the damage / heal doubles as well as the amount of pulses. Max |cffffcc005|r pulsing blasts with |cffffcc005|r pulses.\n\nPulsing Blasts: |cffffcc00" + I2S(HammerOfNature.count[index]) + "|r")
                        elseif id == ELEMENTAL_SPIN then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00125|r Health Regeneration\n+ |cffffcc00125|r Mana Regeneration\n+ |cffffcc00400|r Spell Power\n+ |cffffcc00250|r Intelligence\n\n|cff00ff00Passive|r: |cffffcc00Elemental Waves|r: Every attack has |cffffcc0020%|r chance to spawn an elemental wave at target location damaging an applying an special effect on the wave type. When proccing this effect there is |cffffcc0025%|r chance of creating either a |cffffcc00Holy|r, |cffff0000Fire|r, |cff00ff00Poison|r or |cff8080ffWater|r wave. A |cffffcc00Holy Wave|r will damage enemys and heal allies for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage. A |cffff0000Fire Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(500, unit) + " Magic|r damage and apply a |cffff0000Burn|r effect dealing |cff00ffff" + AbilitySpellDamageEx(100, unit) + " Magic|r damage per second for |cffffcc005|r seconds. |cff00ff00Poison Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and reduce their armor by |cffffcc0010|r  for |cffffcc0010|r seconds. Finnaly the |cff8080ffWater Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and reduce their movement speed by |cffffcc0050%|r for |cffffcc005|r seconds.")
                        elseif id == NECKLACE_OF_VIGOR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Health\n+ |cffffcc0010000|r Mana\n+ |cffffcc00750|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Vigorous Strike|r: After casting an ability your next basic attack will deal |cffffcc00" + R2I2S(3 * GetUnitSpellPowerFlat(unit)) + "|r as bonus |cffd45e19Pure|r damage to the target.\n\nStrikes Left: |cffffcc00" + I2S(NecklaceOfVigor.strikes[index]) + "|r")
                        elseif id == THUNDERGOD_SPEAR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00150%|r Attack Speed\n+ |cffffcc00500|r Damage\n+ |cffffcc00500|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%|r chance to release chain lightning, dealing |cff00ffff" + AbilitySpellDamageEx(500, unit) + " Magical|r damage up to |cffffcc005|r nearby enemies.\n\n|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When activated |cffffcc00Thundergod Spear|r has |cffffcc00100%|r chance of creating a |cffffcc00Chain Lightning|r dealing |cff00ffff" + AbilitySpellDamageEx(2000, unit) + " Magical|r damage up to |cffffcc005|r nearby enemies and drainning |cff8080ff500 Mana|r per proc.")
                        elseif id == WIZARD_STAFF then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00750|r Spell Power\n+ |cffffcc00250|r Intelligence\n+ |cffffcc0010000|r Health\n+ |cffffcc00300|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff00ffffMagical|r damage, heals for |cffffcc005%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Sorcery Mastery|r: After casting an ability, |cff00ffffSpell Power|r is increased by |cffffcc0025|r permanently.\n\nSpell Power Bonus: |cffffcc00" + I2S(WizardStaff.bonus[index]) + "|r")
                        elseif id == PHILOSOPHERS_STONE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0010000|r Mana\n+ |cffffcc0010000|r Health\n+ |cffffcc00300|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Philosopher's Stone|r, every second grants |cffffcc00250 Gold|r.\n\n|cff00ff00Passive|r: |cffffcc00Eternal Life|r: Every |cffffcc00120|r seconds |cff00ff00Health Regeneration|r is increased by |cffffcc00500|r  for |cffffcc0030|r seconds.\n\nGold Granted: |cffffcc00" + I2S(PhilosopherStone.gold[index]) + "|r")
                        elseif id == ENTITY_SCYTHE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00375|r All Stats\n+ |cffffcc00500|r Spell Power\n+ |cffffcc0050|r Movement Speed\n\n|cff00ff00Passive|r: |cffffcc00Gather of Souls|r: For every enemy unit killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r and |cff00ffffSpell Power|r are incresed by |cffffcc001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r and |cff00ffffSpell Power|r by |cffffcc0025|r.\n\nStats Bonus: |cffffcc00" + I2S(EntityScythe.bonus[index]) + "|r\nSpell Power Bonus: |cffffcc00" + I2S(EntityScythe.bonus[index]) + "|r")
                        elseif id == DOOMBRINGER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001250|r Damage\n+ |cffffcc0020%|r Critical Strike Chance\n+ |cffffcc00200%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Death's Blow|r: Every |cffffcc00fifth|r attack is a guaranteed Critical Strike with |cffffcc00200%|r Critical Damage Bonus within |cffffcc00400 AoE|r. If |cffffcc00Death's Blow|r kills the attacked enemy unit, damage is increased by |cffffcc001250|r for |cffffcc0010|r seconds.\n\nBonus Damage: |cffffcc00" + I2S(Doombringer.bonus[index]) + "|r")
                        elseif id == DUAL_ELEMENTAL_DAGGER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00500|r Damage\n+ |cffffcc00250|r Spell Power\n+ |cffffcc0025%|r Evasion\n+ |cffffcc0025%|r Life Steal\n\n|cff00ff00Active|r: |cffffcc00Dual Wield|r: When used, the |cffffcc00Dual Elemental Dagger|r switch between |cffff0000Burning|r and |cff8080ffFreezing|r Mode.\n\n|cff00ff00Passive|r: |cffffcc00Burn or Freeze|r: When |cffffcc00Dual Elemental Dagger|r is in |cffff0000Burning|r mode, all attacked enemy units take |cff00ffff" + AbilitySpellDamageEx(DualDagger.damage[index], unit) + " Magic|r damage per second for |cffffcc003|r seconds. When its in |cff8080ffFreezing|r mode, all attacked enemy units have theirs |cffffcc00Movement Speed and Attack Speed|r reduced by |cffffcc0050%|r for |cffffcc005|r seconds.")
                        elseif id == MOONCHANT_RING then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0020000|r Mana\n+ |cffffcc0010000|r Health\n+ |cffffcc00500|r Mana Regeneration\n+ |cffffcc00350|r Intelligence\n\n|cff00ff00Passive|r: |cffffcc00Moonchant Wisdom|r: Whenever your Hero, allied unit or enemy unit casts a spell within |cffffcc00800 AoE|r, |cffffcc00Moonchant Ring|r gains |cffffcc00|cffffcc00|r1|r charge.\n\n|cff00ff00Active|r: |cffffcc00Moonchant Well|r: When activated, all |cffffcc00Moonchant Ring|r charges are consumed, recovering |cffffcc00" + I2S(500 * MoonchantRing.charges[index]) + "|r |cffff0000Health|r and |cff00ffffMana|r.\n\nCharges: |cffffcc00" + I2S(MoonchantRing.charges[index]) + "|r")
                        elseif id == NATURE_GODDESS_STAFF then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0020%|r Spell Damage\n+ |cffffcc00500|r Intelligence\n+ |cffffcc0010000|r Health\n\n|cff00ff00Passive|r: |cffffcc00Thorned Rose|r: Provides |cffffcc00Thorn Aura|r within |cffffcc00600 AoE|r that returns |cffffcc0035%|r of damage taken.\n\n|cff00ff00Active|r: |cffffcc00Nature's Wrath|r: Creates a |cffffcc00Nature Tornado|r that slows enemy units within |cffffcc00600 AoE|r and deals |cff00ffff" + AbilitySpellDamageEx(1000, unit) + "Magic|r to enemy units within |cffffcc00400 AoE|r. When expired the |cffffcc00Nature Tornado|r explodes, healing all allies within |cffffcc00600 AoE|r for |cffffcc0020000|r |cffff0000Health|r and |cff00ffffMana|r and damaging enemies for |cffffcc0010000|r |cff808080Pure|r damage.\n\nLasts for 30 seconds.")
                        elseif id == PHOENIX_AXE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001250|r Damage\n+ |cffffcc00500|r Spell Power\n+ |cffffcc0025%|r Critical Strike Chance\n+ |cffffcc00250%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Fire Slash|r: After hitting a Critical Strike a |cffffcc00Fire Slash|r is lauched from the attacked unit position, damaging enemy units in its path for |cffffcc00" + I2S(1000 + PhoenixAxe.stacks[index]) + "|r |cffd45e19Pure|r damage. When attacking enemy Heroes, every |cffffcc00third|r attack will lauch a |cffffcc00Fire Slash|r.\n\n|cff00ff00Passive|r: |cffffcc00Slash Stacks|r: For every enemy unit killed by |cffffcc00Fire Slash|r, |cffffcc00Phoenix Axe|r gains |cffffcc001|r stack permanently, causing subsequent Slashes to deal more damage.\n\nStacks: |cffffcc00" + I2S(PhoenixAxe.stacks[index] / 100) + "|r")
                        elseif id == LEGENDARY_BLADE_III then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001500|r Damage\n+ |cffffcc001000|r Spell Power\n+ |cffffcc00150%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Bolt|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.")
                        elseif id == REDEMPTION_SWORD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001500|r Damage\n+ |cffffcc0030%|r Critical Strike Chance\n+ |cffffcc00300%|r Critical Strike Damage\n+ |cffffcc00300|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Redemption Strike|r: Every |cffffcc00fourth|r attack or |cffffcc00Critical Strike|r a light wave will travel from attacked unit postion damaging enemy units in its path for |cffffcc00" + I2S(RedemptionSword.bonus[index]) + "|r damage and will heal your Hero for the same amount for every unit damaged.")
                        elseif id == ELEMENTAL_STONE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0030000|r Mana\n+ |cffffcc0030000|r Health\n+ |cffffcc00750|r Health Regeneration\n+ |cffffcc00750|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Elemental Stone|r, every second grants |cffffcc00" + I2S(250 + 1*ElementalStone.stacks[index]) + " Gold|r. Every enemy unit killed grants a stack, increasing the income by |cffffcc001|r. Hero Kills grants |cffffcc0050|r Stacks.\n\nStacks: |cffffcc00" + I2S(ElementalStone.stacks[index]) + "|r\nGold Granted: |cffffcc00" + I2S(ElementalStone.gold[index]) + "|r")
                        elseif id == SAPPHIRE_HAMMER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00750|r Damage\n+ |cffffcc00400|r Spell Power\n+ |cffffcc00500|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00350 AoE|r, dealing |cffffcc0045%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Unstopable Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc0010|r for |cffffcc0060|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Shattering Blow|r: Every attack has |cffffcc0020%|r chance to shatter the earth around the target, dealing |cff00ffff" + AbilitySpellDamageEx((GetHeroStr(unit, true)/2), unit) + " Magic|r damage and stunning all enemy units within |cffffcc00400 AoE|r for |cffffcc003|r seconds |cffffcc00(1 for Heroes)|r and Healing the Hero for the same amount.\n\nStrength Bonus: |cffffcc00" + I2S(SapphireHammer.bonus[index]) + "|r")
                        elseif id == WARLOCK_RING then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0025000|r Mana\n+ |cffffcc0015000|r Health\n+ |cffffcc00750|r Mana Regeneration\n+ |cffffcc00500|r Intelligence\n\n|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(unit, true) * 0.5)) + "|r.")
                        elseif id == TWIN_PHANTOM_SPEAR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc00250%|r Attack Speed\n+ |cffffcc00750|r Damage\n+ |cffffcc00750|r Spell Power\n+ |cffffcc0075|r Movement Speed\n\n|cff00ff00Active|r: |cffffcc00Thunder Wrath|r: When in |cffffcc00Thunder Wrath|r Mode, every attack has |cffffcc00100%|r chance to release |cffffcc00Chain Lightning|r, dealing |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magical|r damage up to |cffffcc003|r nearby enemies.\n\n|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When in |cffffcc00Lightning Fury|r Mode, every attack has |cffffcc0020%|r chance of creating a |cffffcc00Chain Lightning|r that will bounce indefinitly to the closest enemy unit within |cffffcc00350 AoE|r dealing |cff00ffff" + AbilitySpellDamageEx(250, unit) + " Magical|r damage.")
                        elseif id == RED_MOON_SCYTH then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc00500|r All Stats\n+ |cffffcc00500|r Spell Power\n+ |cffffcc00500|r Damage\n+ |cffffcc0050|r Movement Speed\n+ |cffffcc0050%|r Life Steal\n\n|cff00ff00Passive|r: |cffffcc00Blood Harvest|r: For every enemy unit killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r, |cff00ffffSpell Power|r and |cff00ff00Damage|r are incresed by |cffffcc001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r, |cff00ffffSpell Power|r and |cff00ff00Damage|r by |cffffcc0050|r.\n\nStats Bonus: |cffffcc00" + I2S(MoonScyth.stats[index]) + "|r\nDamage Bonus: |cffffcc00" + I2S(MoonScyth.damage[index]) + "|r\nSpell Power Bonus: |cffffcc00" + I2S(MoonScyth.stats[index]) + "|r")
                        elseif id == LEGENDARY_BLADE_IV then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001750|r Damage\n+ |cffffcc001250|r Spell Power\n+ |cffffcc00200%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Blade|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Dark Blade|r: Every |cffffcc004|r attacks a dark bolt will strike the target reducing its armor by |cffffcc0050|r for |cffffcc005|r seconds.")
                        elseif id == HOLY_HAMMER then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc001000|r Damage\n+ |cffffcc00750|r Spell Power\n+ |cffffcc00750|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00400 AoE|r, dealing |cffffcc0050%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Holy Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc001|r permanently.\n\n|cff00ff00Passive|r: |cffffcc00Holy Inquisition|r: When dealing |cffff0000Physical|r or |cff00ff00Cleave|r damage, |cffffcc00Holy Hammer|r stores |cffffcc00100%|r (|cffffcc0025%|r for |cff00ff00Cleave|r damage) of the damage dealt and immediately starts regenerating health for |cffffcc0010%|r of all damage stored, depleting it until nothing is left. The more damage is stored through |cffffcc00Holy Inquisition|r the higher |cff00ff00Health Regeneration|r becomes. All damage stored depletes within |cffffcc0010|r seconds if no more damage is stored. Stores |cffffcc002x|r as much damage dealt to |cffffcc00Heroes|r.\n\nStrength Bonus: |cffffcc00" + I2S(HolyHammer.bonus[index]) + "|r")
                        elseif id == GLUTTONOUS_AXE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc002250|r Damage\n+ |cffffcc0050%|r Life Steal\n+ |cffffcc0020%|r Critical Strike Chance\n+ |cffffcc00400%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Devouring Strike|r: After hitting a |cffffcc00Critical Strike|r, |cffffcc00Critical Chance|r and |cffffcc00Life Steal|r are increased by |cffffcc000.2%|r and |cffffcc00Critical Damage|r is increased by |cffffcc000.5%|r permanently.\n\nCritical Chance: |cffffcc00" + R2SW(GetUnitCriticalChance(unit), 1, 2) + " %|r\nCritical Damage: |cffffcc00" + R2SW(100*GetUnitCriticalMultiplier(unit), 1, 2) + " %|r\nLife Steal: |cffffcc00" + R2SW(100*GetUnitLifeSteal(unit), 1, 2) + " %|r")
                        elseif id == CROWN_OF_GODS then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0025000|r Mana\n+ |cffffcc0025000|r Health\n+ |cffffcc00750|r Mana Regeneration\n+ |cffffcc00750|r Intelligence\n+ |cffffcc00750|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(unit, true) * CrownOfGods.multiplier[index])) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Divine Protection|r: |cffffcc00Crown of Gods|r provides a divine shield that grows by |cffffcc00100%|r of your Hero total |cff00ffffIntelligence|r every second, blocking all damage taken. When depleted, |cffffcc00Divine Protection|r needs |cffffcc0020|r seconds to recharge, and while recharging, |cffffcc00Arcane Power|r effect is increased to |cffffcc00100%|r of total |cff00ffffIntelligence|r amplification.")
                        elseif id == BLACK_ARMOR then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0040000|r Health\n+ |cffffcc0015|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0020%|r.\n\n|cff00ff00Passive|r: |cffffcc00Spiked Plate|r: When being attacked, returns |cffffcc00" + R2SW(0.5*GetUnitBonus(unit, BONUS_ARMOR), 1, 1) + "%|r (|cffffcc00" + R2S(3*GetUnitBonus(unit, BONUS_ARMOR)) + "% against non-Hero|r) of the damage taken as |cffd45e19Pure|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Impenetrable|r: All damage reduced by |cffffcc00Damage Reduction|r effect is stored. When all damage stored reaches |cffffcc0050000|r, your Hero |cff808080Armor|r is increased by |cffffcc001|r.\n\nArmor Bonus: |cffffcc00" + I2S(BlackArmor.armor[index]) + "|r\nDamage Reduced: |cffffcc00" + R2I2S(BlackArmor.stored[index]) + "|r")
                        elseif id == ANGELIC_SHIELD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc0050000|r Health\n+ |cffffcc00500|r Damage Block\n+ |cffffcc0020|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Guardian Angel|r: |cffffcc00Damage Block|r increases by |cffffcc00100|r  for every |cffffcc0010%|r of missing health. In addition, overblocked damage heals your Hero.\n\n|cff00ff00Active|r: |cffffcc00Sanctified Zone|r: When activated, all allied units within |cffffcc00800 AoE|r becomes immune to all damage, and all the damage your Hero takes during this time is evenly distributed amongst allied units within range. Lasts |cffffcc0015|r seconds.\n\nDamage Block: |cffffcc00" + R2I2S(500 + (10* R2I(100 - GetUnitLifePercent(unit)))) + "|r")
                        elseif id == RADIANT_HELMET then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc0010000|r Mana\n+ |cffffcc0020000|r Health\n+ |cffffcc00500|r Health Regeneration\n+ |cffffcc00250|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Radiant Strength|r: |cff00ff00Health Regeneration|r is increased by |cffffcc00" + R2I2S(RadiantHelmet.regen[index]) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Resilient Attempt|r: When your Hero life drops below |cffffcc0050%|r, |cffffcc00Radiant Strength|r effect is amplified to |cffffcc00100%|r for |cffffcc0020|r seconds. |cffffcc0090|r seconds cooldown.\n\nCooldown: |cffffcc00" + R2I2S(R2I(RadiantHelmet.cooldown[index]/10)) + "|r")
                        elseif id == ELEMENTAL_SPHERE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc002000|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Elemental Essence|r: When a enemy unit dies, it will spawn in its location one |cffffcc00Elemental Essence|r. Any Hero carrying |cffffcc00Elemental Sphere|r will collect all essences within |cffffcc00800 AoE|r, gaining its effects permanently depending on the essence collected. Dying Heroes spawns all 5 essences. Essences lasts for |cffffcc0020|r seconds.\n\n|cffff0000Fire Essence|r: |cffff0000Health|r is increased by |cffffcc0050|r and |cff00ff00Health Regeneration|r is increased by |cffffcc005|r.\n\n|cff00ffffWater Essence|r: |cff00ffffMana|r is increased by |cffffcc0050|r and |cff00ffffMana Regeneration|r is increased by |cffffcc005|r.\n\n|cff808080Air Essence|r: |cffff00ffEvasion|r is increased by |cffffcc000.1%|r and |cffffcc00Movement Speed|r is increased by |cffffcc001|r.\n\n|cff00ff00Life Essence|r: |cff00ffffSpell Power|r is increased by |cffffcc0010|r.\n\ncff6f2583Dark Essence|r: |cffff0000Damage|r is increased by |cffffcc0010|r.\n\n|cffff0000Fire|r: " + I2S(ElementalSphere.fire[index]) + "\n|cff00ffffWater|r: " + I2S(ElementalSphere.water[index]) + "\n|cff808080Air|r: " + I2S(ElementalSphere.air[index]) + "\n|cff00ff00Life|r: " + I2S(ElementalSphere.life[index]) + "\n|cff6f2583Dark|r: " + I2S(ElementalSphere.dark[index]))
                        elseif id == LEGENDARY_BLADE_V then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives:|r\n+ |cffffcc002000|r Damage\n+ |cffffcc001500|r Spell Power\n+ |cffffcc00250%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc005|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc005|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Blade|r: Every |cffffcc005|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, unit) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Dark Blade|r: Every |cffffcc005|r attacks a dark bolt will strike the target reducing its armor by |cffffcc0050|r for |cffffcc005|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Air Blade|r: Every |cffffcc005|r attacks a wind bolt will strike the target and grant maximum movement speed for |cffffcc003|r seconds.")
                        elseif id == LIGHTNING_SWORD then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc002500|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Quick as Lightning|r: |cffffcc00Base Attack Time|r is reduced by |cffffcc000.5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Lightning Embodiment|r: Every |cffffcc000.5|r seconds, a |cffffcc00Lightning|r will emanate from your Hero and hit a random enemy unit within |cffffcc00800 AoE|r, dealing |cff00ffff" + AbilitySpellDamageEx(2500, unit) + " Magic|r damage.")
                        elseif id == SAKURA_BLADE then
                            call BlzSetItemExtendedTooltip(item, "|cffffcc00Gives|r:\n+ |cffffcc001000|r Damage\n+ |cffffcc00100%|r Movement Speed\n+ |cffffcc00400%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Sakura Fall|r: |cffffcc00Movement Speed|r, |cffffcc00Attack Speed|r and |cffff0000Damage|r provided by Sakura Blade also affect allied units.|r\n\n|cff00ff00Passive|r: |cffffcc00Sakura Lamina|r: For every allied Hero within |cffffcc00800 AoE|r, the damage provided by |cffffcc00Sakura Blade|r is increased by |cffffcc00250|r.\n\nBonus Damage: |cffffcc00" + I2S(250*SakuraBlade.bonus[index]) + "|r")
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onPickup takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local item i = GetManipulatedItem()
            local integer id = GetItemTypeId(i)
            local boolean courier = GetUnitTypeId(u) == 'n00J'

            if not courier then
                if id == BOOTS_OF_SPEED then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 25, i)
                elseif id == ORB_OF_DARKNESS then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
                elseif id == ORB_OF_FIRE then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIfb\\AIfbTarget.mdl", "weapon")
                elseif id == ORB_OF_FROST then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
                elseif id == ORB_OF_LIGHT then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
                elseif id == ORB_OF_LIGHTNING then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
                elseif id == ORB_OF_SANDS then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "SandOrb.mdl", "weapon")
                elseif id == ORB_OF_SOULS then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
                elseif id == ORB_OF_THORNS then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruption.mdl", "weapon")
                elseif id == ORB_OF_VENOM then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
                elseif id == ORB_OF_WATER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
                elseif id == ORB_OF_WIND then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
                elseif id == GOLDEN_SWORD then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 24, i)
                elseif id == FUSED_LIFE_CRYSTALS then
                    call LinkBonusToItem(u, BONUS_HEALTH, 350, i)
                elseif id == HEAVY_HAMMER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
                elseif id == SUMMONING_BOOK then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 15, i)
                    call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, 0.1, i)
                elseif id == BOOTS_OF_AGILITY then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 10, i)
                elseif id == BOOTS_OF_STRENGTH then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 10, i)
                elseif id == BOOTS_OF_INTELLIGENCE then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 10, i)
                elseif id == BOOTS_OF_RESTORATION then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
                elseif id == HEAVY_BOOTS then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.15, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
                elseif id == BOOTS_OF_THE_BRAVES then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 150, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.15, i)
                    call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, 0.15, i)
                elseif id == BOOTS_OF_FLAMES then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                elseif id == SILVER_BOOTS then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 4, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
                elseif id == GOLDEN_BOOTS then
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.15, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
                elseif id == HARDENED_SHIELD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 200, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 2, i)
                elseif id == GOLDEN_PLATEMAIL then
                    call LinkBonusToItem(u, BONUS_HEALTH, 225, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 3, i)
                elseif id == LIFE_CRYSTAL then
                    call LinkBonusToItem(u, BONUS_HEALTH, 100, i)
                elseif id == LIFE_ESSENCE_CRYSTAL then
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 2, i)
                elseif id == MANA_CRYSTAL then
                    call LinkBonusToItem(u, BONUS_MANA, 100, i)
                elseif id == MASK_OF_DEATH then
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.05, i)
                elseif id == ASSASSINS_DAGGER then
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 10, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
                elseif id == RUSTY_SWORD then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 7, i)
                elseif id == PLATEMAIL then
                    call LinkBonusToItem(u, BONUS_ARMOR, 2, i)
                elseif id == BRACELET_OF_INTELLIGENCE then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 5, i)
                elseif id == CLAWS_OF_AGILITY then
                    call LinkBonusToItem(u, BONUS_AGILITY, 5, i)
                elseif id == SIMPLE_BOW then
                    call LinkBonusToItem(u, BONUS_AGILITY, 5, i)
                elseif id == GAUNTLET_OF_STRENGTH then
                    call LinkBonusToItem(u, BONUS_STRENGTH, 5, i)
                elseif id == CRYSTAL_RING then
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 1, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 10, i)
                elseif id == GLOVES_OF_HASTE then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.10, i)
                elseif id == ELEMENTAL_SHARD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 175, i)
                    call LinkBonusToItem(u, BONUS_MANA, 175, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 3, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 3, i)
                elseif id == BERSERKER_BOOTS then //Berserker Boots
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 15, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 35, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.1, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                elseif id == RUNIC_BOOTS then
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 75, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 150, i)
                    call LinkBonusToItem(u, BONUS_MANA, 150, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == GLAIVE_SCYTHE then
                    call LinkBonusToItem(u, BONUS_AGILITY, 7, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 7, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 7, i)
                elseif id == MAGE_STICK then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
                    call LinkBonusToItem(u, BONUS_MANA, 150, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 1.5, i)
                elseif id == SORCERER_RING then
                    call LinkBonusToItem(u, BONUS_MANA, 175, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 3, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 20, i)
                elseif id == WARRIOR_BLADE then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.20, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                elseif id == BLACK_NAVAJA then
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 12, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == IRON_AXE then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 10, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.20, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 5, i)
                elseif id == MASK_OF_MADNESS then
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.1, i)
                elseif id == INFUSED_MANA_CRYSTAL then
                    call LinkBonusToItem(u, BONUS_MANA, 350, i)
                elseif id == GLOVES_OF_SPEED then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.25, i)
                elseif id == ORCISH_AXE then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 12, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.30, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 28, i)
                elseif id == ENHANCED_HAMMER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 12, i)
                elseif id == EMERALD_SHOULDER_PLATE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 375, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 8, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == STEEL_ARMOR then
                    call LinkBonusToItem(u, BONUS_HEALTH, 500, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 4, i)
                elseif id == WARRIOR_HELMET then
                    call LinkBonusToItem(u, BONUS_STRENGTH, 7, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SOUL_SCYTHER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 10, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 10, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 10, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == GLOVES_OF_SILVER then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.5, i)
                elseif id == WARRIOR_SHIELD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 400, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 3, i)
                elseif id == MAGE_STAFF then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 25, i)
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.05, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 8, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 275, i)
                elseif id == DEMONIC_MASK then
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.12, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
                elseif id == MAGMA_HELMET then
                    call LinkBonusToItem(u, BONUS_STRENGTH, 10, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 7, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == CHILLING_AXE then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 15, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.35, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 35, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
                elseif id == HOLY_BOW then
                    call LinkBonusToItem(u, BONUS_AGILITY, 7, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 10, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
                elseif id == LIGHTNING_SPEAR then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.55, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 15, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == DESERT_RING then
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 4, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 25, i)
                    call LinkBonusToItem(u, BONUS_MANA, 250, i)
                elseif id == SOUL_SWORD then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 20, i)
                    call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == NATURE_STAFF  then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_PERCENT, 0.1, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 300, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 10, i)
                elseif id == TOXIC_DAGGER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 30, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == OCEANIC_MACE then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 20, i)
                    call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
                elseif id == WIND_SWORD then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 25, i)
                    call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_POWER then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 30, i)
                elseif id == SPHERE_OF_FIRE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_WATER then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_NATURE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_DIVINITY then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                elseif id == SPHERE_OF_LIGHTNING then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_DARKNESS then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SPHERE_OF_AIR then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ETERNITY_STONE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 400, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == FUSION_CRYSTAL then
                    call LinkBonusToItem(u, BONUS_HEALTH, 500, i)
                    call LinkBonusToItem(u, BONUS_MANA, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == WIZARD_STONE then
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 5, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 250, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 5, i)
                    call LinkBonusToItem(u, BONUS_MANA, 250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ANCIENT_STONE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 50, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 10, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 500, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 10, i)
                    call LinkBonusToItem(u, BONUS_MANA, 500, i)
                elseif id == GIANTS_HAMMER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 30, i)
                elseif id == AXE_OF_THE_GREEDY then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 25, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 1., i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 45, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == KNIGHT_BLADE then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 0.5, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.25, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 40, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == RITUAL_DAGGER then
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 15, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.15, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 30, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SAPHIRE_SHOULDER_PLATE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 150, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == FLAMING_ARMOR then
                    call LinkBonusToItem(u, BONUS_HEALTH, 18000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 10, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == DRAGON_HELMET then
                    call LinkBonusToItem(u, BONUS_HEALTH, 7500, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 100, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 100, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == REAPERS_EDGE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 200, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 200, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 200, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == GLOVES_OF_GOLD then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.00, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == COMMANDERS_SHIELD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 12000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 8, i)
                elseif id == SORCERER_STAFF then
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.025, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 150, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == BOOK_OF_FLAMES then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                elseif id == BOOK_OF_OCEANS then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_MANA, 5000, i)
                elseif id == BOOK_OF_NATURE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 200, i)
                elseif id == BOOK_OF_LIGHT then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 200, i)
                elseif id == BOOK_OF_CHAOS then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                elseif id == BOOK_OF_ICE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 10, i)
                elseif id == HELLISH_MASK then
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.3, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                elseif id == ENFLAMED_BOW then
                    call LinkBonusToItem(u, BONUS_AGILITY, 250, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                elseif id == RING_OF_CONVERSION then
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
                elseif id == ANCIENT_SPHERE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 100, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 100, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 100, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == LEGENDARY_BLADE_I then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 0.50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                // elseif id == TRIEDGE_SWORD then
                //     call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                //     call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 10, i)
                //     call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 1, i)
                    
                //     static if LIBRARY_MirrorImage then
                //         if not IsUnitIllusionEx(u) then
                //             call update(u, i)
                //         endif
                //     endif
                elseif id == CROWN_OF_RIGHTEOUSNESS then
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 600, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == HEATING_CLOAK then
                    call LinkBonusToItem(u, BONUS_MANA, 5000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 5000, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == HAMMER_OF_NATURE then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 250, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ELEMENTAL_SPIN then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 125, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 125, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == NECKLACE_OF_VIGOR then
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == THUNDERGOD_SPEAR then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == WIZARD_STAFF then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.05, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 250, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 300, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == PHILOSOPHERS_STONE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 300, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ENTITY_SCYTHE then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 375, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 375, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 375, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == LEGENDARY_BLADE_II then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.00, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                elseif id == DOOMBRINGER then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 2, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == DUAL_ELEMENTAL_DAGGER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 250, i)
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, 25, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.25, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == APOCALYPTIC_MASK then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
                elseif id == RADIANT_HELMET then
                    call LinkBonusToItem(u, BONUS_HEALTH, 20000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 10000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 500, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == JADEN_SHOULDER_PLATE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == MOONCHANT_RING then
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 20000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 350, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == BLOODBOURNE_SHIELD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 15, i)
                elseif id == NATURE_GODDESS_STAFF then
                    call LinkBonusToItem(u, BONUS_HEALTH, 10000, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_PERCENT, 0.2, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == PHOENIX_AXE then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 25, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 2.5, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == WEAVER_I then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 250, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 250, i)
                elseif id == LEGENDARY_BLADE_III then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 1.50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1000, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == REDEMPTION_SWORD then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 30, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 300, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ELEMENTAL_STONE then
                    call LinkBonusToItem(u, BONUS_HEALTH, 30000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 30000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 750, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SAPPHIRE_HAMMER then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 400, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == FIRE_BOW then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 500, i)
                elseif id == WARLOCK_RING then
                    call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == TWIN_PHANTOM_SPEAR then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 750, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.50, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 75, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == RED_MOON_SCYTH then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 500, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, 50, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == HOLY_SCEPTER then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1250, i)
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.1, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
                elseif id == MAGUS_ORB then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 500, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 500, i)
                elseif id == WEAVER_II then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 20000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 20000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 300, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 300, i)
                elseif id == LEGENDARY_BLADE_IV then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.00, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1750, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1250, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SWORD_OF_DOMINATION then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 35, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3.5, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 500, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
                elseif id == ARC_TRINITY then
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, -30, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 3, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
                elseif id == HOLY_HAMMER then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 750, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == GLUTTONOUS_AXE then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 2250, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, 20, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, 4, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, 0.5, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == CROWN_OF_GODS then
                    call LinkBonusToItem(u, BONUS_HEALTH, 25000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 25000, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 750, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 750, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == BLACK_ARMOR then
                    call LinkBonusToItem(u, BONUS_HEALTH, 40000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 15, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == ANGELIC_SHIELD then
                    call LinkBonusToItem(u, BONUS_HEALTH, 50000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 20, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == HELMET_OF_ETERNITY then
                    call LinkBonusToItem(u, BONUS_HEALTH, 30000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, 1000, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, 500, i)
                elseif id == ARCANA_SCEPTER then
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 750, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1500, i)
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, 0.25, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, 750, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, 15000, i)
                    call LinkBonusToItem(u, BONUS_MANA, 15000, i)
                elseif id == ELEMENTAL_SPHERE then
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 2000, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == LEGENDARY_BLADE_V then
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, 2.50, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 2000, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 1500, i)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == CROWN_OF_ICE then
                    call LinkBonusToItem(u, BONUS_STRENGTH, 1000, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, 1000, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, 1000, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE, 1000, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER_FLAT, 2000, i)
                elseif id == GOLDEN_HEART then
                    call LinkBonusToItem(u, BONUS_HEALTH, 50000, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, 50, i)
                elseif id == LIGHTNING_SWORD then
                    call LinkBonusToItem(u, BONUS_DAMAGE, 2500, i)
                    call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) - 0.5, 0)
                    
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                elseif id == SAKURA_BLADE then
                    static if LIBRARY_MirrorImage then
                        if not IsUnitIllusionEx(u) then
                            call update(u, i)
                        endif
                    endif
                endif
            endif
        endmethod

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

            call ShopAddItem(shop, BOOTS_OF_SPEED, movement)
            call ShopAddItem(shop, ANKH_OF_REINCARNATION, consumable)
            call ShopAddItem(shop, POTION_OF_RESTORATION, consumable)
            call ShopAddItem(shop, MASK_OF_DEATH, regeneration)
            call ShopAddItem(shop, CLOAK_OF_FLAMES, damage)
            call ShopAddItem(shop, COMMOM_SHIELD, armor)
            call ShopAddItem(shop, HEAVY_HAMMER, damage)
            call ShopAddItem(shop, ASSASSINS_DAGGER, damage)
            call ShopAddItem(shop, IRON_AXE, damage)
            call ShopAddItem(shop, SIMPLE_BOW, agility)
            call ShopAddItem(shop, SUMMONING_BOOK, spellPower + cooldown)
            call ShopAddItem(shop, COURIER, consumable)
            call ShopAddItem(shop, LIFE_CRYSTAL, health)
            call ShopAddItem(shop, MANA_CRYSTAL, mana)
            call ShopAddItem(shop, LIFE_ESSENCE_CRYSTAL, regeneration)
            call ShopAddItem(shop, CRYSTAL_RING, regeneration + spellPower)
            call ShopAddItem(shop, HOMECOMING_STONE, movement)
            call ShopAddItem(shop, BRACELET_OF_INTELLIGENCE, intelligence)
            call ShopAddItem(shop, CLAWS_OF_AGILITY, agility)
            call ShopAddItem(shop, GAUNTLET_OF_STRENGTH, strength)
            call ShopAddItem(shop, GLOVES_OF_HASTE, attackSpeed)
            call ShopAddItem(shop, PLATEMAIL, armor)
            call ShopAddItem(shop, RUSTY_SWORD, damage)
            call ShopAddItem(shop, ORB_OF_FIRE, damage)
            call ShopAddItem(shop, ORB_OF_FROST, damage)
            call ShopAddItem(shop, ORB_OF_LIGHT, damage)
            call ShopAddItem(shop, ORB_OF_LIGHTNING, damage)
            call ShopAddItem(shop, ORB_OF_SANDS, damage)
            call ShopAddItem(shop, ORB_OF_SOULS, damage + regeneration)
            call ShopAddItem(shop, ORB_OF_THORNS, damage)
            call ShopAddItem(shop, ORB_OF_VENOM, damage)
            call ShopAddItem(shop, ORB_OF_WATER, damage)
            call ShopAddItem(shop, ORB_OF_WIND, damage + movement)
            call ShopAddItem(shop, ORB_OF_DARKNESS, damage)
            call ShopAddItem(shop, SPHERE_OF_POWER, spellPower)
            call ShopAddItem(shop, BOOTS_OF_THE_BRAVES, movement + health + attackSpeed + cooldown)
            call ShopAddItem(shop, BOOTS_OF_AGILITY, movement + agility)
            call ShopAddItem(shop, BOOTS_OF_INTELLIGENCE, movement + intelligence)
            call ShopAddItem(shop, BOOTS_OF_STRENGTH, movement + strength)
            call ShopAddItem(shop, BOOTS_OF_RESTORATION, movement + regeneration + health)
            call ShopAddItem(shop, BOOTS_OF_FLAMES, movement + damage)
            call ShopAddItem(shop, GOLDEN_BOOTS, movement + regeneration + damage)
            call ShopAddItem(shop, HEAVY_BOOTS, movement + attackSpeed + damage)
            call ShopAddItem(shop, SILVER_BOOTS, movement + armor + health)
            call ShopAddItem(shop, BERSERKER_BOOTS, movement + attackSpeed + damage)
            call ShopAddItem(shop, RUNIC_BOOTS, movement + health + mana + spellPower)
            call ShopAddItem(shop, GOLDEN_SWORD, damage)
            call ShopAddItem(shop, GOLDEN_PLATEMAIL, armor + health)
            call ShopAddItem(shop, FUSED_LIFE_CRYSTALS, health)
            call ShopAddItem(shop, INFUSED_MANA_CRYSTAL, mana)
            call ShopAddItem(shop, ELEMENTAL_SHARD, health + mana + regeneration)
            call ShopAddItem(shop, HARDENED_SHIELD, health + armor)
            call ShopAddItem(shop, MASK_OF_MADNESS, regeneration)
            call ShopAddItem(shop, GLOVES_OF_SPEED, attackSpeed)
            call ShopAddItem(shop, GLAIVE_SCYTHE, agility + strength + intelligence)
            call ShopAddItem(shop, MAGE_STICK, spellPower + mana + regeneration)
            call ShopAddItem(shop, SORCERER_RING, mana + regeneration + spellPower)
            call ShopAddItem(shop, WARRIOR_BLADE, damage + attackSpeed)
            call ShopAddItem(shop, BLACK_NAVAJA, damage)
            call ShopAddItem(shop, ORCISH_AXE, damage)
            call ShopAddItem(shop, ENHANCED_HAMMER, damage)
            call ShopAddItem(shop, EMERALD_SHOULDER_PLATE, health + strength)
            call ShopAddItem(shop, STEEL_ARMOR, health + armor)
            call ShopAddItem(shop, WARRIOR_HELMET, strength + regeneration)
            call ShopAddItem(shop, SOUL_SCYTHER, damage + strength + agility + intelligence)
            call ShopAddItem(shop, GLOVES_OF_SILVER, attackSpeed)
            call ShopAddItem(shop, WARRIOR_SHIELD, health + armor)
            call ShopAddItem(shop, MAGE_STAFF, spellPower + intelligence + health + regeneration)
            call ShopAddItem(shop, DEMONIC_MASK, damage + regeneration)
            call ShopAddItem(shop, MAGMA_HELMET, strength + regeneration)
            call ShopAddItem(shop, CHILLING_AXE, damage)
            call ShopAddItem(shop, HOLY_BOW, damage + agility)
            call ShopAddItem(shop, LIGHTNING_SPEAR, damage + attackSpeed)
            call ShopAddItem(shop, DESERT_RING, mana + regeneration + spellPower)
            call ShopAddItem(shop, SOUL_SWORD, damage + regeneration)
            call ShopAddItem(shop, NATURE_STAFF, spellPower + intelligence + health)
            call ShopAddItem(shop, TOXIC_DAGGER, damage)
            call ShopAddItem(shop, OCEANIC_MACE, damage)
            call ShopAddItem(shop, WIND_SWORD, damage + movement)
            call ShopAddItem(shop, SPHERE_OF_FIRE, spellPower)
            call ShopAddItem(shop, SPHERE_OF_WATER, spellPower)
            call ShopAddItem(shop, SPHERE_OF_NATURE, spellPower)
            call ShopAddItem(shop, SPHERE_OF_DIVINITY, spellPower)
            call ShopAddItem(shop, SPHERE_OF_LIGHTNING, spellPower)
            call ShopAddItem(shop, SPHERE_OF_DARKNESS, spellPower)
            call ShopAddItem(shop, SPHERE_OF_AIR, spellPower)
            call ShopAddItem(shop, ETERNITY_STONE, health + regeneration)
            call ShopAddItem(shop, FUSION_CRYSTAL, health + mana + regeneration)
            call ShopAddItem(shop, WIZARD_STONE, health + mana + regeneration)
            call ShopAddItem(shop, ANCIENT_STONE, health + mana + regeneration + spellPower)
            call ShopAddItem(shop, KNIGHT_BLADE, damage + attackSpeed)
            call ShopAddItem(shop, RITUAL_DAGGER, damage + regeneration)
            call ShopAddItem(shop, GIANTS_HAMMER, damage)
            call ShopAddItem(shop, AXE_OF_THE_GREEDY, damage)
            call ShopAddItem(shop, SAPHIRE_SHOULDER_PLATE, health + strength)
            call ShopAddItem(shop, FLAMING_ARMOR, health + armor)
            call ShopAddItem(shop, DRAGON_HELMET, health + strength + regeneration)
            call ShopAddItem(shop, REAPERS_EDGE, spellPower + strength + agility + intelligence)
            call ShopAddItem(shop, GLOVES_OF_GOLD, attackSpeed)
            call ShopAddItem(shop, COMMANDERS_SHIELD, armor + health)
            call ShopAddItem(shop, SORCERER_STAFF, spellPower + health + intelligence + regeneration)
            call ShopAddItem(shop, BOOK_OF_FLAMES, spellPower + damage + intelligence)
            call ShopAddItem(shop, BOOK_OF_OCEANS, spellPower + intelligence + mana)
            call ShopAddItem(shop, BOOK_OF_NATURE, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, BOOK_OF_LIGHT, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, BOOK_OF_CHAOS, spellPower + intelligence + health)
            call ShopAddItem(shop, BOOK_OF_ICE, spellPower + intelligence + armor)
            call ShopAddItem(shop, HELLISH_MASK, damage + regeneration)
            call ShopAddItem(shop, ENFLAMED_BOW, damage + agility)
            call ShopAddItem(shop, RING_OF_CONVERSION, mana + regeneration)
            call ShopAddItem(shop, ANCIENT_SPHERE, spellPower + mana + health + regeneration)
            call ShopAddItem(shop, LEGENDARY_BLADE_I, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, TRIEDGE_SWORD, damage)
            call ShopAddItem(shop, CROWN_OF_RIGHTEOUSNESS, mana + regeneration + spellPower)
            call ShopAddItem(shop, HEATING_CLOAK, mana + health + damage)
            call ShopAddItem(shop, HAMMER_OF_NATURE, damage + strength + spellPower)
            call ShopAddItem(shop, ELEMENTAL_SPIN, regeneration + spellPower + intelligence)
            call ShopAddItem(shop, NECKLACE_OF_VIGOR, health + mana + spellPower)
            call ShopAddItem(shop, THUNDERGOD_SPEAR, attackSpeed + damage + spellPower)
            call ShopAddItem(shop, WIZARD_STAFF, intelligence + regeneration + spellPower + health)
            call ShopAddItem(shop, PHILOSOPHERS_STONE, regeneration + mana + health)
            call ShopAddItem(shop, ENTITY_SCYTHE, spellPower + movement + agility + strength + intelligence)
            call ShopAddItem(shop, LEGENDARY_BLADE_II, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, DOOMBRINGER, damage)
            call ShopAddItem(shop, DUAL_ELEMENTAL_DAGGER, damage + spellPower + regeneration)
            call ShopAddItem(shop, APOCALYPTIC_MASK, damage + regeneration)
            call ShopAddItem(shop, RADIANT_HELMET, health + mana + strength + regeneration)
            call ShopAddItem(shop, JADEN_SHOULDER_PLATE, health + strength)
            call ShopAddItem(shop, MOONCHANT_RING, health + mana + regeneration + intelligence)
            call ShopAddItem(shop, BLOODBOURNE_SHIELD, health + armor)
            call ShopAddItem(shop, NATURE_GODDESS_STAFF, spellPower + health + intelligence)
            call ShopAddItem(shop, PHOENIX_AXE, spellPower + damage)
            call ShopAddItem(shop, WEAVER_I, mana + health + regeneration + spellPower + intelligence + cooldown)
            call ShopAddItem(shop, LEGENDARY_BLADE_III, damage + spellPower + attackSpeed)
            call ShopAddItem(shop, REDEMPTION_SWORD, damage + spellPower)
            call ShopAddItem(shop, ELEMENTAL_STONE, mana + health + regeneration)
            call ShopAddItem(shop, SAPPHIRE_HAMMER, damage + spellPower + strength)
            call ShopAddItem(shop, FIRE_BOW, damage + spellPower + agility)
            call ShopAddItem(shop, WARLOCK_RING, health + spellPower + mana + regeneration + intelligence)
            call ShopAddItem(shop, TWIN_PHANTOM_SPEAR, attackSpeed + spellPower + damage + movement)
            call ShopAddItem(shop, RED_MOON_SCYTH, regeneration + spellPower + damage + movement + agility + strength + intelligence)
            call ShopAddItem(shop, HOLY_SCEPTER, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, MAGUS_ORB, spellPower + intelligence + regeneration)
            call ShopAddItem(shop, WEAVER_II, mana + health + regeneration + spellPower + intelligence + cooldown)
            call ShopAddItem(shop, LEGENDARY_BLADE_IV, spellPower + damage + attackSpeed)
            call ShopAddItem(shop, SWORD_OF_DOMINATION, spellPower + damage)
            call ShopAddItem(shop, ARC_TRINITY, damage + regeneration)
            call ShopAddItem(shop, HOLY_HAMMER, spellPower + damage + strength + regeneration)
            call ShopAddItem(shop, GLUTTONOUS_AXE, damage + regeneration)
            call ShopAddItem(shop, CROWN_OF_GODS, health + mana + regeneration + intelligence + spellPower)
            call ShopAddItem(shop, BLACK_ARMOR, health + armor)
            call ShopAddItem(shop, ANGELIC_SHIELD, health + armor)
            call ShopAddItem(shop, HELMET_OF_ETERNITY, health + mana + regeneration + strength)
            call ShopAddItem(shop, ARCANA_SCEPTER, health + mana + regeneration + intelligence + spellPower)
            call ShopAddItem(shop, ELEMENTAL_SPHERE, health + mana + regeneration + spellPower + damage)
            call ShopAddItem(shop, LEGENDARY_BLADE_V, damage + spellPower + attackSpeed + movement)

            return 0
        endmethod

        private static method onInit takes nothing returns nothing
            call configure()
            call create('n000', 1000, 0.75)
            call create('h006', 1000, 0.75)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct
endlibrary