OnInit("Shield", function (requires)
    requires "Class"
    requires "Unit"
    requires "Damage"
    requires "Modules"
    requires "Indexer"
    requires "ProgressBar"

    -- -------------------------------- Shield v1.0 by Chopinski ------------------------------- --
    local BAR_SCALE = 2.
    local BAR_GAP = 50
    local BAR_OFFSET = 100

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterShieldEvent(code)
        Shield.register(code)
    end

    function RegisterShieldBreakEvent(code)
        Shield.registerBreak(code)
    end

    function GetTriggerShield()
        return Shield.instance
    end

    function CreateShield(source, target, amount, attacktype, damagetype, duration, sfx, attachPoint, showBar, playercolor, showText)
        return Shield.create(source, target, amount, attacktype, damagetype, duration, sfx, attachPoint, showBar, playercolor, showText)
    end

    function GetShieldValue(shield)
        return shield.value
    end

    function SetShieldValue(shield, value)
        shield.value = value
        return shield
    end

    function GetShieldTotal(shield)
        return shield.total
    end

    function GetShieldingSource()
        return Shield.source.unit
    end

    function GetShieldingTarget()
        return Shield.target.unit
    end

    function GetShieldingAmount()
        return Shield.amount
    end

    function SetShieldingAmount(value)
        Shield.amount = value
    end

    function GetShieldingOverdamage()
        return Shield.overdamage
    end

    function RestoreShield(shield)
        return shield:restore()
    end

    function ShieldAddAmount(shield, value)
        return shield:add(value)
    end

    function GetUnitShieldingIncrease(u)
        return Shield.getIncrease(u)
    end

    function GetUnitShieldingDecrease(u)
        return Shield.getDecrease(u)
    end

    function SetUnitShieldingIncrease(u, value)
        return Shield.setIncrease(u, value)
    end

    function SetUnitShieldingDecrease(u, value)
        return Shield.setDecrease(u, value)
    end

    function DestroyShield(shield)
        shield:destroy()
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    Shield = Class()

    Shield.amount = 0
    Shield.instance = nil
    Shield.overdamage = 0
    Shield.attacktype = nil
    Shield.damagetype = nil
    Shield.source = Unit.create(nil)
    Shield.target = Unit.create(nil)

    local slots = {}
    local event = {}
    local broken = {}
    local shields = {}
    local counter = {}
    local increase = {}
    local decrease = {}

    function Shield:destroy()
        if self.allocated then
            if self.bar then
                local list = shields[self.target]

                if list then
                    for _, shield in pairs(list) do
                        if shield.bar and shield.slot > self.slot then
                            shield.slot = shield.slot - 1
                            shield.bar.y = -BAR_OFFSET - BAR_GAP * shield.slot
                        end
                    end
                end

                slots[self.target] = slots[self.target] - 1

                DestroyProgressBar(self.bar)
            end

            if self.effect then
                DestroyEffect(self.effect)
            end

            shields[self.target]:remove(self)

            if self.timer then
                DestroyTimer(self.timer)
            end

            counter[self.target] = counter[self.target] - 1

            self.bar = nil
            self.timer = nil
            self.source = nil
            self.target = nil
            self.effect = nil
            self.attacktype = nil
            self.damagetype = nil
            self.allocated = false
        end
    end

    function Shield:add(amount)
        if self.value + amount > 0 then
            self.value = self.value + amount

            if self.value >= self.total then
                self.total = self.value
            end

            if self.bar then
                SetProgressBarPercentage(self.bar, (self.value / self.total) * 100, 0)

                if self.showText then
                    SetProgressBarText(self.bar, I2S(R2I(self.value)))
                end
            end
        end

        return self
    end

    function Shield:restore()
        self.value = self.total

        if self.bar then
            SetProgressBarPercentage(self.bar, 100, 0)

            if self.showText then
                SetProgressBarText(self.bar, I2S(R2I(self.value)))
            end
        end

        return self
    end

    function Shield.getIncrease(unit)
        return increase[unit] or 0
    end

    function Shield.getDecrease(unit)
        return decrease[unit] or 0
    end

    function Shield.setIncrease(unit, value)
        increase[unit] = value

        return value
    end

    function Shield.setDecrease(unit, value)
        decrease[unit] = value

        return value
    end

    function Shield.register(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function Shield.registerBreak(code)
        if type(code) == "function" then
            table.insert(broken, code)
        end
    end

    function Shield.create(source, target, amount, attacktype, damagetype, duration, sfx, attachPoint, showBar, playercolor, showText)
        local self = Shield.allocate()
        
        Shield.instance = self
        Shield.source.unit = source
        Shield.target.unit = target
        Shield.attacktype = attacktype
        Shield.damagetype = damagetype
        Shield.amount = (amount * (1 + (increase[target] or 0))) * (1 - (decrease[target] or 0))
        
        for i = 1, #event do
            event[i]()
        end
        
        if not shields[target] then
            shields[target] = List.create()
        end
        
        self.slot = 0
        self.source = source
        self.target = target
        self.allocated = true
        self.attacktype = attacktype
        self.damagetype = damagetype
        self.showText = showText
        self.value = Shield.amount
        self.total = Shield.amount
        counter[target] = (counter[target] or 0) + 1
        
        if sfx and sfx ~= "" then
            self.effect = AddSpecialEffectTarget(sfx, target, attachPoint)
        end
        
        if showBar then
            self.slot = slots[target] or 0
            slots[target] = (slots[target] or 0) + 1

            if Shield.amount > 0 then
                self.bar = CreateProgressBar(target, 0, -BAR_OFFSET - BAR_GAP * self.slot, 0, BAR_SCALE, 100, showText)
            else
                self.bar = CreateProgressBar(target, 0, -BAR_OFFSET - BAR_GAP * self.slot, 0, BAR_SCALE, 0, showText)
            end

            if showText then
                SetProgressBarText(self.bar, I2S(R2I(self.value)))
            end

            self.bar.playercolor = playercolor
        end
        
        if duration > 0 then
            self.timer = CreateTimer()
            
            TimerStart(self.timer, duration, false, function ()
                self:destroy()
            end)
        end
        
        shields[target]:insert(self)
        
        return self
    end

    function Shield.onDamage()
        if Damage.amount > 0 and (counter[Damage.target.unit] or 0) > 0 then
            local list = shields[Damage.target.unit]

            if list then
                for _, self in pairs(list) do
                    if Damage.amount <= 0 then
                        break
                    end

                    if Damage.attacktype == self.attacktype or Damage.damagetype == self.damagetype or (self.attacktype == nil and self.damagetype == nil) then
                        if Damage.amount < self.value then
                            self.value = self.value - Damage.amount
                            Damage.amount = 0

                            if self.bar then
                                SetProgressBarPercentage(self.bar, (self.value / self.total) * 100, 0)

                                if self.showText then
                                    SetProgressBarText(self.bar, I2S(R2I(self.value)))
                                end
                            end
                        else
                            Damage.amount = Damage.amount - self.value
                            Shield.amount = 0
                            Shield.instance = self
                            Shield.source.unit = self.source
                            Shield.target.unit = self.target
                            Shield.attacktype = self.attacktype
                            Shield.damagetype = self.damagetype
                            Shield.overdamage = Damage.amount 

                            for i = 1, #broken do
                                broken[i]()
                            end
                            
                            self:destroy()
                        end
                    end
                end
            end
        end
    end

    function Shield.onDeindex()
        local unit = GetIndexUnit()
        local list = shields[unit]

        if list then
            for _, shield in pairs(list) do
                shield:destroy()
            end

            list:destroy()
        end

        slots[unit] = nil
        shields[unit] = nil
        counter[unit] = nil
        increase[unit] = nil
        decrease[unit] = nil
    end

    function Shield.onInit()
        RegisterAnyDamageEvent(Shield.onDamage)
        RegisterUnitDeindexEvent(Shield.onDeindex)
    end
end)