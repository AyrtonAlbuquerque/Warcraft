OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    Weaver = Class(Item)
    Weaver.code = S2A('I08U')

    Weaver:property("mana", { get = function (self) return 15000 end })
    Weaver:property("health", { get = function (self) return 15000 end })
    Weaver:property("manaRegen", { get = function (self) return 250 end })
    Weaver:property("healthRegen", { get = function (self) return 250 end })
    Weaver:property("spellPower", { get = function (self) return 500 end })
    Weaver:property("intelligence", { get = function (self) return 750 end })

    function Weaver.onInit()
        RegisterItem(Weaver.allocate(Weaver.code), BookOfChaos.code, AncientSphere.code, 0, 0, 0)
    end
end)