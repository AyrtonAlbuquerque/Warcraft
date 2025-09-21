OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfLight = Class(Item)
    OrbOfLight.code = S2A('I01X')

    OrbOfLight:property("damage", { get = function (self) return 10 end })

    function OrbOfLight.onInit()
        RegisterItem(OrbOfLight.allocate(OrbOfLight.code), 0, 0, 0, 0, 0)
    end
end)