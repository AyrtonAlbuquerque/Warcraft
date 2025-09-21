OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SummoningBook = Class(Item)
    SummoningBook.code = S2A('I01U')

    SummoningBook:property("spellPower", { get = function (self) return 15 end })
    SummoningBook:property("cooldownReduction", { get = function (self) return 0.1 end })

    function SummoningBook.onInit()
        RegisterItem(SummoningBook.allocate(SummoningBook.code), 0, 0, 0, 0, 0)
    end
end)