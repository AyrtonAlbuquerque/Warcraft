OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GreedyAxe = Class(Item)
    GreedyAxe.code = S2A('I05H')

    GreedyAxe:property("damage", { get = function (self) return 45 end })
    GreedyAxe:property("criticalDamage", { get = function (self) return 1 end })
    GreedyAxe:property("criticalChance", { get = function (self) return 0.25 end })

    function GreedyAxe.onInit()
        RegisterItem(GreedyAxe.allocate(GreedyAxe.code), OrcishAxe.code, OrcishAxe.code, 0, 0, 0)
    end
end)