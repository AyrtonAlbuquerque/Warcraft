OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"
    

    BootsOfTheBraves = Class(Item)
    BootsOfTheBraves.code = S2A('I009')

    BootsOfTheBraves:property("health", { get = function (self) return 150 end })
    BootsOfTheBraves:property("movementSpeed", { get = function (self) return 50 end })
    BootsOfTheBraves:property("attackSpeed", { get = function (self) return 0.15 end })
    BootsOfTheBraves:property("cooldownReduction ", { get = function (self) return 0.15 end })

    function BootsOfTheBraves.onInit()
        RegisterItem(BootsOfTheBraves.allocate(BootsOfTheBraves.code), BootsOfSpeed.code, HomecomingStone.code, GlovesOfHaste.code, LifeCrystal.code, 0)
    end
end)