scope BookOfOceans
    private struct WaterSplash extends Missiles
        unit unit

        method onHit takes unit hit returns boolean
            if IsUnitEnemy(hit, owner) and UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) and hit != unit then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_MAGIC, null)
                call DestroyEffectTimed(AddSpecialEffectTarget("WaterBreathDamage.mdx", hit, "chest"), 3)
                call UnitAddMoveSpeedBonus(hit, 0, -50, 3.00)
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            set unit = null
        endmethod
    endstruct
    
    struct BookOfOceans extends Item
        static constant integer code = 'I06E'
        static constant integer unit = 'o005'
        
        real mana = 5000
        real intelligence = 250
        real spellPowerFlat = 600

        private static method onDamage takes nothing returns nothing
            local real i = 0
            local real a
            local real z
            local WaterSplash missile

            if GetUnitTypeId(Damage.source.unit) == unit then
                set z = GetUnitFlyHeight(Damage.target.unit)
                set a = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y) + 157.5*bj_DEGTORAD
               
                loop
                    exitwhen i > 45.0
                        set missile = WaterSplash.create(Damage.target.x, Damage.target.y, z, Damage.target.x + 300*Cos(a + i*bj_DEGTORAD), Damage.target.y + 300*Sin(a + i*bj_DEGTORAD), z)
                        set missile.source = Damage.source.unit
                        set missile.unit = Damage.target.unit
                        set missile.owner = Damage.source.player
                        set missile.model = "WaterBreath.mdx"
                        set missile.scale = 0.75
                        set missile.speed = 900
                        set missile.collision = 100
                        set missile.damage = 1.2*GetEventDamage()

                        call missile.launch()
                    set i = i + 22.5
                endloop
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SummoningBook.code, SphereOfWater.code, 0, 0, 0)
        endmethod
    endstruct
endscope