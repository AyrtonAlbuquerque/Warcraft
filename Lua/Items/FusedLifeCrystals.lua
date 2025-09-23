OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    FusedLifeCrystals = Class(Item)
    FusedLifeCrystals.code = S2A('I01G')

    FusedLifeCrystals:property("health", { get = function (self) return 350 end })

    function FusedLifeCrystals.onInit()
        RegisterItem(FusedLifeCrystals.allocate(FusedLifeCrystals.code), LifeCrystal.code, LifeCrystal.code, LifeCrystal.code, 0, 0)
    end
end)