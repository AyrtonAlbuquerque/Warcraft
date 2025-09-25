OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LegendaryBladeIII = Class(Item)
    LegendaryBladeIII.code = S2A('I08X')

    LegendaryBladeIII:property("damage", { get = function (self) return 1750 end })
    LegendaryBladeIII:property("spellPower", { get = function (self) return 1250 end })
    LegendaryBladeIII:property("attackSpeed", { get = function (self) return 2 end })

    function LegendaryBladeIII.onInit()
        RegisterItem(LegendaryBladeIII.allocate(LegendaryBladeIII.code), SphereOfWater.code, LegendaryBladeII.code, 0, 0, 0)
    end
end)