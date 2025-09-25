OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OceanicMace = Class(Item)
    OceanicMace.code = S2A('I04A')

    OceanicMace:property("damage", { get = function (self) return 20 end })

    function OceanicMace.onInit()
        RegisterItem(OceanicMace.allocate(OceanicMace.code), OrbOfWater.code, EnhancedHammer.code, 0, 0, 0)
    end
end)