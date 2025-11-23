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
            local real value
            local real lesser
            local real dot

            if IsUnitType(u, UNIT_TYPE_HERO) then
                set dot = 25 + (5 * GetHeroLevel(u))
                set value = 200 + (20 * GetHeroLevel(u))
                set lesser = 100 + (10 * GetHeroLevel(u))
            else
                set dot = 25 + (5 * GetUnitLevel(u))
                set value = 200 + (20 * GetUnitLevel(u))
                set lesser = 100 + (10 * GetUnitLevel(u))
            endif

            return "|cffffcc00Gives:|r+ |cffffcc00100|r Spell Power\n+ |cffffcc0020|r Intelligence\n+ |cffffcc0012|r Health Regeneration\n+ |cffffcc0012|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Elemental Waves|r: Every attack has |cffffcc0020%%|r chance to spawn an elemental wave at target location damaging an applying an special effect on the wave type. When proccing this effect there is |cffffcc0025%%|r chance of creating either a |cffffcc00Holy|r, |cffff0000Fire|r, |cff00ff00Poison|r or |cff8080ffWater|r wave. A |cffffcc00Holy Wave|r will damage enemys and heal allies for |cff00ffff" + N2S(value, 0) + " Magic|r damage. A |cffff0000Fire Wave|r damage enemys for |cff00ffff" + N2S(lesser, 0) + " Magic|r damage and apply a |cffff0000Burn|r effect dealing |cff00ffff" + N2S(dot, 0) + " Magic|r damage per second for |cffffcc005|r seconds. |cff00ff00Poison Wave|r damage enemys for |cff00ffff" + N2S(value, 0) + " Magic|r damage and reduce their armor by |cffffcc0010|r  for |cffffcc0010|r seconds. Finnaly the |cff8080ffWater Wave|r damage enemys for |cff00ffff" + N2S(value, 0) + " Magic|r damage and reduce their movement speed by |cffffcc0050%%|r for |cffffcc005|r seconds."
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

                    if Damage.source.isHero then
                        set missile.damage = 100 + (10 * GetHeroLevel(Damage.source.unit))
                    else
                        set missile.damage = 100 + (10 * GetUnitLevel(Damage.source.unit))
                    endif
                elseif missile.type == 2 then
                    set missile.model  = "HolyBreath.mdx"
                    
                    if Damage.source.isHero then
                        set missile.damage = 200 + (20 * GetHeroLevel(Damage.source.unit))
                    else
                        set missile.damage = 200 + (20 * GetUnitLevel(Damage.source.unit))
                    endif
                elseif missile.type == 3 then
                    set missile.model  = "AcidBreath.mdx"
                    
                    if Damage.source.isHero then
                        set missile.damage = 200 + (20 * GetHeroLevel(Damage.source.unit))
                    else
                        set missile.damage = 200 + (20 * GetUnitLevel(Damage.source.unit))
                    endif
                elseif missile.type == 4 then
                    set missile.model  = "WaterBreath.mdx"
                    
                    if Damage.source.isHero then
                        set missile.damage = 200 + (20 * GetHeroLevel(Damage.source.unit))
                    else
                        set missile.damage = 200 + (20 * GetUnitLevel(Damage.source.unit))
                    endif
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