OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WarlockRing = Class(Item)
    WarlockRing.code = S2A('I09C')

    WarlockRing:property("mana", { get = function (self) return 25000 end })
    WarlockRing:property("health", { get = function (self) return 15000 end })
    WarlockRing:property("manaRegen", { get = function (self) return 750 end })
    WarlockRing:property("intelligence", { get = function (self) return 500 end })

    function WarlockRing.onInit()
        RegisterItem(WarlockRing.allocate(WarlockRing.code), SphereOfDarkness.code, MoonchantRing.code, 0, 0, 0)
    end
end)