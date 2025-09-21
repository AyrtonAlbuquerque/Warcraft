OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BraceletOfIntelligence = Class(Item)
    BraceletOfIntelligence.code = S2A('I00H')

    BraceletOfIntelligence:property("intelligence", { get = function (self) return 5 end })

    function BraceletOfIntelligence.onInit()
        RegisterItem(BraceletOfIntelligence.allocate(BraceletOfIntelligence.code), 0, 0, 0, 0, 0)
    end
end)