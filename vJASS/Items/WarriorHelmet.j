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
        static constant string effect = "PurpleSphere.mdx"
        
        // Attributes
        real strength = 8
        real tenacity = 0.15
        real healthRegen = 5

        private static real array cooldown

        private integer index

        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc008|r Strength\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc0015%|r Control Resistance\n\n|cff00ff00Passive|r: |cffffcc00Overheal:|r When |cffff0000Health|r drops below |cffffcc00" + N2S(GetHealthFactor() * 100, 0) + "%|r, all |cffffcc00Crowd Control|r are dispelled and |cff00ff00Health Regeneration|r is increased by |cffffcc00" + N2S(GetBonusRegen(), 0) + "|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r second.\n\nCooldown: |cffffcc00" + N2S(WarriorHelmet.cooldown[id], 0) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            set cooldown[index] = cooldown[index] - 1
                    
            return cooldown[index] > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) and Damage.target.health < (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and cooldown[Damage.target.id] == 0 then
                set this = thistype.allocate(0)
                set index = Damage.target.id
                set cooldown[index] = GetCooldown()
                
                call StartTimer(1, true, this, Damage.target.id)
                call UnitDispelAllCrowdControl(Damage.target.unit)
                call AddUnitBonusTimed(Damage.target.unit, BONUS_HEALTH_REGEN, GetBonusRegen(), GetDuration())
                call DestroyEffectTimed(AddSpecialEffectTarget(effect, Damage.target.unit, "chest"), GetDuration())
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HealingCrystal.code, HealingCrystal.code, GauntletOfStrength.code, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope