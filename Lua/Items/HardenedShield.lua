OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HardenedShield = Class(Item)
    HardenedShield.code = S2A('I017')

    HardenedShield:property("armor", { get = function (self) return 2 end })
    HardenedShield:property("block", { get = function (self) return 15 end })
    HardenedShield:property("health", { get = function (self) return 200 end })

    function HardenedShield.onInit()
        RegisterItem(HardenedShield.allocate(HardenedShield.code), CommomShield.code, LifeCrystal.code, Platemail.code, 0, 0)
    end
end)