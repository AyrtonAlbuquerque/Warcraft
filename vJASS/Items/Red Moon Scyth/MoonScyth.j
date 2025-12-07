scope MoonScyth
    private struct SoulMissile extends Missile
        boolean hero

        method onFinish takes nothing returns boolean
            call MoonScyth.add(target, hero)

            return true
        endmethod
    endstruct

    struct MoonScyth extends Item
        static constant integer code = 'I09I'
        static integer array stats
        static integer array amount
        static integer array counter

        real damage = 50
        real agility = 25
        real strength = 25
        real intelligence = 25
        real spellPower = 75
        real lifeSteal = 0.2
        real movementSpeed = 25

        static method add takes unit u, boolean hero returns nothing
            local integer id = GetUnitUserData(u)
            local integer value = 1
    
            if hero then
                set value = 5
            endif
    
            set stats[id] = stats[id] + value
            set amount[id] = amount[id] + value

            call UnitAddStat(u, value, value, value)
            call AddUnitBonus(u, BONUS_SPELL_POWER, value)
            call AddUnitBonus(u, BONUS_DAMAGE, value)
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0025|r All Stats\n+ |cffffcc0075|r Spell Power\n+ |cffffcc0050|r Damage\n+ |cffffcc0025|r Movement Speed\n+ |cffffcc0020%%|r Life Steal\n\n|cff00ff00Passive|r: |cffffcc00Blood Harvest|r: Every |cffffcc004|r enemy units killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r, |cff00ffffSpell Power|r and |cffff0000Damage|r are incresed by |cffffff001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r, |cff00ffffSpell Power|r and |cffff0000Damage|r by |cffffff005|r.\n\nStats Bonus: |cffffcc00" + I2S(stats[id]) + "|r\nDamage Bonus: |cffffcc00" + I2S(amount[id]) + "|r\nSpell Power Bonus: |cffffcc00" + I2S(stats[id]) + "|r"
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed = GetTriggerUnit()
            local integer index = GetUnitUserData(killer)
            local real x
            local real y
            local real tx
            local real ty
            local SoulMissile missile
        
            if UnitHasItemOfType(killer, code) then
                set x = GetUnitX(killed)
                set y = GetUnitY(killed)
                set tx = GetUnitX(killer)
                set ty = GetUnitY(killer)

                if IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
                    if DistanceBetweenCoordinates(tx, ty, x, y) <= 200 then
                        call add(killer, IsUnitType(killed, UNIT_TYPE_HERO))
                    else
                        set missile = SoulMissile.create(x, y, GetUnitFlyHeight(killed) + 100, tx, ty, 100)
                        set missile.target = killer
                        set missile.speed = 1000
                        set missile.model = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
                        set missile.hero = IsUnitType(killed, UNIT_TYPE_HERO)

                        call missile.launch()
                    endif
                else
                    set counter[index] = counter[index] + 1

                    if counter[index] >= 4 then
                        set counter[index] = 0

                        if DistanceBetweenCoordinates(tx, ty, x, y) <= 200 then
                            call add(killer, IsUnitType(killed, UNIT_TYPE_HERO))
                        else
                            set missile = SoulMissile.create(x, y, GetUnitFlyHeight(killed) + 100, tx, ty, 100)
                            set missile.target = killer
                            set missile.speed = 1000
                            set missile.model = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
                            set missile.hero = IsUnitType(killed, UNIT_TYPE_HERO)

                            call missile.launch()
                        endif
                    endif
                endif
            endif
            
            set killer = null
            set killed = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HellishMask.code, EntityScythe.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope