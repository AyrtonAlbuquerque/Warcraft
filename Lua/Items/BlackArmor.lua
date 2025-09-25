OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BlackArmor = Class(Item)
    BlackArmor.code = S2A('I0AC')

    BlackArmor:property("armor", { get = function (self) return 15 end })
    BlackArmor:property("health", { get = function (self) return 40000 end })

    function BlackArmor.onInit()
        RegisterItem(BlackArmor.allocate(BlackArmor.code), SphereOfDarkness.code, FlamingArmor.code, 0, 0, 0)
    end
end)