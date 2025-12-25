library DivineSmite requires Spell, Utilities, Modules optional LightInfusion optional NewBonus
    /* --------------------- Divine Smite v1.4 by Chopinski --------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    //     Mythic          - Divine Edict Effect
    //     AZ              - Light Stomp effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Divine Smite ability
        private constant integer ABILITY       = 'Trl1'
        // The Divine Smite model
        private constant string  MODEL         = "Divine Edict.mdl"
        // The  Divine Smite heal model
        private constant string  HEAL_MODEL    = "HolyLight2.mdl"
        // The Divine Smite model
        private constant string  ATTACH_POINT  = "origin"
        // The Divine Smite normal scale
        private constant real    SCALE         = 0.6
        // The Divine Smite infused scale
        private constant real    INFUSED_SCALE = 1.
        // The Divine Smite stomp model
        private constant string  STOMP         = "LightStomp.mdl"
        // The Divine Smite stomp scale
        private constant real    STOMP_SCALE   = 0.8
    endglobals

    // The Divine Smite damage/heal
    private function GetDamage takes unit source, integer level, boolean infused returns real
        static if LIBRARY_NewBonus then
            if infused then
                return 50. * level + (0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.1 * level * GetHeroStr(source, true))
            else    
                return 100. * level + (0.25 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.25 * level * GetHeroStr(source, true))
            endif
        else
            if infused then
                return 50. * level + (0.1 * level *  GetHeroStr(source, true))
            else    
                return 100. * level + (0.25 * level *  GetHeroStr(source, true))
            endif
        endif
    endfunction

    // The Divine Smite AoE
    private function GetAoE takes unit source, integer level, boolean infused returns real
        if infused then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1) + 50 * level
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
        endif
    endfunction

    // The Divine Smite Infused duration
    private function GetDuration takes integer level returns real
        return 3. + 0.*level
    endfunction

    // The Divine Smite infused damage/heal interval
    private function GetInterval takes integer level returns real
        return 0.5 + 0.*level
    endfunction

    // Filter for damage/heal
    private function GroupFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DivineSmite extends Spell
        private real x
        private real y
        private real aoe
        private unit unit
        private real damage
        private real period
        private real duration
        private player player

        method destroy takes nothing returns nothing
            call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
            call deallocate()

            set unit = null
            set player = null
        endmethod

        private static method smite takes unit caster, player owner, real x, real y, real aoe, real damage returns nothing
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsInRange(g, x, y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if GroupFilter(owner, u) then
                        if IsUnitEnemy(u, owner) then
                            call UnitDamageTarget(caster, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        else
                            call SetWidgetLife(u, GetWidgetLife(u) + damage)
                            call DestroyEffect(AddSpecialEffectTarget(HEAL_MODEL, u, ATTACH_POINT))
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r calls forth a |cffffcc00Divine Smite|r at the target area, healing allied units and damaging enemy units within |cffffcc00" + N2S(GetAoE(source, level, false), 0) + " AoE|r for |cff00ffff" + N2S(GetDamage(source, level, false), 0) + "|r |cff00ffffMagic|r damage/heal.\n\n|cffffcc00Light Infused|r: |cffffcc00Divine Smite|r area of effect is increased to |cffffcc00" + N2S(GetAoE(source, level, true), 0) + " AoE|r and it becomes a beam, lasting for |cffffcc00" + N2S(GetDuration(level), 1) + "|r seconds and damaging/healing every |cffffcc00" + N2S(GetInterval(level), 1) + "|r seconds for |cff00ffff" + N2S(GetDamage(source, level, true), 0) + "|r |cff00ffffMagic|r damage/heal."
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - period

            if duration > 0 then
                call smite(unit, player, x, y, aoe, damage)
            endif
            
            return duration > 0
        endmethod

        private method onCast takes nothing returns nothing
            local boolean infused

            static if LIBRARY_LightInfusion then
                set infused = LightInfusion.charges[Spell.source.id] > 0

                if LightInfusion.charges[Spell.source.id] > 0 then
                    set this = thistype.allocate()
                    set x = Spell.x
                    set y = Spell.y
                    set unit = Spell.source.unit
                    set player = Spell.source.player
                    set period = GetInterval(Spell.level)
                    set duration = GetDuration(Spell.level)
                    set aoe = GetAoE(Spell.source.unit, Spell.level, true)
                    set damage = GetDamage(Spell.source.unit, Spell.level, true)

                    call LightInfusion.consume(Spell.source.id)
                    call smite(unit, player, x, y, aoe, damage)
                    call SpamEffect(MODEL, x, y, 0, INFUSED_SCALE, 0.15, 20)
                    call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
                    call StartTimer(period, true, this, 0)
                else
                    call DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
                    call DestroyEffect(AddSpecialEffectEx(STOMP, Spell.x, Spell.y, 0, SCALE))
                    call smite(Spell.source.unit, Spell.source.player, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false))
                endif
            else
                call DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
                call DestroyEffect(AddSpecialEffectEx(STOMP, Spell.x, Spell.y, 0, SCALE))
                call smite(Spell.source.unit, Spell.source.player, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false))
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary