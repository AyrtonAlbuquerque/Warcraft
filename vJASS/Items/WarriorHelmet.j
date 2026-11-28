scope WarriorHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetCooldown takes nothing returns real
        return 60.
    endfunction
    
    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    private constant function GetBonusRegen takes nothing returns real
        return 50.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WarriorHelmet extends Item
        static constant integer code = 'I019'
        private static timer array cooldown
        
        // Attributes
        real strength = 8
        real tenacity = 0.15
        real healthRegen = 5

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc008|r Strength\n+ |cffffcc0015%|r Resolve\n+ |cffffcc005|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Overheal:|r When |cffff0000Health|r drops below |cffffcc00" + N2S(GetHealthFactor() * 100, 0) + "%|r, all |cffffcc00Crowd Control|r are dispelled and |cff00ff00Health Regeneration|r is increased by |cffffcc00" + N2S(GetBonusRegen(), 0) + "|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r second."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if cooldown[id] == null then
                set cooldown[id] = CreateTimer()
            endif

            call UnitStartItemCooldown(u, i, TimerGetRemaining(cooldown[id]))
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, code) and Damage.target.health < (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and TimerGetRemaining(cooldown[Damage.target.id]) <= 0 then
                call UnitDispelAllCrowdControl(Damage.target.unit)
                call TimerStart(cooldown[Damage.target.id], GetCooldown(), false, null)
                call UnitStartItemTypeCooldown(Damage.target.unit, code, GetCooldown())
                call AddUnitBonusTimed(Damage.target.unit, BONUS_HEALTH_REGEN, GetBonusRegen(), GetDuration())
                call DestroyEffectTimed(AddSpecialEffectTarget("PurpleSphere.mdl", Damage.target.unit, "chest"), GetDuration())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HealingCrystal.code, HealingCrystal.code, GauntletOfStrength.code, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope