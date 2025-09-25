OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RingOfConversion = Class(Item)
    RingOfConversion.code = S2A('I06X')

    RingOfConversion:property("mana", { get = function (self) return 10000 end })
    RingOfConversion:property("manaRegen", { get = function (self) return 250 end })

    function RingOfConversion.onInit()
        RegisterItem(RingOfConversion.allocate(RingOfConversion.code), DesertRing.code, SphereOfPower.code, SphereOfPower.code, 0, 0)
    end
end)