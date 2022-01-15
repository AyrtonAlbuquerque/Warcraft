library BreathOfFire requires SpellEffectEvent, PluginSpellEffect, NewBonus, Utilities, Missiles, optional KegSmash
    /* -------------------- Breath of Fire v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     AZ                 - Breth of Fire model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Breath of Fire Ability
        public  constant integer ABILITY      = 'A003'
        // The Breath of Fire model
        private constant string  MODEL        = "BreathOfFire.mdl"
        // The Breath of Fire scale
        private constant real    SCALE        = 0.75
        // The Breath of Fire Missile speed
        private constant real    SPEED        = 500.
        // The Breath of Fire DoT period
        private constant real    PERIOD       = 1.
        // The Breath of Fire DoT model
        private constant string  DOT_MODEL    = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
        // The Breath of Fire DoT model attach point
        private constant string  ATTACH       = "origin"
    endglobals

    // The Breath of Fire final AoE
    private function GetFinalArea takes integer level returns real
        return 400. + 0.*level
    endfunction

    // The Breath of Fire cone width
    private function GetCone takes integer level returns real
        return 60. + 0.*level
    endfunction

    // The Breath of Fire DoT/Brew Cloud ignite duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Breath of Fire travel distance, by default the ability cast range
    private function GetDistance takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction

    // The Breath of Fire DoT damage
    private function GetDoTDamage takes integer level returns real
        return 10.*level
    endfunction

    // The Breath of Fire Brew Cloud ignite damage
    private function GetIgniteDamage takes integer level returns real
        return 25.*level
    endfunction

    // The Breath of Fire Brew Cloud ignite damage interval
    private function GetIgniteInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The Breath of Fire Damage
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction

    // The Breath of Fire armor reduction
    private function GetArmorReduction takes integer level returns integer
        return 5 + 0*level
    endfunction

    // The Breath of Fire Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoT
        static thistype array n
        static thistype array data
		static integer 		  didx  = -1
        static timer 		  timer = CreateTimer()

        unit    source
        unit    target
        real    damage
        effect  effect
        integer armor
        integer index
        integer duration

        private method remove takes integer i returns integer
            call AddUnitBonus(target, BONUS_ARMOR, armor)
            call DestroyEffect(effect)

            set source   = null
            set target   = null
            set effect   = null
			set data[i]  = data[didx]
            set didx 	 = didx - 1
            set n[index] = 0

			if didx == -1 then
				call PauseTimer(timer)
			endif

			call deallocate()

			return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this
	
			loop
				exitwhen i > didx
					set this = data[i]

                    if duration > 0 then
                        if UnitAlive(target) then
                            static if LIBRARY_KegSmash then
                                if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                                    call UnitDamageTarget(source, target, 2*damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                else
                                    call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                endif
                            else
                                call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                            endif
                        else
                            set i = remove(i)
                        endif
					else
						set i = remove(i)
                    endif
                    set duration = duration - 1
				set i = i + 1
			endloop
        endmethod

        static method create takes unit source, unit target, integer level returns thistype
            local integer  i = GetUnitUserData(target)
            local thistype this
        
            if n[i] != 0 then
                set this = n[i]
            else
                set this = thistype.allocate()
                set .source    = source
                set .target    = target
                set .damage    = GetDoTDamage(level)
                set .index     = i
                set .effect    = AddSpecialEffectTarget(DOT_MODEL, target, ATTACH)
                set .armor     = 0
                set n[i]       = this
                set didx       = didx + 1
                set data[didx] = this

                static if LIBRARY_KegSmash then
                    if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                        set armor = GetArmorReduction(level)
                        call AddUnitBonus(target, BONUS_ARMOR, -armor)
                    endif
                endif

                if didx == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                endif
            endif

            set duration = R2I(GetDuration(source, level)/PERIOD)

            return this
        endmethod
    endstruct

    private struct BreathOfFire extends Missiles
        group   group
        integer level
        real    fov
        real    face
        real    centerX
        real    centerY
        real    distance
        real    ignite_damage
        real    ignite_duration
        real    ignite_interval

        method onHit takes unit hit returns boolean
            if IsUnitInCone(hit, centerX, centerY, distance, face, fov) then
                if DamageFilter(owner, hit) then
                    if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call DoT.create(source, hit, level)
                    endif
                endif
            endif

            return false
        endmethod

        method onPeriod takes nothing returns boolean
            static if LIBRARY_KegSmash then
                local unit u
                local real d

                call GroupEnumUnitsOfPlayer(group, owner, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if GetUnitTypeId(u) == Utilities_DUMMY and BrewCloud.active(u) then
                            set d = DistanceBetweenCoordinates(x, y, GetUnitX(u), GetUnitY(u))
                            if d <= collision + KegSmash_GetAoE(source, level)/2 and IsUnitInCone(u, centerX, centerY, 2*distance, face, 180) then
                                call BrewCloud.ignite(u, ignite_damage, ignite_duration, ignite_interval)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            call DestroyGroup(group)
            set group = null
        endmethod

        private static method onCast takes nothing returns nothing
            local real     a    = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real     d    = GetDistance(Spell.source.unit, Spell.level)
            local effect   e    = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE)
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)

            set speed     = SPEED
            set source    = Spell.source.unit 
            set owner     = Spell.source.player
            set level     = Spell.level
            set centerX   = Spell.source.x
            set centerY   = Spell.source.y
            set face      = a*bj_RADTODEG
            set distance  = d
            set fov       = GetCone(Spell.level)
            set damage    = GetDamage(Spell.level)
            set collision = GetFinalArea(Spell.level)
            set group     = CreateGroup()
            set ignite_damage   = GetIgniteDamage(Spell.level)
            set ignite_duration = GetDuration(Spell.source.unit, Spell.level)
            set ignite_interval = GetIgniteInterval(Spell.level)

            call BlzSetSpecialEffectYaw(e, a)
            call DestroyEffect(e)
            call launch()

            set e = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary