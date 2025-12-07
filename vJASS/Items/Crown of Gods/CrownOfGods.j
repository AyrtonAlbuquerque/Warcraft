scope CrownOfGods
    struct CrownOfGods extends Item
        static constant integer code = 'I0A9'

        // Attributes
        real mana = 1200
        real health = 1000
        real manaRegen = 25
        real intelligence = 30
        real spellPower = 100

        private unit unit
        private effect effect
        private texttag texttag
        private integer index
        private integer duration
        private real bonus
        private real shield
        private boolean recharging

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyTextTag(texttag)            
            call deallocate()

            set bonus = 0
            set shield = 0
            set unit = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer count = UnitCountItemOfType(unit, code)

            call AddUnitBonus(unit, BONUS_SPELL_POWER, -bonus)

            if count > 0 then
                set shield = shield + 0.1 * GetHeroInt(unit, true) * 0.03125

                if not recharging then
                    set bonus = GetUnitBonus(unit, BONUS_SPELL_POWER) * 0.25 * count

                    call SetTextTagText(texttag, R2I2S(shield), 0.014)
                    call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                    call SetTextTagColor(texttag, 255, 0, 0, 255)           
                else
                    set bonus = GetUnitBonus(unit, BONUS_SPELL_POWER) * 0.4 * count

                    call SetTextTagText(texttag, "Recharging..", 0.013)
                    call SetTextTagPos(texttag, (GetUnitX(unit) - 40), GetUnitY(unit), 200)
                    call SetTextTagColor(texttag, 255, 0, 0, 255)
                    
                    if duration <= 0 then
                        set recharging = false

                        call DestroyEffect(effect)
                        set effect = AddSpecialEffectTarget("SacredShield.mdl", unit, "origin")
                    endif

                    set duration = duration - 1
                endif

                call AddUnitBonus(unit, BONUS_SPELL_POWER, bonus)

                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set unit = u
                set effect = AddSpecialEffectTarget("SacredShield.mdl", u, "origin")
                set texttag = CreateTextTag()
                set index = id
                set shield = 0
                set bonus = 0
                set recharging = false

                call SetTextTagText(texttag, "0", 0.014)
                call SetTextTagPos(texttag, (GetUnitX(u) - 40), GetUnitY(u), 200)
                call SetTextTagColor(texttag, 255, 0, 0, 255)
                call SetTextTagPermanent(texttag, true)
                call StartTimer(0.03125, true, this, id)
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

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), CrownOfRightouesness.code, WarlockRing.code, 0, 0, 0)
        endmethod
    endstruct
endscope