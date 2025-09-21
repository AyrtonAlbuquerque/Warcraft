OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfFlames = Class(Item)
    BootsOfFlames.code = S2A('I010')

    BootsOfFlames:property("damage", { get = function (self) return 10 end })
    BootsOfFlames:property("movementSpeed", { get = function (self) return 50 end })

    function BootsOfFlames.onInit()
        RegisterItem(BootsOfFlames.allocate(BootsOfFlames.code), BootsOfSpeed.code, HomecomingStone.code, CloakOfFlames.code, 0, 0)
    end
end)