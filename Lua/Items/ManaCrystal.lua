OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ManaCrystal = Class(Item)
    ManaCrystal.code = S2A('I00J')

    ManaCrystal:property("mana", { get = function (self) return 100 end })

    function ManaCrystal.onInit()
        RegisterItem(ManaCrystal.allocate(ManaCrystal.code), 0, 0, 0, 0, 0)
    end
end)