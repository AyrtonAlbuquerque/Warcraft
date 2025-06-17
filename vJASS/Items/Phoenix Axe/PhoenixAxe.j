scope PhoenixAxe
    private struct FireSlash extends Missiles
        integer index

        method onHit takes unit hit returns boolean
            if IsUnitEnemy(hit, owner) and UnitAlive(hit) and not IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                if not UnitAlive(hit) then
                    set PhoenixAxe.stacks[index] = PhoenixAxe.stacks[index] + 100
                endif
            endif

            return false
        endmethod
    endstruct
    
    struct PhoenixAxe extends Item
        static constant integer code = 'I08R'
        static integer array stacks
        private static integer array attack

        real damage = 1250
        real criticalChance = 0.25
        real criticalDamage = 2.5
        real spellPower = 500

        private static method launch takes unit source, unit target, real damage returns nothing
            local real x = GetUnitX(target)
            local real y = GetUnitY(target)
            local real a = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local FireSlash missile = FireSlash.create(x, y, GetUnitFlyHeight(target), x + 600*Cos(a), y + 600*Sin(a), 0)

            set missile.source = source
            set missile.damage = damage
            set missile.model = "Fire_Slash.mdx"
            set missile.speed = 1200
            set missile.collision = 75
            set missile.owner = GetOwningPlayer(source)
            set missile.index = GetUnitUserData(source)

            call missile.launch()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc001250|r Damage\n+ |cffffcc00500|r Spell Power\n+ |cffffcc0025%%|r Critical Strike Chance\n+ |cffffcc00250%%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Fire Slash|r: After hitting a Critical Strike a |cffffcc00Fire Slash|r is lauched from the attacked unit position, damaging enemy units in its path for |cffffcc00" + I2S(1000 + stacks[id]) + "|r |cffd45e19Pure|r damage. When attacking enemy Heroes, every |cffffcc00third|r attack will lauch a |cffffcc00Fire Slash|r.\n\n|cff00ff00Passive|r: |cffffcc00Slash Stacks|r: For every enemy unit killed by |cffffcc00Fire Slash|r, |cffffcc00Phoenix Axe|r gains |cffffcc001|r stack permanently, causing subsequent Slashes to deal more damage.\n\nStacks: |cffffcc00" + I2S(stacks[id] / 100) + "|r"
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                call launch(source, target, 1000 + stacks[GetUnitUserData(source)])
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and Damage.target.isHero then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1
                
                if attack[Damage.source.id] >= 3 then
                    set attack[Damage.source.id] = 0
                    call launch(Damage.source.unit, Damage.target.unit, 1000 + stacks[Damage.source.id])
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), SphereOfFire.code, GreedyAxe.code, 0, 0, 0)
        endmethod
    endstruct
endscope