OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    PhilosopherStone = Class(Item)
    PhilosopherStone.code = S2A('I07U')

    PhilosopherStone:property("mana", { get = function (self) return 10000 end })
    PhilosopherStone:property("health", { get = function (self) return 10000 end })
    PhilosopherStone:property("healthRegen", { get = function (self) return 300 end })

    function PhilosopherStone.onInit()
        RegisterItem(PhilosopherStone.allocate(PhilosopherStone.code), ElementalShard.code, AncientStone.code, 0, 0, 0)
    end
end)