OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    AncientStone = Class(Item)
    AncientStone.code = S2A('I05D')

    AncientStone:property("mana", { get = function (self) return 500 end })
    AncientStone:property("health", { get = function (self) return 500 end })
    AncientStone:property("manaRegen", { get = function (self) return 10 end })
    AncientStone:property("healthRegen", { get = function (self) return 10 end })
    AncientStone:property("spellPower", { get = function (self) return 50 end })

    function AncientStone.onInit()
        RegisterItem(AncientStone.allocate(AncientStone.code), WizardStone.code, 0, 0, 0, 0)
    end
end)