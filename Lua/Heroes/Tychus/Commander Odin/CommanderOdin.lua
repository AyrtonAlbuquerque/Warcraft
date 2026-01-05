OnInit("CommanderOdin", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "Overkill"
    requires.optional "RunAndGun"
    requires.optional "OdinAttack"
    requires.optional "FragGranade"
    requires.optional "OdinAnnihilate"
    requires.optional "OdinIncinerate"
    requires.optional "AutomatedTurrent"

    -- ---------------------------- Commander Odin v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Commander Odin ability
    local ABILITY = S2A('Tyc5')

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        CommanderOdin = Class(Spell)

        CommanderOdin.morphed = {}

        function CommanderOdin:destroy()
            self.unit = nil
        end

        function CommanderOdin:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r calls for a |cffffcc00Commander Odin|r to pilot, gaining |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_ALTERNATE_FORM_HIT_POINT_BONUS, level - 1), 0) .. "|r bonus |cffff0000Health|r and new abilities for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, level - 1), 1) .. "|r seconds."
        end

        function CommanderOdin:onCast()
            local this = { destroy = CommanderOdin.destroy }

            this.level = Spell.level
            this.unit = Spell.source.unit
            CommanderOdin.morphed[Spell.source.unit] = not (CommanderOdin.morphed[Spell.source.unit] or false)
            this.hide = CommanderOdin.morphed[Spell.source.unit]

            TimerStart(CreateTimer(), BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_DURATION_NORMAL, Spell.level - 1) + 0.01, false, function ()
                if this.hide then
                    if OdinAttack then
                        SetUnitAbilityLevel(this.unit, OdinAttack_ABILITY, this.level)
                    end

                    if OdinAnnihilate then
                        SetUnitAbilityLevel(this.unit, OdinAnnihilate_ABILITY, this.level)
                    end

                    if OdinIncinerate then
                        SetUnitAbilityLevel(this.unit, OdinIncinerate_ABILITY, this.level)
                    end
                end

                if FragGranade then
                    BlzUnitDisableAbility(this.unit, FragGranade_ABILITY, this.hide, this.hide)
                end

                if AutomatedTurrent then
                    BlzUnitDisableAbility(this.unit, AutomatedTurrent_ABILITY, this.hide, this.hide)
                end

                if Overkill then
                    BlzUnitDisableAbility(this.unit, Overkill_ABILITY, this.hide, this.hide)
                end

                if RunAndGun then
                    BlzUnitDisableAbility(this.unit, RunAndGun_ABILITY, this.hide, this.hide)
                end

                this:destroy()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function CommanderOdin.onInit()
            RegisterSpell(CommanderOdin.allocate(), ABILITY)
        end
    end
end)