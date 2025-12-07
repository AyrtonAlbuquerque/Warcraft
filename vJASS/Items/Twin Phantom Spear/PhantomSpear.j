scope PhantomSpear
    struct PhantomSpear extends Item
        static constant integer code = 'I09F'

        // Attributes
        real damage = 75
        real attackSpeed = 1
        real movementSpeed = 25
        real spellPower = 75

        private static boolean array thunder

        private unit prev
        private unit next
        private unit unit
        private real amount
        private group group
        private player player

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set prev = null
            set next = null
            set unit = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00100%%|r Attack Speed\n+ |cffffcc0075|r Damage\n+ |cffffcc0075|r Spell Power\n+ |cffffcc0025|r Movement Speed\n\n|cff00ff00Active|r: |cffffcc00Thunder Wrath|r: When in |cffffcc00Thunder Wrath|r Mode, every attack has |cffffcc00100%%|r chance to release |cffffcc00Chain Lightning|r, dealing |cff00ffff" + N2S(150 + 10 * GetWidgetLevel(u) + 0.03 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER), 0) + " Magic|r damage up to |cffffcc003|r nearby enemies.\n\n|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When in |cffffcc00Lightning Fury|r Mode, every attack has |cffffcc0020%%|r chance of creating a |cffffcc00Chain Lightning|r that will bounce indefinitly to the closest enemy unit within |cffffcc00350 AoE|r dealing |cff00ffff" + N2S(50 + 5 * GetWidgetLevel(u) + 0.01 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER), 0) + " Magic|r damage."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set group = GetEnemyUnitsInRange(player, GetUnitX(prev), GetUnitY(prev), 350, false, false)

            call GroupRemoveUnit(group, prev)

            if BlzGroupGetSize(group) > 0 then
                if next == null or not UnitAlive(next) then
                    set next = GetClosestUnitGroup(GetUnitX(prev), GetUnitY(prev), group)
                else
                    if BlzGroupGetSize(group) > 1 then
                        call GroupRemoveUnit(group, next)
                        set next = GetClosestUnitGroup(GetUnitX(prev), GetUnitY(prev), group)
                    endif
                endif
        
                call DestroyLightningTimed(AddLightningEx("GRNL", true, GetUnitX(prev), GetUnitY(prev), GetUnitZ(prev) + 80.0, GetUnitX(next), GetUnitY(next), GetUnitZ(next) + 80.0), 0.3)
                call DestroyEffect(AddSpecialEffectTarget("Shock_Green.mdx", next, "chest"))
                call UnitDamageTarget(unit, next, amount, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
                call DestroyGroup(group)

                set u = prev
                set prev = next
                set next = u
                set u = null

                return true
            endif

            return false
        endmethod

        private method onDrop takes unit u, item i returns nothing
            if not UnitHasItemOfType(u, code) then
                set thunder[GetUnitUserData(u)] = false  
                call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNMoonArrow.blp")
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            if thunder[Spell.source.id] then
                set thunder[Spell.source.id] = false
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNMoonArrow.blp")
            else
                set thunder[Spell.source.id] = true
                call BlzSetItemIconPath(GetItemOfTypeFromUnitBJ(Spell.source.unit, code), "ReplaceableTextures\\CommandButtons\\BTNPhantomSpear.blp")
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local group g
            local real amount
            local thistype this
        
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and not Damage.target.isMagicImmune then
                if not thunder[Damage.source.id] then
                    set amount = 150 + 10 * Damage.source.level + 0.03 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER)
                    call CreateChainLightning(Damage.source.unit, Damage.target.unit, amount, 500, 0.2, 0.1, 3, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "MYNL", "Shock_Teal.mdx", "chest", false)
                else 
                    if GetRandomInt(1,100) <= 20 then
                        set g = GetEnemyUnitsInRange(Damage.source.player, Damage.target.x, Damage.target.y, 350, false, false)
                        set amount = 50 + 5 * Damage.source.level + 0.01 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER)

                        call GroupRemoveUnit(g, Damage.target.unit)
        
                        if BlzGroupGetSize(g) == 0 then
                            call DestroyLightningTimed(AddLightningEx("GRNL", true, Damage.source.x, Damage.source.y, Damage.source.z + 80.0, Damage.target.x, Damage.target.y, Damage.target.z + 80.0), 0.3)
                            call DestroyEffect(AddSpecialEffectTarget("Shock_Green.mdx", Damage.target.unit, "chest"))
                            call UnitDamageTarget(Damage.source.unit, Damage.target.unit, amount, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
                        else
                            set this = thistype.allocate(0)
                            set prev = Damage.target.unit
                            set next = null
                            set .amount = amount
                            set unit = Damage.source.unit
                            set player = Damage.source.player

                            call StartTimer(0.2, true, this, -1)
                            call UnitDamageTarget(Damage.source.unit, Damage.target.unit, amount, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
                        endif

                        call DestroyGroup(g)
                    endif
                endif
            endif
        
            set g = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent('A01F', function thistype.onCast)
            call RegisterItem(allocate(code), GlovesOfGold.code, ThundergodSpear.code, 0, 0, 0)
        endmethod
    endstruct
endscope