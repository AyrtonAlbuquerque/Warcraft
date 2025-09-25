OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    JadenShoulderPlate = Class(Item)
    JadenShoulderPlate.code = S2A('I08F')

    JadenShoulderPlate:property("health", { get = function (self) return 25000 end })
    JadenShoulderPlate:property("strength", { get = function (self) return 500 end })

    function JadenShoulderPlate.onInit()
        RegisterItem(JadenShoulderPlate.allocate(JadenShoulderPlate.code), EmeraldShoulderPlate.code, SaphireShoulderPlate.code, 0, 0, 0)
    end
end)