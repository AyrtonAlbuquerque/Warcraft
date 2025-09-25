OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HellishMask = Class(Item)
    HellishMask.code = S2A('I06R')

    HellishMask:property("damage", { get = function (self) return 750 end })
    HellishMask:property("lifeSteal", { get = function (self) return 0.3 end })

    function HellishMask.onInit()
        RegisterItem(HellishMask.allocate(HellishMask.code), DemonicMask.code, SphereOfDarkness.code, 0, 0, 0)
    end
end)