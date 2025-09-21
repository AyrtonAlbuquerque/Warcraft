OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LifeEssenceCrystal = Class(Item)
    LifeEssenceCrystal.code = S2A('I00L')

    LifeEssenceCrystal:property("healthRegen", { get = function (self) return 2 end })

    function LifeEssenceCrystal.onInit()
        RegisterItem(LifeEssenceCrystal.allocate(LifeEssenceCrystal.code), 0, 0, 0, 0, 0)
    end
end)