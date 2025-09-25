OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    KnightBlade = Class(Item)
    KnightBlade.code = S2A('I05K')

    KnightBlade:property("damage", { get = function (self) return 40 end })
    KnightBlade:property("attackSpeed", { get = function (self) return 0.25 end })
    KnightBlade:property("criticalChance", { get = function (self) return 0.2 end })
    KnightBlade:property("criticalDamage", { get = function (self) return 0.2 end })

    function KnightBlade.onInit()
        RegisterItem(KnightBlade.allocate(KnightBlade.code), WarriorBlade.code, OrcishAxe.code, 0, 0, 0)
    end
end)