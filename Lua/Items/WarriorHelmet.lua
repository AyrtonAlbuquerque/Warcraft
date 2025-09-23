OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WarriorHelmet = Class(Item)
    WarriorHelmet.code = S2A('I034')

    WarriorHelmet:property("strength", { get = function (self) return 7 end })
    WarriorHelmet:property("healthRegen", { get = function (self) return 5 end })

    function WarriorHelmet.onInit()
        RegisterItem(WarriorHelmet.allocate(WarriorHelmet.code), GauntletOfStrength.code, LifeEssenceCrystal.code, LifeEssenceCrystal.code, 0, 0)
    end
end)