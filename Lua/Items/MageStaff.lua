OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MageStaff = Class(Item)
    MageStaff.code = S2A('I03G')

    MageStaff:property("health", { get = function (self) return 275 end })
    MageStaff:property("spellVamp", { get = function (self) return 0.05 end })
    MageStaff:property("spellPower", { get = function (self) return 25 end })
    MageStaff:property("intelligence", { get = function (self) return 8 end })

    function MageStaff.onInit()
        RegisterItem(MageStaff.allocate(MageStaff.code), BraceletOfIntelligence.code, FusedLifeCrystals.code, MageStick.code, 0, 0)
    end
end)