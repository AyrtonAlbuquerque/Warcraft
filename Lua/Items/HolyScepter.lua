OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HolyScepter = Class(Item)
    HolyScepter.code = S2A('I09L')

    HolyScepter:property("manaRegen", { get = function (self) return 500 end })
    HolyScepter:property("intelligence", { get = function (self) return 500 end })
    HolyScepter:property("spellPower", { get = function (self) return 1250 end })

    function HolyScepter.onInit()
        RegisterItem(HolyScepter.allocate(HolyScepter.code), WizardStaff.code, CrownOfRightouesness.code, 0, 0, 0)
    end
end)