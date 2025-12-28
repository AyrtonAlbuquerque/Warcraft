OnInit("SpellShield", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Metamorphosis"

    -- ----------------------------- Spell Shield v1.5 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Spell Shield ability
    local ABILITY    = S2A('Idn4')
    -- The raw code of the Spell Shield buff
    local BUFF       = S2A('BId1')
    -- The Spell Shield model
    local MODEL      = "SpellShield.mdl"
    -- Spell Shield block effect period
    local PERIOD     = 0.03125
    -- The on cast missile model
    local MISSILE    = "Windwalk Necro Soul.mdl"
    -- The missile speed
    local SPEED      = 1000
    -- The missile scale
    local SCALE      = 0.5

    -- The Adaptive Strike damage
    local function GetConversion(level)
        return 0.2 + 0.1*level
    end

    -- The Spell Shield on cast AoE
    local function GetAoE(source, level)
        return 800 + 0.*level
    end

    -- The Spell Shield on cast damage
    local function GetDamage(source, level)
        return 50*level + (0.6 + 0.1*level)*GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The missile arc.
    local function GetArc(level)
        return GetRandomReal(5, 15)
    end

    -- The missile curve.
    local function GetCurve(level)
        return GetRandomReal(-10, 10)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Projectile = Class(Missile)

        function Projectile:onFinish()
            if UnitAlive(self.target) then
                UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
            end

            return true
        end
    end

    do
        SpellShield = Class(Spell)

        local array = {}
        local timer = CreateTimer()
        local group = CreateGroup()

        function SpellShield:destroy()
            DestroyEffect(self.effect)

            self.source = nil
            self.target = nil
            self.effect = nil
        end

        function SpellShield:onTooltip(source, level, ability)
            return "|cffffcc00Illidan|r becomes immune to all crowd control for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, level - 1), 1) .. "|r seconds and any enemy unit that casts an ability within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r are damaged for |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage. In addition, |cffffcc00" .. N2S(GetConversion(level) * 100, 0) .. "%%|r of all |cff00ffffMagic|r damage |cffffcc00Illidan|r takes while under the effect of |cffffcc00Spell Shield|r is converted into bonus damage, lasting until the effect expires."
        end

        function SpellShield.onPeriod()
            for i = #array, 1, -1 do
                local self = array[i]

                self.duration = self.duration - 1

                if self.duration > 0 then
                    self.x = GetUnitX(self.target)
                    self.y = GetUnitY(self.target)
                    self.angle = AngleBetweenCoordinates(self.x, self.y, GetUnitX(self.source), GetUnitY(self.source))

                    if Metamorphosis then
                        if GetUnitAbilityLevel(self.target, Metamorphosis_BUFF) > 0 then
                            self.height = GetUnitZ(self.target) + 400
                        else
                            self.height = GetUnitZ(self.target) + 100
                        end
                    else
                        self.height = GetUnitZ(self.target) + 100
                    end

                    BlzSetSpecialEffectPosition(self.effect, self.x + 60*math.cos(self.angle), self.y + 60*math.sin(self.angle), self.height)
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                else
                    self:destroy()
                    table.remove(array, i)

                    if #array == 0 then
                        PauseTimer(timer)
                    end
                end
            end
        end

        function SpellShield:onCast()
            UnitDispelAllCrowdControl(Spell.source.unit)
            GroupAddUnit(group, Spell.source.unit)
        end

        function SpellShield.onCrowdControl()
            if GetUnitAbilityLevel(GetCrowdControlUnit(), BUFF) > 0 then
                SetCrowdControlDuration(0)
            end
        end

        function SpellShield.onSpell()
            local size = BlzGroupGetSize(group)
            local g = CreateGroup()
            
            if size > 0 then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local unit = BlzGroupUnitAt(group, i)
                    
                    if GetUnitAbilityLevel(unit, BUFF) > 0 then
                        local x = GetUnitX(unit)
                        local y = GetUnitY(unit)
                        local level = GetUnitAbilityLevel(unit, ABILITY)
                        
                        if UnitAlive(unit) and IsUnitEnemy(unit, Spell.source.player) and DistanceBetweenCoordinates(x, y, Spell.source.x, Spell.source.y) < GetAoE(unit, level) then
                            local missile = Projectile.create(x, y, GetUnitZ(unit) + 60, Spell.source.x, Spell.source.y, Spell.source.z + 60)
                            
                            missile.model = MISSILE
                            missile.speed = SPEED
                            missile.scale = SCALE
                            missile.source = unit
                            missile.target = Spell.source.unit
                            missile.damage = GetDamage(unit, level)
                            missile.arc = GetArc(level) * bj_DEGTORAD
                            missile.curve = GetCurve(level) * bj_DEGTORAD

                            missile:launch()
                        end
                    elseif unit ~= Spell.source.unit then
                        GroupAddUnit(g, unit)
                    end
                end
            end

            BlzGroupRemoveGroupFast(g, group)
            DestroyGroup(g)
        end

        function SpellShield.onDamage()
            if Damage.amount > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                local self = SpellShield.allocate()

                self.duration = 16
                self.source = Damage.source.unit
                self.target = Damage.target.unit
                self.angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                self.x = Damage.target.x + 60*math.cos(self.angle)
                self.y = Damage.target.y + 60*math.sin(self.angle)
                self.effect = AddSpecialEffect(MODEL, self.x, self.y)
                self.bonus = Damage.amount * GetConversion(GetUnitAbilityLevel(Damage.target.unit, ABILITY))
                Damage.amount = Damage.amount - self.bonus

                if Metamorphosis then
                    if GetUnitAbilityLevel(Damage.target.unit, Metamorphosis_BUFF) > 0 then
                        self.height = GetUnitZ(Damage.target.unit) + 400
                    else
                        self.height = GetUnitZ(Damage.target.unit) + 100
                    end
                else
                    self.height = GetUnitZ(Damage.target.unit) + 100
                end
        
                table.insert(array, self)
                BlzSetSpecialEffectZ(self.effect, self.height)
                BlzSetSpecialEffectScale(self.effect, 1.5)
                BlzSetSpecialEffectYaw(self.effect, self.angle)
                BlzSetSpecialEffectColor(self.effect, 0, 0, 255)
                LinkBonusToBuff(Damage.target.unit, BONUS_DAMAGE, self.bonus, BUFF)

                if #array == 1 then
                    TimerStart(timer, PERIOD, true, SpellShield.onPeriod)
                end
            end
        end

        function SpellShield.onInit()
            RegisterSpell(SpellShield.allocate(), ABILITY)
            RegisterSpellDamageEvent(SpellShield.onDamage)
            RegisterAnyCrowdControlEvent(SpellShield.onCrowdControl)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, SpellShield.onSpell)
        end
    end
end)