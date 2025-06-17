scope SphereOfWater
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 1.18
    endfunction

    private constant function GetChance takes nothing returns real
        return 25.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 50.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 500.
    endfunction

    private constant function GetAngle takes nothing returns real
        return 90.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfWater extends Item
        static constant integer code = 'I04K'
        static constant integer buff = 'B00J'
        static constant integer ability = 'A03O'
		static constant integer bolt = 'A03L'
        private static constant real cone = 60

        real spellPower = 50

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage|r is amplified by |cffffcc0018%%.|r\n\n|cff00ff00Passive|r: |cffffcc00Water Bubble|r: Every attack has |cffffcc0025%%|r chance to surronds the target in a water bubble. Attacking units affected by Water Bubble causes the bubble to splash bolts of water to enemy units behind the target, dealing |cff0080ff" + N2S(GetDamage(), 0) + "|r |cff0080fffMagic|r damage.\n\nLasts for 5 seconds."
        endmethod

        private static method onDamage takes nothing returns nothing
            local unit dummy
            local unit u
            local group g

            if UnitHasItemOfType(Damage.source.unit, code) then
                set Damage.amount = Damage.amount * GetDamageFactor()

                if Damage.isEnemy and GetRandomInt(1, 100) <= GetChance() then
                    call CastAbilityTarget(Damage.target.unit, ability, "faeriefire", 1)
                endif
            endif

            if GetUnitAbilityLevel(Damage.target.unit, buff) > 0 then
                set g = CreateGroup()
                set dummy = DummyRetrieve(Damage.source.player, Damage.target.x, Damage.target.y, GetUnitFlyHeight(Damage.target.unit), 0)

                call UnitAddAbility(dummy, bolt)
                call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, GetAoE(), null)

                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                        if IsUnitInCone(u, Damage.target.x, Damage.target.y, GetAoE(), GetUnitFacing(Damage.source.unit), GetAngle()) then
                            if IsUnitEnemy(u, Damage.source.player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                                call IssueTargetOrder(dummy, "thunderbolt", u)
                                call UnitDamageTarget(Damage.source.unit, u, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                            endif
                        endif
                    call GroupRemoveUnit(g, u)
                endloop
                
                call DestroyGroup(g)
                call DummyRecycle(dummy)
            endif

            set g = null
            set dummy = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfWater.code, SphereOfPower.code, 0, 0, 0)
        endmethod
    endstruct
endscope