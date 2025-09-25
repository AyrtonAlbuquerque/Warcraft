OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    AncientSphere = Class(Item)
    AncientSphere.code = S2A('I070')

    AncientSphere:property("mana", { get = function (self) return 10000 end })
    AncientSphere:property("health", { get = function (self) return 10000 end })
    AncientSphere:property("manaRegen", { get = function (self) return 100 end })
    AncientSphere:property("healthRegen", { get = function (self) return 100 end })
    AncientSphere:property("spellPower", { get = function (self) return 100 end })

    function AncientSphere.onInit()
        RegisterItem(AncientSphere.allocate(AncientSphere.code), SphereOfPower.code, AncientStone.code, 0, 0, 0)
    end
end)