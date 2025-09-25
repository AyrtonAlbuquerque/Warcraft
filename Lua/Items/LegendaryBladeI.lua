OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LegendaryBladeI = Class(Item)
    LegendaryBladeI.code = S2A('I073')

    LegendaryBladeI:property("damage", { get = function (self) return 1000 end })
    LegendaryBladeI:property("attackSpeed", { get = function (self) return 0.5 end })
    LegendaryBladeI:property("spellPower", { get = function (self) return 500 end })

    function LegendaryBladeI.onInit()
        RegisterItem(LegendaryBladeI.allocate(LegendaryBladeI.code), WarriorBlade.code, SphereOfFire.code, 0, 0, 0)
    end
end)