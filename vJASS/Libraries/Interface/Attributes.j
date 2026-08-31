scope Attributes
    globals
        // The size of the attributes buttons
        private constant real ATTRIBUTES_WIDTH = 0.0125
        private constant real ATTRIBUTES_HEIGHT = 0.0125
        // Textures
        private constant string DAMAGE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
        private constant string ARMOR_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
        private constant string STRENGTH_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
        private constant string AGILITY_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
        private constant string INTELLIGENCE_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"
        private constant string SPELL_POWER_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNPriestAdept.blp"
        private constant string MAGIC_RESISTANCE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAntiMagicShell.blp"
        private constant string CRITICAL_STRIKE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp"
        private constant string EVASION_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNEvasion.blp"
        private constant string MOVEMENT_SPEED_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"
        // Main attribute highlight
        private constant string ATTRIBUTE_HIGHLIGHT = "goldenbrown.mdx"
        private constant real HIGHLIGHT_SCALE = 0.125
        private constant real HIGHLIGHT_XOFFSET = 0.052
        private constant real HIGHLIGHT_YOFFSET = 0.048
    endglobals

    private struct Damage extends Attribute
        private static framehandle frame

        method trim takes string text, boolean flag returns string
            local integer i = 0
            local integer length

            if flag and text != null then
                set length = StringLength(text)

                loop
                    exitwhen i == length - 1
                        if SubString(text, i, i + 1) == "-" then
                            return SubString(text, i + 2, length)
                        endif
                    set i = i + 1
                endloop
            endif

            return text
        endmethod

        method update takes unit u returns nothing
            local string damage = trim(BlzFrameGetText(frame), true)
            local string lifeSteal = "|cffffcc00" + I2S(R2I(10)) + "%|r"
            local string armorPen = "|cffff0000" + I2S(R2I(5)) + "|r" + " | " + "|cffffcc00" + I2S(R2I(15)) + "%|r"
            local string attackSpeed = "|cffffcc00" + I2S(R2I(20)) + "%|r"

            set value.text = damage
            set tooltip.text = "Damage: " + damage + "\nLife Steal: " + lifeSteal + "\nArmor Penetration: " + armorPen + "\nAttack Speed: " + attackSpeed
            set visible = IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            set frame = BlzGetFrameByName("InfoPanelIconValue", 0)

            call thistype.allocate(0.357, 0.09, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), DAMAGE_TEXTURE, "Damage", null)
        endmethod
    endstruct

    private struct Armor extends Attribute
        private static framehandle frame

        method update takes unit u returns nothing
            local string armor = BlzFrameGetText(frame)
            local string block = "10"
            local string reduction = "|cffffcc00" + I2S(R2I(24)) + "%|r"
            local string control = "|cffffcc00" + I2S(R2I(15)) + "%|r"

            set value.text = armor
            set tooltip.text = "Armor: " + armor + "\nDamage Block: " + block + "\nDamage Reduction: " + reduction + "\nControl Resistance: " + control
            set visible = IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            set frame = BlzGetFrameByName("InfoPanelIconValue", 2)

            call thistype.allocate(0.357, 0.076, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), ARMOR_TEXTURE, "Armor", null)
        endmethod
    endstruct

    private struct Strength extends Attribute
        private static framehandle frame
        private static boolean array highlighted

        method update takes unit u returns nothing
            local string amount = BlzFrameGetText(frame)
            local integer id = GetPlayerId(GetLocalPlayer())
            local boolean hero = IsUnitType(u, UNIT_TYPE_HERO)
            local integer primary = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)

            set value.text = amount
            set tooltip.text = "Strength: " + amount
            set visible = hero and IsUnitVisible(u, GetLocalPlayer())

            if hero then
                if primary == 1 and not highlighted[id] then
                    set highlighted[id] = true

                    call display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary != 1 and highlighted[id] then
                    set highlighted[id] = false

                    call display(null, 0, 0, 0)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set frame = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)

            call thistype.allocate(0.357, 0.062, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), STRENGTH_TEXTURE, "Strength", null)
        endmethod
    endstruct

    private struct Agility extends Attribute
        private static framehandle frame
        private static boolean array highlighted

        method update takes unit u returns nothing
            local string amount = BlzFrameGetText(frame)
            local integer id = GetPlayerId(GetLocalPlayer())
            local boolean hero = IsUnitType(u, UNIT_TYPE_HERO)
            local integer primary = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)

            set value.text = amount
            set tooltip.text = "Agility: " + amount
            set visible = hero and IsUnitVisible(u, GetLocalPlayer())

            if hero then
                if primary == 3 and not highlighted[id] then
                    set highlighted[id] = true

                    call display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary != 3 and highlighted[id] then
                    set highlighted[id] = false
                    
                    call display(null, 0, 0, 0)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set frame = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)

            call thistype.allocate(0.357, 0.048, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), AGILITY_TEXTURE, "Agility", null)
        endmethod
    endstruct

    private struct Intelligence extends Attribute
        private static framehandle frame
        private static boolean array highlighted

        method update takes unit u returns nothing
            local string amount = BlzFrameGetText(frame)
            local integer id = GetPlayerId(GetLocalPlayer())
            local boolean hero = IsUnitType(u, UNIT_TYPE_HERO)
            local integer primary = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)

            set value.text = amount
            set tooltip.text = "Intelligence: " + amount
            set visible = hero and IsUnitVisible(u, GetLocalPlayer())

            if hero then
                if primary == 2 and not highlighted[id] then
                    set highlighted[id] = true

                    call display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary != 2 and highlighted[id] then
                    set highlighted[id] = false
                    
                    call display(null, 0, 0, 0)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set frame = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)

            call thistype.allocate(0.357, 0.034, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), INTELLIGENCE_TEXTURE, "Intelligence", null)
        endmethod
    endstruct

    private struct SpellPower extends Attribute
        method update takes unit u returns nothing
            local string power = "|cff3ad2f8" + I2S(GetRandomInt(0, 9999)) + "|r"
            local string spellVamp = "|cffffcc00" + I2S(R2I(5)) + "%|r"
            local string magicPen = "|cff00ffff" + I2S(R2I(5)) + "|r" + " | " + "|cffffcc00" + I2S(R2I(20)) + "%|r"
            local string cdr = "|cffffcc00" + I2S(R2I(20)) + "%|r"

            set value.text = power
            set tooltip.text = "Spell Power: " + power + "\nSpell Vamp: " + spellVamp + "\nMagic Penetration: " + magicPen + "\nCooldown Reduction: " + cdr
            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.09, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), SPELL_POWER_TEXTURE, "Spell Power", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct MagicResistance extends Attribute
        method update takes unit u returns nothing
            local string amount = "10"
            local string reduction = "|cffffcc00" + I2S(R2I(24)) + "%|r"

            set value.text = amount
            set tooltip.text = "Magic Resistance: " + amount + "\nDamage Reduction: " + reduction
            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.076, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), MAGIC_RESISTANCE_TEXTURE, "Magic Resistance", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct CriticalStrike extends Attribute
        method update takes unit u returns nothing
            local string chance = "|cffffcc00" + I2S(R2I(25)) + "%|r"
            local string damage = "|cffffcc00" + I2S(R2I(70)) + "%|r"

            set value.text = chance
            set tooltip.text = "Critical Chance: " + chance + "\nCritical Damage: " + damage
            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.062, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), CRITICAL_STRIKE_TEXTURE, "Critical Strike", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct Evasion extends Attribute
        method update takes unit u returns nothing
            local string evasion = "|cffffcc00" + I2S(R2I(25)) + "%|r"
            local string pierce = "|cffffcc00" + I2S(R2I(15)) + "%|r"

            set value.text = evasion
            set tooltip.text = "Evasion: " + evasion + "\nTrue Strike Chance: " + pierce
            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.048, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), EVASION_TEXTURE, "Evasion", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct MovementSpeed extends Attribute
        method update takes unit u returns nothing
            local real speed = GetUnitMoveSpeed(u)

            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())

            if speed >= 270 then
                set value.text = "|cff22f722" + I2S(R2I(speed)) + "|r"
                set tooltip.text = "Movement Speed: " + "|cff22f722" + I2S(R2I(speed)) + "|r"
            else
                set value.text = "|cffff0000" + I2S(R2I(speed)) + "|r"
                set tooltip.text = "Movement Speed: " + "|cffff0000" + I2S(R2I(speed)) + "|r"
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.034, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), MOVEMENT_SPEED_TEXTURE, "Movement Speed", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct CooldownReduction extends Attribute
        method update takes unit u returns nothing
            set value.text = "20%"
            set tooltip.text = "Cooldown Reduction: 20%"
            set visible = IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.46, 0.106, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNMoonStone.blp", "Cooldown Reduction", FRAMEPOINT_BOTTOM)
        endmethod
    endstruct

    private struct AttackSpeed extends Attribute
        method update takes unit u returns nothing
            set value.text = "50%"
            set tooltip.text = "Attack Speed: 50%"
            set visible = BlzGetUnitWeaponBooleanField(u, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.46, 0.065, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNGlove.blp", "Attack Speed", FRAMEPOINT_TOP)
        endmethod
    endstruct

    private struct LifeSteal extends Attribute
        method update takes unit u returns nothing
            set value.text = "15%"
            set tooltip.text = "Life Steal: 15%"
            set visible = IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.327, 0.106, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNMaskOfDeath.blp", "Life Steal", FRAMEPOINT_BOTTOM)
        endmethod
    endstruct

    private struct HealthRegeneration extends Attribute
        method update takes unit u returns nothing
            set value.text = "10/s"
            set tooltip.text = "Health Regeneration: 10/s"
            set visible = not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.327, 0.065, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNHealthStone.blp", "Health Regeneration", FRAMEPOINT_TOP)
        endmethod
    endstruct
endscope