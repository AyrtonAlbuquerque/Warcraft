OnInit("ManaOrb", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------- Mana Orb v1.1 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY        = S2A('Jna8')
    -- The raw code of the level 1 buff
    local BUFF_1         = S2A('BJn0')
    -- The raw code of the level 2 buff
    local BUFF_2         = S2A('BJn1')
    -- The raw code of the level 3 buff
    local BUFF_3         = S2A('BJn2')
    -- The raw code of the level 4 buff
    local BUFF_4         = S2A('BJn3')
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        ManaOrb = Class(Spell)

        local buff = {}

        function ManaOrb:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            
            self.group = nil
            self.timer = nil
            self.player = nil
            self.effect = nil
        end

        function ManaOrb:onTooltip(source, level, ability)
            return "Enemy units that die within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r of |cffffcc00Jaina|r have a |cffffcc00" .. N2S(20, 0) .. "%%|r chance to drop a |cff00ffffMana Orb|r. Enemy heroes always drop an orb. Whenever |cffffcc00Jaina|r or an allied |cffffcc00Hero|r comes near a |cff00ffffMana Orb|r they will collect it, gaining |cff00ffff" .. N2S(10 + 10 * level, 0) .. "|r maximum mana. The orb lingers for |cffffcc0020|r seconds before disappearing."
        end

        function ManaOrb.onDamage()
            if Damage.amount > 0 then
                buff[Damage.target.unit] = nil
                
                if Damage.amount >= Damage.target.health and UnitDropFilter(Damage.target.unit) then
                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_4) then
                            buff[Damage.target.unit] = BUFF_4
                        end
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_3) then
                            buff[Damage.target.unit] = BUFF_3
                        end
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_2) then
                            buff[Damage.target.unit] = BUFF_2
                        end
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_1) then
                            buff[Damage.target.unit] = BUFF_1
                        end
                    end
                end
            end
        end

        function ManaOrb.onDeath()
            local unit = GetTriggerUnit()
            
            if buff[unit] then
                local self = { destroy = ManaOrb.destroy }

                self.x = GetUnitX(unit)
                self.y = GetUnitY(unit)
                self.timer = CreateTimer()
                self.group = CreateGroup()
                self.player = GetOwningPlayer(unit)
                self.effect = AddSpecialEffectEx(MODEL, self.x, self.y, 0, SCALE)
                self.duration = GetDuratoin(buff[unit])
                self.range = GetPickupRange(buff[unit])
                self.bonus = GetManaBonus(buff[unit])
                
                TimerStart(self.timer, PERIOD, true, function ()
                    if self.duration > 0 then
                        self.duration = self.duration - PERIOD

                        GroupEnumUnitsInRange(self.group, self.x, self.y, self.range, nil)

                        local u = FirstOfGroup(self.group)

                        while u do
                            if UnitPickupFilter(self.player, u) then
                                AddUnitBonus(u, BONUS_MANA, self.bonus)
                                DestroyEffect(AddSpecialEffectTarget(EFFECT, u, ATTACH))
                                self:destroy()
                                break
                            end

                            GroupRemoveUnit(self.group, u)
                            u = FirstOfGroup(self.group)
                        end
                    else
                        self:destroy()
                    end
                end)
            end
        end

        function ManaOrb.onInit()
            RegisterSpell(ManaOrb.allocate(), ABILITY)
            RegisterAnyDamageEvent(ManaOrb.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, ManaOrb.onDeath)
        end
    end
end)