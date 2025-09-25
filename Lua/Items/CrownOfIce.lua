OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CrownOfIce = Class(Item)
    CrownOfIce.code = S2A('I0AU')

    CrownOfIce:property("damage", { get = function (self) return 1000 end })
    CrownOfIce:property("agility", { get = function (self) return 1000 end })
    CrownOfIce:property("strength", { get = function (self) return 1000 end })
    CrownOfIce:property("intelligence", { get = function (self) return 1000 end })
    CrownOfIce:property("spellPower", { get = function (self) return 2000 end })

    function CrownOfIce.onInit()
        RegisterItem(CrownOfIce.allocate(CrownOfIce.code), 0, 0, 0, 0, 0)
    end
end)