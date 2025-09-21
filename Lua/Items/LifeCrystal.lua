OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LifeCrystal = Class(Item)
    LifeCrystal.code = S2A('I00B')

    LifeCrystal:property("health", { get = function (self) return 100 end })

    function LifeCrystal.onInit()
        RegisterItem(LifeCrystal.allocate(LifeCrystal.code), 0, 0, 0, 0, 0)
    end
end)