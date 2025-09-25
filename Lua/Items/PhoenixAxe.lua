OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    PhoenixAxe = Class(Item)
    PhoenixAxe.code = S2A('I08R')

    PhoenixAxe:property("damage", { get = function (self) return 1250 end })
    PhoenixAxe:property("criticalDamage", { get = function (self) return 0.25 end })
    PhoenixAxe:property("criticalChance", { get = function (self) return 2.5 end })
    PhoenixAxe:property("spellPower", { get = function (self) return 500 end })

    function PhoenixAxe.onInit()
        RegisterItem(PhoenixAxe.allocate(PhoenixAxe.code), SphereOfFire.code, GreedyAxe.code, 0, 0, 0)
    end
end)