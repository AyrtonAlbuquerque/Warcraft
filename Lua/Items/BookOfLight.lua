OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfLight = Class(Item)
    BookOfLight.code = S2A('I06K')

    BookOfLight:property("manaRegen", { get = function (self) return 200 end })
    BookOfLight:property("intelligence", { get = function (self) return 250 end })
    BookOfLight:property("spellPower", { get = function (self) return 600 end })

    function BookOfLight.onInit()
        RegisterItem(BookOfLight.allocate(BookOfLight.code), SummoningBook.code, SphereOfDivinity.code, 0, 0, 0)
    end
end)