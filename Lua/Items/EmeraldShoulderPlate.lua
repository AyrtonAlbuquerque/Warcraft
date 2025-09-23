OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    EmeraldShoulderPlate = Class(Item)
    EmeraldShoulderPlate.code = S2A('I02Y')

    EmeraldShoulderPlate:property("health", { get = function (self) return 375 end })
    EmeraldShoulderPlate:property("strength", { get = function (self) return 8 end })

    function EmeraldShoulderPlate.onInit()
        RegisterItem(EmeraldShoulderPlate.allocate(EmeraldShoulderPlate.code), GauntletOfStrength.code, GauntletOfStrength.code, FusedLifeCrystals.code, 0, 0)
    end
end)