--[[ requires RegisterPlayerUnitEvent, Missiles, Utilities, MouseUtils, NewBonus optional ArsenalUpgrade
    /* ----------------------- Overkill v1.2 by Chopinski ----------------------- */
    // Credits:
    //     Blizzard         - Icon
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     MyPad            - MouseUtils
    //     Gray Knight      - Bullet model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Overkill ability
    Overkill_ABILITY = FourCC('A004')
    -- The raw code of the Overkill buff
    local BUFF       = FourCC('B001')
    -- The Bullet model
    local MODEL      = "Bullet.mdl"
    -- The Bullet scale
    local SCALE      = 1.
    -- The Bullet speed
    local SPEED      = 2000.
    -- The firing period
    local PERIOD     = 0.03125

    -- The X coordinate starting point for the bullets. This exists so the bullets
    -- will come out of the tychus model weapon barrel.
    local function GetX(x, face)
        return x + 120*Cos(face + 13*bj_DEGTORAD)
    end

    -- The Y coordinate starting point for the bullets. This exists so the bullets
    -- will come out of the tychus model weapon barrel.
    local function GetY(y, face)
        return y + 120*Sin(face + 13*bj_DEGTORAD)
    end

    -- The Bullet damage.
    local function GetDamage(level, source)
        return (5. + 5.*level) + GetUnitBonus(source, BONUS_DAMAGE)*0.25*level
    end

    -- The Bullet collision.
    local function GetCollision(level)
        return 15. + 0.*level
    end

    -- The Bullets max aoe spread.
    local function GetMaxAoE(level)
        return 200. + 0.*level
    end

    -- The Bullet max travel distance
    local function GetTravelDistance(level)
        return 600. + 0.*level
    end

    -- The Bullet mana cost
    local function GetManaCost(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 0.5 + 0.*level
            else
                return 1. + 0.*level
            end
        else
            return 1. + 0.*level
        end
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Overkill = setmetatable({}, {})
    local mt = getmetatable(Overkill)
    mt.__index = mt
    
    local timer = CreateTimer()
    local array = {}
    local n = {}
    local key = 0
    
    function mt:destroy(i)
        AddUnitAnimationProperties(self.unit, "spin", false)
        QueueUnitAnimation(self.unit, "Stand Ready")
        IssueImmediateOrderById(self.unit, 852590)
        DisarmUnit(self.unit, false)

        array[i] = array[key]
        key = key - 1
        n[self.unit] = nil
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:onOrder()
        local order = GetIssuedOrderId()
        local unit = GetOrderedUnit()
        local this

        if order == 852589 then
            if n[unit] then
                this = n[unit]
            else
                this = {}
                setmetatable(this, mt)
                
                this.unit = unit
                this.prevX = GetUnitX(unit)
                this.prevY = GetUnitY(unit)
                this.player = GetOwningPlayer(unit)
                key = key + 1
                array[key] = this
                n[unit] = this

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                        local morphed = false
                        
                        while i <= key do
                            local this = array[i]
                            local level = GetUnitAbilityLevel(this.unit, Overkill_ABILITY)
                            local cost = GetManaCost(this.unit, level)
                            
                            if CommanderOdin then
                                morphed = CommanderOdin.morphed[this.unit]
                            end
                            
                            if GetUnitAbilityLevel(this.unit, BUFF) > 0 and GetUnitState(this.unit, UNIT_STATE_MANA) >= cost and not morphed then
                                local offset = GetTravelDistance(level)
                                local range = GetRandomRange(GetMaxAoE(level))
                                local face = GetUnitFacing(this.unit)*bj_DEGTORAD
                                local x = GetUnitX(this.unit)
                                local y = GetUnitY(this.unit)
                                local bullet = Missiles:create(GetX(x, face), GetY(y, face), 70, GetRandomCoordInRange(x + offset*Cos(face), range, true), GetRandomCoordInRange(y + offset*Sin(face), range, false), GetRandomReal(0, 80))
                                
                                bullet:model(MODEL)
                                bullet:speed(SPEED)
                                bullet:scale(SCALE)
                                bullet.source = this.unit
                                bullet.owner = this.player
                                bullet.damage = GetDamage(level, this.unit)
                                bullet.collision = GetCollision(level)

                                bullet.onHit = function(hit)
                                    if DamageFilter(bullet.owner, hit) then
                                        UnitDamageTarget(bullet.source, hit, bullet.damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil)
                                    end

                                    return false
                                end

                                if x ~= this.prevX and y ~= this.prevY then
                                    this.prevX = x
                                    this.prevY = y
                                    AddUnitAnimationProperties(this.unit, "spin", true)
                                else
                                    AddUnitAnimationProperties(this.unit, "spin", false)
                                    SetUnitAnimation(this.unit, "Attack")
                                end

                                AddUnitMana(this.unit, -cost)
                                BlzSetUnitFacingEx(this.unit, AngleBetweenCoordinates(x, y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player))*bj_RADTODEG)
                                bullet:launch()
                            else
                                i = this:destroy(i)
                            end
                            i = i + 1
                        end
                    end)
                end
            end
            DisarmUnit(unit, true)
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
            Overkill:onOrder()
        end)
    end)
end