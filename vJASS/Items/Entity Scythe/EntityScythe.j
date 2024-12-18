scope EntityScythe
    private struct SoulMissile extends Missiles
        boolean hero
        
        method onFinish takes nothing returns boolean
            call EntityScythe.add(target, hero)

            return true
        endmethod
    endstruct
    
    struct EntityScythe extends Item
        static constant integer code = 'I07X'
        static integer array bonus

        real agility = 375
        real strength = 375
        real intelligence = 375
        real spellPower = 500
        real movementSpeed = 50
        
        static method add takes unit target, boolean hero returns nothing
            local integer amount = 1
            local integer index = GetUnitUserData(target)
    
            if hero then
                set amount = 25
            endif
    
            set bonus[index] = bonus[index] + amount

            call AddUnitBonus(target, BONUS_SPELL_POWER, amount)
            call UnitAddStat(target, amount, amount, amount)
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00375|r All Stats\n+ |cffffcc00500|r Spell Power\n+ |cffffcc0050|r Movement Speed\n\n|cff00ff00Passive|r: |cffffcc00Gather of Souls|r: For every enemy unit killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r and |cff00ffffSpell Power|r are incresed by |cffffcc001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r and |cff00ffffSpell Power|r by |cffffcc0025|r.\n\nStats Bonus: |cffffcc00" + I2S(bonus[id]) + "|r\nSpell Power Bonus: |cffffcc00" + I2S(bonus[id]) + "|r")
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
        
            if UnitHasItemOfType(killer, code) and not IsUnitIllusionEx(killer) then
                set x = GetUnitX(killed)
                set y = GetUnitY(killed)
                set tx = GetUnitX(killer)
                set ty = GetUnitY(killer)

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
            
            set killer = null
            set killed = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, SoulSword.code, ReapersEdge.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope