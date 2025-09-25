OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GluttonousAxe = Class(Item)
    GluttonousAxe.code = S2A('I0A6')

    GluttonousAxe:property("damage", { get = function (self) return 2250 end })
    GluttonousAxe:property("criticalDamage", { get = function (self) return 4 end })
    GluttonousAxe:property("criticalChance", { get = function (self) return 0.2 end })
    GluttonousAxe:property("lifeSteal", { get = function (self) return 0.5 end })

    function GluttonousAxe.onInit()
        RegisterItem(GluttonousAxe.allocate(GluttonousAxe.code), ApocalypticMask.code, PhoenixAxe.code, 0, 0, 0)
    end
end)