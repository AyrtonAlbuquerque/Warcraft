library ItemToolTips requires Utilities, NewBonus

    function ItemToolTips takes nothing returns nothing
        local timer   t           = GetExpiredTimer()
        //---------------------------------------------
        local unit    u           = LoadUnitHandle(udg_HeroHash, GetHandleId(t), 1)
        //---------------------------------------------
        local item    i           = LoadItemHandle(udg_HeroHash, GetHandleId(t), 2)
        //---------------------------------------------
        local integer index       = GetUnitUserData(u)
        //---------------------------------------------
        local real    spell_power = GetUnitSpellPowerFlat(u)
        //---------------------------------------------
        local string  s
        //---------------------------------------------

        if UnitHasItem(u, i) then
            if(GetItemTypeId(i) == 'I05Z') then
                set s = ("|cffffff00Gives|r:
+ |cffffff00200|r All Stats
+ |cffffff00400|r Spell Power

|cff00ff00Passive|r|cffffff00: Soul Reaper|r: Every |cffffff002|r enemy units killed, |cffff0000Strength|r,|cff00ff00 Agility |rand |cff00ffffIntelligence|r are increased by |cffffff001|r and|cff008080 Spell Power|r is incresed by |cffffff000.5|r permanently. Killing a enemy Hero increases all stats by |cffffff0020|r and|cff008080 Spell Power|r by|cffffff00 5|r.

Spell Power Bonus: |cff008080" + R2SW(ReapersEdge.spell[index], 1, 1) + "|r 
Stats Bonus: |cffffff00" + I2S(ReapersEdge.stats[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05H') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00750 |rDamage
+ |cffffcc0035% |rCritical Strike Chance
+ |cffffcc00175% |rCritical Strike Damage

|cff00ff00Passive|r: |cffffcc00Pillage|r: After hitting a critical strike, for the next |cffffcc003 |rseconds, the Hero gains |cffffcc0050% |rAttack Speed bonus and every attack grants |cffffcc00Gold |requal to |cffffcc002.5% (25% against Heroes)|r of the damage dealt.

Gold Granted: |cffffff00" + I2S(GreedyAxe.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I02P') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0025|r Damage
+ |cffffcc0010%|r Evasion

|cff00ff00Passive|r: |cffffcc00Assassination:|r Every attack has |cffffcc0010%|r chance to instantly kill |cffffcc00non-Hero|r targets and increase bounty of killed enemy by |cffffcc00250 gold|r.

Gold Granted: |cffffff00" + I2S(BlackNavaja.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I010') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0010|r Damage
+ |cffffcc0050|r Movement Speed

|cff80ff00Active:|r |cffffcc001000|r Range Blink.

|cff80ff00Passive:|r Every second all enemy units within |cffffcc00300 AoE|r take |cff00ffff" + AbilitySpellDamageEx(20, u) + " Magic|r damage.

Reaching level |cff80ff0015|r with this Boots in inventory grants |cffff800025 All Stats|r.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05W') then
                set s = ("|cffffff00Gives|r:
+ |cffffff00100|r Strength
+ |cffffff00100|r Health Regeneration
+ |cffffff007500|r Health

|cff00ff00Passive|r: |cffffff00Dragon Endurance|r: Every|cffffff00 5|r units killed wilhe this item is equipped grants |cffffff001|r bonus |cff00ff00Health Regeneration|r permanently. |cffffff00Hero|r kills grants |cffffff005|r bonus|cff00ff00 health regeneration|r.

|cff00ff00Active|r: |cffffff00Dragon's Bless|r: When activated, the |cff00ff00Health Regeneration|r granted by this item passive effect is|cffffff00 doubled|r for |cffffff0020|r seconds.

90 seconds cooldown.

Health Regeneration Bonus: |cff00ff00" + R2SW(DragonHelmet.bonus[index], 1, 1) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I02Y') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00375|r Health
+ |cffffcc008|r Strength

|cff00ff00Passive|r: |cffffcc00Strong Arm:|r Every attack taken has |cffffcc0010%|r chance to increase Hero |cffff0000Strength|r by |cffffcc001|r for 15 seconds.

Current Strength Bonus: |cffff0000" + I2S(EmeraldPlate.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I052') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc0025 |rHealth Regeneration
+|cffffcc005000 |rHealth

|cff00ff00Passive|r: |cffffcc00Eternal Youth|r: When killing a unit |cff00ff00Heatlh Regeneration|r is increased by |cffffcc005|r and |cffff0000Maximum Health|r is increased by |cffffcc00100 |rfor |cffffcc0060 |rseconds.

Heath Bonus: |cffff0000" + I2S(EternityStone.health[index]) + "|r
Health Regeneration Bonus: |cff00ff00" + I2S(EternityStone.regen[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I057') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc005000 |rMana
+|cffffcc005000 |rHealth

|cff00ff00Passive|r: |cffffcc00Charge|r: When killing a unit the number of charges of Fusion Crystal are increased by |cffffcc001|r.

|cff00ff00Active|r: |cffffcc00Energy Release|r: When activated, all charges are consumed and for |cffffcc0010 |rseconds, |cffff0000Health|r and |cff80ffffMana|r Regeneration are increased by |cffffcc00" + I2S(50 * FusionCrystal.charges[index]) + "|r.

90 seconds Cooldown

Charges: |cffffcc00" + I2S(FusionCrystal.charges[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I062') then
                set s = ("|cffffff00Gives:
+ |cffffff00200%|r Attack Speed

|cff00ff00Passive|r: |cffffff00Hand of Midas|r: Every attack has|cffffff00 1%|r chance to turn|cffff0000 non-Hero|r targets into a pile of |cffffff00Gold|r equivalent to their|cffff0000 Maximum Health|r.|r

Gold Granted: |cffffff00" + I2S(GlovesOfGold.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05K') then
                set s = ("|cffffcc00Gives:|r
+ |cffffff00650|r Damage
+ |cffffff0030%|r Attack Speed
+ |cffffff0020%|r Critical Strike Chance
+ |cffffff00100%|r Critical Strike Damage

|cff00ff00Passive|r: |cffffff00Critical Frenzy|r: After hitting a critical strike your Hero damage is increased by |cffffff005% (10% against Heroes)|r of the damage dealt by the critical strike for |cffffff005|r seconds.

Damage Bonus: |cffffff00" + I2S(KnightBlade.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I03M') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0010|r Strength
+ |cffffcc007|r Health Regeneration

|cff00ff00Passive|r: |cffffcc00Purifying Flames:|r When your Hero's life drops below |cffffcc0025%|r, |cff00ff00health regeneration|r is increased by |cffffcc0030 hp/s|r and all enemy units within |cffffcc00300|r AoE takes |cff00ffff" + AbilitySpellDamageEx(20, u) +" Magic|r damage per second. Lasts |cffffcc0020|r seconds.

Cooldown: |cffffcc00" + I2S(MagmaHelmet.cooldown[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05N') then
                set s = ("|cffffff00Gives|r:
+ |cffffff00250|r Damage
+ |cffffff0015%|r Evasion
+ |cffffff0015%|r Life Steal

|cff00ff00Passive|r: |cffffff00Assassination|r: Every attack has |cffffff0010%|r chance to instantly kill|cffffff00 non-Hero|r targets and increase bounty of killed enemy by |cffffff001000 gold|r.

|cff00ff00Passive|r: |cffffff00Sacrifice|r: When an enemy unit is assassinated by this item effect, your Hero health is recovered by |cffffff0015%|r of the target |cffffff00max health|r.

Gold Granted: |cffffcc00" + I2S(RitualDagger.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I022') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00150|r Health
+ |cffffcc00150|r Mana
+ |cffffcc0020|r Spell Power
+ |cffffcc0075|r Movement Speed

|cff80ff00Active:|r|cffffcc00 Restoration: |rHeals Health and Mana for |cffffcc00" + I2S(50 * GetHeroLevel(u)) + "|r.

Reaching level |cff80ff0015 |rgrants |cffff800025 All Stats|r.

10 seconds cooldown.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05Q') then
                set s = ("|cffffff00Gives|r:
+ |cffffff0015000|r Health
+ |cffffff00150|r Strength

|cff00ff00Passive|r: |cffffff00Strong Will|r: Every attack taken has |cffffff0010%|r chance to increase Hero |cffff0000Strength|r and |cff00ff00Agility|r by |cffffff0010|r for 30 seconds.

Current Strength Bonus: |cffff0000" + I2S(SaphirePlate.strength[index]) + "|r
Current Agility Bonus: |cff00ff00" + I2S(SaphirePlate.agility[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I037') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00100|r All Stats
+ |cffffcc0050|r Damage

|cff00ff00Passive|r: |cffffcc00Soul Eater:|r Every |cffffcc006|r enemy units killed, |cffff0000Strength|r, |cff00ff00Agility|r and |cff00ffffIntelligence|r are increased by |cffffcc001|r permanently. Killing a enemy Hero increases all stats by |cffffcc003|r.

Stats Bonus: |cffffcc00" + I2S(SoulScyther.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I041') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00300 |rDamage

|cff00ff00Passive|r: |cffffcc00Soul Steal|r: Every attack heals |cff00ff00" + R2SW(50.0 + SoulSword.bonus[index], 0, 0) + "|r Health and deals |cff0080ff" + AbilitySpellDamageEx(200, u) +"|r bonus |cff0080ffMagic |rdamage. Killing an enemy unit, increases the on attack heal by |cffffcc000.2|r. Hero kills increases on attack heal by |cffffcc002|r.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05T') then
                set s = ("|cffffff00Gives|r:
+ |cffffff0018000|r Health
+ |cffffff0010|r Armor

|cff00ff00Passive|r: |cffffff00Damage Reduction|r: All damage taken are reduced by |cffffff0015%|r.

|cff00ff00Passive|r: |cffffff00Guarding Flames|r: Every second, all enemy units within |cffffff00400 AoE|r take |cff0080ff" + AbilitySpellDamageEx(250, u) + "|r |cff0080ffMagic|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I03V') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc0055%|r Attack Speed
+|cffffcc0015|r Damage

|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%|r chance to release chain lightning, dealing |cff00ffff" + AbilitySpellDamageEx(25, u) + " Magic|r damage up to |cffffcc004|r nearby enemies.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I050') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500 |rSpell Power

|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc00200% |rAttack Speed and |cffffcc0040% |rMovement Speed bonus.

|cff00ff00Passive|r: |cffffcc00Gale|r: Attacks have |cffffcc0020%|r chance to knockback the target and all enemy units behind it within |cffffcc00400 |rAoE for |cffffcc00200 |runits over |cffffcc000.5|r seconds and dealing |cff0080ff" + AbilitySpellDamageEx(500, u) + "|r bonus |cff0080ffMagic|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04W') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Dark Curse|r: Every attack has |cffffcc0030%|r chance to Deal |cff0080ff" + AbilitySpellDamageEx(1000, u) + "|r |cff0080ffMagic|r damage and cast |cffffcc00Dark Curse|r in the target, reducing its armor and all aliied units within |cffffcc00600|r AoE by |cffffcc0010|r.

Lasts for 10 seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04H') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage |ris amplified by |cffffcc0018%.|r

|cff00ff00Passive|r: |cffffcc00Flying Flames|r: Engulfs the Hero with flames, releasing flaming bolts to random enemy units within |cffffcc00600|r AoE every |cffffcc001|r second, dealing |cff0080ff" + AbilitySpellDamageEx(500, u) + "|r |cff0080ffMagic|r damage on impact and setting the target on fire, dealing |cff0080ff" + AbilitySpellDamageEx(250, u) + "|r |cff0080ffMagic|r damage per second.

Lasts for 10 seconds (4 on Heroes).")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04T') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Thunder Bolt|r: Every attack has |cffffcc0020%|r to call down thunder bolts on the target and up to |cffffcc004|r nearby enemy units within |cffffcc00500|r AoE, dealing |cff0080ff" + AbilitySpellDamageEx(1000, u) + "|r |cff0080ffMagic|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04N') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Thorned Armor|r: When receiving physical damage, returns 25% of the damage taken.

|cff00ff00Passive|r: |cffffcc00Overgrowth|r: Every attack has |cffffcc0020%|r chance to entangle the target, dealing |cff0080ff" + AbilitySpellDamageEx(500, u) + "|r |cff0080ffMagic|r damage per second for |cffffcc0010|r seconds (|cffffcc003 for Heroes|r). If the entangled unit dies, the entanglement will spread to the |cffffcc002|r nearest targets.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04K') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage|r is amplified by |cffffcc0018%.|r

|cff00ff00Passive|r: |cffffcc00Water Bubble|r: Every attack has |cffffcc0025%|r chance to surronds the target in a water bubble. Attacking units affected by Water Bubble causes the bubble to splash bolts of water to enemy units behind the target, dealing |cff0080ff" + AbilitySpellDamageEx(500, u) + "|r |cff0080fffMagic|r damage.

Lasts for 5 seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I047') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc0030|r Damage

|cff00ff00Passive|r: |cffffcc00Toxic Blade|r: Attacking enemies poison them dealing |cff0080ff" + AbilitySpellDamageEx(20, u) + " Magic|r damage per second.

Lasts for 5 seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I04D') then
                set s = ("|cffffcc00Gives:|r
+|cffffcc00300|r Damage

|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc0020%|r Attack Speed and |cffffcc008%|r Movement Speed bonus.

|cff00ff00Passive|r: |cffffcc00Wind Blow|r: Attacks have |cffffcc0020%|r chance to knockback the target |cffffcc00200|r units over |cffffcc000.5|r seconds and deal |cff00ffff" + AbilitySpellDamageEx(25, u) + " Magic|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I05A') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0010000|r Health
+ |cffffcc007500|r Mana
+ |cffffcc0075|r Health Regeneration
+ |cffffcc0050|r Mana Regeneration

|cff00ff00Passive|r: |cffffcc00Magical Growth|r: Every time you cast an |cffffcc00active|r spell, the number of charges of Wizard Stone are increased by |cffffcc001|r and your Hero |cff0080ffSpell Power|r is increased by |cffffcc0010|r. When the number of charges reach |cffffcc0050|r, the Wizard Stone transforms into |cffffcc00Ancient Stone|r, |cffffcc00doubling|r all the stats given and granting an extra |cffffcc00500|r |cff0080ffSpell Power|r.

Charges: |cffffcc00" + I2S(WizardStone.table[GetHandleId(i)].integer[0]) + "|r
Spell Power Bonus: |cff0080ff" + I2S(WizardStone.table[GetHandleId(i)].integer[1]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I068') then
                set s = ("|cffffff00Gives|r:
+ |cffffff00500|r Spell Power
+ |cffffff00150|r Intelligence
+ |cffffff005000|r Health

|cff00ff00Passive|r: |cffffff00Spell Vamp|r: Dealing |cff0000ffMagical|r damage, heals for |cffffff002.5%|r of damage dealt.

|cff00ff00Passive|r: |cffffff00Sorcerer Trait|r: After casting an ability, |cff0000ffSpell Power|r is increased by |cffffff00250|r for |cffffff0015|r seconds.

Current Spell Power Bonus: |cff0080ff" + R2I2S(SorcererStaff.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I034') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc007|r Strength
+ |cffffcc005|r Health Regeneration

|cff00ff00Passive|r: |cffffcc00Overheal|r: When Hero's life drops below |cffffcc0050%|r, |cff00ff00Health Regeneration|r is increased by |cffffcc0020 Hp/s|r for |cffffcc0015|r seconds.

Cooldown: |cffffcc00" + I2S(WarriorHelmet.cooldown[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I070') then
                set s = ("|cffffff00Gives:|r
+ |cffffff0010000|r Health
+ |cffffff0010000|r Mana
+ |cffffff00100|r Spell Power
+ |cffffff00100|r Health Regeneration
+ |cffffff00100|r Mana Regeneration

|cff00ff00Passive|r: |cffffff00Infused Enlightenment|r: Every |cffffff0045|r seconds your Hero gains permanently |cffffff001000|r Health, |cffffff001000|r Mana, |cffffff0010|r Spell Power, |cffffff0010|r Health Regeneration and |cffffff0010|r Mana Regeneration.

Health Bonus: |cffff0000" + I2S(AncientSphere.hp[index]) + "|r
Mana Bonus: |cff0000ff" + I2S(AncientSphere.mp[index]) + "|r
Health Regen Bonus: |cff00ff00" + I2S(AncientSphere.hr[index]) + "|r
Mana Regen Bonus: |cff00ffff"  + I2S(AncientSphere.mr[index]) + "|r
Spell Power Bonus: |cff0080ff" + I2S(AncientSphere.sp[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I076') then
                set s = ("|cffffff00Gives:|r
+ |cffffff001000|r Damage
+ |cffffff0010%|r Critical Strike Chance
+ |cffffff00100%|r Critical Strike Damage

|cff00ff00Passive|r: |cffffff00Critical Mass|r: After hitting a critical strike |cffffff00Triedge|r gains |cffffff003|r stacks, increasing damage by |cffffff00250|r, Criticial Strike Chance by |cffffff002%|r and Critical Strike Damage by |cffffff0010%|r per stack. Attacking an enemy unit consumes 1 stack. Max |cffffff0010|r stacks.

Stacks: |cffffff00" + I2S(TriedgeSword.stacks[index]) + "|r
Bonus Damage: |cffffff00" + I2S(TriedgeSword.damage[index]) + "|r
Bonus Critical Strike Chance: |cffffff00" + I2S(TriedgeSword.bonusChance[index]) + "%|r
Bonus Critical Strike Damage: |cffffff00" + I2S(TriedgeSword.bonusDamage[index]) + "%|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I079') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0010000|r Mana
+ |cffffcc00250|r Mana Regeneration
+ |cffffcc00600|r Spell Power

|cff00ff00Acitve|r: |cffffcc00Light Shield|r: When activated, creates a light barrier around the Hero, blocking up to |cffffff00" + R2I2S(5000 + (5 * spell_power)) + "|r damage or until its duration is over. Lasts |cffffff0030|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07C') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc005000|r Health
+ |cffffcc005000|r Mana

|cff00ff00Passive|r: |cffffcc00Immolation|r: Every second, all enemy units within |cffffcc00400 AoE|r take |cff00ffff" + AbilitySpellDamageEx(HeatingCloak.damage[index], u) + " Magic|r damage.

|cff00ff00Passive|r: |cffffcc00Turn up the Heat|r: Every |cffffcc0060|r seconds |cffffcc00Heating Cloak|r charges up and the damage dealt by its immolation is increased by |cff00ffff500 Magic|r damage for |cffffcc0030|r seconds.

" + HeatingCloak.state[index] + "|cffffcc00" + HeatingCloak.cd[index] + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07F') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00500|r Damage
+ |cffffcc00250|r Spell Power
+ |cffffcc00250|r Strength

|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00300 AoE|r, dealing |cffffcc0040%|r of damage dealt.

|cff00ff00Passive|r: |cffffcc00Force of Nature|r: Every |cffffcc00fifth|r attack a powerfull blow will damage the target for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and create a |cffffcc00Pulsing Blast|r at the target location. The |cffffcc00Pulsing Blast|r heals all nearby allies and damages all nearby enemy units within |cffffcc00400 AoE|r  for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage / |cff00ff001000|r heal. If the blow kills the target, the damage / heal doubles as well as the amount of pulses. Max |cffffcc005|r pulsing blasts with |cffffcc005|r pulses.

Pulsing Blasts: |cffffcc00" + I2S(HammerOfNature.count[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07I') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00125|r Health Regeneration
+ |cffffcc00125|r Mana Regeneration
+ |cffffcc00400|r Spell Power
+ |cffffcc00250|r Intelligence

|cff00ff00Passive|r: |cffffcc00Elemental Waves|r: Every attack has |cffffcc0020%|r chance to spawn an elemental wave at target location damaging an applying an special effect on the wave type. When proccing this effect there is |cffffcc0025%|r chance of creating either a |cffffff00Holy|r, |cffff0000Fire|r, |cff00ff00Poison|r or |cff8080ffWater|r wave. A |cffffff00Holy Wave|r will damage enemys and heal allies for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage. A |cffff0000Fire Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(500, u) + " Magic|r damage and apply a |cffff0000Burn|r effect dealing |cff00ffff" + AbilitySpellDamageEx(100, u) + " Magic|r damage per second for |cffffcc005|r seconds. |cff00ff00Poison Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and reduce their armor by |cffffcc0010|r  for |cffffcc0010|r seconds. Finnaly the |cff8080ffWater Wave|r damage enemys for |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and reduce their movement speed by |cffffcc0050%|r for |cffffcc005|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07L') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0010000|r Health
+ |cffffcc0010000|r Mana
+ |cffffcc00750|r Spell Power

|cff00ff00Passive|r: |cffffcc00Vigorous Strike|r: After casting an ability your next basic attack will deal |cffffcc00" + R2I2S(3 * spell_power) + "|r as bonus |cffd45e19Pure|r damage to the target.

Strikes Left: |cffffcc00" + I2S(NecklaceOfVigor.strikes[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07O') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00150%|r Attack Speed
+ |cffffcc00500|r Damage
+ |cffffcc00500|r Spell Power

|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%|r chance to release chain lightning, dealing |cff00ffff" + AbilitySpellDamageEx(500, u) + " Magical|r damage up to |cffffcc005|r nearby enemies.

|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When activated |cffffcc00Thundergod Spear|r has |cffffcc00100%|r chance of creating a |cffffcc00Chain Lightning|r dealing |cff00ffff" + AbilitySpellDamageEx(2000, u) + " Magical|r damage up to |cffffcc005|r nearby enemies and drainning |cff8080ff500 Mana|r per proc.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07R') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc00750|r Spell Power
+ |cffffcc00250|r Intelligence
+ |cffffcc0010000|r Health
+ |cffffcc00300|r Mana Regeneration

|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff00ffffMagical|r damage, heals for |cffffcc005%|r of damage dealt.

|cff00ff00Passive|r: |cffffcc00Sorcery Mastery|r: After casting an ability, |cff00ffffSpell Power|r is increased by |cffffcc0025|r permanently.

Spell Power Bonus: |cffffcc00" + I2S(WizardStaff.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07U') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0010000|r Mana
+ |cffffcc0010000|r Health
+ |cffffcc00300|r Health Regeneration

|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Philosopher's Stone|r, every second grants |cffffcc00250 Gold|r.

|cff00ff00Passive|r: |cffffcc00Eternal Life|r: Every |cffffcc00120|r seconds |cff00ff00Health Regeneration|r is increased by |cffffcc00500|r  for |cffffcc0030|r seconds.

Gold Granted: |cffffcc00" + I2S(PhilosopherStone.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I07X') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc00375|r All Stats
+ |cffffcc00500|r Spell Power
+ |cffffcc0050|r Movement Speed

|cff00ff00Passive|r: |cffffcc00Gather of Souls|r: For every enemy unit killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r and |cff00ffffSpell Power|r are incresed by |cffffff001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r and |cff00ffffSpell Power|r by |cffffff0025|r.

Stats Bonus: |cffffcc00" + I2S(EntityScythe.bonus[index]) + "|r
Spell Power Bonus: |cffffcc00" + I2S(EntityScythe.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I083') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001250|r Damage
+ |cffffcc0020%|r Critical Strike Chance
+ |cffffcc00200%|r Critical Strike Damage

|cff00ff00Passive|r: |cffffcc00Death's Blow|r: Every |cffffcc00fifth|r attack is a guaranteed Critical Strike with |cffffcc00200%|r Critical Damage Bonus within |cffffcc00400 AoE|r. If |cffffcc00Death's Blow|r kills the attacked enemy unit, damage is increased by |cffffcc001250|r for |cffffcc0010|r seconds.

Bonus Damage: |cffffcc00" + I2S(Doombringer.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I086') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc00500|r Damage
+ |cffffcc00250|r Spell Power
+ |cffffcc0025%|r Evasion
+ |cffffcc0025%|r Life Steal

|cff00ff00Active|r: |cffffcc00Dual Wield|r: When used, the |cffffcc00Dual Elemental Dagger|r switch between |cffff0000Burning|r and |cff8080ffFreezing|r Mode.

|cff00ff00Passive|r: |cffffcc00Burn or Freeze|r: When |cffffcc00Dual Elemental Dagger|r is in |cffff0000Burning|r mode, all attacked enemy units take |cff00ffff" + AbilitySpellDamageEx(DualDagger.damage[index], u) + " Magic|r damage per second for |cffffcc003|r seconds. When its in |cff8080ffFreezing|r mode, all attacked enemy units have theirs |cffffcc00Movement Speed and Attack Speed|r reduced by |cffffcc0050%|r for |cffffcc005|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I08I') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0020000|r Mana
+ |cffffcc0010000|r Health
+ |cffffcc00500|r Mana Regeneration
+ |cffffcc00350|r Intelligence

|cff00ff00Passive|r: |cffffcc00Moonchant Wisdom|r: Whenever your Hero, allied unit or enemy unit casts a spell within |cffffcc00800 AoE|r, |cffffcc00Moonchant Ring|r gains |cffffff00|cffffff00|r1|r charge.

|cff00ff00Active|r: |cffffcc00Moonchant Well|r: When activated, all |cffffcc00Moonchant Ring|r charges are consumed, recovering |cffffcc00" + I2S(500 * MoonchantRing.charges[index]) + "|r |cffff0000Health|r and |cff00ffffMana|r.

Charges: |cffffcc00" + I2S(MoonchantRing.charges[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I08O') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0020%|r Spell Damage
+ |cffffcc00500|r Intelligence
+ |cffffcc0010000|r Health

|cff00ff00Passive|r: |cffffcc00Thorned Rose|r: Provides |cffffcc00Thorn Aura|r within |cffffcc00600 AoE|r that returns |cffffcc0035%|r of damage taken.

|cff00ff00Active|r: |cffffcc00Nature's Wrath|r: Creates a |cffffcc00Nature Tornado|r that slows enemy units within |cffffcc00600 AoE|r and deals |cff00ffff" + AbilitySpellDamageEx(1000, u) + "Magic|r to enemy units within |cffffcc00400 AoE|r. When expired the |cffffcc00Nature Tornado|r explodes, healing all allies within |cffffcc00600 AoE|r for |cffffcc0020000|r |cffff0000Health|r and |cff00ffffMana|r and damaging enemies for |cffffcc0010000|r |cff808080Pure|r damage.

Lasts for 30 seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I08R') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001250|r Damage
+ |cffffcc00500|r Spell Power
+ |cffffcc0025%|r Critical Strike Chance
+ |cffffcc00250%|r Critical Strike Damage

|cff00ff00Passive|r: |cffffcc00Fire Slash|r: After hitting a Critical Strike a |cffffcc00Fire Slash|r is lauched from the attacked unit position, damaging enemy units in its path for |cffffcc00" + I2S(1000 + PhoenixAxe.stacks[index]) + "|r |cffd45e19Pure|r damage. When attacking enemy Heroes, every |cffffcc00third|r attack will lauch a |cffffcc00Fire Slash|r.

|cff00ff00Passive|r: |cffffcc00Slash Stacks|r: For every enemy unit killed by |cffffcc00Fire Slash|r, |cffffcc00Phoenix Axe|r gains |cffffcc001|r stack permanently, causing subsequent Slashes to deal more damage.

Stacks: |cffffcc00" + I2S(PhoenixAxe.stacks[index] / 100) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I08X') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001500|r Damage
+ |cffffcc001000|r Spell Power
+ |cffffcc00150%|r Attack Speed

|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.

|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.

|cff00ff00Passive|r: |cffffcc00Water Bolt|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I090') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001500|r Damage
+ |cffffcc0030%|r Critical Strike Chance
+ |cffffcc00300%|r Critical Strike Damage
+ |cffffcc00300|r Spell Power

|cff00ff00Passive|r: |cffffcc00Redemption Strike|r: Every |cffffcc00fourth|r attack or |cffffcc00Critical Strike|r a light wave will travel from attacked unit postion damaging enemy units in its path for |cffffcc00" + I2S(RedemptionSword.bonus[index]) + "|r damage and will heal your Hero for the same amount for every unit damaged.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I093') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0030000|r Mana
+ |cffffcc0030000|r Health
+ |cffffcc00750|r Health Regeneration
+ |cffffcc00750|r Mana Regeneration

|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Elemental Stone|r, every second grants |cffffcc00" + I2S(250 + 1*ElementalStone.stacks[index]) + " Gold|r. Every enemy unit killed grants a stack, increasing the income by |cffffcc001|r. Hero Kills grants |cffffcc0050|r Stacks.

Stacks: |cffffcc00" + I2S(ElementalStone.stacks[index]) + "|r
Gold Granted: |cffffcc00" + I2S(ElementalStone.gold[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I096') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00750|r Damage
+ |cffffcc00400|r Spell Power
+ |cffffcc00500|r Strength

|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00350 AoE|r, dealing |cffffcc0045%|r of damage dealt.

|cff00ff00Passive|r: |cffffcc00Unstopable Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc0010|r for |cffffcc0060|r seconds.

|cff00ff00Passive|r: |cffffcc00Shattering Blow|r: Every attack has |cffffcc0020%|r chance to shatter the earth around the target, dealing |cff00ffff" + AbilitySpellDamageEx((GetHeroStr(u, true)/2), u) + " Magic|r damage and stunning all enemy units within |cffffcc00400 AoE|r for |cffffcc003|r seconds |cffffcc00(1 for Heroes)|r and Healing the Hero for the same amount.

Strength Bonus: |cffffcc00" + I2S(SapphireHammer.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I09C') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0025000|r Mana
+ |cffffcc0015000|r Health
+ |cffffcc00750|r Mana Regeneration
+ |cffffcc00500|r Intelligence

|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(u, true) * 0.5)) + "|r.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I09F') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc00250%|r Attack Speed
+ |cffffcc00750|r Damage
+ |cffffcc00750|r Spell Power
+ |cffffcc0075|r Movement Speed

|cff00ff00Active|r: |cffffcc00Thunder Wrath|r: When in |cffffcc00Thunder Wrath|r Mode, every attack has |cffffcc00100%|r chance to release |cffffcc00Chain Lightning|r, dealing |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magical|r damage up to |cffffcc003|r nearby enemies.

|cff00ff00Active|r: |cffffcc00Lightning Fury|r: When in |cffffcc00Lightning Fury|r Mode, every attack has |cffffcc0020%|r chance of creating a |cffffcc00Chain Lightning|r that will bounce indefinitly to the closest enemy unit within |cffffcc00350 AoE|r dealing |cff00ffff" + AbilitySpellDamageEx(250, u) + " Magical|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________                
            elseif(GetItemTypeId(i) == 'I09I') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc00500|r All Stats
+ |cffffcc00500|r Spell Power
+ |cffffcc00500|r Damage
+ |cffffcc0050|r Movement Speed
+ |cffffcc0050%|r Life Steal

|cff00ff00Passive|r: |cffffcc00Blood Harvest|r: For every enemy unit killed, |cffff0000Strength|r,|cff00ff00 Agility|r ,|cff00ffffIntelligence|r, |cff00ffffSpell Power|r and |cff00ff00Damage|r are incresed by |cffffff001|r permanently. Killing a enemy Hero increases |cff00ff00A|r|cff00ff1el|r|cff00ff3el|r|cff00ff5e |r|cff00ff7eS|r|cff00ff9et|r|cff00ffbea|r|cff00ffdet|r|cff00fffes|r, |cff00ffffSpell Power|r and |cff00ff00Damage|r by |cffffff0050|r.

Stats Bonus: |cffffcc00" + I2S(MoonScyth.stats[index]) + "|r
Damage Bonus: |cffffcc00" + I2S(MoonScyth.damage[index]) + "|r
Spell Power Bonus: |cffffcc00" + I2S(MoonScyth.stats[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I09U') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001750|r Damage
+ |cffffcc001250|r Spell Power
+ |cffffcc00200%|r Attack Speed

|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.

|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.

|cff00ff00Passive|r: |cffffcc00Water Blade|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.

|cff00ff00Passive|r: |cffffcc00Dark Blade|r: Every |cffffcc004|r attacks a dark bolt will strike the target reducing its armor by |cffffcc0050|r for |cffffcc005|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0A3') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc001000|r Damage
+ |cffffcc00750|r Spell Power
+ |cffffcc00750|r Strength

|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00400 AoE|r, dealing |cffffcc0050%|r of damage dealt.

|cff00ff00Passive|r: |cffffcc00Holy Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc001|r permanently.

|cff00ff00Passive|r: |cffffcc00Holy Inquisition|r: When dealing |cffff0000Physical|r or |cff00ff00Cleave|r damage, |cffffcc00Holy Hammer|r stores |cffffcc00100%|r (|cffffcc0025%|r for |cff00ff00Cleave|r damage) of the damage dealt and immediately starts regenerating health for |cffffcc0010%|r of all damage stored, depleting it until nothing is left. The more damage is stored through |cffffcc00Holy Inquisition|r the higher |cff00ff00Health Regeneration|r becomes. All damage stored depletes within |cffffcc0010|r seconds if no more damage is stored. Stores |cffffcc002x|r as much damage dealt to |cffffcc00Heroes|r.

Strength Bonus: |cffffcc00" + I2S(HolyHammer.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0A6') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc002250|r Damage
+ |cffffcc0050%|r Life Steal
+ |cffffcc0020%|r Critical Strike Chance
+ |cffffcc00400%|r Critical Strike Damage

|cff00ff00Passive|r: |cffffcc00Devouring Strike|r: After hitting a |cffffcc00Critical Strike|r, |cffffcc00Critical Chance|r and |cffffcc00Life Steal|r are increased by |cffffcc000.2%|r and |cffffcc00Critical Damage|r is increased by |cffffcc000.5%|r permanently.

Critical Chance: |cffffcc00" + R2SW(GetUnitCriticalChance(u), 1, 2) + " %|r
Critical Damage: |cffffcc00" + R2SW(100*GetUnitCriticalMultiplier(u), 1, 2) + " %|r
Life Steal: |cffffcc00" + R2SW(100*GetUnitLifeSteal(u), 1, 2) + " %|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________    
            elseif(GetItemTypeId(i) == 'I0A9') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0025000|r Mana
+ |cffffcc0025000|r Health
+ |cffffcc00750|r Mana Regeneration
+ |cffffcc00750|r Intelligence
+ |cffffcc00750|r Spell Power

|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(u, true) * CrownOfGods.multiplier[index])) + "|r.

|cff00ff00Passive|r: |cffffcc00Divine Protection|r: |cffffcc00Crown of Gods|r provides a divine shield that grows by |cffffcc00100%|r of your Hero total |cff00ffffIntelligence|r every second, blocking all damage taken. When depleted, |cffffcc00Divine Protection|r needs |cffffcc0020|r seconds to recharge, and while recharging, |cffffcc00Arcane Power|r effect is increased to |cffffcc00100%|r of total |cff00ffffIntelligence|r amplification.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AC') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0040000|r Health
+ |cffffcc0015|r Armor

|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0020%|r.

|cff00ff00Passive|r: |cffffcc00Spiked Plate|r: When being attacked, returns |cffffcc00" + R2SW(0.5*GetUnitBonus(u, BONUS_ARMOR), 1, 1) + "%|r (|cffffcc00" + R2S(3*GetUnitBonus(u, BONUS_ARMOR)) + "% against non-Hero|r) of the damage taken as |cffd45e19Pure|r damage.

|cff00ff00Passive|r: |cffffcc00Impenetrable|r: All damage reduced by |cffffcc00Damage Reduction|r effect is stored. When all damage stored reaches |cffffcc0050000|r, your Hero |cff808080Armor|r is increased by |cffffcc001|r.

Armor Bonus: |cffffcc00" + I2S(BlackArmor.armor[index]) + "|r
Damage Reduced: |cffffcc00" + R2I2S(BlackArmor.stored[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AF') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc0050000|r Health
+ |cffffcc00500|r Damage Block
+ |cffffcc0020|r Armor

|cff00ff00Passive|r: |cffffcc00Guardian Angel|r: |cffffcc00Damage Block|r increases by |cffffcc00100|r  for every |cffffcc0010%|r of missing health. In addition, overblocked damage heals your Hero.

|cff00ff00Active|r: |cffffcc00Sanctified Zone|r: When activated, all allied units within |cffffcc00800 AoE|r becomes immune to all damage, and all the damage your Hero takes during this time is evenly distributed amongst allied units within range. Lasts |cffffcc0015|r seconds.

Damage Block: |cffffcc00" + R2I2S(500 + (10* R2I(100 - GetUnitLifePercent(u)))) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I08C') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc0010000|r Mana
+ |cffffcc0020000|r Health
+ |cffffcc00500|r Health Regeneration
+ |cffffcc00250|r Strength

|cff00ff00Passive|r: |cffffcc00Radiant Strength|r: |cff00ff00Health Regeneration|r is increased by |cffffcc00" + R2I2S(RadiantHelmet.regen[index]) + "|r.

|cff00ff00Passive|r: |cffffcc00Resilient Attempt|r: When your Hero life drops below |cffffcc0050%|r, |cffffcc00Radiant Strength|r effect is amplified to |cffffcc00100%|r for |cffffcc0020|r seconds. |cffffcc0090|r seconds cooldown.

Cooldown: |cffffcc00" + R2I2S(R2I(RadiantHelmet.cooldown[index]/10)) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AO') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc002000|r Spell Power

|cff00ff00Passive|r: |cffffcc00Elemental Essence|r: When a enemy unit dies, it will spawn in its location one |cffffcc00Elemental Essence|r. Any Hero carrying |cffffcc00Elemental Sphere|r will collect all essences within |cffffcc00800 AoE|r, gaining its effects permanently depending on the essence collected. Dying Heroes spawns all 5 essences. Essences lasts for |cffffcc0020|r seconds.

|cffff0000Fire Essence|r: |cffff0000Health|r is increased by |cffffcc0050|r and |cff00ff00Health Regeneration|r is increased by |cffffcc005|r.

|cff00ffffWater Essence|r: |cff00ffffMana|r is increased by |cffffcc0050|r and |cff00ffffMana Regeneration|r is increased by |cffffcc005|r.

|cff808080Air Essence|r: |cffff00ffEvasion|r is increased by |cffffcc000.1%|r and |cffffff00Movement Speed|r is increased by |cffffcc001|r.

|cff00ff00Life Essence|r: |cff00ffffSpell Power|r is increased by |cffffcc0010|r.

|cff6f2583Dark Essence|r: |cffff0000Damage|r is increased by |cffffcc0010|r.

|cffff0000Fire|r: " + I2S(ElementalSphere.fire[index]) + "
|cff00ffffWater|r: " + I2S(ElementalSphere.water[index]) + "
|cff808080Air|r: " + I2S(ElementalSphere.air[index]) + "
|cff00ff00Life|r: " + I2S(ElementalSphere.life[index]) + "
|cff6f2583Dark|r: " + I2S(ElementalSphere.dark[index]))
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AR') then
                set s = ("|cffffcc00Gives:|r
+ |cffffcc002000|r Damage
+ |cffffcc001500|r Spell Power
+ |cffffcc00250%|r Attack Speed

|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc005|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.

|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc005|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.

|cff00ff00Passive|r: |cffffcc00Water Blade|r: Every |cffffcc005|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.

|cff00ff00Passive|r: |cffffcc00Dark Blade|r: Every |cffffcc005|r attacks a dark bolt will strike the target reducing its armor by |cffffcc0050|r for |cffffcc005|r seconds.

|cff00ff00Passive|r: |cffffcc00Air Blade|r: Every |cffffcc005|r attacks a wind bolt will strike the target and grant maximum movement speed for |cffffcc003|r seconds.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AY') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc002500|r Damage

|cff00ff00Passive|r: |cffffcc00Quick as Lightning|r: |cffffcc00Base Attack Time|r is reduced by |cffffcc000.5|r seconds.

|cff00ff00Passive|r: |cffffcc00Lightning Embodiment|r: Every |cffffcc000.5|r seconds, a |cffffcc00Lightning|r will emanate from your Hero and hit a random enemy unit within |cffffcc00800 AoE|r, dealing |cff00ffff" + AbilitySpellDamageEx(2500, u) + " Magic|r damage.")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
            elseif(GetItemTypeId(i) == 'I0AZ') then
                set s = ("|cffffcc00Gives|r:
+ |cffffcc001000|r Damage
+ |cffffcc00100%|r Movement Speed
+ |cffffcc00400%|r Attack Speed

|cff00ff00Passive|r: |cffffcc00Sakura Fall|r: |cffffff00Movement Speed|r, |cffffcc00Attack Speed|r and |cffff0000Damage|r provided by Sakura Blade also affect allied units.|r

|cff00ff00Passive|r: |cffffcc00Sakura Lamina|r: For every allied Hero within |cffffcc00800 AoE|r, the damage provided by |cffffcc00Sakura Blade|r is increased by |cffffcc00250|r.

Bonus Damage: |cffffcc00" + I2S(250*SakuraBlade.bonus[index]) + "|r")
                call BlzSetItemExtendedTooltip(i, s)
//____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
                //set s = ("" +  + "|r")
                //set s = ("" +  + "|r")
                //set s = ("" +  + "|r")
            endif
        else
            call FlushChildHashtable(udg_HeroHash, GetHandleId(t))
            call PauseTimer(t)
            call DestroyTimer(t)
        endif

        set t = null
        set u = null
        set i = null
    endfunction

    function UpdateItemToolTip takes unit u, item i returns nothing
        local timer t = CreateTimer()

        call SaveUnitHandle(udg_HeroHash, GetHandleId(t), 1, u)
        call SaveItemHandle(udg_HeroHash, GetHandleId(t), 2, i)
        call TimerStart(t, 0.5, true, function ItemToolTips)

        set t = null
    endfunction

endlibrary