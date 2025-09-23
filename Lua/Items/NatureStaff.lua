OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    NatureStaff = Class(Item)
    NatureStaff.code = S2A('I044')

    NatureStaff:property("health", { get = function (self) return 300 end })
    NatureStaff:property("intelligence", { get = function (self) return 10 end })

    function NatureStaff.onInit()
        RegisterItem(NatureStaff.allocate(NatureStaff.code), OrbOfThorns.code, MageStaff.code, 0, 0, 0)
    end
end)