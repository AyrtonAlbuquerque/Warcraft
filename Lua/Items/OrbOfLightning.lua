OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfLightning = Class(Item)
    OrbOfLightning.code = S2A('I01N')

    OrbOfLightning:property("damage", { get = function (self) return 10 end })

    function OrbOfLightning.onInit()
        RegisterItem(OrbOfLightning.allocate(OrbOfLightning.code), 0, 0, 0, 0, 0)
    end
end)