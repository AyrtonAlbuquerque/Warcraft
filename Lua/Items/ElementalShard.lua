OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ElementalShard = Class(Item)
    ElementalShard.code = S2A('I00T')

    ElementalShard:property("mana", { get = function (self) return 175 end })
    ElementalShard:property("health", { get = function (self) return 175 end })
    ElementalShard:property("manaRegen", { get = function (self) return 3 end })
    ElementalShard:property("healthRegen", { get = function (self) return 3 end })

    function ElementalShard.onInit()
        RegisterItem(ElementalShard.allocate(ElementalShard.code), LifeCrystal.code, ManaCrystal.code, LifeEssenceCrystal.code, CrystalRing.code, 0)
    end
end)