OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SorcererStaff = Class(Item)
    SorcererStaff.code = S2A('I068')

    SorcererStaff:property("intelligence", { get = function (self) return 150 end })
    SorcererStaff:property("spellPower", { get = function (self) return 500 end })
    SorcererStaff:property("health", { get = function (self) return 5000 end })

    function SorcererStaff.onInit()
        RegisterItem(SorcererStaff.allocate(SorcererStaff.code), MageStaff.code, SphereOfPower.code, 0, 0, 0)
    end
end)