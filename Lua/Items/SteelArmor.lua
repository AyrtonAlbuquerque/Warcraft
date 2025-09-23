OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SteelArmor = Class(Item)
    SteelArmor.code = S2A('I031')

    SteelArmor:property("armor", { get = function (self) return 4 end })
    SteelArmor:property("health", { get = function (self) return 500 end })

    function SteelArmor.onInit()
        RegisterItem(SteelArmor.allocate(SteelArmor.code), FusedLifeCrystals.code, GoldenPlatemail.code, 0, 0, 0)
    end
end)