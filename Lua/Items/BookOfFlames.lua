OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BookOfFlames = Class(Item)
    BookOfFlames.code = S2A('I06B')

    BookOfFlames:property("damage", { get = function (self) return 500 end })
    BookOfFlames:property("intelligence", { get = function (self) return 250 end })
    BookOfFlames:property("spellPower", { get = function (self) return 600 end })

    function BookOfFlames.onInit()
        RegisterItem(BookOfFlames.allocate(BookOfFlames.code), SummoningBook.code, SphereOfFire.code, 0, 0, 0)
    end
end)