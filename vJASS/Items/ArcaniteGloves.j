scope ArcaniteGloves
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetReduction takes nothing returns real
        return 1.
    endfunction

    private constant function GetChance takes nothing returns integer
        return 15
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ArcaniteGloves extends Item
        static constant integer code = 'I01M'
        private static thistype array array

        // Attributes
        real intelligence = 15
        real attackSpeed = 0.4
        real cooldownReduction = 0.2

        private integer index
        private List abilities

        private method destroy takes nothing returns nothing
            set array[index] = 0

            call abilities.destroy()
            call deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.source.id]
            local List node
            local List next

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and this != 0 then
                if GetRandomInt(1, 100) <= GetChance() and abilities.size > 0 then
                    set node = abilities.next

                    loop
                        exitwhen node == abilities
                            set next = node.next

                            if GetUnitAbilityLevel(Damage.source.unit, node.data) > 0 then
                                if BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, node.data) <= GetReduction() then
                                    call BlzEndUnitAbilityCooldown(Damage.source.unit, node.data)
                                    call abilities.remove(node.data)
                                else
                                    call BlzSetUnitAbilityCooldownRemaining(Damage.source.unit, node.data, BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, node.data) - GetReduction())
                                endif
                            endif
                        set node = next
                    endloop 
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local boolean ultimate = BlzGetAbilityIntegerField(Spell.ability, ABILITY_IF_REQUIRED_LEVEL) >= 10
            local thistype this = array[Spell.source.id]

            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 and not ultimate then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set index = Spell.source.id
                    set array[index] = this
                    set abilities = List.create()
                endif

                call abilities.insert(Spell.id)
            endif
        endmethod

        private static method onDeindex takes nothing returns nothing
            local thistype this = array[GetUnitUserData(GetIndexUnit())]

            if this != 0 then
                call destroy()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), GlovesOfSteel.code, SpellbookOfWitchcraft.code, PendantOfVigor.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterAnySpellEvent(function thistype.onCast)
            call RegisterUnitDeindexEvent(function thistype.onDeindex)
        endmethod
    endstruct
endscope