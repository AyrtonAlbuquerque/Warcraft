scope BookOfChaos
    private struct SmokeWave extends Missiles
        unit unit

        method onHit takes unit hit returns boolean
            if IsUnitEnemy(hit, owner) and UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) and hit != unit then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_MAGIC, null)
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            set unit = null
        endmethod
    endstruct
    
    struct BookOfChaos extends Item
        static constant integer code = 'I06N'
        static constant integer unit = 'n00M'
        static constant integer ability = 'A04L'

        private static integer array attack

        real health = 5000
        real intelligence = 250
        real spellPowerFlat = 600
        
        private static method onDamage takes nothing returns nothing
            local real i = 0
            local real a
            local real z
            local SmokeWave missile

            if GetUnitTypeId(Damage.source.unit) == unit then
                set z = GetUnitFlyHeight(Damage.target.unit)

                if attack[Damage.source.id] == 1 then
                    set a = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y) + 135*bj_DEGTORAD
                    loop
                        exitwhen i > 90 
                            set missile = SmokeWave.create(Damage.target.x, Damage.target.y, z, Damage.target.x + 300*Cos(a + i*bj_DEGTORAD), Damage.target.y + 300*Sin(a + i*bj_DEGTORAD), z)
                            set missile.source = Damage.source.unit
                            set missile.unit = Damage.target.unit
                            set missile.model = "ShaSmokeAttack.mdx"
                            set missile.scale = 2
                            set missile.speed = 400
                            set missile.collision = 100
                            set missile.damage = GetEventDamage()
                            set missile.owner = Damage.source.player

                            call missile.launch()
                        set i = i + 18
                    endloop
                elseif attack[Damage.source.id] == 2 then
                    call DestroyEffect(AddSpecialEffect("ShaSmash.mdx", Damage.target.x, Damage.target.y))
                    call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, 300, GetEventDamage(), ATTACK_TYPE_CHAOS, DAMAGE_TYPE_MAGIC, false, true, false)
                endif
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()
            local integer index

            if GetUnitTypeId(source) == unit then
                set index = GetUnitUserData(source)

                if GetRandomInt(1, 2) == 1 then
                    set attack[index] = 1
                    call SetUnitAnimationByIndex(source, 3)
                    call QueueUnitAnimation(source, "Stand Ready")
                else
                    set attack[index] = 2
                    call SetUnitAnimationByIndex(source, 5)
                    call QueueUnitAnimation(source, "Stand Ready")
                endif
            endif

            set source = null
        endmethod

        private static method onCast takes nothing returns nothing
            local unit omen = CreateUnit(Spell.source.player, unit, Spell.x, Spell.y, GetUnitFacing(Spell.source.unit))

            call DestroyEffectTimed(AddSpecialEffectEx("Haunt_v2.mdx", Spell.x, Spell.y, 0, 5), 6.423)
            call SetUnitAnimation(omen, "Birth")
            call QueueUnitAnimation(omen, "Stand")

            set omen = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call thistype.allocate(code, SummoningBook.code, SphereOfDarkness.code, 0, 0, 0)
        endmethod
    endstruct
endscope