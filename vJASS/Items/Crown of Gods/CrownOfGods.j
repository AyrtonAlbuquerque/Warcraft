scope CrownOfGods
    struct CrownOfGods extends Item
        static constant integer code = 'I0A9'

        // Attributes
        real mana = 25000
        real health = 25000
        real manaRegen = 750
        real intelligence = 750
        real spellPower = 750

        private static real array multiplier

        private unit unit
        private effect effect
        private texttag texttag
        private integer index
        private integer duration
        private boolean amplify
        private real shield
        private boolean recharging

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyTextTag(texttag)            
            call super.destroy()

            set shield = 0
            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0025000|r Mana\n+ |cffffcc0025000|r Health\n+ |cffffcc00750|r Mana Regeneration\n+ |cffffcc00750|r Intelligence\n+ |cffffcc00750|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(u, true) * multiplier[id])) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Divine Protection|r: |cffffcc00Crown of Gods|r provides a divine shield that grows by |cffffcc00100%%|r of your Hero total |cff00ffffIntelligence|r every second, blocking all damage taken. When depleted, |cffffcc00Divine Protection|r needs |cffffcc0020|r seconds to recharge, and while recharging, |cffffcc00Arcane Power|r effect is increased to |cffffcc00100%%|r of total |cff00ffffIntelligence|r amplification.")
        endmethod

        private method onPeriod takes nothing returns boolean
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

                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local thistype self
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set self = thistype.new()
                set self.unit = u
                set self.effect = AddSpecialEffectTarget("SacredShield.mdl", u, "origin")
                set self.texttag = CreateTextTag()
                set self.index = id
                set self.amplify = false
                set self.shield = 0
                set self.recharging = false
                set multiplier[id] = 0.5

                call SetTextTagText(self.texttag, "0", 0.014)
                call SetTextTagPos(self.texttag, (GetUnitX(u) - 40), GetUnitY(u), 200)
                call SetTextTagColor(self.texttag, 255, 0, 0, 255)
                call SetTextTagPermanent(self.texttag, true)
                call StartTimer(0.03125, true, self, id)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if Damage.amount > 0 then
                if UnitHasItemOfType(Damage.target.unit, code) and HasStartedTimer(Damage.target.id) then
                    set this = GetTimerInstance(Damage.target.id)

                    if this != 0 then
                        if shield > 0 and not recharging then
                            if Damage.amount > shield then
                                set shield = 0
                                set duration = 640
                                set recharging = true
                                set amplify = true
                                set multiplier[Damage.target.id] = 1.
                                set Damage.amount = Damage.amount - shield

                                call DestroyEffect(effect)
                                set effect = AddSpecialEffectTarget("Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl", unit, "overhead")
                            else
                                set shield = shield - Damage.amount
                                set Damage.amount = 0
                            endif
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onSpellDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.amount > 0 then
                set Damage.amount = damage + GetHeroInt(Damage.source.unit, true)*multiplier[Damage.source.id]
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
            call thistype.allocate(code, CrownOfRightouesness.code, WarlockRing.code, 0, 0, 0)
        endmethod
    endstruct
endscope