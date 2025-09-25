OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    DragonHelmet = Class(Item)
    DragonHelmet.code = S2A('I05W')

    DragonHelmet:property("health", { get = function (self) return 7500 end })
    DragonHelmet:property("strength", { get = function (self) return 100 end })
    DragonHelmet:property("healthRegen", { get = function (self) return 100 end })

    function DragonHelmet.onInit()
        RegisterItem(DragonHelmet.allocate(DragonHelmet.code), WarriorHelmet.code, EternityStone.code, 0, 0, 0)
    end
end)