scope CommanderShield
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusArmor takes nothing returns real
        return 10.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction

    private constant function GetChance takes nothing returns integer
        return 33
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct CommanderShield extends Item
        static constant integer code = 'I01S'
        private static effect array sfx
        private static real array bonus
        
        // Attributes
        real armor = 8
        real block = 60
        real health = 800
        real shielding = 0.2

        private real x
        private real y
        private real angle
        private unit source
        private unit target
        private effect effect
        private integer duration

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set source = null
            set target = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1
            
            if duration > 0 then
                set x = GetUnitX(target)
                set y = GetUnitY(target)
                set angle = AngleBetweenCoordinates(x, y, GetUnitX(source), GetUnitY(source))

                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectPosition(effect, x + 60*Cos(angle), y + 60*Sin(angle), BlzGetUnitZ(target))
            endif

            return duration > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) then
                if Damage.target.health < (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and bonus[Damage.target.id] == 0 then
                    set bonus[Damage.target.id] = GetBonusArmor()
                    set sfx[Damage.target.id] = AddSpecialEffectTarget("ShieldWall.mdl", Damage.target.unit, "origin")

                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, bonus[Damage.target.id])
                elseif Damage.target.health >= (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and bonus[Damage.target.id] > 0 then
                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, -bonus[Damage.target.id])
                    call DestroyEffect(sfx[Damage.target.id])

                    set sfx[Damage.target.id] = null
                    set bonus[Damage.target.id] = 0
                endif

                if Damage.amount > 0 and GetRandomInt(0, 100) <= GetChance() then
                    set this = thistype.allocate(0)
                    set duration = 16
                    set source = Damage.source.unit
                    set target = Damage.target.unit
                    set angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                    set x = Damage.target.x + 60*Cos(angle)
                    set y = Damage.target.y + 60*Sin(angle)
                    set effect = AddSpecialEffect("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", x, y)
                    set Damage.amount = 0
            
                    call StartTimer(0.03, true, this, 0)
                    call BlzSetSpecialEffectScale(effect, 1.5)
                    call BlzSetSpecialEffectYaw(effect, angle)
                    call BlzSetSpecialEffectZ(effect, Damage.target.z)
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), VitalityStone.code, IronShield.code, SoldierChestPlate.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope