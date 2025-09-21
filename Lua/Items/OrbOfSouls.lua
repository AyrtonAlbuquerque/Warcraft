OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfSouls = Class(Item)
    OrbOfSouls.code = S2A('I01O')

    OrbOfSouls:property("damage", { get = function (self) return 10 end })

    function OrbOfSouls.onInit()
        RegisterItem(OrbOfSouls.allocate(OrbOfSouls.code), 0, 0, 0, 0, 0)
    end
end)