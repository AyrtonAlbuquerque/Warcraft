OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfPower = Class(Item)
    SphereOfPower.code = S2A('I04G')

    SphereOfPower:property("spellPower", { get = function (self) return 30 end })

    function SphereOfPower.onInit()
        RegisterItem(SphereOfPower.allocate(SphereOfPower.code), 0, 0, 0, 0, 0)
    end
end)