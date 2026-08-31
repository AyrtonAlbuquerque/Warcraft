OnInit(function(requires)
    requires "Class"
    requires "Interface"

    -- The size of the attributes buttons
    local ATTRIBUTES_WIDTH = 0.0125
    local ATTRIBUTES_HEIGHT = 0.0125
    -- Textures
    local DAMAGE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
    local ARMOR_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
    local STRENGTH_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
    local AGILITY_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
    local INTELLIGENCE_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"
    local SPELL_POWER_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNPriestAdept.blp"
    local MAGIC_RESISTANCE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAntiMagicShell.blp"
    local CRITICAL_STRIKE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp"
    local EVASION_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNEvasion.blp"
    local MOVEMENT_SPEED_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"
    -- Main attribute highlight
    local ATTRIBUTE_HIGHLIGHT = "goldenbrown.mdx"
    local HIGHLIGHT_SCALE = 0.125
    local HIGHLIGHT_XOFFSET = 0.052
    local HIGHLIGHT_YOFFSET = 0.048

    do
        local Damage = Class(Attribute)

        local frame

        function Damage:trim(text, flag)
            if flag and text ~= nil then
                local length = StringLength(text)
                local i = 0

                while i < length - 1 do
                    if SubString(text, i, i + 1) == "-" then
                        return SubString(text, i + 2, length)
                    end

                    i = i + 1
                end
            end

            return text
        end

        function Damage:update(unit)
            local damage = Damage:trim(BlzFrameGetText(frame), true)
            local lifeSteal = "|cffffcc00" .. I2S(R2I(10)) .. "%|r"
            local armorPen = "|cffff0000" .. I2S(R2I(5)) .. "|r" .. " | " .. "|cffffcc00" .. I2S(R2I(15)) .. "%|r"
            local attackSpeed = "|cffffcc00" .. I2S(R2I(20)) .. "%|r"

            self.value.text = damage
            self.tooltip.text = "Damage: " .. damage .. "\nLife Steal: " .. lifeSteal .. "\nArmor Penetration: " .. armorPen .. "\nAttack Speed: " .. attackSpeed
            self.visible = IsUnitVisible(unit, GetLocalPlayer())
        end

        function Damage.onInit()
            frame = BlzGetFrameByName("InfoPanelIconValue", 0)

            Damage.allocate(0.357, 0.09, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), DAMAGE_TEXTURE, "Damage", nil)
        end
    end

    do
        local Armor = Class(Attribute)

        local frame

        function Armor:update(unit)
            local armor = BlzFrameGetText(frame)
            local block = "10"
            local reduction = "|cffffcc00" .. I2S(R2I(24)) .. "%|r"
            local control = "|cffffcc00" .. I2S(R2I(15)) .. "%|r"

            self.value.text = armor
            self.tooltip.text = "Armor: " .. armor .. "\nDamage Block: " .. block .. "\nDamage Reduction: " .. reduction .. "\nControl Resistance: " .. control
            self.visible = IsUnitVisible(unit, GetLocalPlayer())
        end

        function Armor.onInit()
            frame = BlzGetFrameByName("InfoPanelIconValue", 2)

            Armor.allocate(0.357, 0.076, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), ARMOR_TEXTURE, "Armor", nil)
        end
    end

    do
        local Strength = Class(Attribute)

        local frame
        local highlighted = {}

        function Strength:update(unit)
            local amount = BlzFrameGetText(frame)
            local id = GetPlayerId(GetLocalPlayer())
            local hero = IsUnitType(unit, UNIT_TYPE_HERO)
            local primary = BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)

            self.value.text = amount
            self.tooltip.text = "Strength: " .. amount
            self.visible = hero and IsUnitVisible(unit, GetLocalPlayer())

            if hero then
                if primary == 1 and not highlighted[id] then
                    highlighted[id] = true

                    self:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary ~= 1 and highlighted[id] then
                    highlighted[id] = false

                    self:display(nil, 0, 0, 0)
                end
            end
        end

        function Strength.onInit()
            frame = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)

            Strength.allocate(0.357, 0.062, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), STRENGTH_TEXTURE, "Strength", nil)
        end
    end

    do
        local Agility = Class(Attribute)

        local frame
        local highlighted = {}

        function Agility:update(unit)
            local amount = BlzFrameGetText(frame)
            local id = GetPlayerId(GetLocalPlayer())
            local hero = IsUnitType(unit, UNIT_TYPE_HERO)
            local primary = BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)

            self.value.text = amount
            self.tooltip.text = "Agility: " .. amount
            self.visible = hero and IsUnitVisible(unit, GetLocalPlayer())

            if hero then
                if primary == 3 and not highlighted[id] then
                    highlighted[id] = true

                    self:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary ~= 3 and highlighted[id] then
                    highlighted[id] = false

                    self:display(nil, 0, 0, 0)
                end
            end
        end

        function Agility.onInit()
            frame = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)

            Agility.allocate(0.357, 0.048, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), AGILITY_TEXTURE, "Agility", nil)
        end
    end

    do
        local Intelligence = Class(Attribute)

        local frame
        local highlighted = {}

        function Intelligence:update(unit)
            local amount = BlzFrameGetText(frame)
            local id = GetPlayerId(GetLocalPlayer())
            local hero = IsUnitType(unit, UNIT_TYPE_HERO)
            local primary = BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)

            self.value.text = amount
            self.tooltip.text = "Intelligence: " .. amount
            self.visible = hero and IsUnitVisible(unit, GetLocalPlayer())

            if hero then
                if primary == 2 and not highlighted[id] then
                    highlighted[id] = true

                    self:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                elseif primary ~= 2 and highlighted[id] then
                    highlighted[id] = false

                    self:display(nil, 0, 0, 0)
                end
            end
        end

        function Intelligence.onInit()
            frame = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)

            Intelligence.allocate(0.357, 0.034, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), INTELLIGENCE_TEXTURE, "Intelligence", nil)
        end
    end

    do
        local SpellPower = Class(Attribute)

        function SpellPower:update(unit)
            local power = "|cff3ad2f8" .. I2S(GetRandomInt(0, 9999)) .. "|r"
            local spellVamp = "|cffffcc00" .. I2S(R2I(5)) .. "%|r"
            local magicPen = "|cff00ffff" .. I2S(R2I(5)) .. "|r" .. " | " .. "|cffffcc00" .. I2S(R2I(20)) .. "%|r"
            local cdr = "|cffffcc00" .. I2S(R2I(20)) .. "%|r"

            self.value.text = power
            self.tooltip.text = "Spell Power: " .. power .. "\nSpell Vamp: " .. spellVamp .. "\nMagic Penetration: " .. magicPen .. "\nCooldown Reduction: " .. cdr
            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function SpellPower.onInit()
            SpellPower.allocate(0.429, 0.09, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), SPELL_POWER_TEXTURE, "Spell Power", FRAMEPOINT_LEFT)
        end
    end

    do
        local MagicResistance = Class(Attribute)

        function MagicResistance:update(unit)
            local amount = "10"
            local reduction = "|cffffcc00" .. I2S(R2I(24)) .. "%|r"

            self.value.text = amount
            self.tooltip.text = "Magic Resistance: " .. amount .. "\nDamage Reduction: " .. reduction
            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function MagicResistance.onInit()
            MagicResistance.allocate(0.429, 0.076, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), MAGIC_RESISTANCE_TEXTURE, "Magic Resistance", FRAMEPOINT_LEFT)
        end
    end

    do
        local CriticalStrike = Class(Attribute)

        function CriticalStrike:update(unit)
            local chance = "|cffffcc00" .. I2S(R2I(25)) .. "%|r"
            local damage = "|cffffcc00" .. I2S(R2I(70)) .. "%|r"

            self.value.text = chance
            self.tooltip.text = "Critical Chance: " .. chance .. "\nCritical Damage: " .. damage
            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function CriticalStrike.onInit()
            CriticalStrike.allocate(0.429, 0.062, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), CRITICAL_STRIKE_TEXTURE, "Critical Strike", FRAMEPOINT_LEFT)
        end
    end

    do
        local Evasion = Class(Attribute)

        function Evasion:update(unit)
            local evasion = "|cffffcc00" .. I2S(R2I(25)) .. "%|r"
            local pierce = "|cffffcc00" .. I2S(R2I(15)) .. "%|r"

            self.value.text = evasion
            self.tooltip.text = "Evasion: " .. evasion .. "\nTrue Strike Chance: " .. pierce
            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function Evasion.onInit()
            Evasion.allocate(0.429, 0.048, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), EVASION_TEXTURE, "Evasion", FRAMEPOINT_LEFT)
        end
    end

    do
        local MovementSpeed = Class(Attribute)

        function MovementSpeed:update(unit)
            local speed = GetUnitMoveSpeed(unit)

            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())

            if speed >= 270 then
                self.value.text = "|cff22f722" .. I2S(R2I(speed)) .. "|r"
                self.tooltip.text = "Movement Speed: " .. "|cff22f722" .. I2S(R2I(speed)) .. "|r"
            else
                self.value.text = "|cffff0000" .. I2S(R2I(speed)) .. "|r"
                self.tooltip.text = "Movement Speed: " .. "|cffff0000" .. I2S(R2I(speed)) .. "|r"
            end
        end

        function MovementSpeed.onInit()
            MovementSpeed.allocate(0.429, 0.034, ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), MOVEMENT_SPEED_TEXTURE, "Movement Speed", FRAMEPOINT_LEFT)
        end
    end

    do
        local CooldownReduction = Class(Attribute)

        function CooldownReduction:update(unit)
            self.value.text = "20%"
            self.tooltip.text = "Cooldown Reduction: 20%"
            self.visible = IsUnitType(unit, UNIT_TYPE_HERO) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function CooldownReduction.onInit()
            CooldownReduction.allocate(0.46, 0.106, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNMoonStone.blp", "Cooldown Reduction", FRAMEPOINT_BOTTOM)
        end
    end

    do
        local AttackSpeed = Class(Attribute)

        function AttackSpeed:update(unit)
            self.value.text = "50%"
            self.tooltip.text = "Attack Speed: 50%"
            self.visible = BlzGetUnitWeaponBooleanField(unit, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function AttackSpeed.onInit()
            AttackSpeed.allocate(0.46, 0.065, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNGlove.blp", "Attack Speed", FRAMEPOINT_TOP)
        end
    end

    do
        local LifeSteal = Class(Attribute)

        function LifeSteal:update(unit)
            self.value.text = "15%"
            self.tooltip.text = "Life Steal: 15%"
            self.visible = IsUnitType(unit, UNIT_TYPE_HERO) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function LifeSteal.onInit()
            LifeSteal.allocate(0.327, 0.106, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNMaskOfDeath.blp", "Life Steal", FRAMEPOINT_BOTTOM)
        end
    end

    do
        local HealthRegeneration = Class(Attribute)

        function HealthRegeneration:update(unit)
            self.value.text = "10/s"
            self.tooltip.text = "Health Regeneration: 10/s"
            self.visible = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and IsUnitVisible(unit, GetLocalPlayer())
        end

        function HealthRegeneration.onInit()
            HealthRegeneration.allocate(0.327, 0.065, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNHealthStone.blp", "Health Regeneration", FRAMEPOINT_TOP)
        end
    end
end)