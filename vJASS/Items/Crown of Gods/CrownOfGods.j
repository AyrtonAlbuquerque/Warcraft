scope CrownOfGods
    struct CrownOfGods extends Item
        static constant integer code = 'I0A9'

        private static integer key = -1
        private static thistype array array
        private static thistype array struct
        private static real array multiplier
        private static timer timer = CreateTimer()

        private unit unit
        private effect effect
        private texttag texttag
        private integer index
        private integer duration
        private boolean amplify
        private real shield
        private boolean recharging

        // Attributes
        real mana = 25000
        real health = 25000
        real manaRegen = 750
        real intelligence = 750
        real spellPowerFlat = 750

        private method remove takes integer i returns integer
            call DestroyEffect(effect)
            call DestroyTextTag(texttag)

            set shield = 0
            set unit = null
            set effect = null
            set array[i] = array[key]
            set key = key - 1
            set struct[index] = 0

            if key == -1 then
                call PauseTimer(timer)
            endif
            
            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0025000|r Mana\n+ |cffffcc0025000|r Health\n+ |cffffcc00750|r Mana Regeneration\n+ |cffffcc00750|r Intelligence\n+ |cffffcc00750|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(u, true) * multiplier[id])) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Divine Protection|r: |cffffcc00Crown of Gods|r provides a divine shield that grows by |cffffcc00100%|r of your Hero total |cff00ffffIntelligence|r every second, blocking all damage taken. When depleted, |cffffcc00Divine Protection|r needs |cffffcc0020|r seconds to recharge, and while recharging, |cffffcc00Arcane Power|r effect is increased to |cffffcc00100%|r of total |cff00ffffIntelligence|r amplification.")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItemOfType(unit, code) then
                        set shield = shield + GetHeroInt(unit, true)*0.03125

                        if not recharging then
                            call SetTextTagText(texttag, R2I2S(shield), 0.014)
                            call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                            call SetTextTagColor(texttag, 255, 0, 0, 255)           
                        else
                            call SetTextTagText(texttag, "Recharging..", 0.013)
                            call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                            call SetTextTagColor(texttag, 255, 0, 0, 255)
                            
                            if duration <= 0 then
                                set amplify = false
                                set recharging = false
                                set multiplier[index] = 0.5

                                call DestroyEffect(effect)
                                set effect = AddSpecialEffectTarget("SacredShield.mdl", unit, "origin")
                            endif

                            set duration = duration - 1
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this

            if damage > 0 then
                if UnitHasItemOfType(Damage.target.unit, code) and struct[Damage.target.id] != 0 then
                    set this = struct[Damage.target.id]
                    if shield > 0 and not recharging then
                        if damage > shield then
                            set shield = 0
                            set duration = 640
                            set recharging = true
                            set amplify = true
                            set multiplier[Damage.target.id] = 1.

                            call DestroyEffect(effect)
                            set effect = AddSpecialEffectTarget("Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl", unit, "overhead")
                            call BlzSetEventDamage(damage - shield)
                        else
                            set shield = shield - damage
                            call BlzSetEventDamage(0)
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onSpellDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                call BlzSetEventDamage(damage + GetHeroInt(Damage.source.unit, true)*multiplier[Damage.source.id]) 
            endif
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local thistype self

            if not UnitHasItemOfType(u, code) then
                set self = thistype.new()
                set unit = u
                set effect = AddSpecialEffectTarget("SacredShield.mdl", u, "origin")
                set texttag = CreateTextTag()
                set index = GetUnitUserData(u)
                set amplify = false
                set shield = 0
                set recharging = false
                set key = key + 1
                set array[key] = self
                set struct[index] = self
                set multiplier[index] = 0.5

                call SetTextTagText(texttag, "0", 0.014)
                call SetTextTagPos(texttag, (GetUnitX(u) - 40), GetUnitY(u), 200)
                call SetTextTagColor(texttag, 255, 0, 0, 255)
                call SetTextTagPermanent(texttag, true)

                if key == 0 then
                    call TimerStart(timer, 0.03125, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
            call thistype.allocate(code, CrownOfRightouesness.code, WarlockRing.code, 0, 0, 0)
        endmethod
    endstruct
endscope