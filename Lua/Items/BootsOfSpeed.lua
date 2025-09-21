OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfSpeed = Class(Item)
    BootsOfSpeed.code = S2A('I00A')

    BootsOfSpeed:property("movementSpeed", { get = function (self) return 25 end })

    function BootsOfSpeed.onInit()
        RegisterItem(BootsOfSpeed.allocate(BootsOfSpeed.code), 0, 0, 0, 0, 0)
    end
end)