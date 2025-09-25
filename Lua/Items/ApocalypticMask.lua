OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ApocalypticMask = Class(Item)
    ApocalypticMask.code = S2A('I089')

    ApocalypticMask:property("damage", { get = function (self) return 1500 end })
    ApocalypticMask:property("lifeSteal", { get = function (self) return 0.5 end })

    function ApocalypticMask.onInit()
        RegisterItem(ApocalypticMask.allocate(ApocalypticMask.code), HellishMask.code, SphereOfDarkness.code, 0, 0, 0)
    end
end)