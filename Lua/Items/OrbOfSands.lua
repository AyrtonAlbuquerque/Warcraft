OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfSands = Class(Item)
    OrbOfSands.code = S2A('I01V')

    OrbOfSands:property("damage", { get = function (self) return 10 end })

    function OrbOfSands.onInit()
        RegisterItem(OrbOfSands.allocate(OrbOfSands.code), 0, 0, 0, 0, 0)
    end
end)