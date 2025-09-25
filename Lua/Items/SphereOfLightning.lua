OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SphereOfLightning = Class(Item)
    SphereOfLightning.code = S2A('I04T')

    SphereOfLightning:property("spellPower", { get = function (self) return 50 end })

    function SphereOfLightning.onInit()
        RegisterItem(SphereOfLightning.allocate(SphereOfLightning.code), OrbOfLightning.code, SphereOfPower.code, 0, 0, 0)
    end
end)