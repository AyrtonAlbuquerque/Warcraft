OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LegendaryBladeIV = Class(Item)
    LegendaryBladeIV.code = S2A('I09U')

    LegendaryBladeIV:property("damage", { get = function (self) return 1750 end })
    LegendaryBladeIV:property("attackSpeed", { get = function (self) return 2 end })
    LegendaryBladeIV:property("spellPower", { get = function (self) return 1250 end })

    function LegendaryBladeIV.onInit()
        RegisterItem(LegendaryBladeIV.allocate(LegendaryBladeIV.code), SphereOfDarkness.code, LegendaryBladeIII.code, 0, 0, 0)
    end
end)