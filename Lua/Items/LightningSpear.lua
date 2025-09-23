OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LightningSpear = Class(Item)
    LightningSpear.code = S2A('I03V')

    LightningSpear:property("damage", { get = function (self) return 15 end })
    LightningSpear:property("attackSpeed", { get = function (self) return 0.55 end })

    function LightningSpear.onInit()
        RegisterItem(LightningSpear.allocate(LightningSpear.code), OrbOfLightning.code, GlovesOfSilver.code, 0, 0, 0)
    end
end)