OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    FusionCrystal = Class(Item)
    FusionCrystal.code = S2A('I057')

    FusionCrystal:property("mana", { get = function (self) return 500 end })
    FusionCrystal:property("health", { get = function (self) return 500 end })

    function FusionCrystal.onInit()
        RegisterItem(FusionCrystal.allocate(FusionCrystal.code), FusedLifeCrystals.code, InfusedManaCrystal.code, 0, 0, 0)
    end
end)