OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WizardStaff = Class(Item)
    WizardStaff.code = S2A('I07R')

    WizardStaff:property("health", { get = function (self) return 10000 end })
    WizardStaff:property("intelligence", { get = function (self) return 250 end })
    WizardStaff:property("manaRegen", { get = function (self) return 300 end })
    WizardStaff:property("spellPower", { get = function (self) return 750 end })

    function WizardStaff.onInit()
        RegisterItem(WizardStaff.allocate(WizardStaff.code), SphereOfPower.code, SorcererStaff.code, 0, 0, 0)
    end
end)