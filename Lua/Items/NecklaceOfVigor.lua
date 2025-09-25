OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    NecklaceOfVigor = Class(Item)
    NecklaceOfVigor.code = S2A('I07L')

    NecklaceOfVigor:property("mana", { get = function (self) return 10000 end })
    NecklaceOfVigor:property("health", { get = function (self) return 10000 end })
    NecklaceOfVigor:property("spellPower", { get = function (self) return 750 end })

    function NecklaceOfVigor.onInit()
        RegisterItem(NecklaceOfVigor.allocate(NecklaceOfVigor.code), AncientStone.code, 0, 0, 0, 0)
    end
end)