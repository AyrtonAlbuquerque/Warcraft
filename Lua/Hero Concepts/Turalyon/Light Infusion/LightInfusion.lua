--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Utilities, NewBonus
   /* -------------------- Light Infusion v1.2 by Chopinski -------------------- */
    // Credits:
    //     NO-Bloody-Name  - Icon
    //     Bribe           - SpellEffectEvent, Table
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Divine Edict Effect
    //     JetFangInferno  - LightFlash effect
    /* ----------------------------------- END ---------------------------------- */ 
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Light Infusion ability
    local ABILITY     = FourCC('A000')
    -- The Light Infusion orb model
    local MODEL       = "LightOrb.mdl"
    -- The Light Infusion orb scale
    local SCALE       = 1.
    -- The Light Infusion orb death model
    local DEATH_MODEL = "LightFlash.mdl"
    -- The Light Infusion death model scale
    local DEATH_SCALE = 0.5
    -- The Light Infusion orbs offset
    local OFFSET      = 125.
    -- The Light Infusion orb update period
    local PERIOD      = 0.05

    -- The Light Infusion max number of charges
    local function GetMaxCharges(level)
        return 3 + 0*level
    end

    -- The Light Infusion health regen bonus per stack
    local function GetBonusRegen(level)
        return 5. + 0.*level
    end

    -- The Light Infusion level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15 or level == 20
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    LightInfusion = setmetatable({}, {})
    local mt = getmetatable(LightInfusion)
    mt.__index = mt
    
    LightInfusion.charges = {}
    
    local timer = CreateTimer()
    local array = {}
    local effect = {}
    local n = {}
    local key = 0
    local STEP = 2.5*bj_DEGTORAD
    local CIRCLE = 2*bj_PI
    
    function mt:consume(unit)
        if (LightInfusion.charges[unit] or 0) > 0 and n[unit] then
            local this = n[unit]
            local x = BlzGetLocalSpecialEffectX(effect[unit][LightInfusion.charges[unit]])
            local y = BlzGetLocalSpecialEffectY(effect[unit][LightInfusion.charges[unit]])
            local z = BlzGetLocalSpecialEffectZ(effect[unit][LightInfusion.charges[unit]])
            
            DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, x, y, z, DEATH_SCALE))
            DestroyEffect(effect[unit][LightInfusion.charges[unit]])
            LightInfusion.charges[unit] = LightInfusion.charges[unit] - 1
            
            if LightInfusion.charges[unit] > 0 then
                this.arc = CIRCLE/LightInfusion.charges[unit]
            end

            AddUnitBonus(unit, BONUS_HEALTH_REGEN, -this.bonus)
            this.bonus = LightInfusion.charges[unit]*GetBonusRegen(GetUnitAbilityLevel(unit, ABILITY))
            AddUnitBonus(unit, BONUS_HEALTH_REGEN, this.bonus)
        end
    end
    
    function mt:destroy(i)
        for j = 1, GetMaxCharges(GetUnitAbilityLevel(self.unit, ABILITY)) do
            DestroyEffect(effect[self.unit][j])
        end
        effect[self.unit] = nil

        array[i] = array[key]
        key = key - 1
        LightInfusion.charges[self.unit] = nil
        n[self.unit] = nil
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:onCast()
        local this

        if (LightInfusion.charges[Spell.source.unit] or 0) < GetMaxCharges(Spell.level) then
            if n[Spell.source.unit] then
                this = n[Spell.source.unit]
            else
                this = {}
                setmetatable(this, mt)
                
                this.unit = Spell.source.unit
                effect[this.unit] = {}
                this.angle = 0
                this.bonus = 0
                n[this.unit] = this
                key = key + 1
                array[key] = this

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                
                        while i <= key do
                            local this = array[i]
                            
                            if (LightInfusion.charges[this.unit] or 0) > 0 then
                                local x = GetUnitX(this.unit)
                                local y = GetUnitY(this.unit)
                                local z = GetUnitZ(this.unit) + 100
                                
                                this.angle = this.angle + STEP
                                for j = 1, LightInfusion.charges[this.unit] do
                                    BlzSetSpecialEffectPosition(effect[this.unit][j], x + OFFSET*Cos(this.angle + j*this.arc), y + OFFSET*Sin(this.angle + j*this.arc), z)
                                end
                            else
                                i = this:destroy(i)
                            end
                            i = i + 1
                        end
                    end)
                end
            end

            LightInfusion.charges[this.unit] = (LightInfusion.charges[this.unit] or 0) + 1
            effect[this.unit][LightInfusion.charges[this.unit]] = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, Spell.source.z + 100, SCALE)
            this.arc = CIRCLE/LightInfusion.charges[this.unit]

            AddUnitBonus(this.unit, BONUS_HEALTH_REGEN, -this.bonus)
            this.bonus = LightInfusion.charges[this.unit]*GetBonusRegen(Spell.level)
            AddUnitBonus(this.unit, BONUS_HEALTH_REGEN, this.bonus)
        else
            ResetUnitAbilityCooldown(Spell.source.unit, Spell.id)
            DisplayTextToPlayer(Spell.source.player, 0, 0, "Already at full stacks.")
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            LightInfusion:onCast()
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()

            if GetLevel(GetHeroLevel(unit)) then
                IncUnitAbilityLevel(unit, ABILITY)
            end
        end)
    end)
end