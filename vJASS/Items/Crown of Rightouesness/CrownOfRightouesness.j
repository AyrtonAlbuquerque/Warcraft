scope CrownOfRightouesness
    struct CrownOfRightouesness extends Item
        static constant integer code = 'I079'
        static constant integer buff = 'B00W'
        static constant integer ability = 'A00V'

        // Attributes
        real mana = 10000
        real manaRegen = 250
        real spellPower = 600

        private static real array shield

        private unit unit
        private integer index
        private texttag texttag

        method destroy takes nothing returns nothing
            call DestroyTextTag(texttag)
            call super.destroy()

            set shield[index] = 0
            set unit = null
            set texttag = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Mana\n+ |cffffcc00250|r Mana Regeneration\n+ |cffffcc00600|r Spell Power\n\n|cff00ff00Acitve|r: |cffffcc00Light Shield|r: When activated, creates a light barrier around the Hero, blocking up to |cffffcc00" + R2I2S(5000 + (5 * GetUnitSpellPowerFlat(u))) + "|r damage or until its duration is over. Lasts |cffffcc0030|r seconds.")
        endmethod
            
        private method onPeriod takes nothing returns boolean
            if GetUnitAbilityLevel(unit, buff) > 0 and shield[index] > 0 then
                call SetTextTagText(texttag, R2I2S(shield[index]), 0.015)
                call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                call SetTextTagColor(texttag, 255, 255, 255, 255)
                call SetTextTagPermanent(texttag, false)
            
                return true
            endif

            return false
        endmethod

        private static method onDamage takes nothing returns nothing
            if shield[Damage.target.id] > 0 and Damage.amount > 0 then
                if Damage.amount > shield[Damage.target.id] then
                    set Damage.amount = Damage.amount - shield[Damage.target.id]
                    set shield[Damage.target.id] = 0

                    call UnitRemoveAbility(Damage.target.unit, buff)
                else
                    set shield[Damage.target.id] = shield[Damage.target.id] - Damage.amount
                    set Damage.amount = 0
                endif
            endif
        endmethod   

        private static method onCast takes nothing returns nothing
            local thistype this = GetTimerInstance(Spell.source.id)
        
            if this == 0 then
                set this = thistype.new()
                set unit = Spell.source.unit
                set texttag = CreateTextTag()
                set index = Spell.source.id

                call StartTimer(0.03125, true, this, index)
            endif

            if texttag == null then
                set texttag = CreateTextTag()
            endif

            set shield[index] = shield[index] + (5000 + 5*GetUnitSpellPowerFlat(unit))
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call thistype.allocate(code, DesertRing.code, SphereOfDivinity.code, 0, 0, 0)
        endmethod
    endstruct
endscope