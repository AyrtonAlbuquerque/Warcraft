OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HeatingCloak = Class(Item)
    HeatingCloak.code = S2A('I07C')

    HeatingCloak:property("mana", { get = function (self) return 5000 end })
    HeatingCloak:property("health", { get = function (self) return 5000 end })

    function HeatingCloak.onInit()
        RegisterItem(HeatingCloak.allocate(HeatingCloak.code), OrbOfFire.code, OrbOfFrost.code, CloakOfFlames.code, 0, 0)
    end
end)