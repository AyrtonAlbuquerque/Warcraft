OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfVenom = Class(Item)
    OrbOfVenom.code = S2A('I01K')

    OrbOfVenom:property("damage", { get = function (self) return 10 end })

    function OrbOfVenom.onInit()
        RegisterItem(OrbOfVenom.allocate(OrbOfVenom.code), 0, 0, 0, 0, 0)
    end
end)