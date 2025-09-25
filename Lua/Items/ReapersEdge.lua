OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ReapersEdge = Class(Item)
    ReapersEdge.code = S2A('I05Z')

    ReapersEdge:property("agility", { get = function (self) return 200 end })
    ReapersEdge:property("strength", { get = function (self) return 200 end })
    ReapersEdge:property("intelligence", { get = function (self) return 200 end })
    ReapersEdge:property("spellPower", { get = function (self) return 400 end })

    function ReapersEdge.onInit()
        RegisterItem(ReapersEdge.allocate(ReapersEdge.code), SoulScyther.code, SphereOfPower.code, 0, 0, 0)
    end
end)