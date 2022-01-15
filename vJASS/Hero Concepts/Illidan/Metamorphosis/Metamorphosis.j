library Metamorphosis requires DamageInterface, SpellEffectEvent, PluginSpellEffect, Utilities, NewBonusUtils
    /* --------------------- Metamorphosis v1.2 by Chopinski -------------------- */
    // Credits:
    //     BLazeKraze      - Icon
    //     Bribe           - SpellEffectEvent
    //     Mythic          - Damnation Black model (edited by me)
    //     Henry           - Dark Illidan model from Warcraft Underground
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Metamorphosis ability
        private constant integer ABILITY     = 'A006'
        // The raw code of the Metamorphosis buff
        public  constant integer BUFF        = 'BEme'
        // The Metamorphosis lift off model
        private constant string  MODEL       = "Damnation Black.mdl"
        // The fear model
        private constant string  FEAR_MODEL  = "Fear.mdl"
        // The the fear attachment point
        private constant string  ATTACH_FEAR = "overhead"
    endglobals

    // The Metamorphosis AoE for Fear effect
    private function GetAoE takes integer level returns real
        return 400. + 0.*level
    endfunction

    // The Metamorphosis Fear Duration
    private function GetDuration takes unit source, integer level returns real
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        endif
    endfunction

    // The Metamorphosis Armor debuff Duration
    private function GetArmorDuration takes unit source, integer level returns real
        return 5. + 0.*level
    endfunction

    // The Metamorphosis Health Bonus
    private function GetBonusHealth takes unit source, integer level returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 100*level
        else
            return 50*level
        endif
    endfunction

    // The Metamorphosis Damage Bonus
    private function GetBonusDamage takes unit source, integer level returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 10*level
        else
            return 5*level
        endif
    endfunction

    // Fear Filter
    private function FearFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Metamorphosis
        timer   timer
        unit    unit
        group   group
        player  player
        integer level

        static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer  health = 0
            local integer  damage = 0
            local unit     u

            call DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit), 2))
            call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(level), null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if FearFilter(player, u) then
                        set health = health + GetBonusHealth(u, level)
                        set damage = damage + GetBonusDamage(u, level)
                        call UnitApplyFear(u, GetDuration(u, level), FEAR_MODEL, ATTACH_FEAR)
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call LinkBonusToBuff(unit, BONUS_HEALTH, health, BUFF)
            call LinkBonusToBuff(unit, BONUS_DAMAGE, damage, BUFF)
            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call deallocate()

            set timer  = null
            set unit   = null
            set group  = null
            set player = null
        endmethod

        static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer  = NewTimerEx(this)
            set group  = CreateGroup()
            set unit   = Spell.source.unit
            set player = Spell.source.player
            set level  = Spell.level

            call TimerStart(timer, 0.5, false, function thistype.onExpire)
        endmethod

        static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.source.unit, BUFF) > 0 then
                if Damage.isEnemy and not Damage.target.isMagicImmune then
                    call AddUnitBonusTimed(Damage.target.unit, BONUS_ARMOR, -1, GetArmorDuration(Damage.target.unit, GetUnitAbilityLevel(Damage.source.unit, ABILITY)))
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary