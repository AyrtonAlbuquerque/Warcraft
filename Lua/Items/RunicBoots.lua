OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RunicBoots = Class(Item)
    RunicBoots.code = S2A('I022')

    RunicBoots:property("mana", { get = function (self) return 150 end })
    RunicBoots:property("health", { get = function (self) return 150 end })
    RunicBoots:property("spellPower", { get = function (self) return 20 end })
    RunicBoots:property("movementSpeed", { get = function (self) return 75 end })

    function RunicBoots.onInit()
        RegisterItem(RunicBoots.allocate(RunicBoots.code), BootsOfSpeed.code, LifeCrystal.code, ManaCrystal.code, 0, 0)
    end
end)