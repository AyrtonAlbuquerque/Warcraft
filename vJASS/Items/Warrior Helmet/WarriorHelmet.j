scope WarriorHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetCooldown takes nothing returns real
        return 90.
    endfunction
    
    private constant function GetDuration takes nothing returns real
        return 15.
    endfunction

    private constant function GetBonusRegen takes nothing returns real
        return 20.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WarriorHelmet extends Item
        static constant integer code = 'I034'
        static constant string effect = "PurpleSphere.mdx"
        
        // Attributes
        real strength = 7
        real healthRegen = 5

        private static real array cooldown

        private integer index

        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc007|r Strength\n+ |cffffcc005|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Overheal|r: When Hero's life drops below |cffffcc0050%|r, |cff00ff00Health Regeneration|r is increased by |cffffcc0020 Hp/s|r for |cffffcc0015|r seconds.\n\nCooldown: |cffffcc00" + R2I2S(WarriorHelmet.cooldown[id]) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            set cooldown[index] = cooldown[index] - 1
                    
            return cooldown[index] > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) and GetWidgetLife(Damage.target.unit) < (BlzGetUnitMaxHP(Damage.target.unit)*GetHealthFactor()) and cooldown[Damage.target.id] == 0 then
                set this = thistype.allocate(0)
                set index = Damage.target.id
                set cooldown[index] = GetCooldown()
                
                call StartTimer(1, true, this, Damage.target.id)
                call AddUnitBonusTimed(Damage.target.unit, BONUS_HEALTH_REGEN, GetBonusRegen(), GetDuration())
                call DestroyEffectTimed(AddSpecialEffectTarget(effect, Damage.target.unit, "chest"), GetDuration())
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), GauntletOfStrength.code, LifeEssenceCrystal.code, LifeEssenceCrystal.code, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope