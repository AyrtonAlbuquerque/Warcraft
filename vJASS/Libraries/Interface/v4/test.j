scope Attributes
    private struct SpellPower extends Attribute
        method update takes unit u returns nothing
            local integer amount = GetRandomInt(0, 9999)

            set value.text = "|cff3ad2f8" + I2S(amount) + "|r"
            set tooltip.text = "|cff3ad2f8Spell Power: " + I2S(amount) + "|r"
            set visible = IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.09, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNSpellSteal.blp", "Spell Power", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct MagicResistence extends Attribute
        method update takes unit u returns nothing
            set value.text = "10"
            set tooltip.text = "Magic Resistence: 10\nDamage Reduction: 25%"
            set visible = IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.076, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNRunedBracers.blp", "Magic Resistence", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct CriticalStrike extends Attribute
        method update takes unit u returns nothing
            set value.text = "25%"
            set tooltip.text = "Critical Strike: 25%"
            set visible = u != null and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())

            if IsUnitType(u, UNIT_TYPE_HERO) then
                set x = 0.429
                set y = 0.062
            else
                set x = 0.429
                set y = 0.09
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.062, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp", "Critical Strike", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct ControlResistence extends Attribute
        method update takes unit u returns nothing
            set value.text = "30%"
            set tooltip.text = "Tenacity: 30%"
            set visible = IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, GetLocalPlayer())
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.048, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\PassiveButtons\\PASBTNAnimalWarTraining.blp", "Tenacity", FRAMEPOINT_LEFT)
        endmethod
    endstruct

    private struct MovementSpeed extends Attribute
        method update takes unit u returns nothing
            local real speed = GetUnitMoveSpeed(u)

            set visible = u != null and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, GetLocalPlayer())

            if speed >= 270 then
                set value.text = "|cff22f722" + I2S(R2I(speed)) + "|r"
                set tooltip.text = "Movement Speed: " + "|cff22f722" + I2S(R2I(speed)) + "|r"
            else
                set value.text = "|cffff0000" + I2S(R2I(speed)) + "|r"
                set tooltip.text = "Movement Speed: " + "|cffff0000" + I2S(R2I(speed)) + "|r"
            endif

            if IsUnitType(u, UNIT_TYPE_HERO) then
                set x = 0.429
                set y = 0.034
            else
                set x = 0.429
                set y = 0.076
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(0.429, 0.034, 0.0125, 0.0125, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp", "Movement Speed", FRAMEPOINT_LEFT)
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