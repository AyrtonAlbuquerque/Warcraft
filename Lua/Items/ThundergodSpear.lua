OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ThundergodSpear = Class(Item)
    ThundergodSpear.code = S2A('I07O')

    ThundergodSpear:property("damage", { get = function (self) return 500 end })
    ThundergodSpear:property("attackSpeed", { get = function (self) return 1.5 end })
    ThundergodSpear:property("spellPower", { get = function (self) return 500 end })

    function ThundergodSpear.onInit()
        RegisterItem(ThundergodSpear.allocate(ThundergodSpear.code), LightningSpear.code, SphereOfLightning.code, 0, 0, 0)
    end
end)