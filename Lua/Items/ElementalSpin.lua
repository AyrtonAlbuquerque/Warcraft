OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ElementalSpin = Class(Item)
    ElementalSpin.code = S2A('I07I')

    ElementalSpin:property("intelligence", { get = function (self) return 250 end })
    ElementalSpin:property("manaRegen", { get = function (self) return 125 end })
    ElementalSpin:property("healthRegen", { get = function (self) return 125 end })
    ElementalSpin:property("spellPower", { get = function (self) return 400 end })

    function ElementalSpin.onInit()
        RegisterItem(ElementalSpin.allocate(ElementalSpin.code), OrbOfFire.code, OrbOfWater.code, OrbOfVenom.code, OrbOfLight.code, 0)
    end
end)