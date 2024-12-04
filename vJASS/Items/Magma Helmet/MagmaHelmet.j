scope MagmaHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetCooldown takes nothing returns real
        return 90.
    endfunction
    
    private constant function GetDuration takes nothing returns real
        return 20.
    endfunction

    private constant function GetBonusRegen takes nothing returns real
        return 30.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.25
    endfunction

    private constant function GetDamage takes nothing returns real
        return 20.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 300.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct MagmaHelmet extends Item
        static constant integer code = 'I03M'
        static constant string burn = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl"

        // Attributes
        real strength = 10
        real healthRegen = 7

        private static real array cooldown

        private unit unit
        private effect effect
        private group group
        private player player
        private integer index
        private real duration

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyGroup(group)
            call super.destroy()

            set cooldown[index] = 0
            set duration = 0
            set unit = null
            set effect = null
            set group = null
            set player = null
        endmethod

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010|r Strength\n+ |cffffcc007|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Purifying Flames:|r When your Hero's life drops below |cffffcc0025%%|r, |cff00ff00health regeneration|r is increased by |cffffcc0030 hp/s|r and all enemy units within |cffffcc00300|r AoE takes |cff00ffff" + AbilitySpellDamageEx(GetDamage(), u) +" Magic|r damage per second. Lasts |cffffcc0020|r seconds.\n\nCooldown: |cffffcc00" + R2I2S(MagmaHelmet.cooldown[id]) + "|r")
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - 1
            set cooldown[index] = cooldown[index] - 1

            if duration >= 0 then
                set group = CreateGroup()

                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(), null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            if UnitDamageTarget(unit, u, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                call DestroyEffect(AddSpecialEffectTarget(burn, u, "origin"))
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                call DestroyGroup(group)

                if duration == 0 then
                    call DestroyEffect(effect)
                endif
            else
                return cooldown[index] > 0
            endif

            return true
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) and GetWidgetLife(Damage.target.unit) < (BlzGetUnitMaxHP(Damage.target.unit)*GetHealthFactor()) and cooldown[Damage.target.id] == 0 then
                set this = thistype.new()
                set unit = Damage.target.unit
                set effect = AddSpecialEffectTarget("Flame Shield.mdx", Damage.target.unit, "origin")
                set player = Damage.target.player
                set index = Damage.target.id
                set duration = GetDuration()
                set cooldown[index] = GetCooldown()

                call StartTimer(1, true, this, Damage.target.id)
                call AddUnitBonusTimed(Damage.target.unit, BONUS_HEALTH_REGEN, GetBonusRegen(), GetDuration())
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, OrbOfFire.code, WarriorHelmet.code, 0, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope