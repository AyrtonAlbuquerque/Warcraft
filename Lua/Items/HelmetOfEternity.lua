OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HelmetOfEternity = Class(Item)
    HelmetOfEternity.code = S2A('I0AI')

    HelmetOfEternity:property("mana", { get = function (self) return 15000 end })
    HelmetOfEternity:property("health", { get = function (self) return 30000 end })
    HelmetOfEternity:property("strength", { get = function (self) return 500 end })
    HelmetOfEternity:property("healthRegen", { get = function (self) return 1000 end })

    function HelmetOfEternity.onInit()
        RegisterItem(HelmetOfEternity.allocate(HelmetOfEternity.code), EternityStone.code, RadiantHelmet.code, 0, 0, 0)
    end
end)