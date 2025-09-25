OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LegendaryBladeII = Class(Item)
    LegendaryBladeII.code = S2A('I080')

    LegendaryBladeII:property("damage", { get = function (self) return 1250 end })
    LegendaryBladeII:property("attackSpeed", { get = function (self) return 1 end })
    LegendaryBladeII:property("spellPower", { get = function (self) return 750 end })

    function LegendaryBladeII.onInit()
        RegisterItem(LegendaryBladeII.allocate(LegendaryBladeII.code), SphereOfDivinity.code, LegendaryBladeI.code, 0, 0, 0)
    end
end)