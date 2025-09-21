OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HeavyBoots = Class(Item)
    HeavyBoots.code = S2A('I00W')

    HeavyBoots:property("damage", { get = function (self) return 15 end })
    HeavyBoots:property("attackSpeed", { get = function (self) return 0.15 end })
    HeavyBoots:property("movementSpeed", { get = function (self) return 50 end })

    function HeavyBoots.onInit()
        RegisterItem(HeavyBoots.allocate(HeavyBoots.code), BootsOfSpeed.code, HomecomingStone.code, RustySword.code, GlovesOfHaste.code, 0)
    end
end)