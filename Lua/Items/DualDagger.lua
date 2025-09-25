OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    DualDagger = Class(Item)
    DualDagger.code = S2A('I086')

    DualDagger:property("damage", { get = function (self) return 500 end })
    DualDagger:property("evasion", { get = function (self) return 0.25 end })
    DualDagger:property("lifeSteal", { get = function (self) return 0.25 end })
    DualDagger:property("spellPower", { get = function (self) return 250 end })

    function DualDagger.onInit()
        RegisterItem(DualDagger.allocate(DualDagger.code), RitualDagger.code, SphereOfFire.code, SphereOfWater.code, 0, 0)
    end
end)