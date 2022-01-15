library ThunderClap requires SpellEffectEvent, PluginSpellEffect, TimedHandles
    /* --------------------- Thunder Clap v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    //     TriggerHappy   - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Thunder Clap ability
        public  constant integer ABILITY             = 'A003'
        // The raw code of the Thunder Clap Recast ability
        public  constant integer THUNDER_CLAP_RECAST = 'A004'
        // The raw code of the War Stomp ability
        public  constant integer WAR_STOMP           = 'A005'
        // The model used when storm bolt refunds mana on kill
        private constant string  HEAL_EFFECT         = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
        // The attachment point of the bonus dmaage model
        private constant string  ATTACH_POINT        = "origin"
    endglobals

    // The AoE for calculating the heal
    private function GetAoE takes unit source, integer id, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, id), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // Filter for units
    private function Filtered takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and /*
            */ UnitAlive(target) and /*
            */ not IsUnitType(target, UNIT_TYPE_STRUCTURE) and /*
            */ not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ThunderClap extends array
        private static method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local integer i = 0
            local real heal = 0
            local unit u
            local integer size
    
            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.id, Spell.level), null)
            set size = BlzGroupGetSize(g)
            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(g, i)
                    if Filtered(Spell.source.player, u) then
                        if IsUnitType(u, UNIT_TYPE_HERO) then
                            set heal = heal + 0.1
                        else
                            set heal = heal + 0.025
                        endif
                    endif
                set i = i + 1
            endloop
            call DestroyGroup(g)
            call SetWidgetLife(Spell.source.unit, GetWidgetLife(Spell.source.unit) + (BlzGetUnitMaxHP(Spell.source.unit)*heal))
            call DestroyEffectTimed(AddSpecialEffectTarget(HEAL_EFFECT, Spell.source.unit, ATTACH_POINT), 1.0)
            
            set u = null
            set g = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterSpellEffectEvent(THUNDER_CLAP_RECAST, function thistype.onCast)
            call RegisterSpellEffectEvent(WAR_STOMP, function thistype.onCast)
        endmethod
    endstruct
endlibrary