OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BootsOfIntelligence = Class(Item)
    BootsOfIntelligence.code = S2A('I00Q')

    BootsOfIntelligence:property("intelligence", { get = function (self) return 10 end })
    BootsOfIntelligence:property("movementSpeed", { get = function (self) return 50 end })

    function BootsOfIntelligence.onInit()
        RegisterItem(BootsOfIntelligence.allocate(BootsOfIntelligence.code), BootsOfSpeed.code, BraceletOfIntelligence.code, HomecomingStone.code, 0, 0)
    end
end)