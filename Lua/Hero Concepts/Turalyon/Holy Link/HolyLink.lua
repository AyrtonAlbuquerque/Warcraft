--[[ requires SpellEffectEvent, Utilities, DamageInterface, NewBonus, optional LightInfusion
    /* ----------------------- Holy Link v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Metal_Sonic     - Rejuvenation Effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Holy Link ability
    local ABILITY       = FourCC('A002')
    -- The Holy Link Normal buff model
    local MODEL         = "Rejuvenation.mdl"
    -- The Holy Link infused buff model
    local INFUSED_MODEL = "Rejuvenation.mdl"
    -- The Holy Link lightning effect
    local LIGHTNING     = "HWSB"
    -- The Holy Link model attachment point
    local ATTACH_POINT  = "chest"
    -- The Holy Link update period
    local PERIOD        = 0.031250000

    -- The Holy Link Health Regen bonus
    local function GetBonus(unit, level)
        local real base = 5. + 5.*level

        return (base + base*(1 - (GetUnitLifePercent(unit)*0.01)))*PERIOD
    end

    -- The Holy Link Movement Speed bonus
    local function GetMovementBonus(level, infused)
        if infused then
            return 50 + 0*level
        else
            return 0
        end
    end

    -- The Holy Link break distance
    local function GetAoE(level, infused)
        if infused then
            return 1200. + 0.*level
        else
            return 800. + 0.*level
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    HolyLink = setmetatable({}, {})
    local mt = getmetatable(HolyLink)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local reduce = {}
    local n = {}
    local key = 0
    
    function mt:destroy(i)
        DestroyLightning(self.lightning)
        DestroyEffect(self.effect)

        if self.infused then
            reduce[self.target] = reduce[self.target] - 1
            DestroyEffect(self.e)
            AddUnitBonus(self.unit, BONUS_MOVEMENT_SPEED, -self.bonus)
            AddUnitBonus(self.target, BONUS_MOVEMENT_SPEED, -self.bonus)
        end

        n[self.unit] = nil
        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:link(source, target, level, infused)
        local this = {}
        setmetatable(this, mt)

        this.unit = source
        this.target = target
        this.infused = infused
        this.bonus = GetMovementBonus(level, infused)
        this.distance = GetAoE(level, infused)
        this.count = 0
        this.lightning = AddLightningEx(LIGHTNING, false, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 30, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 30)
        this.effect = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
        n[this.unit] = this
        key = key + 1
        array[key] = this

        if infused then
            this.e = AddSpecialEffectTarget(MODEL, source, ATTACH_POINT)
            reduce[target] = (reduce[target] or 0) + 1
            AddUnitBonus(source, BONUS_MOVEMENT_SPEED, this.bonus)
            AddUnitBonus(target, BONUS_MOVEMENT_SPEED, this.bonus)
        end

        if key == 1 then
            TimerStart(timer, PERIOD, true, function()
                local i = 1
                
                while i <= key do
                    local this = array[i]
                    local x = GetUnitX(this.unit)
                    local y = GetUnitY(this.unit)
                    local tx = GetUnitX(this.target)
                    local ty = GetUnitY(this.target)
                    
                    if DistanceBetweenCoordinates(x, y, tx, ty) <= this.distance and UnitAlive(this.target) and UnitAlive(this.unit) then
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)

                        if this.infused then
                            SetWidgetLife(this.unit, GetWidgetLife(this.unit) + GetBonus(this.unit, level))
                            SetWidgetLife(this.target, GetWidgetLife(this.target) + GetBonus(this.target, level))
                        else
                            SetWidgetLife(this.target, GetWidgetLife(this.target) + GetBonus(this.target, level))
                        end
                        
                        if this.count <= 28 then -- This is here because reforged lightnings dont persist visually...
                            this.count = this.count + 1
                            MoveLightningEx(this.lightning, false, x, y, GetUnitZ(this.unit) + 30, tx, ty, GetUnitZ(this.target) + 30)
                        else
                            this.count = 0
                            DestroyLightning(this.lightning)
                            this.lightning = AddLightningEx(LIGHTNING, false, x, y, GetUnitZ(this.unit) + 30, tx, ty, GetUnitZ(this.target) + 30)
                        end
                    else
                        i = this:destroy(i)
                    end
                    i = i + 1
                end
            end)
        end
    end
    
    function mt:onCast()
        local this

        if n[Spell.source.unit] then -- If a link already exists
            this = n[Spell.source.unit]
            
            if Spell.target.unit == this.target then -- Trying to link with already linked target
                if LightInfusion then
                    if this.infused then -- Already Infused, reset
                        ResetUnitAbilityCooldown(this.unit, Spell.id)
                    else
                        this.infused = (LightInfusion.charges[this.unit] or 0) > 0
                        this.distance = GetAoE(Spell.level, this.infused)
                        this.bonus = GetMovementBonus(Spell.level, this.infused)

                        if this.infused then
                            reduce[this.target] = (reduce[this.target] or 0) + 1 
                            this.e = AddSpecialEffectTarget(MODEL, this.unit, ATTACH_POINT)
                            AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, this.bonus)
                            AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, this.bonus)
                        end
                        LightInfusion:consume(this.unit)
                    end
                else
                    ResetUnitAbilityCooldown(this.unit, Spell.id)
                end
            else -- Link exists but trying to link to another unit
                DestroyLightning(this.lightning)
                DestroyEffect(this.effect)
                
                if LightInfusion then
                    if this.infused then -- Clean up from previous linked unit
                        reduce[this.target] = reduce[this.target] - 1
                        AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, -this.bonus)
                        AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, -this.bonus)
                        DestroyEffect(this.e)
                    end

                    -- Set up for current linked unit
                    this.unit = Spell.source.unit
                    this.target = Spell.target.unit
                    this.infused = (LightInfusion.charges[this.unit] or 0) > 0
                    this.bonus = GetMovementBonus(Spell.level, this.infused)
                    this.distance = GetAoE(Spell.level, this.infused)
                    this.count = 0
                    this.lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                    this.effect = AddSpecialEffectTarget(MODEL, this.target, ATTACH_POINT)

                    if this.infused then
                        reduce[this.target] = (reduce[this.target] or 0) + 1 
                        this.e = AddSpecialEffectTarget(MODEL, this.unit, ATTACH_POINT)
                        AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, this.bonus)
                        AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, this.bonus)
                    end
                    LightInfusion:consume(this.unit)
                else
                    this.unit = Spell.source.unit
                    this.target = Spell.target.unit
                    this.infused = false
                    this.bonus = GetMovementBonus(Spell.level, this.infused)
                    this.distance = GetAoE(Spell.level, this.infused)
                    this.count = 0
                    this.lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                    this.effect = AddSpecialEffectTarget(MODEL, this.target, ATTACH_POINT)
                end
            end
        else -- Create the link
            if LightInfusion then
                self:link(Spell.source.unit, Spell.target.unit, Spell.level, (LightInfusion.charges[Spell.source.unit] or 0) > 0)
                LightInfusion:consume(Spell.source.unit)
            else
                self:link(Spell.source.unit, Spell.target.unit, Spell.level, false)
            end
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            HolyLink:onCast()
        end)

        if LightInfusion then
            RegisterAnyDamageEvent(function()
                local damage = GetEventDamage()

                if damage > 0 and (reduce[Damage.target.unit] or 0) > 0 then
                    BlzSetEventDamage(damage*0.75)
                end
            end)
        end
    end)
end