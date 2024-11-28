scope ReapersEdge
    private struct SoulMissile extends Missiles
        boolean hero

        method onFinish takes nothing returns boolean
            call ReapersEdge.add(target, hero)

            return true
        endmethod
    endstruct
    
    struct ReapersEdge extends Item
        static constant integer code = 'I05Z'
        static integer array stats
        static real array spell
        private static integer array array

        real agility = 200
        real strength = 200
        real intelligence = 200
        real spellPowerFlat = 400

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00200|r All Stats\n+ |cffffcc00400|r Spell Power\n\n|cff00ff00Passive|r|cffffcc00: Soul Reaper|r: Every |cffffcc002|r enemy units killed, |cffff0000Strength|r,|cff00ff00 Agility |rand |cff00ffffIntelligence|r are increased by |cffffcc001|r and|cff008080 Spell Power|r is incresed by |cffffcc000.5|r permanently. Killing a enemy Hero increases all stats by |cffffcc0020|r and|cff008080 Spell Power|r by|cffffcc00 5|r.\n\nSpell Power Bonus: |cff008080" + R2SW(spell[id], 1, 1) + "|r\nStats Bonus: |cffffcc00" + I2S(stats[id]) + "|r")
        endmethod

        static method add takes unit target, boolean hero returns nothing
            local integer index = GetUnitUserData(target)
            local integer stats
            local real spell

            if hero then
                set stats = 20
                set spell = 5
            else
                set stats = 1
                set spell = 0.5
            endif

            set ReapersEdge.spell[index] = ReapersEdge.spell[index] + spell
            set ReapersEdge.stats[index] = ReapersEdge.stats[index] + stats
            call UnitAddSpellPowerFlat(target, spell)
            call UnitAddStat(target, stats, stats, stats)
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed = GetTriggerUnit()
            local integer index  = GetUnitUserData(killer)  
            local boolean hero   
            local real x
            local real y
            local real tx
            local real ty
            local SoulMissile missile

            if UnitHasItemOfType(killer, code) and not IsUnitIllusionEx(killer) then
                set killed = GetTriggerUnit()
                set hero = IsUnitType(killed, UNIT_TYPE_HERO)
                set x = GetUnitX(killed)
                set y = GetUnitY(killed)
                set tx = GetUnitX(killer)
                set ty = GetUnitY(killer)
                
                if DistanceBetweenCoordinates(x, y, tx, ty) <= 200 then
                    if hero then
                        call add(killer, hero)
                    else
                        set array[index] = array[index] + 1
                        if array[index] == 2 then
                            call add(killer, hero)
                            set array[index] = 0
                        endif
                    endif
                else
                    if hero then
                        set missile = SoulMissile.create(x, y, GetUnitFlyHeight(killed) + 60, tx, ty, 60)
                        set missile.target = killer
                        set missile.model = "Abilities\\Weapons\\VoidWalkerMissile\\VoidWalkerMissile.mdl"
                        set missile.speed = 1000
                        set missile.arc = 30
                        set missile.hero = hero

                        call missile.launch()
                    else
                        set array[index] = array[index] + 1
                        if array[index] == 2 then
                            set missile = SoulMissile.create(x, y, GetUnitFlyHeight(killed) + 60, tx, ty, 60)
                            set missile.target = killer
                            set missile.model = "Abilities\\Weapons\\VoidWalkerMissile\\VoidWalkerMissile.mdl"
                            set missile.speed = 1000
                            set missile.arc = 30
                            set missile.hero = hero
                            set array[index] = 0

                            call missile.launch()
                        endif
                    endif
                endif
            endif
            
            set killer = null
            set killed = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, SoulScyther.code, SphereOfPower.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope