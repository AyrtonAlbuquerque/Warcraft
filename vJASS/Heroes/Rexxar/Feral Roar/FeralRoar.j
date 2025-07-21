library FeralRoar requires Spell, NewBonus, Utilities, CrowdControl optional Misha
    /* ---------------------- Feral Roar v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY = 'A002'
        // The buff raw code
        private constant integer BUFF    = 'B001'
        // The model used in fear
        private constant string  FEAR    = "Fear.mdx"
        // Where the fear model is attached to
        private constant string  ATTACH  = "overhead"
        // The ability order string
        private constant string  ORDER   = "battleroar"
    endglobals

    // The aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction
    
    // The fear duration
    private function GetFearDuration takes integer level returns real
        return 1. + 0.25*level
    endfunction
    
    // The helath regeneration bonus
    private function GetBonusRegeneration takes integer level returns real
        return 10. + 10*level
    endfunction
    
    // The bonus damage
    private function GetBonusDamage takes unit source, integer level returns real
        return 0.2 + 0.05*level
    endfunction
    
    // The bonus armor
    private function GetBonusArmor takes unit source, integer level returns real
        return 4. + level
    endfunction
    
    // The Unit Filter
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct FeralRoar extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r roars in fury, increasing the damage of nearby allies by |cffffcc00" + N2S(GetBonusDamage(source, level) * 100, 0) + "%|r of base damage, armor by |cffffcc00" + N2S(GetBonusArmor(source, level), 0) + "|r and fearing enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r for |cffffcc00" + N2S(GetFearDuration(level), 2) + "|r seconds. If |cffffcc00Misha|r is summoned she will also roar granting the same effects and gainning |cff00ff00" + N2S(GetBonusRegeneration(level), 1) + " Health Regeneration|r.\n\nLasts for |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, level - 1), 0) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local unit u
            local integer size
            local integer i = 0
            local group g = CreateGroup()
            local integer level = Spell.level
            local integer id = Spell.source.id
            local unit source = Spell.source.unit
            local player owner = Spell.source.player
            
            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, GetAoE(source, level), null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) then
                        if IsUnitAlly(u, owner) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            if GetUnitAbilityLevel(u, BUFF) == 0 then
                                call LinkBonusToBuff(u, BONUS_DAMAGE, BlzGetUnitBaseDamage(source, 0) * GetBonusDamage(u, level), BUFF)
                                call LinkBonusToBuff(u, BONUS_ARMOR, GetBonusArmor(u, level), BUFF)
                            endif
                        else
                            if UnitFilter(owner, u) then
                                call FearUnit(u, GetFearDuration(level), FEAR, ATTACH, false)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)
            
            static if LIBRARY_Misha then
                if GetUnitTypeId(source) != Misha_MISHA then
                    set size = BlzGroupGetSize(Misha.group[id])
                    
                    if size > 0 then
                        loop
                            exitwhen i == size
                                set u = BlzGroupUnitAt(Misha.group[id], i)
                                
                                call UnitAddAbilityTimed(u, ABILITY, 0.5, level, false)
                                call BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_ILF_MANA_COST, level - 1, 0)
                                call IssueImmediateOrder(u, ORDER)
                            set i = i + 1
                        endloop
                    endif
                else
                    call LinkBonusToBuff(source, BONUS_HEALTH_REGEN, GetBonusRegeneration(level), BUFF)
                endif
            endif
            
            set u = null
            set g = null
        endmethod
    
        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary