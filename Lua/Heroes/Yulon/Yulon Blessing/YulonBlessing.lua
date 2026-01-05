OnInit("YulonBlessing", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Yulon Blessing v1.2 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY          = S2A('Yul7')
    -- The Model
    local MODEL            = "DragonBless.mdl"
    -- The model in the caster
    local CASTER_MODEL     = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
    -- The attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end
    
    -- The percentage of health converted per level
    local function GetPercentage(level)
        return 0.02 + 0.*level
    end
    
    -- The minimum health percentage allowed for a conversion to occur
    local function GetMinHealthPercentage(level)
        return 10. + 0.*level
    end
    
    -- The ability period
    local function GetPeriod(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The Unit Filter.
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitAlly(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        YulonBlessing = Class()

        local array = {}
        local active = {}

        function YulonBlessing:execute()
            local level = GetUnitAbilityLevel(self.unit, ABILITY)
            
            if GetUnitLifePercent(self.unit) >= GetMinHealthPercentage(level) and UnitAlive(self.unit) then
                local amount = BlzGetUnitMaxHP(self.unit) * GetPercentage(level)
                
                DestroyEffectTimed(AddSpecialEffectTarget(CASTER_MODEL, self.unit, ATTACH_POINT), 1)
                SetWidgetLife(self.unit, GetWidgetLife(self.unit) - amount)
                AddUnitMana(self.unit, amount)
                GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.unit, level), nil)
                GroupRemoveUnit(self.group, self.unit)

                local u = FirstOfGroup(self.group)

                while u do
                    if UnitFilter(self.player, u) then
                        DestroyEffect(AddSpecialEffectTarget(MODEL, u, ATTACH_POINT))
                        SetWidgetLife(u, GetWidgetLife(u) + amount)
                        AddUnitMana(u, amount)
                    end

                    GroupRemoveUnit(self.group, u)
                    u = FirstOfGroup(self.group)
                end
            else
                IssueImmediateOrderById(self.unit, 852544)
            end
        end

        function YulonBlessing:onCast()
            local this = array[Spell.source.unit]

            if not this then
                this = YulonBlessing.allocate()
                
                this.unit = Spell.source.unit
                this.player = Spell.source.player
                this.group = CreateGroup()
                this.timer =CreateTimer()
                array[Spell.source.unit] = this
            end

            this:execute()
        end

        function YulonBlessing.onLearn(source, skill, level)
            if active[source] then
                IssueImmediateOrderById(source, 852544)
                IssueImmediateOrderById(source, 852543)
            end
        end

        function YulonBlessing.onOrder()
            local order = GetIssuedOrderId()
        
            if order == 852543 or order == 852544 then
                local source = GetOrderedUnit()
                local self = array[source]

                active[source] = order == 852543
                
                if not self then
                    self = YulonBlessing.allocate()

                    self.unit = source
                    self.group = CreateGroup()
                    self.timer = CreateTimer()
                    self.player = GetOwningPlayer(source)
                    array[source] = self
                end
                
                if active[source] then
                    TimerStart(self.timer, GetPeriod(source, GetUnitAbilityLevel(source, ABILITY)), true, function ()
                        local level = GetUnitAbilityLevel(self.unit, ABILITY)
            
                        if level > 0 then
                            if active[self.unit] then
                                self:execute()
                            end
                        else
                            PauseTimer(self.timer)
                            DestroyTimer(self.timer)
                            DestroyGroup(self.group)
                            
                            array[self.unit] = nil

                            self.unit = nil
                            self.timer = nil
                            self.group = nil
                            self.player = nil
                        end
                    end)
                else
                    PauseTimer(self.timer)
                end
            end
        end

        function YulonBlessing.onInit()
            RegisterSpell(YulonBlessing.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, YulonBlessing.onOrder)
        end
    end
end)