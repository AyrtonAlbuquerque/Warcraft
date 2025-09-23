OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    InfusedManaCrystal = Class(Item)
    InfusedManaCrystal.code = S2A('I027')

    InfusedManaCrystal:property("mana", { get = function (self) return 350 end })

    function InfusedManaCrystal.onInit()
        RegisterItem(InfusedManaCrystal.allocate(InfusedManaCrystal.code), ManaCrystal.code, ManaCrystal.code, ManaCrystal.code, 0, 0)
    end
end)