OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfOceans = Class(Item)
    BookOfOceans.code = S2A('I06E')

    BookOfOceans:property("mana", { get = function (self) return 5000 end })
    BookOfOceans:property("intelligence", { get = function (self) return 250 end })
    BookOfOceans:property("spellPower", { get = function (self) return 600 end })

    function BookOfOceans.onInit()
        RegisterItem(BookOfOceans.allocate(BookOfOceans.code), SummoningBook.code, SphereOfWater.code, 0, 0, 0)
    end
end)