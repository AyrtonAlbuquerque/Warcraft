OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MoonScyth = Class(Item)
    MoonScyth.code = S2A('I09I')

    MoonScyth:property("damage", { get = function (self) return 500 end })
    MoonScyth:property("agility", { get = function (self) return 500 end })
    MoonScyth:property("strength", { get = function (self) return 500 end })
    MoonScyth:property("intelligence", { get = function (self) return 500 end })
    MoonScyth:property("lifeSteal", { get = function (self) return 0.5 end })
    MoonScyth:property("movementSpeed", { get = function (self) return 50 end })

    function MoonScyth.onInit()
        RegisterItem(MoonScyth.allocate(MoonScyth.code), HellishMask.code, EntityScythe.code, 0, 0, 0)
    end
end)