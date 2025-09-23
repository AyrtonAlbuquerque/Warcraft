OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SoulSword = Class(Item)
    SoulSword.code = S2A('I041')

    SoulSword:property("damage", { get = function (self) return 20 end })

    function SoulSword.onInit()
        RegisterItem(SoulSword.allocate(SoulSword.code), OrbOfSouls.code, GoldenSword.code, 0, 0, 0)
    end
end)