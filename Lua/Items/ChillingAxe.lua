OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ChillingAxe = Class(Item)
    ChillingAxe.code = S2A('I03P')

    ChillingAxe:property("strength", { get = function (self) return 35 end })
    ChillingAxe:property("criticalChance", { get = function (self) return 0.15 end })
    ChillingAxe:property("criticalDamage", { get = function (self) return 0.35 end })

    function ChillingAxe.onInit()
        RegisterItem(ChillingAxe.allocate(ChillingAxe.code), OrbOfFrost.code, OrcishAxe.code, 0, 0, 0)
    end
end)