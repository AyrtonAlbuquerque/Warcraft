OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfThorns = Class(Item)
    OrbOfThorns.code = S2A('I01W')

    OrbOfThorns:property("damage", { get = function (self) return 10 end })

    function OrbOfThorns.onInit()
        RegisterItem(OrbOfThorns.allocate(OrbOfThorns.code), 0, 0, 0, 0, 0)
    end
end)