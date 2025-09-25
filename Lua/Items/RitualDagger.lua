OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RitualDagger = Class(Item)
    RitualDagger.code = S2A('I05N')

    RitualDagger:property("damage", { get = function (self) return 30 end })
    RitualDagger:property("lifeSteal", { get = function (self) return 0.15 end })
    RitualDagger:property("evasion", { get = function (self) return 0.15 end })

    function RitualDagger.onInit()
        RegisterItem(RitualDagger.allocate(RitualDagger.code), BlackNavaja.code, MaskOfMadness.code, 0, 0, 0)
    end
end)