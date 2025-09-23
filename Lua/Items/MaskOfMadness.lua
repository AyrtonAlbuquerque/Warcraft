OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MaskOfMadness = Class(Item)
    MaskOfMadness.code = S2A('I024')

    MaskOfMadness:property("lifeSteal", { get = function (self) return 0.1 end })

    function MaskOfMadness.onInit()
        RegisterItem(MaskOfMadness.allocate(MaskOfMadness.code), MaskOfDeath.code, 0, 0, 0, 0)
    end
end)