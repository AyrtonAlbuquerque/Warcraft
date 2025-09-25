OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfChaos = Class(Item)
    BookOfChaos.code = S2A('I06N')

    BookOfChaos:property("health", { get = function (self) return 5000 end })
    BookOfChaos:property("intelligence", { get = function (self) return 250 end })
    BookOfChaos:property("spellPower", { get = function (self) return 600 end })

    function BookOfChaos.onInit()
        RegisterItem(BookOfChaos.allocate(BookOfChaos.code), SummoningBook.code, SphereOfDarkness.code, 0, 0, 0)
    end
end)