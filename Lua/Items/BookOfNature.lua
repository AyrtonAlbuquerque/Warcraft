OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfNature = Class(Item)
    BookOfNature.code = S2A('I06H')

    BookOfNature:property("healthRegen", { get = function (self) return 200 end })
    BookOfNature:property("intelligence", { get = function (self) return 250 end })
    BookOfNature:property("spellPower", { get = function (self) return 600 end })

    function BookOfNature.onInit()
        RegisterItem(BookOfNature.allocate(BookOfNature.code), SummoningBook.code, SphereOfNature.code, 0, 0, 0)
    end
end)