scope HolyBow
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I03S'
        static constant integer buff    = 'B00E'
        static constant integer ability = 'A039'
        static constant string order    = "faeriefire"
    endmodule

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
        implement Configuration
    
        real agility = 7
        real damage = 10

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and GetUnitAbilityLevel(Damage.source.unit, buff) > 0 then
                if Damage.source.isHero then
                    call SetWidgetLife(Damage.target.unit, (GetWidgetLife(Damage.target.unit) + damage*GetHeroHealFactor()))
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetHeroHealFactor())), Damage.target.unit)
                else
                    call BlzSetEventDamage(-damage)
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), Damage.target.unit)
                endif
            endif
        endmethod

        static method onAttackDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and UnitHasItemOfType(Damage.source.unit, item) then
                if Damage.isAlly then
                    call BlzSetEventDamage(-damage*GetAllyHealFactor())
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetAllyHealFactor())), Damage.target.unit)
                else
                    if GetRandomReal(1, 100) <= GetChance() then
                        call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                    endif
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
        endmethod
    endstruct
endscope