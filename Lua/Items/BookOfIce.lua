OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfIce = Class(Item)
    BookOfIce.code = S2A('I055')

    BookOfIce:property("armor", { get = function (self) return 10 end })
    BookOfIce:property("intelligence", { get = function (self) return 250 end })
    BookOfIce:property("spellPower", { get = function (self) return 600 end })

    function BookOfIce.onInit()
        RegisterItem(BookOfIce.allocate(BookOfIce.code), SummoningBook.code, SphereOfAir.code, 0, 0, 0)
    end
end)