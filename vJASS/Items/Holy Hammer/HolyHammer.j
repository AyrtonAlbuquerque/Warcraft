scope HolyHammer
    struct HolyHammer extends Item
        static constant integer code = 'I0A3'
        static integer array bonus

        private static integer key  = -1
        private static thistype array array
        private static integer array struct
        private static timer timer = CreateTimer()

        private unit unit
        private effect effect
        private texttag texttag
        private integer index
        private real stored
        private real regen

        // Attributes
        real damage = 1000
        real strength = 750
        real spellPowerFlat = 750

        private method remove takes integer i returns integer
            call DestroyTextTag(texttag)
            call DestroyEffect(effect)

            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set effect = null
            set texttag = null
            set struct[index] = 0

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc001000|r Damage\n+ |cffffcc00750|r Spell Power\n+ |cffffcc00750|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00400 AoE|r, dealing |cffffcc0050%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Holy Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc001|r permanently.\n\n|cff00ff00Passive|r: |cffffcc00Holy Inquisition|r: When dealing |cffff0000Physical|r or |cff00ff00Cleave|r damage, |cffffcc00Holy Hammer|r stores |cffffcc00100%|r (|cffffcc0025%|r for |cff00ff00Cleave|r damage) of the damage dealt and immediately starts regenerating health for |cffffcc0010%|r of all damage stored, depleting it until nothing is left. The more damage is stored through |cffffcc00Holy Inquisition|r the higher |cff00ff00Health Regeneration|r becomes. All damage stored depletes within |cffffcc0010|r seconds if no more damage is stored. Stores |cffffcc002x|r as much damage dealt to |cffffcc00Heroes|r.\n\nStrength Bonus: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if stored > 0 then
                        set stored = stored - regen
                
                        call SetTextTagText(texttag, R2I2S(stored), 0.013)
                        call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit) - 100, 0)
                        call SetTextTagColor(texttag, 0, 255, 0, 255)
                        call SetWidgetLife(unit, GetWidgetLife(unit) + regen)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this
        
            if damage > 0 and UnitHasItemOfType(Damage.source.unit, code) then
                if Damage.isEnemy and Damage.source.isMelee and not Damage.target.isStructure and (Damage.isAttack or Damage.damagetype == DAMAGE_TYPE_ENHANCED) then  
                    if struct[Damage.source.id] != 0 then
                        set this = struct[Damage.source.id]
                    else
                        set this = thistype.new()
                        set unit = Damage.source.unit
                        set effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl", unit, "chest")
                        set texttag = CreateTextTag()
                        set index = Damage.source.id
                        set stored = 0
                        set regen = 0
                        set key = key + 1
                        set array[key] = this
                        set struct[index] = this

                        call SetTextTagText(texttag, R2I2S(stored), 0.013)
                        call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit) - 100, 0)
                        call SetTextTagColor(texttag, 0, 255, 0, 255)
                        call SetTextTagPermanent(texttag, true)

                        if key == 0 then
                            call TimerStart(timer, 0.03125, true, function thistype.onPeriod)
                        endif
                    endif

                    if Damage.target.isHero then
                        set damage = 2*damage
                    endif

                    if Damage.isAttack then
                        set bonus[index] = bonus[index] + 1
                        set stored = stored + damage
                        call UnitAddStat(unit, 1, 0, 0)
                    else
                        set stored = stored + 0.25*damage
                    endif
            
                    set regen = stored/320
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SphereOfDivinity.code, SapphireHammer.code, 0, 0, 0)
        endmethod
    endstruct
endscope