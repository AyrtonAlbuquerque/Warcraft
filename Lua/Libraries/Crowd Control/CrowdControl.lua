OnInit("CrowdControl", function(requires)
    requires "Class"
    requires "Utilities"
    requires.optional "Tenacity"

    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- This is the maximum recursion limit allowed by the system.
    -- Its value must be greater than or equal to 0. When equal to 0
    -- no recursion is allowed. Values too big can cause screen freezes.
    local RECURSION_LIMIT    = 8
    -- The raw code of the true sight ability.
    -- Add this to dummy cast based disables
    -- so that the dummy can see invisible units
    CrowdControl_TRUE_SIGHT = S2A('U014')

    -- ---------------------------------------------------------------------------------------------- --
    --                                             Systems                                            --
    -- ---------------------------------------------------------------------------------------------- --
    do
        CrowdControl = Class()

        CrowdControl.key = 0
        CrowdControl.type = {}
        CrowdControl.value = {}
        CrowdControl.angle = {}
        CrowdControl.model = {}
        CrowdControl.point = {}
        CrowdControl.stack = {}
        CrowdControl.target = {}
        CrowdControl.source = {}
        CrowdControl.duration = {}

        local index = 0
        local event = {}
        local struct = {}
        local trigger = {}

        function CrowdControl.apply(control, src, tgt, val, ang, dur, sfx, bone, stk)
            local self = struct[control]

            if self then
                if self.start and not IsUnitType(tgt, UNIT_TYPE_MAGIC_IMMUNE) and UnitAlive(tgt) and dur > 0 then
                    CrowdControl.type[CrowdControl.key] = control
                    CrowdControl.value[CrowdControl.key] = val
                    CrowdControl.angle[CrowdControl.key] = ang
                    CrowdControl.model[CrowdControl.key] = sfx
                    CrowdControl.point[CrowdControl.key] = bone
                    CrowdControl.stack[CrowdControl.key] = stk
                    CrowdControl.target[CrowdControl.key] = tgt
                    CrowdControl.source[CrowdControl.key] = src
                    CrowdControl.duration[CrowdControl.key] = dur

                    CrowdControl.onEvent(CrowdControl.key)

                    if Tenacity then
                        CrowdControl.duration[CrowdControl.key] = GetTenacityDuration(CrowdControl.target[CrowdControl.key], CrowdControl.duration[CrowdControl.key])
                    end

                    if CrowdControl.type[CrowdControl.key] ~= control then
                        return CrowdControl.apply(CrowdControl.type[CrowdControl.key], CrowdControl.source[CrowdControl.key], CrowdControl.target[CrowdControl.key], CrowdControl.value[CrowdControl.key], CrowdControl.angle[CrowdControl.key], CrowdControl.duration[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key], CrowdControl.stack[CrowdControl.key])
                    end

                    return self:start(CrowdControl.source[CrowdControl.key], CrowdControl.target[CrowdControl.key], CrowdControl.value[CrowdControl.key], CrowdControl.angle[CrowdControl.key], CrowdControl.duration[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key], CrowdControl.stack[CrowdControl.key])
                end
            else
                print("Invalid CrowdControl Type")
            end

            return false
        end

        function CrowdControl.dispel(unit, control)
            local self = struct[control]

            if self then
                if self.finish and UnitAlive(unit) then
                    return self:finish(unit)
                end
            end

            return false
        end

        function CrowdControl.dispelAll(unit)
            local self
            
            if UnitAlive(unit) then
                for i = 1, index do
                    self = struct[i]

                    if self then
                        if self.finish then
                            self:finish(unit)
                        end
                    end
                end
            end
        end

        function CrowdControl.remaining(unit, control)
            local self = struct[control]

            if self then
                if self.getRemaining and UnitAlive(unit) then
                    return self:getRemaining(unit)
                end
            end

            return 0
        end

        function CrowdControl.applied(unit, control)
            local self = struct[control]

            if self then
                if self.isApplied and UnitAlive(unit) then
                    return self:isApplied(unit)
                end
            end

            return false
        end

        function CrowdControl.register(control)
            index = index + 1
            struct[index] = control

            return index
        end

        function CrowdControl.registerEvent(control, code)
            if type(code) == "function" then
                if control > 0 then
                    if not event[control] then event[control] = {} end
                    table.insert(event[control], code)
                else
                    table.insert(trigger, code)
                end
            end
        end

        function CrowdControl.onEvent(k)
            CrowdControl.key = CrowdControl.key + 1

            if k <= RECURSION_LIMIT then
                if event[CrowdControl.type[k]] then
                    for i = 1, #event[CrowdControl.type[k]] do
                        event[CrowdControl.type[k]][i]()
                    end
                end

                for i = 1, #trigger do
                    trigger[i]()
                end
            end

            CrowdControl.key = CrowdControl.key - 1
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          LUA API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterCrowdControl(control)
        return CrowdControl.register(control)
    end

    function RegisterCrowdControlEvent(control, code)
        CrowdControl.registerEvent(control, code)
    end

    function RegisterAnyCrowdControlEvent(code)
        CrowdControl.registerEvent(0, code)
    end

    function UnitApplyCrowdControl(control, source, target, value, angle, duration, model, point, stack)
        return CrowdControl.apply(control, source, target, value, angle, duration, model, point, stack)
    end

    function GetCrowdControlSource()
        return CrowdControl.source[CrowdControl.key - 1]
    end

    function GetCrowdControlTarget()
        return CrowdControl.target[CrowdControl.key - 1]
    end

    function GetCrowdControlType()
        return CrowdControl.type[CrowdControl.key - 1]
    end

    function GetCrowdControlDuration()
        return CrowdControl.duration[CrowdControl.key - 1]
    end

    function GetCrowdControlValue()
        return CrowdControl.value[CrowdControl.key - 1]
    end

    function GetCrowdControlAngle()
        return CrowdControl.angle[CrowdControl.key - 1]
    end

    function GetCrowdControlModel()
        return CrowdControl.model[CrowdControl.key - 1]
    end

    function GetCrowdControlBone()
        return CrowdControl.point[CrowdControl.key - 1]
    end

    function GetCrowdControlStack()
        return CrowdControl.stack[CrowdControl.key - 1]
    end

    function GetCrowdControlRemaining(target, control)
        return CrowdControl.remaining(target, control)
    end

    function SetCrowdControlSource(unit)
        CrowdControl.source[CrowdControl.key - 1] = unit
    end

    function SetCrowdControlTarget(unit)
        CrowdControl.target[CrowdControl.key - 1] = unit
    end

    function SetCrowdControlType(control)
        CrowdControl.type[CrowdControl.key - 1] = control
    end

    function SetCrowdControlDuration(duration)
        CrowdControl.duration[CrowdControl.key - 1] = duration
    end

    function SetCrowdControlValue(amount)
        CrowdControl.value[CrowdControl.key - 1] = amount
    end

    function SetCrowdControlAngle(amount)
        CrowdControl.angle[CrowdControl.key - 1] = amount
    end

    function SetCrowdControlModel(model)
        CrowdControl.model[CrowdControl.key - 1] = model
    end

    function SetCrowdControlBone(point)
        CrowdControl.point[CrowdControl.key - 1] = point
    end

    function SetCrowdControlStack(stack)
        CrowdControl.stack[CrowdControl.key - 1] = stack
    end

    function UnitDispelCrowdControl(target, control)
        CrowdControl.dispel(target, control)
    end

    function UnitDispelAllCrowdControl(target)
        CrowdControl.dispelAll(target)
    end
end)
