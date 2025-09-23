OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GoldenPlatemail = Class(Item)
    GoldenPlatemail.code = S2A('I01D')

    GoldenPlatemail:property("armor", { get = function (self) return 2 end })
    GoldenPlatemail:property("health", { get = function (self) return 225 end })

    function GoldenPlatemail.onInit()
        RegisterItem(GoldenPlatemail.allocate(GoldenPlatemail.code), LifeCrystal.code, Platemail.code, Platemail.code, 0, 0)
    end
end)