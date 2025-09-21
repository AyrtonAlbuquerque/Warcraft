OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfWater = Class(Item)
    OrbOfWater.code = S2A('I01M')

    OrbOfWater:property("damage", { get = function (self) return 10 end })

    function OrbOfWater.onInit()
        RegisterItem(OrbOfWater.allocate(OrbOfWater.code), 0, 0, 0, 0, 0)
    end
end)