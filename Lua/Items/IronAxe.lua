OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    IronAxe = Class(Item)
    IronAxe.code = S2A('I01S')

    IronAxe:property("damage", { get = function (self) return 5 end })
    IronAxe:property("criticalChance", { get = function (self) return 0.1 end })
    IronAxe:property("criticalDamage", { get = function (self) return 0.2 end })

    function IronAxe.onInit()
        RegisterItem(IronAxe.allocate(IronAxe.code), 0, 0, 0, 0, 0)
    end
end)