OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CrownOfGods = Class(Item)
    CrownOfGods.code = S2A('I0A9')

    CrownOfGods:property("mana", { get = function (self) return 25000 end })
    CrownOfGods:property("health", { get = function (self) return 25000 end })
    CrownOfGods:property("manaRegen", { get = function (self) return 750 end })
    CrownOfGods:property("intelligence", { get = function (self) return 750 end })
    CrownOfGods:property("spellPower", { get = function (self) return 750 end })

    function CrownOfGods.onInit()
        RegisterItem(CrownOfGods.allocate(CrownOfGods.code), CrownOfRightouesness.code, WarlockRing.code, 0, 0, 0)
    end
end)