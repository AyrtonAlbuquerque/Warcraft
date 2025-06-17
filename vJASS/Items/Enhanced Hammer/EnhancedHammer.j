scope EnhancedHammer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 150.
    endfunction

    private constant function GetChance takes nothing returns real
        return 30.
    endfunction

    private constant function GetDamageFactor takes nothing returns real
        return 0.0495
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct EnhancedHammer extends Item
        static constant integer code = 'I02V'
        static constant string effect = "Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl"
    
        real damage = 12

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local group g
            local unit v

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.source.isMelee and damage > 0 and GetRandomReal(1, 100) <= GetChance() then
                set g = CreateGroup()

                call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, GetAoE(), null)
                loop
                    set v = FirstOfGroup(g)
                    exitwhen v == null
                        if IsUnitEnemy(v, Damage.source.player) and UnitAlive(v) and v != Damage.target.unit and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                            if UnitDamageTarget(Damage.source.unit, v, damage*GetDamageFactor(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                                call DestroyEffect(AddSpecialEffectTarget(effect, v, "chest"))
                            endif
                        endif
                    call GroupRemoveUnit(g, v)
                endloop
                call DestroyGroup(g)
            endif

            set g = null
            set v = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), RustySword.code, HeavyHammer.code, HeavyHammer.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope