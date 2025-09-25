OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    AngelicShield = Class(Item)
    AngelicShield.code = S2A('I0AF')

    AngelicShield:property("armor", { get = function (self) return 20 end })
    AngelicShield:property("health", { get = function (self) return 50000 end })

    function AngelicShield.onInit()
        RegisterItem(AngelicShield.allocate(AngelicShield.code), SphereOfDivinity.code, BloodbourneShield.code, 0, 0, 0)
    end
end)