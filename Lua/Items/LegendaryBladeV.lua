OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LegendaryBladeV = Class(Item)
    LegendaryBladeV.code = S2A('I0AR')

    LegendaryBladeV:property("damage", { get = function (self) return 2000 end })
    LegendaryBladeV:property("attackSpeed", { get = function (self) return 2.5 end })
    LegendaryBladeV:property("spellPower", { get = function (self) return 1500 end })

    function LegendaryBladeV.onInit()
        RegisterItem(LegendaryBladeV.allocate(LegendaryBladeV.code), SphereOfAir.code, LegendaryBladeIV.code, 0, 0, 0)
    end
end)