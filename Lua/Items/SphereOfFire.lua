OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfFire = Class(Item)
    SphereOfFire.code = S2A('I04H')

    SphereOfFire:property("spellPower", { get = function (self) return 50 end })

    function SphereOfFire.onInit()
        RegisterItem(SphereOfFire.allocate(SphereOfFire.code), OrbOfFire.code, SphereOfPower.code, 0, 0, 0)
    end
end)