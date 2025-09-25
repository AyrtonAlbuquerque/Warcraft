OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ElementalStone = Class(Item)
    ElementalStone.code = S2A('I093')

    ElementalStone:property("mana", { get = function (self) return 30000 end })
    ElementalStone:property("health", { get = function (self) return 30000 end })
    ElementalStone:property("manaRegen", { get = function (self) return 750 end })
    ElementalStone:property("healthRegen", { get = function (self) return 750 end })

    function ElementalStone.onInit()
        RegisterItem(ElementalStone.allocate(ElementalStone.code), ElementalShard.code, PhilosopherStone.code, 0, 0, 0)
    end
end)