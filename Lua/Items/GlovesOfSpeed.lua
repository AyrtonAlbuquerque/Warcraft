OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GlovesOfSpeed = Class(Item)
    GlovesOfSpeed.code = S2A('I02A')

    GlovesOfSpeed:property("attackSpeed", { get = function (self) return 0.25 end })

    function GlovesOfSpeed.onInit()
        RegisterItem(GlovesOfSpeed.allocate(GlovesOfSpeed.code), GlovesOfHaste.code, GlovesOfHaste.code, 0, 0, 0)
    end
end)