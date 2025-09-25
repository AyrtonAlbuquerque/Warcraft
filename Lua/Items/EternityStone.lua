OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    EternityStone = Class(Item)
    EternityStone.code = S2A('I052')

    EternityStone:property("health", { get = function (self) return 400 end })
    EternityStone:property("healthRegen", { get = function (self) return 5 end })

    function EternityStone.onInit()
        RegisterItem(EternityStone.allocate(EternityStone.code), FusedLifeCrystals.code, LifeEssenceCrystal.code, 0, 0, 0)
    end
end)