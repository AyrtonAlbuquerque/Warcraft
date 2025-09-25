OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WizardStone = Class(Item)
    WizardStone.code = S2A('I05A')

    WizardStone:property("mana", { get = function (self) return 250 end })
    WizardStone:property("health", { get = function (self) return 250 end })
    WizardStone:property("manaRegen", { get = function (self) return 5 end })
    WizardStone:property("healthRegen", { get = function (self) return 5 end })

    function WizardStone.onInit()
        RegisterItem(WizardStone.allocate(WizardStone.code), ElementalShard.code, 0, 0, 0, 0)
    end
end)