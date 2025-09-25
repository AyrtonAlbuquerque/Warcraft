OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MoonchantRing = Class(Item)
    MoonchantRing.code = S2A('I08I')

    MoonchantRing:property("mana", { get = function (self) return 20000 end })
    MoonchantRing:property("health", { get = function (self) return 10000 end })
    MoonchantRing:property("manaRegen", { get = function (self) return 500 end })
    MoonchantRing:property("intelligence", { get = function (self) return 350 end })

    function MoonchantRing.onInit()
        RegisterItem(MoonchantRing.allocate(MoonchantRing.code), FusionCrystal.code, RingOfConversion.code, 0, 0, 0)
    end
end)