OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BerserkerBoots = Class(Item)
    BerserkerBoots.code = S2A('I020')

    BerserkerBoots:property("damage", { get = function (self) return 15 end })
    BerserkerBoots:property("evasion", { get = function (self) return 0.15 end })
    BerserkerBoots:property("attackSpeed", { get = function (self) return 0.1 end })
    BerserkerBoots:property("movementSpeed", { get = function (self) return 35 end })

    function BerserkerBoots.onInit()
        RegisterItem(BerserkerBoots.allocate(BerserkerBoots.code), BootsOfSpeed.code, GlovesOfHaste.code, GlovesOfHaste.code, AssassinsDagger.code, 0)
    end
end)