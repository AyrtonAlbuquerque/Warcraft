OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ArcanaScepter = Class(Item)
    ArcanaScepter.code = S2A('I0AL')

    ArcanaScepter:property("mana", { get = function (self) return 15000 end })
    ArcanaScepter:property("health", { get = function (self) return 15000 end })
    ArcanaScepter:property("manaRegen", { get = function (self) return 750 end })
    ArcanaScepter:property("intelligence", { get = function (self) return 750 end })
    ArcanaScepter:property("spellPower", { get = function (self) return 1500 end })

    function ArcanaScepter.onInit()
        RegisterItem(ArcanaScepter.allocate(ArcanaScepter.code), HolyScepter.code, AncientSphere.code, 0, 0, 0)
    end
end)