OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    NatureGoddessStaff = Class(Item)
    NatureGoddessStaff.code = S2A('I08O')

    NatureGoddessStaff:property("health", { get = function (self) return 10000 end })
    NatureGoddessStaff:property("intelligence", { get = function (self) return 500 end })

    function NatureGoddessStaff.onInit()
        RegisterItem(NatureGoddessStaff.allocate(NatureGoddessStaff.code), SphereOfNature.code, NatureStaff.code, 0, 0, 0)
    end
end)