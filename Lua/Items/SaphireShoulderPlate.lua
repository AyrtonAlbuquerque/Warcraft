OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SaphireShoulderPlate = Class(Item)
    SaphireShoulderPlate.code = S2A('I05Q')

    SaphireShoulderPlate:property("strength", { get = function (self) return 150 end })
    SaphireShoulderPlate:property("health", { get = function (self) return 15000 end })

    function SaphireShoulderPlate.onInit()
        RegisterItem(SaphireShoulderPlate.allocate(SaphireShoulderPlate.code), FusedLifeCrystals.code, EmeraldShoulderPlate.code, 0, 0, 0)
    end
end)