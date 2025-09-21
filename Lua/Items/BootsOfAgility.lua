OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfAgility = Class(Item)
    BootsOfAgility.code = S2A('I00O')

    BootsOfAgility:property("agility", { get = function (self) return 10 end })
    BootsOfAgility:property("movementSpeed", { get = function (self) return 50 end })

    function BootsOfAgility.onInit()
        RegisterItem(BootsOfAgility.allocate(BootsOfAgility.code), BootsOfSpeed.code, ClawsOfAgility.code, HomecomingStone.code, 0, 0)
    end
end)