--[[ requires RegisterPlayerUnitEvent, Utilities, NewBonus, DamageInterface
    /* ----------------------- Water Orb v1.0 by Chopinski ---------------------- */
    // Credits:
    //     Darkfang             - Icon
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     General Frank        - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the level 1 buff
    local BUFF_1         = FourCC('B002')
    -- The raw code of the level 2 buff
    local BUFF_2         = FourCC('B003')
    -- The raw code of the level 3 buff
    local BUFF_3         = FourCC('B004')
    -- The raw code of the level 4 buff
    local BUFF_4         = FourCC('B005')
    -- The orb model
    local MODEL          = "OrbWaterX.mdl"
    -- The orb model scale
    local SCALE          = 1.
    -- The pickup effect model
    local EFFECT         = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
    -- The pickup effect model attach point
    local ATTACH         = "origin"
    -- The update period
    local PERIOD         = 0.25

    -- The orb duration
    local function GetDuratoin(buff)
        if buff == BUFF_1 then
            return 20.
        elseif buff == BUFF_2 then
            return 20.
        elseif buff == BUFF_3 then
            return 20.
        else
            return 20.
        end
    end

    -- The max mana bonus
    local function GetManaBonus(buff)
        if buff == BUFF_1 then
            return 20.
        elseif buff == BUFF_2 then
            return 30.
        elseif buff == BUFF_3 then
            return 40.
        else
            return 50.
        end
    end
    
    -- The chance to drop an orb
    local function GetDropChance(unit, buff)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 100
        else
            if buff == BUFF_1 then
                return 20
            elseif buff == BUFF_2 then
                return 20
            elseif buff == BUFF_3 then
                return 20
            else
                return 20
            end
        end
    end
    
    -- The orb pickup range
    local function GetPickupRange(buff)
        if buff == BUFF_1 then
            return 100.
        elseif buff == BUFF_2 then
            return 100.
        elseif buff == BUFF_3 then
            return 100.
        else
            return 100.
        end
    end
    
    -- The unit drop filter
    local function UnitDropFilter(unit)
        return not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end
    
    -- The unit pickup filter
    local function UnitPickupFilter(player, target)
        return UnitAlive(target) and IsUnitType(target, UNIT_TYPE_HERO) and IsUnitEnemy(target, player)
    end
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local WaterOrb = setmetatable({}, {})
        local mt = getmetatable(WaterOrb)
        mt.__index = mt

        local timer = CreateTimer()
        local key = 0
        local array = {}
        local flag = {}

        function mt:allocate()
            local this = {}
            setmetatable(this, mt)
            return this
        end

        function mt:remove(i)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)

            array[i] = array[key]
            key = key - 1

            if key == 0 then
                PauseTimer(timer)
            end

            self = nil

            return i - 1
        end

        function mt:onPeriod()
            local i = 1
            local this

            while i <= key do
                this = array[i]

                if this.duration > 0 then
                    this.duration = this.duration - PERIOD

                    GroupEnumUnitsInRange(this.group, this.x, this.y, this.range, nil)
                    for j = 0, BlzGroupGetSize(this.group) - 1 do
                        local unit = BlzGroupUnitAt(this.group, j)

                        if UnitPickupFilter(this.player, unit) then
                            AddUnitBonus(unit, BONUS_MANA, this.bonus)
                            DestroyEffect(AddSpecialEffectTarget(EFFECT, unit, ATTACH))
                            i = this:remove(i)
                            break
                        end
                    end
                else
                    i = this:remove(i)
                end
                i = i + 1
            end
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
                local unit = GetTriggerUnit()

                if flag[unit] then
                    local this = WaterOrb:allocate()
                    key = key + 1
                    array[key] = this

                    this.x = GetUnitX(unit)
                    this.y = GetUnitY(unit)
                    this.group = CreateGroup()
                    this.player = GetOwningPlayer(unit)
                    this.effect = AddSpecialEffectEx(MODEL, this.x, this.y, 0, SCALE)
                    this.duration = GetDuratoin(flag[unit])
                    this.range = GetPickupRange(flag[unit])
                    this.bonus = GetManaBonus(flag[unit])

                    if key == 1 then
                        TimerStart(timer, PERIOD, true, function() WaterOrb:onPeriod() end)
                    end
                end
            end)

            RegisterAnyDamageEvent(function()
                local damage = GetEventDamage()

                if damage > 0 then
                    flag[Damage.target.unit] = nil

                    if damage >= GetWidgetLife(Damage.target.unit) and UnitDropFilter(Damage.target.unit) then
                        if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                            if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_4) then
                                flag[Damage.target.unit] = BUFF_4
                            end
                        elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                            if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_3) then
                                flag[Damage.target.unit] = BUFF_3
                            end
                        elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                            if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_2) then
                                flag[Damage.target.unit] = BUFF_2
                            end
                        elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                            if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_1) then
                                flag[Damage.target.unit] = BUFF_1
                            end
                        end
                    end
                end
            end)
        end)
    end
end