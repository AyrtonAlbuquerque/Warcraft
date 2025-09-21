OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfRestoration = Class(Item)
    BootsOfRestoration.code = S2A('I00Y')

    BootsOfRestoration:property("health", { get = function (self) return 200 end })
    BootsOfRestoration:property("healthRegen", { get = function (self) return 5 end })
    BootsOfRestoration:property("movementSpeed", { get = function (self) return 50 end })

    function BootsOfRestoration.onInit()
        RegisterItem(BootsOfRestoration.allocate(BootsOfRestoration.code), BootsOfSpeed.code, LifeCrystal.code, HomecomingStone.code, LifeEssenceCrystal.code, 0)
    end
end)