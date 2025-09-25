OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SwordOfDomination = Class(Item)
    SwordOfDomination.code = S2A('I09X')

    SwordOfDomination:property("damage", { get = function (self) return 2000 end })
    SwordOfDomination:property("criticalDamage", { get = function (self) return 3.5 end })
    SwordOfDomination:property("criticalChance", { get = function (self) return 0.35 end })
    SwordOfDomination:property("spellPower", { get = function (self) return 500 end })

    function SwordOfDomination.onInit()
        RegisterItem(SwordOfDomination.allocate(SwordOfDomination.code), RedemptionSword.code, 0, 0, 0, 0)
    end
end)