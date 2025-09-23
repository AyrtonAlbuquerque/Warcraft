OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WarriorBlade = Class(Item)
    WarriorBlade.code = S2A('I02M')

    WarriorBlade:property("damage", { get = function (self) return 25 end })
    WarriorBlade:property("attackSpeed", { get = function (self) return 0.2 end })

    function WarriorBlade.onInit()
        RegisterItem(WarriorBlade.allocate(WarriorBlade.code), GoldenSword.code, GlovesOfHaste.code, 0, 0, 0)
    end
end)