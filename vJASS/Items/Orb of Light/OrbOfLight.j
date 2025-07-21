scope OrbOfLight
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAllyHealFactor takes nothing returns real
        return 0.2
    endfunction

    private constant function GetHeroHealFactor takes nothing returns real
        return 0.25
    endfunction

    private constant function GetChance takes nothing returns real
        return 15.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfLight extends Item
        static constant integer code = 'I01X'
        static constant integer ability = 'A022'
        static constant integer buff = 'B008'
        static constant string order = "faeriefire"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 and not (Damage.target.unit == Damage.source.unit) and damage > 0 then
                if Damage.source.isHero then
                    call BlzSetEventDamage(-damage*GetHeroHealFactor())
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetHeroHealFactor())), Damage.target.unit, 0.015)
                else
                    call BlzSetEventDamage(-damage)
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), Damage.target.unit, 0.015)
                endif        
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                if Damage.isAlly then
                    call BlzSetEventDamage(-damage*GetAllyHealFactor())
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage*GetAllyHealFactor())), Damage.target.unit, 0.015)
                elseif GetRandomReal(1, 100) <= GetChance() then
                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
        endmethod
    endstruct
endscope