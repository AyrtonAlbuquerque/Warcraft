scope ElementalSpin
    private struct Waves extends Missile
        method onUnit takes unit hit returns boolean
            if UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                if IsUnitEnemy(hit, owner) then
                    call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)

                    if type == 1 then
                        //call DamageOverTimeEx(source, hit, 500, 5, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, "ImmolationRedDamage.mdx", "chest")
                    elseif type == 3 then
                        call AddUnitBonusTimed(hit, BONUS_ARMOR, -10, 10)
                    elseif type == 4 then
                        call AddUnitBonusTimed(hit, BONUS_MOVEMENT_SPEED, -0.5*GetUnitMoveSpeed(hit), 5.00)
                    endif
                elseif type == 2 and IsUnitAlly(hit, owner) then
                    call SetWidgetLife(hit, (GetWidgetLife(hit) + damage))
                    call ArcingTextTag.create(("|cff32cd32" + "+" + N2S(damage, 0)), hit, 0.015)
                endif
            endif

            return false
        endmethod
    endstruct
    
    struct ElementalSpin extends Item
        static constant integer code = 'I07I'

        real intelligence = 20
        real manaRegen = 12
        real healthRegen = 12
        real spellPower = 100
        
        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00100|r Spell Power\n+ |cffffcc0020|r Intelligence\n+ |cffffcc0012|r Health Regeneration\n+ |cffffcc0012|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Elemental Waves|r: Every attack has |cffffcc0020%%|r chance to spawn an elemental wave at target location damaging an applying an special effect on the wave type. When proccing this effect there is |cffffcc0025%%|r chance of creating either a |cffffcc00Holy|r, |cffff0000Fire|r, |cff00ff00Poison|r or |cff8080ffWater|r wave. A |cffffcc00Holy Wave|r will damage enemys and heal allies for |cff00ffff" + N2S(200 + (20 * GetWidgetLevel(u)) + (0.02 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage. A |cffff0000Fire Wave|r damage enemys for |cff00ffff" + N2S(100 + (10 * GetWidgetLevel(u)) + (0.02 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage and apply a |cffff0000Burn|r effect dealing |cff00ffff" + N2S(25 + (5 * GetWidgetLevel(u)) + (0.005 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage per second for |cffffcc005|r seconds. |cff00ff00Poison Wave|r damage enemys for |cff00ffff" + N2S(200 + (20 * GetWidgetLevel(u)) + (0.02 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage and reduce their armor by |cffffcc0010|r  for |cffffcc0010|r seconds. Finnaly the |cff8080ffWater Wave|r damage enemys for |cff00ffff" + N2S(200 + (20 * GetWidgetLevel(u)) + (0.02 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage and reduce their movement speed by |cffffcc0050%%|r for |cffffcc005|r seconds."
        endmethod

        private static method onDamage takes nothing returns nothing
            local real a
            local real z
            local Waves missile

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and GetRandomInt(1, 100) <= 20 and not Damage.target.isStructure then
                set z = GetUnitFlyHeight(Damage.target.unit)
                set a = AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y)
                set missile = Waves.create(Damage.target.x, Damage.target.y, z, Damage.target.x + 350*Cos(a), Damage.target.y + 350*Sin(a), z)

                set missile.type = GetRandomInt(1, 4)

                if missile.type == 1 then
                    set missile.model  = "LavaBreath.mdx"
                    set missile.damage = 100 + (10 * Damage.source.level) + (0.02 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
                elseif missile.type == 2 then
                    set missile.model  = "HolyBreath.mdx"
                    set missile.damage = 200 + (20 * Damage.source.level) + (0.02 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
                elseif missile.type == 3 then
                    set missile.model  = "AcidBreath.mdx"
                    set missile.damage = 200 + (20 * Damage.source.level) + (0.02 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
                elseif missile.type == 4 then
                    set missile.model  = "WaterBreath.mdx"
                    set missile.damage = 200 + (20 * Damage.source.level) + (0.02 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
                endif
                
                set missile.source = Damage.source.unit
                set missile.owner = Damage.source.player
                set missile.speed = 900
                set missile.scale = 0.75
                set missile.collision = 250

                call missile.launch()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfFire.code, OrbOfWater.code, OrbOfVenom.code, OrbOfLight.code, 0)
        endmethod
    endstruct
endscope