OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    EntityScythe = Class(Item)
    EntityScythe.code = S2A('I07X')

    EntityScythe:property("agility", { get = function (self) return 375 end })
    EntityScythe:property("strength", { get = function (self) return 375 end })
    EntityScythe:property("intelligence", { get = function (self) return 375 end })
    EntityScythe:property("spellPower", { get = function (self) return 375 end })
    EntityScythe:property("movementSpeed", { get = function (self) return 50 end })

    function EntityScythe.onInit()
        RegisterItem(EntityScythe.allocate(EntityScythe.code), SoulSword.code, ReapersEdge.code, 0, 0, 0)
    end
end)