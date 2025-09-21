OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HeavyHammer = Class(Item)
    HeavyHammer.code = S2A('I01Q')

    HeavyHammer:property("damage", { get = function (self) return 5 end })

    function HeavyHammer.onInit()
        RegisterItem(HeavyHammer.allocate(HeavyHammer.code), 0, 0, 0, 0, 0)
    end
end)