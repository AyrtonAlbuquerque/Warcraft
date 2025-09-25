OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ArcTrinity = Class(Item)
    ArcTrinity.code = S2A('I0A0')

    ArcTrinity:property("damage", { get = function (self) return 2000 end })
    ArcTrinity:property("criticalDamage", { get = function (self) return 3 end })
    ArcTrinity:property("criticalChance", { get = function (self) return -0.3 end })

    function ArcTrinity.onInit()
        RegisterItem(ArcTrinity.allocate(ArcTrinity.code), TriedgeSword.code, TriedgeSword.code, TriedgeSword.code, 0, 0)
    end
end)