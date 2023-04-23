scope GiantsHammer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item      = 'I05E'
        static constant integer ability   = 'A029'
        static constant string STUN_MODEL = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        static constant string STUN_POINT = "overhead"
    endmodule

    private constant function GetChance takes nothing returns real
        return 15.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 250.
    endfunction

    private constant function GetStunDuration takes nothing returns real
        return 1.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GiantsHammer extends Item
        implement Configuration

        real damage = 30

        static method onDamage takes nothing returns nothing   
            local group g
            local unit u
        
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and Damage.source.isMelee and GetRandomReal(1, 100) <= GetChance() then
                set g = CreateGroup()

                call UnitAddAbilityTimed(Damage.source.unit, ability, GetDuration(), 1, true)
                call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, GetAoE(), null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                        if IsUnitEnemy(u, Damage.source.player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                            call StunUnit(u, GetStunDuration(), STUN_MODEL, STUN_POINT, false)
                        endif
                    call GroupRemoveUnit(g, u)
                endloop
                call DestroyGroup(g)
            endif

            set g = null
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope