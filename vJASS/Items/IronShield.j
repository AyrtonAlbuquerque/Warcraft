scope IronShield
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusBlock takes nothing returns real
        return 10.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct IronShield extends Item
        static constant integer code = 'I01A'
        private static real array bonus
        
        // Attributes
        real armor = 5
        real block = 30
        real health = 300

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) then
                if Damage.target.health < (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and bonus[Damage.target.id] == 0 then
                    set bonus[Damage.target.id] = GetBonusBlock()
                    call AddUnitBonus(Damage.target.unit, BONUS_DAMAGE_BLOCK, bonus[Damage.target.id])
                elseif Damage.target.health >= (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and bonus[Damage.target.id] > 0 then
                    call AddUnitBonus(Damage.target.unit, BONUS_DAMAGE_BLOCK, -bonus[Damage.target.id])
                    set bonus[Damage.target.id] = 0
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), LifeCrystal.code, CommomShield.code, Platemail.code, 0, 0)
        endmethod
    endstruct
endscope