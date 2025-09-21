OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CrystalRing = Class(Item)
    CrystalRing.code = S2A('I00K')

    CrystalRing:property("manaRegen", { get = function (self) return 1 end })
    CrystalRing:property("spellPower", { get = function (self) return 10 end })

    function CrystalRing.onInit()
        RegisterItem(CrystalRing.allocate(CrystalRing.code), 0, 0, 0, 0, 0)
    end
end)