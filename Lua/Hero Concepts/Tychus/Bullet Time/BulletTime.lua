--[[ requires RegisterPlayerUnitEvent, DamageInterface, NewBonusUtils
    /* ---------------------- Bullet Time v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Vexorian        - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Bullet Time ability
    local ABILITY = FourCC('A000')

    -- The Bullet Time duration after no attacks.
    local function GetDuration(level)
        return 5. + 0.*level
    end

    -- The Bullet Time Attack Speed bonus per attack per level
    local function GetBonus(level)
        return 0.1 + 0.*level
    end

    -- The Bullet Time Max bonus per level. Real(1. => 100%)
    local function GetMaxBonus(level)
        return 1.*level
    end

    -- The Bullet Time level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local array = {}
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()

            if GetLevel(GetHeroLevel(unit)) then
                IncUnitAbilityLevel(unit, ABILITY)
            end
        end)
        
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local this

            if level > 0 and Damage.isEnemy then
                local amount = GetBonus(level)

                if array[Damage.source.unit] then
                    this = array[Damage.source.unit]
                else
                    this = {}
                    this.timer = CreateTimer()
                    this.unit = Damage.source.unit
                    this.bonus = 0.
                    array[this.unit] = this
                end

                if this.bonus + amount <= GetMaxBonus(level) then
                    this.bonus = this.bonus + amount
                    AddUnitBonus(this.unit, BONUS_ATTACK_SPEED, amount)
                end

                TimerStart(this.timer, GetDuration(level), false, function()
                    AddUnitBonus(this.unit, BONUS_ATTACK_SPEED, -this.bonus)
                    PauseTimer(this.timer)
                    DestroyTimer(this.timer)
                    array[this.unit] = nil
                    this = nil
                end)
            end
        end)
    end)
end