OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MagmaHelmet = Class(Item)
    MagmaHelmet.code = S2A('I03M')

    MagmaHelmet:property("strength", { get = function (self) return 10 end })
    MagmaHelmet:property("healthRegen", { get = function (self) return 7 end })

    function MagmaHelmet.onInit()
        RegisterItem(MagmaHelmet.allocate(MagmaHelmet.code), OrbOfFire.code, WarriorHelmet.code, 0, 0, 0)
    end
end)