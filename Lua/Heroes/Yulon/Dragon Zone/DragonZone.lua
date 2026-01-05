OnInit("DragonZone", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ----------------------------- Dragon Zone v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY          = S2A('Yul5')
    -- The raw code of the regen ability
    local REGEN_ABILITY    = S2A('Yul6')
    -- The Model
    local MODEL            = "DragonZone.mdl"
    -- The model scale
    local SCALE            = 2.5
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"
    -- The pdate period
    local PERIOD           = 0.1

    -- The bonus regeneration
    local function GetBonusRegen(source, level)
        if Bonus then
            return 25 * level + (0.05 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25 * level
        end
    end

    -- The AOE
    local function GetAoE(source, level)
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The maximum Knock Back duration
    local function GetMaxKnockBackDuration(source, level)
        return 0.5 + 0.*level
    end

    -- The spell duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The caster time scale. Speed or slow down aniamtions.
    local function GetTimeScale(source, level)
        return 1.5
    end

    -- The amoount of time until time scale is reset
    local function GetTimeScaleTime(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
    end

    -- The Unit Filter.
    local function UnitFilter(p, u)
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DragonZone = Class(Spell)

        function DragonZone:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            
            self.unit = nil
            self.timer = nil
            self.group = nil
            self.player = nil
        end

        function DragonZone:onTooltip(source, level, abiltiy)
            return "|cffffcc00Yu'lon|r creates a safe zone around himself. The zone heals any allied unit within it for |cff00ff00" .. N2S(GetBonusRegen(source, level), 1) .. " Health Regeneration|r bonus and knocks back any enemy unit that tries to get through it. |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r zone. Lasts |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function DragonZone:onCast()
            local dummy = DummyRetrieve(Spell.source.player, Spell.source.x, Spell.source.y, 0, 0) 
            local this = { destroy = DragonZone.destroy }

            this.x = Spell.source.x
            this.y = Spell.source.y
            this.unit = Spell.source.unit
            this.player = Spell.source.player
            this.timer = CreateTimer()
            this.group = CreateGroup()
            this.aoe = GetAoE(this.unit, Spell.level)
            this.duration = GetDuration(this.unit, Spell.level)
            this.knock = GetMaxKnockBackDuration(this.unit, Spell.level)
            
            DestroyEffectTimed(AddSpecialEffectEx(MODEL, this.x, this.y, 0, SCALE), this.duration)
            UnitAddAbilityTimed(dummy, REGEN_ABILITY, this.duration, 1, true)
            local spell = BlzGetUnitAbility(dummy, REGEN_ABILITY)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED, 0, GetBonusRegen(this.unit, Spell.level))
            IncUnitAbilityLevel(dummy, REGEN_ABILITY)
            DecUnitAbilityLevel(dummy, REGEN_ABILITY)
            DummyRecycleTimed(dummy, this.duration)
            SetUnitTimeScale(this.unit, GetTimeScale(this.unit, Spell.level))
            TimerStart(CreateTimer(), GetTimeScaleTime(this.unit, Spell.level), false, function ()
                SetUnitTimeScale(this.unit, 1)
                DestroyTimer(GetExpiredTimer())
            end)
            TimerStart(this.timer, PERIOD, true, function ()
                this.duration = this.duration - PERIOD

                if this.duration > 0 then            
                    GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)

                    local u = FirstOfGroup(this.group)

                    while u do
                        if UnitFilter(this.player, u) then
                            if not IsUnitKnockedBack(u) then
                                local angle = AngleBetweenCoordinates(this.x, this.y, GetUnitX(u), GetUnitY(u))
                                local distance = DistanceBetweenCoordinates(this.x, this.y, GetUnitX(u), GetUnitY(u))
                                
                                KnockbackUnit(u, angle, this.aoe + 25 - distance, this.knock*(distance/this.aoe), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                            end
                        end

                        GroupRemoveUnit(this.group, u)
                        u = FirstOfGroup(this.group) 
                    end
                else
                    this:destroy()
                end
            end)
        end

        function DragonZone.onInit()
            RegisterSpell(DragonZone.allocate(), ABILITY)
        end
    end
end)