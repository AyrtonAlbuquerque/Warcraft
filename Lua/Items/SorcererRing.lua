OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SorcererRing = Class(Item)
    SorcererRing.code = S2A('I02J')

    SorcererRing:property("mana", { get = function (self) return 175 end })
    SorcererRing:property("manaRegen", { get = function (self) return 3 end })
    SorcererRing:property("spellPower", { get = function (self) return 20 end })

    function SorcererRing.onInit()
        RegisterItem(SorcererRing.allocate(SorcererRing.code), ManaCrystal.code, CrystalRing.code, CrystalRing.code, 0, 0)
    end
end)