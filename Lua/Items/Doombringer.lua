OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    Doombringer = Class(Item)
    Doombringer.code = S2A('I083')

    Doombringer:property("damage", { get = function (self) return 1250 end })
    Doombringer:property("criticalDamage", { get = function (self) return 2 end })
    Doombringer:property("criticalChance", { get = function (self) return 0.2 end })

    function Doombringer.onInit()
        RegisterItem(Doombringer.allocate(Doombringer.code), SphereOfFire.code, TriedgeSword.code, 0, 0, 0)
    end
end)