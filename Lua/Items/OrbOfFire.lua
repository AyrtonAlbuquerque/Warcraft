OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfFire = Class(Item)
    OrbOfFire.code = S2A('I01J')

    OrbOfFire:property("damage", { get = function (self) return 10 end })

    function OrbOfFire.onInit()
        RegisterItem(OrbOfFire.allocate(OrbOfFire.code), 0, 0, 0, 0, 0)
    end
end)