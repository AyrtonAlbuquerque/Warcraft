OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfStrength = Class(Item)
    BootsOfStrength.code = S2A('I00M')

    BootsOfStrength:property("strength", { get = function (self) return 10 end })
    BootsOfStrength:property("movementSpeed", { get = function (self) return 50 end })

    function BootsOfStrength.onInit()
        RegisterItem(BootsOfStrength.allocate(BootsOfStrength.code), BootsOfSpeed.code, GauntletOfStrength.code, HomecomingStone.code, 0, 0)
    end
end)