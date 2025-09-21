OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrbOfDarkness = Class(Item)
    OrbOfDarkness.code = S2A('I01Y')

    OrbOfDarkness:property("damage", { get = function (self) return 10 end })

    function OrbOfDarkness.onInit()
        RegisterItem(OrbOfDarkness.allocate(OrbOfDarkness.code), 0, 0, 0, 0, 0)
    end
end)