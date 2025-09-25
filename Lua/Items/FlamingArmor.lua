OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    FlamingArmor = Class(Item)
    FlamingArmor.code = S2A('I05T')

    FlamingArmor:property("armor", { get = function (self) return 10 end })
    FlamingArmor:property("health", { get = function (self) return 18000 end })

    function FlamingArmor.onInit()
        RegisterItem(FlamingArmor.allocate(FlamingArmor.code), CloakOfFlames.code, FusedLifeCrystals.code, SteelArmor.code, 0, 0)
    end
end)