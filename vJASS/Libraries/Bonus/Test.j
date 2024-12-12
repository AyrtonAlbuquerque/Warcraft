scope Display
    globals
        integer current
        string name
    endglobals

    private struct Test
        private static method add takes nothing returns nothing
            call AddUnitBonus(Spell.source.unit, current, 1)
        endmethod
        
        private static method sub takes nothing returns nothing
            call AddUnitBonus(Spell.source.unit, current, -1)
        endmethod
        
        private static method nil takes nothing returns nothing
            call RemoveUnitBonus(Spell.source.unit, current)
        endmethod
        
        private static method Set takes nothing returns nothing
            call SetUnitBonus(Spell.source.unit, current, 100)
        endmethod
        
        private static method get takes nothing returns nothing
            call DisplayTimedTextToPlayer(Player(0), 0, 0, 3, (GetUnitName(Spell.source.unit) + " has " + R2S(GetUnitBonus(Spell.source.unit, current)) + " " + name))
        endmethod

        private static method dagger takes nothing returns nothing
            call AddUnitBonusTimed(Spell.source.unit, current, 50, 10)
        endmethod

        private static method cycle takes nothing returns nothing
            if current == BONUS_DAMAGE then
                set current = BONUS_ARMOR
                set name = "Bonus Armor"
            elseif current == BONUS_ARMOR then
                set current = BONUS_AGILITY
                set name = "Bonus Agility"
            elseif current == BONUS_AGILITY then
                set current = BONUS_STRENGTH
                set name = "Bonus Strength"
            elseif current == BONUS_STRENGTH then
                set current = BONUS_INTELLIGENCE
                set name = "Bonus Intelligence"
            elseif current == BONUS_INTELLIGENCE then
                set current = BONUS_HEALTH
                set name = "Bonus Health"
            elseif current == BONUS_HEALTH then
                set current = BONUS_MANA
                set name = "Bonus Mana"
            elseif current == BONUS_MANA then
                set current = BONUS_MOVEMENT_SPEED
                set name = "Bonus Movement Speed"
            elseif current == BONUS_MOVEMENT_SPEED then
                set current = BONUS_SIGHT_RANGE
                set name = "Bonus Sight Range"
            elseif current == BONUS_SIGHT_RANGE then
                set current = BONUS_HEALTH_REGEN
                set name = "Bonus Health Regen"
            elseif current == BONUS_HEALTH_REGEN then
                set current = BONUS_MANA_REGEN
                set name = "Bonus Mana Regen"
            elseif current == BONUS_MANA_REGEN then
                set current = BONUS_ATTACK_SPEED
                set name = "Bonus Attack Speed"
            elseif current == BONUS_ATTACK_SPEED then
                set current = BONUS_MAGIC_RESISTANCE
                set name = "Bonus Magic Resistence"
            elseif current == BONUS_MAGIC_RESISTANCE then
                set current = BONUS_LIFE_STEAL
                set name = "Bonus Life Steal"
            elseif current == BONUS_LIFE_STEAL then
                set current = BONUS_EVASION_CHANCE
                set name = "Bonus Evasion Chance"
            elseif current == BONUS_EVASION_CHANCE then
                set current = BONUS_CRITICAL_CHANCE
                set name = "Bonus Critical Chance"
            elseif current == BONUS_CRITICAL_CHANCE then
                set current = BONUS_CRITICAL_DAMAGE
                set name = "Bonus Critical Damage"
            elseif current == BONUS_CRITICAL_DAMAGE then
                set current = BONUS_MISS_CHANCE
                set name = "Bonus Miss Chance"
            elseif current == BONUS_MISS_CHANCE then
                set current = BONUS_SPELL_POWER
                set name = "Bonus Spell Power"
            elseif current == BONUS_SPELL_POWER then
                set current = BONUS_SPELL_VAMP
                set name = "Bonus Spell Vamp"
            elseif current == BONUS_SPELL_VAMP then
                set current = BONUS_COOLDOWN_REDUCTION
                set name = "Bonus Cooldown Reduction"
            elseif current == BONUS_COOLDOWN_REDUCTION then
                set current = BONUS_COOLDOWN_REDUCTION_FLAT
                set name = "Bonus Cooldown Reduction Flat"
            elseif current == BONUS_COOLDOWN_REDUCTION_FLAT then
                set current = BONUS_COOLDOWN_OFFSET
                set name = "Bonus Cooldown Offset"
            elseif current == BONUS_COOLDOWN_OFFSET then
                set current = BONUS_TENACITY
                set name = "Bonus Tenacity"
            elseif current == BONUS_TENACITY then
                set current = BONUS_TENACITY_FLAT
                set name = "Bonus Tenacity Flat"
            elseif current == BONUS_TENACITY_FLAT then
                set current = BONUS_TENACITY_OFFSET
                set name = "Bonus Tenacity Offset"
            elseif current == BONUS_TENACITY_OFFSET then
                set current = BONUS_DAMAGE
                set name = "Bonus Damage"
            endif

            call BlzSetAbilityExtendedTooltip('A005', "Cycles the active bonus being modified by the abilities.\n\nCurrent: |cffffff00" + name + "|r", 0)
        endmethod

        private static method onInit takes nothing returns nothing
            set name = "Bonus Damage"
            set current = BONUS_DAMAGE

            call RegisterSpellEffectEvent('A000', function thistype.add)
            call RegisterSpellEffectEvent('A001', function thistype.sub)
            call RegisterSpellEffectEvent('A002', function thistype.nil)
            call RegisterSpellEffectEvent('A003', function thistype.Set)
            call RegisterSpellEffectEvent('A004', function thistype.get)
            call RegisterSpellEffectEvent('A005', function thistype.cycle)
            call RegisterSpellEffectEvent('A007', function thistype.dagger)
        endmethod
    endstruct
endscope