OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfWater = Class(Item)
    SphereOfWater.code = S2A('I04K')

    SphereOfWater:property("spellPower", { get = function (self) return 50 end })

    function SphereOfWater.onInit()
        RegisterItem(SphereOfWater.allocate(SphereOfWater.code), OrbOfWater.code, SphereOfPower.code, 0, 0, 0)
    end
end)