scope EnhancedHammer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 200.
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
        static constant integer code = 'I017'
        static constant string effect = "Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl"
    
        real damage = 10
        real strength = 10

        private static method forGroup takes thistype this, unit u returns nothing
            call DestroyEffect(AddSpecialEffectTarget(effect, u, "chest"))
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.source.isMelee and Damage.amount > 0 and GetRandomReal(0, 100) <= GetChance() then
                call Group.create()
                    .inRange(Damage.target.x, Damage.target.y, GetAoE())
                    .remove(Damage.target.unit)
                    .isAlive()
                    .enemyOf(Damage.source.player)
                    .isNot().ofType(UNIT_TYPE_STRUCTURE)
                    .damage(Damage.source.unit, Damage.amount * GetDamageFactor(), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, 0, thistype.forGroup)
                    .destroy()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HeavyHammer.code, GauntletOfStrength.code, GauntletOfStrength.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope