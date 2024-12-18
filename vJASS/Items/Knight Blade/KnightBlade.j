scope KnightBlade
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetMaxDamage takes nothing returns integer
        return 60
    endfunction

    private constant function GetBonusFactor takes nothing returns real
        return 0.05
    endfunction

    private constant function GetBonusHeroFactor takes nothing returns real
        return 0.1
    endfunction

    private constant function GetDuration takes nothing returns integer
        return 5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct KnightBlade extends Item
        static constant integer code = 'I05K'

        // Attributes
        real damage = 40
        real attackSpeed = 0.25
        real criticalChance = 0.2
        real criticalDamage = 0.5

        private static integer array bonus
        private static HashTable table

        private integer index
        private integer damageBonus

        method destroy takes nothing returns nothing
            set bonus[index] = bonus[index] - damageBonus

            if bonus[index] <= 0 then
                call DestroyEffect(table[index].effect[0])
                set table[index].effect[0] = null
            endif

            call super.destroy()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0040|r Damage\n+ |cffffcc0025%%|r Attack Speed\n+ |cffffcc0020%%|r Critical Strike Chance\n+ |cffffcc0050%%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Critical Frenzy|r: After hitting a critical strike your Hero damage is increased by |cffffcc005%% (10%% against Heroes)|r of the damage dealt by the critical strike for |cffffcc005|r seconds. Max |cffffcc0060|r bonus damage.\n\nDamage Bonus: |cffffcc00" + I2S(KnightBlade.bonus[id]) + "|r")
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source)
            local integer damage
            local thistype this

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) and bonus[id] < GetMaxDamage() then
                set damage = R2I(GetCriticalDamage())

                if IsUnitType(target, UNIT_TYPE_HERO) then
                    set damage = R2I(damage*GetBonusHeroFactor())
                else
                    set damage = R2I(damage*GetBonusFactor())
                endif

                if bonus[id] + damage > GetMaxDamage() then
                    set damage = GetMaxDamage() - bonus[id]
                endif

                if damage > 0 then
                    set this = thistype.new()
                    set index = id
                    set damageBonus = damage
                    set bonus[id] = bonus[id] + damage

                    call StartTimer(GetDuration(), false, this, -1)
                    call AddUnitBonusTimed(source, BONUS_DAMAGE, damage, GetDuration())

                    if table[index].effect[0] == null then
                        set table[index].effect[0] = AddSpecialEffectTarget("Sweep_Fire_Medium.mdx", source, "weapon")
                    endif
                endif
            endif

            set source = null
            set target = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, WarriorBlade.code, OrcishAxe.code, 0, 0, 0)
        endmethod
    endstruct    
endscope