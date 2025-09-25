OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CommanderShield = Class(Item)
    CommanderShield.code = S2A('I065')

    CommanderShield:property("armor", { get = function (self) return 8 end })
    CommanderShield:property("block", { get = function (self) return 100 end })
    CommanderShield:property("health", { get = function (self) return 12000 end })

    function CommanderShield.onInit()
        RegisterItem(CommanderShield.allocate(CommanderShield.code), FusedLifeCrystals.code, WarriorShield.code, 0, 0, 0)
    end
end)