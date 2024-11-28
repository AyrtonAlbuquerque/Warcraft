scope EnflamedBow
    struct EnflamedBow extends Item
        static constant integer code = 'I06U'

        private static timer timer = CreateTimer()
        private static HashTable table
        private static integer key = -1
        private static thistype array array
        private static integer array counting
        
        private unit source
        private unit target
        private effect effect
        private integer index
        private integer sourceId
        private integer targetId
        private integer duration

        // Attributes
        real damage = 500
        real agility = 250

        private method remove takes integer i returns integer
            set counting[index] = counting[index] - 1
            call DestroyEffect(effect)
			
			if counting[index] <= 0 then
                call DestroyEffect(table[sourceId].effect[0])
                set table[sourceId].effect[0] = null
                set counting[index] = 0
			endif

            set array[i] = array[key]
            set key = key - 1
            set source = null
            set target = null
            set effect = null
            set table[sourceId][targetId] = 0

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
			local thistype this
			
			loop
				exitwhen i > key
                    set this = array[i]
	
					if duration > 0 then
						if UnitAlive(target) then
							if UnitDamageTarget(source, target, 62.5, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
								call SetWidgetLife(source, GetWidgetLife(source) + 62.5)
							endif
						else
							set duration = 1
						endif
					else
						set i = remove(i)
                    endif

                    set duration = duration - 1
				set i = i + 1
			endloop
        endmethod

        private static method onDamage takes nothing returns nothing
			local thistype this

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and not (GetEventDamage() > GetWidgetLife(Damage.target.unit)) then
                if table[Damage.source.handle][Damage.target.handle] == 0 then
					set this = thistype.new()
					set source = Damage.source.unit
                    set target = Damage.target.unit
                    set effect = AddSpecialEffectTarget("Ember Red.mdx", Damage.target.unit, "chest")
                    set sourceId = Damage.source.handle
                    set targetId = Damage.target.handle
                    set index = Damage.source.id
                    set duration = 16
					set key = key + 1
                    set array[key] = this
                    set counting[index] = counting[index] + 1
                    set table[sourceId][targetId] = this

                    if table[sourceId].effect[0] == null then
                        set table[sourceId].effect[0] = AddSpecialEffectTarget("Ember Yellow.mdx", Damage.source.unit, "chest")
                    endif

                    if key == 0 then
                        call TimerStart(timer, 0.25, true, function thistype.onPeriod)
                    endif
                else
                    set this = table[Damage.source.handle][Damage.target.handle]
				endif
	
                set duration = 16
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, HolyBow.code, SphereOfFire.code, 0, 0, 0)
        endmethod
    endstruct
endscope