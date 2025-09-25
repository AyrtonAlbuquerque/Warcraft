OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MagusOrb = Class(Item)
    MagusOrb.code = S2A('I09O')

    MagusOrb:property("agility", { get = function (self) return 500 end })
    MagusOrb:property("strength", { get = function (self) return 500 end })
    MagusOrb:property("intelligence", { get = function (self) return 500 end })
    MagusOrb:property("manaRegen", { get = function (self) return 500 end })
    MagusOrb:property("healthRegen", { get = function (self) return 500 end })
    MagusOrb:property("spellPower", { get = function (self) return 500 end })

    function MagusOrb.onInit()
        RegisterItem(MagusOrb.allocate(MagusOrb.code), ElementalSpin.code, AncientSphere.code, 0, 0, 0)
    end
end)