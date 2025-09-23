OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MageStick = Class(Item)
    MageStick.code = S2A('I02G')

    MageStick:property("mana", { get = function (self) return 150 end })
    MageStick:property("manaRegen", { get = function (self) return 1.5 end })
    MageStick:property("spellPower", { get = function (self) return 20 end })

    function MageStick.onInit()
        RegisterItem(MageStick.allocate(MageStick.code), ManaCrystal.code, ManaCrystal.code, CrystalRing.code, 0, 0)
    end
end)