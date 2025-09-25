OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfNature = Class(Item)
    SphereOfNature.code = S2A('I04N')

    SphereOfNature:property("spellPower", { get = function (self) return 50 end })

    function SphereOfNature.onInit()
        RegisterItem(SphereOfNature.allocate(SphereOfNature.code), OrbOfThorns.code, SphereOfPower.code, 0, 0, 0)
    end
end)