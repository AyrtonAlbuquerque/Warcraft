scope BookOfIce
    struct BookOfIce extends Item
        static constant integer code = 'I055'
        static constant integer unit = 'n00N'
        static constant integer ability = 'A00I'
        
        private static integer array attack

        real armor = 10
        real intelligence = 250
        real spellPower = 600
        
        private static method onDamage takes nothing returns nothing
            local unit v
            local group g
            local effect e

            if GetUnitTypeId(Damage.source.unit) == unit then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= 3 then
                    set g = CreateGroup()
                    set e = AddSpecialEffect("IceSlam.mdx", Damage.target.x, Damage.target.y)
                    set attack[Damage.source.id] = 0

                    call BlzSetSpecialEffectScale(e, 0.5)
                    call BlzSetSpecialEffectTimeScale(e, 2.0)
                    call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, 500, null)

                    loop
                        set v = FirstOfGroup(g)
                        exitwhen v == null
                            if IsUnitEnemy(v, Damage.source.player) and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                                call UnitDamageTarget(Damage.source.unit, v, 2500, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                call KnockupUnit(v, 500, 0.75, null, null, false)
                            endif
                        call GroupRemoveUnit(g, v)
                    endloop

                    call DestroyGroup(g)
                    call DestroyEffect(e)
                endif
            endif

            set e = null
            set g = null
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()

            if GetUnitTypeId(source) == unit and attack[GetUnitUserData(source)] == 2 then
                call SetUnitAnimationByIndex(source, 17)
                call QueueUnitAnimation(source, "Stand Ready")
            endif
            
            set source = null
        endmethod

        private static method onCast takes nothing returns nothing
            local unit titan = CreateUnit(Spell.source.player, unit, Spell.x, Spell.y, GetUnitFacing(Spell.source.unit))

            call SetUnitAnimation(titan, "Birth")
            call QueueUnitAnimation(titan, "Stand")

            set titan = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfAir.code, 0, 0, 0)
        endmethod
    endstruct
endscope