OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CrownOfRightouesness = Class(Item)
    CrownOfRightouesness.code = S2A('I079')

    CrownOfRightouesness:property("mana", { get = function (self) return 10000 end })
    CrownOfRightouesness:property("manaRegen", { get = function (self) return 250 end })
    CrownOfRightouesness:property("spellPower", { get = function (self) return 600 end })

    function CrownOfRightouesness.onInit()
        RegisterItem(CrownOfRightouesness.allocate(CrownOfRightouesness.code), DesertRing.code, SphereOfDivinity.code, 0, 0, 0)
    end
end)