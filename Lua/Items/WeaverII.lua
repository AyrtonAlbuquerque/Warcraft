OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WeaverII = Class(Item)
    WeaverII.code = S2A('I09R')

    WeaverII:property("mana", { get = function (self) return 20000 end })
    WeaverII:property("health", { get = function (self) return 20000 end })
    WeaverII:property("manaRegen", { get = function (self) return 300 end })
    WeaverII:property("healthRegen", { get = function (self) return 300 end })
    WeaverII:property("intelligence", { get = function (self) return 500 end })
    WeaverII:property("spellPower", { get = function (self) return 1000 end })

    function WeaverII.onInit()
        RegisterItem(WeaverII.allocate(WeaverII.code), Weaver.code, 0, 0, 0, 0)
    end
end)