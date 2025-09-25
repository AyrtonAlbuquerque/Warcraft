OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RadiantHelmet = Class(Item)
    RadiantHelmet.code = S2A('I08C')

    RadiantHelmet:property("mana", { get = function (self) return 10000 end })
    RadiantHelmet:property("health", { get = function (self) return 20000 end })
    RadiantHelmet:property("strength", { get = function (self) return 250 end })
    RadiantHelmet:property("healthRegen", { get = function (self) return 500 end })

    function RadiantHelmet.onInit()
        RegisterItem(RadiantHelmet.allocate(RadiantHelmet.code), DragonHelmet.code, PhilosopherStone.code, 0, 0, 0)
    end
end)