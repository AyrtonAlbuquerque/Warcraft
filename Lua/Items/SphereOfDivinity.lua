OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfDivinity = Class(Item)
    SphereOfDivinity.code = S2A('I04Q')

    SphereOfDivinity:property("spellPower", { get = function (self) return 50 end })

    function SphereOfDivinity.onInit()
        RegisterItem(SphereOfDivinity.allocate(SphereOfDivinity.code), OrbOfLight.code, SphereOfPower.code, 0, 0, 0)
    end
end)