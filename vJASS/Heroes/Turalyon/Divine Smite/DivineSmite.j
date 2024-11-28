library DivineSmite requires SpellEffectEvent, PluginSpellEffect, Utilities, optional LightInfusion
    /* --------------------- Divine Smite v1.2 by Chopinski --------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    //     Bribe           - SpellEffectEvent
    //     Mythic          - Divine Edict Effect
    //     AZ              - Light Stomp effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Divine Smite ability
        private constant integer ABILITY       = 'A001'
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
        if infused then
            return 50.*level
        else    
            return 100.*level
        endif
    endfunction

    // The Divine Smite AoE
    private function GetAoE takes unit source, integer level, boolean infused returns real
        if infused then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1) + 50*level
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
    private struct DivineSmite
        timer   timer
        unit    unit
        player  player
        real    damage
        real    aoe
        real    x
        real    y
        integer i

        private static method smite takes unit caster, player owner, real x, real y, real aoe, real damage returns nothing
            local group g = CreateGroup()
            local unit  u

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

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if i > 0 then
                call smite(unit, player, x, y, aoe, damage)
            else
                call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
                call ReleaseTimer(timer)
                call deallocate()

                set timer  = null
                set unit   = null
                set player = null
            endif
            set i = i - 1
        endmethod

        private static method cast takes unit caster, player owner, integer level, real x, real y, real aoe, real amount, boolean infused returns nothing
            local thistype this

            if infused then
                set this   = thistype.allocate()
                set timer  = NewTimerEx(this)
                set unit   = caster
                set player = owner
                set damage = amount
                set .aoe   = aoe
                set .x     = x
                set .y     = y
                set .i     = R2I(GetDuration(level)/GetInterval(level))

                call smite(caster, owner, x, y, aoe, amount)
                call SpamEffect(MODEL, x, y, 0, INFUSED_SCALE, 0.15, 20)
                call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
                call TimerStart(timer, GetInterval(level), true, function thistype.onPeriod)
            else
                call DestroyEffect(AddSpecialEffectEx(MODEL, x, y, 0, SCALE))
                call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, SCALE))
                call smite(caster, owner, x, y, aoe, amount)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local boolean infused

            static if LIBRARY_LightInfusion then
                set infused = LightInfusion.charges[Spell.source.id] > 0
                
                call LightInfusion.consume(Spell.source.id)
                call cast(Spell.source.unit, Spell.source.player, Spell.level, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, infused), GetDamage(Spell.source.unit, Spell.level, infused), infused)
            else
                call cast(Spell.source.unit, Spell.source.player, Spell.level, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false), false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary