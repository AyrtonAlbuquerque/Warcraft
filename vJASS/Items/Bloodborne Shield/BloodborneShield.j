scope BloodbourneShield
    struct BloodbourneShield extends Item
        static constant integer code = 'I08L'

        real armor = 15
        real health = 25000

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.target.unit, code) and damage > 0 then
                call HealArea(Damage.target.player, Damage.target.x, Damage.target.y, 600, damage*0.15, "HealGreen.mdx", "origin")
        
                if Damage.isAttack and GetRandomInt(1, 100) <= 10 then
                    call DestroyEffect(AddSpecialEffectTarget("Bloodborne_Defend.mdx", Damage.target.unit, "origin"))
                    call HealArea(Damage.target.player, Damage.target.x, Damage.target.y, 600, 2*damage, "", "")
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, CommanderShield.code, PhilosopherStone.code, 0, 0, 0)
        endmethod
    endstruct
endscope