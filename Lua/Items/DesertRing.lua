OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    DesertRing = Class(Item)
    DesertRing.code = S2A('I03Y')

    DesertRing:property("mana", { get = function (self) return 250 end })
    DesertRing:property("manaRegen", { get = function (self) return 4 end })
    DesertRing:property("spellPower", { get = function (self) return 25 end })

    function DesertRing.onInit()
        RegisterItem(DesertRing.allocate(DesertRing.code), OrbOfSands.code, SorcererRing.code, 0, 0 ,0)
    end
end)