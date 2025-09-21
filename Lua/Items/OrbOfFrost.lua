OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfFrost = Class(Item)
    OrbOfFrost.code = S2A('I01L')

    OrbOfFrost:property("damage", { get = function (self) return 10 end })

    function OrbOfFrost.onInit()
        RegisterItem(OrbOfFrost.allocate(OrbOfFrost.code), 0, 0, 0, 0, 0)
    end
end)