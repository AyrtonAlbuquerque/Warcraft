OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ClawsOfAgility = Class(Item)
    ClawsOfAgility.code = S2A('I00I')

    ClawsOfAgility:property("agility", { get = function (self) return 5 end })

    function ClawsOfAgility.onInit()
        RegisterItem(ClawsOfAgility.allocate(ClawsOfAgility.code), 0, 0, 0, 0, 0)
    end
end)