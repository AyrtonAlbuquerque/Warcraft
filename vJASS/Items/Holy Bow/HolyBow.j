scope HolyBow
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetAllyHealFactor takes nothing returns real
        return 0.3
    endfunction

    private constant function GetHeroHealFactor takes nothing returns real
        return 0.33
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct HolyBow extends Item
        static constant integer code = 'I03S'
        static constant integer buff = 'B00E'
        static constant integer ability = 'A039'
        static constant string order = "faeriefire"
    
        real agility = 7
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and GetUnitAbilityLevel(Damage.source.unit, buff) > 0 then
                if Damage.source.isHero then
                    call SetWidgetLife(Damage.target.unit, (GetWidgetLife(Damage.target.unit) + damage*GetHeroHealFactor()))
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetHeroHealFactor())), Damage.target.unit, 0.015)
                else
                    call BlzSetEventDamage(-damage)
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), Damage.target.unit, 0.015)
                endif
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and UnitHasItemOfType(Damage.source.unit, code) then
                if Damage.isAlly then
                    call BlzSetEventDamage(-damage*GetAllyHealFactor())
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetAllyHealFactor())), Damage.target.unit, 0.015)
                else
                    if GetRandomReal(1, 100) <= GetChance() then
                        call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call RegisterItem(allocate(code), OrbOfLight.code, SimpleBow.code, 0, 0, 0)
        endmethod
    endstruct
endscope