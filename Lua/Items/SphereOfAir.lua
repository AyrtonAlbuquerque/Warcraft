OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfAir = Class(Item)
    SphereOfAir.code = S2A('I050')

    SphereOfAir:property("spellPower", { get = function (self) return 50 end })

    function SphereOfAir.onInit()
        RegisterItem(SphereOfAir.allocate(SphereOfAir.code), OrbOfWind.code, SphereOfPower.code, 0, 0, 0)
    end
end)