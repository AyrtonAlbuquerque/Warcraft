scope CrownOfRightouesness
    struct CrownOfRightouesness extends Item
        static constant integer code = 'I079'
        static constant integer buff = 'B00W'
        static constant integer ability = 'A00V'

        private static integer key  = -1
        private static real array shield
        private static integer array struct
        private static thistype array array
        private static timer timer = CreateTimer()

        private unit unit
        private integer index
        private texttag texttag

        // Attributes
        real mana = 10000
        real manaRegen = 250
        real spellPowerFlat = 600

        private method remove takes integer i returns integer
            call DestroyTextTag(texttag)

            set array[i] = array[key]
            set key = key - 1
            set shield[index] = 0
            set struct[index] = 0
            set unit = null
            set texttag = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Mana\n+ |cffffcc00250|r Mana Regeneration\n+ |cffffcc00600|r Spell Power\n\n|cff00ff00Acitve|r: |cffffcc00Light Shield|r: When activated, creates a light barrier around the Hero, blocking up to |cffffcc00" + R2I2S(5000 + (5 * GetUnitSpellPowerFlat(u))) + "|r damage or until its duration is over. Lasts |cffffcc0030|r seconds.")
        endmethod
            
        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if GetUnitAbilityLevel(unit, buff) > 0 and shield[index] > 0 then
                        call SetTextTagText(texttag, R2I2S(shield[index]), 0.015)
                        call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                        call SetTextTagColor(texttag, 255, 255, 255, 255)
                        call SetTextTagPermanent(texttag, false)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this

            if shield[Damage.target.id] > 0 and damage > 0 then
                if damage > shield[Damage.target.id] then
                    set damage = damage - shield[Damage.target.id]
                    set shield[Damage.target.id] = 0

                    call BlzSetEventDamage(damage)
                    call UnitRemoveAbility(Damage.target.unit, buff)
                else
                    set shield[Damage.target.id] = shield[Damage.target.id] - damage

                    call BlzSetEventDamage(0)
                endif
            endif
        endmethod   

        private static method onCast takes nothing returns nothing
            local thistype this   
        
            if struct[Spell.source.id] != 0 then
                set this = struct[Spell.source.id]

                if texttag == null then
                    set texttag = CreateTextTag()
                endif
            else
                set this = thistype.new()
                set unit = Spell.source.unit
                set texttag = CreateTextTag()
                set index = Spell.source.id
                set key = key + 1
                set array[key] = this
                set struct[index] = this

                if key == 0 then
                    call TimerStart(timer, 0.03125, true, function thistype.onPeriod)
                endif
            endif

            set shield[index] = shield[index] + (5000 + 5*GetUnitSpellPowerFlat(unit))
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call thistype.allocate(code, DesertRing.code, SphereOfDivinity.code, 0, 0, 0)
        endmethod
    endstruct
endscope