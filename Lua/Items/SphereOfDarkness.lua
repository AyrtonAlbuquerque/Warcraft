OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfDarkness = Class(Item)
    SphereOfDarkness.code = S2A('I04W')

    SphereOfDarkness:property("spellPower", { get = function (self) return 50 end })

    function SphereOfDarkness.onInit()
        RegisterItem(SphereOfDarkness.allocate(SphereOfDarkness.code), OrbOfDarkness.code, SphereOfPower.code, 0, 0, 0)
    end
end)