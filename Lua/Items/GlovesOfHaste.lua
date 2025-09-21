OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GlovesOfHaste = Class(Item)
    GlovesOfHaste.code = S2A('I00C')

    GlovesOfHaste:property("attackSpeed", { get = function (self) return 0.1 end })

    function GlovesOfHaste.onInit()
        RegisterItem(GlovesOfHaste.allocate(GlovesOfHaste.code), 0, 0, 0, 0, 0)
    end
end)