OnInit("Switch", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "MirrorImage"

    -- -------------------------------- Switch v1.5 by Chopinski ------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Switch ability
    Switch_ABILITY      = S2A('Smr0')
    -- The switch effect
    local SWITCH_EFFECT = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Switch = Class(Spell)

        function Switch:destroy()
            self.unit = nil
            self.group = nil
        end

        function Switch.switch(source, target)
            local x = GetUnitX(source)
            local y = GetUnitY(source)
            local g1 = CreateGroup()
            local g2 = CreateGroup()
            local sourceFace = GetUnitFacing(source)
            local targetFace = GetUnitFacing(target)

            PauseUnit(source, true)
            ShowUnit(source, false)
            DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, x, y))
            GroupEnumUnitsOfPlayer(g1, GetOwningPlayer(source), nil)

            local u = FirstOfGroup(g1)

            while u do
                if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                    PauseUnit(u, true)
                    ShowUnit(u, false)
                    DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, GetUnitX(u), GetUnitY(u)))
                    GroupAddUnit(g2, u)
                end

                GroupRemoveUnit(g1, u)
                u = FirstOfGroup(g1)
            end

            DestroyGroup(g1)
            SetUnitPosition(source, GetUnitX(target), GetUnitY(target))
            SetUnitFacing(source, targetFace)
            SetUnitPosition(target, x, y)
            SetUnitFacing(target, sourceFace)

            return g2
        end

        function Switch:onCast()
            if GetUnitTypeId(Spell.source.unit) == GetUnitTypeId(Spell.target.unit) and IsUnitIllusionEx(Spell.target.unit) then
                local this = { destroy = Switch.destroy }

                this.unit = Spell.source.unit
                this.group = Switch.switch(Spell.source.unit, Spell.target.unit)

                TimerStart(CreateTimer(), 0.25, false, function ()
                    PauseUnit(this.unit, false)
                    ShowUnit(this.unit, true)

                    local u = FirstOfGroup(this.group)

                    while u do
                        PauseUnit(u, false)
                        ShowUnit(u, true)
                        GroupRemoveUnit(this.group, u)
                        u = FirstOfGroup(this.group)
                    end

                    DestroyGroup(this.group)
                    SelectUnit(this.unit, true)
                    SelectUnitAddForPlayer(this.unit, GetOwningPlayer(this.unit))
                    DestroyTimer(GetExpiredTimer())
                    this:destroy()
                end)
            end
        end

        function Switch.onInit()
            RegisterSpell(Switch.allocate(), Switch_ABILITY)
        end
    end
end)