OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfWind = Class(Item)
    OrbOfWind.code = S2A('I01P')

    OrbOfWind:property("damage", { get = function (self) return 10 end })

    function OrbOfWind.onInit()
        RegisterItem(OrbOfWind.allocate(OrbOfWind.code), 0, 0, 0, 0, 0)
    end
end)