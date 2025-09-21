OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SimpleBow = Class(Item)
    SimpleBow.code = S2A('I01T')

    SimpleBow:property("agility", { get = function (self) return 5 end })

    function SimpleBow.onInit()
        RegisterItem(SimpleBow.allocate(SimpleBow.code), 0, 0, 0, 0, 0)
    end
end)