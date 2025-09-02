OnInit("Spell", function(requires)
    requires "Class"
    requires "Unit"
    requires "RegisterPlayerUnitEvent"

    Spell = Class()

    local array = {}
    local struct = {}
    local learned = {}
    local location = Location(0, 0)

    Spell.sources = Unit.create(nil)
    Spell.targets = Unit.create(nil)

    Spell:property("x", { get = function(self) return GetSpellTargetX() end })

    Spell:property("y", { get = function(self) return GetSpellTargetY() end })

    Spell:property("z", { 
        get = function(self)
            MoveLocation(location, self.x, self.y)

            if self.target.unit then
                return self.target.z
            else
                return GetLocationZ(location)
            end
        end
    })

    Spell:property("id", { get = function(self) return GetSpellAbilityId()  end })

    Spell:property("level", { get = function(self) return GetUnitAbilityLevel(self.source.unit, self.id) end })

    Spell:property("ability", { get = function(self) return BlzGetUnitAbility(self.source.unit, self.id) end })

    Spell:property("source", { 
        get = function(self) return Spell.sources end,
        set = function(self, unit) Spell.sources.unit = unit end
    })

    Spell:property("target", { 
        get = function(self) return Spell.targets end,
        set = function(self, unit) Spell.targets.unit = unit end
    })

    Spell:property("aoe", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_AREA_OF_EFFECT, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_AREA_OF_EFFECT, self.level - 1, value) end
    })

    Spell:property("cost", { 
        get = function(self) return BlzGetAbilityIntegerLevelField(self.ability, ABILITY_ILF_MANA_COST, self.level - 1) end,
        set = function(self, value) BlzSetAbilityIntegerLevelField(self.ability, ABILITY_ILF_MANA_COST, self.level - 1, value) end
    })

    Spell:property("castRange", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_CAST_RANGE, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_CAST_RANGE, self.level - 1, value) end
    })

    Spell:property("castTime", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_CASTING_TIME, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_CASTING_TIME, self.level - 1, value) end
    })

    Spell:property("cooldown", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_COOLDOWN, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_COOLDOWN, self.level - 1, value) end
    })

    Spell:property("duration", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_DURATION_NORMAL, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_DURATION_NORMAL, self.level - 1, value) end
    })

    Spell:property("durationHero", { 
        get = function(self) return BlzGetAbilityRealLevelField(self.ability, ABILITY_RLF_DURATION_HERO, self.level - 1) end,
        set = function(self, value) BlzSetAbilityRealLevelField(self.ability, ABILITY_RLF_DURATION_HERO, self.level - 1, value) end
    })

    Spell:property("tooltip", { 
        get = function(self) return BlzGetAbilityStringLevelField(self.ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, self.level - 1) end,
        set = function(self, value) BlzSetAbilityStringLevelField(self.ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, self.level - 1, value) end
    })

    Spell:property("isAlly", { get = function(self) return IsUnitAlly(self.target.unit, self.source.player) end })

    Spell:property("isEnemy", { get = function(self) return IsUnitEnemy(self.target.unit, self.source.player) end })

    function Spell.register(spell, id)
        if spell and id > 0 then
            struct[id] = spell
        end
    end

    function Spell.__setup(source, target)
        if GetUnitAbilityLevel(source, FourCC('Aloc')) == 0 then
            Spell.source = source
            Spell.target = target
        end
    end

    function Spell.__onPeriod()
        for i = 1, #array do
            local this = array[i]
            local level = GetUnitAbilityLevel(this.unit, this.code)

            if level > 0 then
                BlzSetAbilityStringLevelField(this.ability, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, level - 1, this.type:onTooltip(this.unit, level, this.ability))
            end
        end
    end

    function Spell.__onLearning()
        local source = GetLearningUnit()
        local skill = GetLearnedSkill()
        local level = GetUnitAbilityLevel(source, skill)
        local this = struct[skill]
        local spell

        if this then
            if this.onLearn then
                this:onLearn(source, skill, level)
            end

            if this.onTooltip and level == 1 then
                spell = {}
                spell.type = this
                spell.code = skill
                spell.unit = source
                spell.ability = BlzGetUnitAbility(source, skill)

                if not learned[skill] then
                    learned[skill] = {}
                end

                learned[skill][source] = spell

                table.insert(array, spell)
            end
        end
    end

    function Spell.__onCasting()
        local this = struct[Spell.id]
        local spell

        Spell.__setup(GetTriggerUnit(), GetSpellTargetUnit())

        if this then
            if this.onCast then
                this:onCast()
            end

            if this.onTooltip then
                Spell.tooltip = this:onTooltip(Spell.source.unit, Spell.level, Spell.ability)

                if not learned[Spell.id] then
                    spell = {}
                    spell.type = this
                    spell.code = Spell.id
                    spell.unit = Spell.source.unit
                    spell.ability = Spell.ability
                    learned[Spell.id] = {}
                    learned[Spell.id][Spell.source.unit] = spell

                    table.insert(array, spell)
                end
            end
        end
    end

    function Spell.__onEnding()
        local this = struct[Spell.id]

        Spell.__setup(GetTriggerUnit(), GetSpellTargetUnit())

        if this then
            if this.onEnd then
                this:onEnd()
            end
        end
    end

    function Spell.__onStarting()
        local this = struct[Spell.id]

        Spell.__setup(GetTriggerUnit(), GetSpellTargetUnit())

        if this then
            if this.onStart then
                this:onStart()
            end
        end
    end

    function Spell.__onFinishing()
        local this = struct[Spell.id]

        Spell.__setup(GetTriggerUnit(), GetSpellTargetUnit())

        if this then
            if this.onFinish then
                this:onFinish()
            end
        end
    end

    function Spell.__onChanneling()
        local this = struct[Spell.id]

        Spell.__setup(GetTriggerUnit(), GetSpellTargetUnit())

        if this then
            if this.onChannel then
                this:onChannel()
            end
        end
    end

    function Spell.onInit()
        TimerStart(CreateTimer(), 1, true, Spell.__onPeriod)
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, Spell.__onLearning)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, Spell.__onStarting)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, Spell.__onCasting)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, Spell.__onEnding)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, Spell.__onFinishing)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, Spell.__onChanneling)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterSpell(spell, id)
        Spell.register(spell, id)
    end
end)