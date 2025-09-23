OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SoulScyther = Class(Item)
    SoulScyther.code = S2A('I037')

    SoulScyther:property("damage", { get = function (self) return 10 end })
    SoulScyther:property("agility", { get = function (self) return 10 end })
    SoulScyther:property("strength", { get = function (self) return 10 end })
    SoulScyther:property("intelligence", { get = function (self) return 10 end })

    function SoulScyther.onInit()
        RegisterItem(SoulScyther.allocate(SoulScyther.code), RustySword.code, GlaiveScythe.code, 0, 0, 0)
    end
end)