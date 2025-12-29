OnInit("Reanimation", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Reanimation v1.5 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the reanimation ability
    local ABILITY                   = S2A('Mnr0')
    -- The raw code of the Mannoroth unit in the editor
    local REANIMATION_METAMORPHOSIS = S2A('Mnr6')
    -- The raw code of the reanimation metamorphosis 
    -- ability that is used to change its model
    local REANIMATION_BUFF          = S2A('BMn0')
    -- The effect created on the gorund when mannoroth dies
    local MANNOROTH_SKELETON        = "Reanimation.mdl"
    -- The size of the skeleton model
    local SKELETON_SCALE            = 0.4

    -- The Ability Cooldown
    local function GetCooldown(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, REANIMATION_METAMORPHOSIS), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Reanimation = Class(Spell)

        local array = {}
        local reanimated = {}

        function Reanimation:destroy()
            BlzSetAbilityStringLevelField(BlzGetUnitAbility(self.unit, ABILITY), ABILITY_SLF_ICON_NORMAL, self.level - 1, "ReplaceableTextures\\CommandButtons\\PASReanimation.blp")
            IncUnitAbilityLevel(self.unit, ABILITY)
            DecUnitAbilityLevel(self.unit, ABILITY)
            DestroyTimer(self.timer)

            array[self.timer] = nil
            reanimated[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.effect = nil
        end

        function Reanimation.onExpire()
            local self = array[GetExpiredTimer()]

            if self then
                self.stage = self.stage + 1

                if self.stage == 1 then
                    BlzPauseUnitEx(self.unit, false)
                    ShowUnit(self.unit, false)
                    SetUnitLifePercentBJ(self.unit, 100)
                    SetUnitManaPercentBJ(self.unit, 100)
                    IssueImmediateOrder(self.unit, "metamorphosis")
                    SetUnitInvulnerable(self.unit, true)
                    BlzPauseUnitEx(self.unit, true)
                    self.effect = AddSpecialEffect(MANNOROTH_SKELETON, GetUnitX(self.unit), GetUnitY(self.unit))
                    BlzSetSpecialEffectScale(self.effect, SKELETON_SCALE)
                    BlzSetSpecialEffectYaw(self.effect, self.face)
                    TimerStart(self.timer, 2, false, Reanimation.onExpire)
                elseif self.stage == 2 then
                    BlzPlaySpecialEffect(self.effect, ANIM_TYPE_MORPH)
                    TimerStart(self.timer, 9, false, Reanimation.onExpire)
                elseif self.stage == 3 then
                    BlzSetSpecialEffectZ(self.effect, 4000)
                    ShowUnit(self.unit, true)
                    BlzPauseUnitEx(self.unit, false)
                    SetUnitInvulnerable(self.unit, false)
                    DestroyEffect(self.effect)
                    TimerStart(self.timer, GetCooldown(self.unit, self.level) - 14, false, Reanimation.onExpire)
                else
                    self:destroy()
                end
            end
        end

        function Reanimation.onDamage()
            local level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)
        
            if level > 0 and Damage.amount >= Damage.target.health and not reanimated[Damage.target.unit] then
                local self = Reanimation.allocate()

                self.timer = CreateTimer()
                self.stage = 0
                self.level = level
                self.unit = Damage.target.unit
                self.face = GetUnitFacing(Damage.target.unit) * bj_DEGTORAD

                Damage.amount = 0
                array[self.timer] = self
                reanimated[self.unit] = true

                TimerStart(self.timer, 3, false, Reanimation.onExpire)
                BlzSetAbilityStringLevelField(BlzGetUnitAbility(self.unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtonsDisabled\\DISPASReanimation.blp")
                IncUnitAbilityLevel(self.unit, ABILITY)
                DecUnitAbilityLevel(self.unit, ABILITY)
                SetUnitInvulnerable(self.unit, true)
                BlzPauseUnitEx(self.unit, true)
                SetUnitAnimation(self.unit, "Death")
            end
        end

        function Reanimation.onInit()
            RegisterAnyDamageEvent(Reanimation.onDamage)
        end
    end
end)