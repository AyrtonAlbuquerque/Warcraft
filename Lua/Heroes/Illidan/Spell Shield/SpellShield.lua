--[[ requires DamageInterface, SpellEffectEvent, Utilities, NewBonusUtils, CrowdControl, optional Metamorphosis
    /* --------------------- Spell Shield v1.3 by Chopinski --------------------- */
    // Credits:
    //     Darkfang        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Spell Shield ability
    local ABILITY      = FourCC('A004')
    -- The raw code of the Spell Shield buff
    local BUFF         = FourCC('B003')
    -- The Spell Shield model
    local MODEL        = "SpellShield.mdl"
    -- Spell Shield block effect period
    local PERIOD       = 0.03125

    -- The Adaptive Strike damage
    local function GetConversion(level)
        return 0.2 + 0.1*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    SpellShield = setmetatable({}, {})
    local mt = getmetatable(SpellShield)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local key = 0
    
    function mt:destroy(i)
        DestroyEffect(self.effect)

        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:onDamage()
        local damage = GetEventDamage()
        
        if damage > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
            local this = {}
            setmetatable(this, mt)
            
            this.source = Damage.source.unit
            this.target = Damage.target.unit
            this.angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
            this.x = Damage.target.x + 60*Cos(this.angle)
            this.y = Damage.target.y + 60*Sin(this.angle)
            this.count = 16
            this.effect = AddSpecialEffect(MODEL, this.x, this.y)
            key = key + 1
            array[key] = this
            damage = damage*(1 - GetConversion(GetUnitAbilityLevel(Damage.target.unit, ABILITY)))

            if Metamorphosis then
                if GetUnitAbilityLevel(Damage.target.unit, Metamorphosis_BUFF) > 0 then
                    this.height = GetUnitZ(Damage.target.unit) + 400
                else
                    this.height = GetUnitZ(Damage.target.unit) + 100
                end
            else
                this.height = GetUnitZ(Damage.target.unit) + 100
            end
            
            BlzSetSpecialEffectZ(this.effect, this.height)
            BlzSetSpecialEffectScale(this.effect, 1.5)
            BlzSetSpecialEffectYaw(this.effect, this.angle)
            BlzSetSpecialEffectColor(this.effect, 0, 0, 255)
            BlzSetEventDamage(damage)
            LinkBonusToBuff(Damage.target.unit, BONUS_DAMAGE, damage, BUFF)

            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1

                    while i <= key do
                        local this = array[i]
                        
                        if this.count <= 0 then
                            i = this:destroy(i)
                        else
                            this.x = GetUnitX(this.target)
                            this.y = GetUnitY(this.target)
                            this.angle = AngleBetweenCoordinates(this.x, this.y, GetUnitX(this.source), GetUnitY(this.source))

                            if Metamorphosis then
                                if GetUnitAbilityLevel(this.target, Metamorphosis_BUFF) > 0 then
                                    this.height = GetUnitZ(this.target) + 400
                                else
                                    this.height = GetUnitZ(this.target) + 100
                                end
                            else
                                this.height = GetUnitZ(this.target) + 100
                            end

                            BlzSetSpecialEffectPosition(this.effect, this.x + 60*Cos(this.angle), this.y + 60*Sin(this.angle), this.height)
                            BlzSetSpecialEffectYaw(this.effect, this.angle)
                        end
                        this.count = this.count - 1
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            UnitDispelAllCrowdControl(Spell.source.unit)
        end)
        
        RegisterSpellDamageEvent(function()
            SpellShield:onDamage()
        end)

        RegisterAnyCrowdControlEvent(function()
            if GetUnitAbilityLevel(GetCrowdControlUnit(), BUFF) > 0 then
                SetCrowdControlDuration(0)
            end
        end)
    end)
end