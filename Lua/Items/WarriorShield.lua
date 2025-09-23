OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WarriorShield = Class(Item)
    WarriorShield.code = S2A('I03D')

    WarriorShield:property("armor", { get = function (self) return 3 end })
    WarriorShield:property("block", { get = function (self) return 20 end })
    WarriorShield:property("health", { get = function (self) return 400 end })

    function WarriorShield.onInit()
        RegisterItem(WarriorShield.allocate(WarriorShield.code), FusedLifeCrystals.code, GoldenPlatemail.code, HardenedShield.code, 0, 0)
    end
end)