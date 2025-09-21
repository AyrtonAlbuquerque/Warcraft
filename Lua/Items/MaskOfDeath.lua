OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    MaskOfDeath = Class(Item)
    MaskOfDeath.code = S2A('I00U')

    MaskOfDeath:property("lifeSteal", { get = function (self) return 0.05 end })

    function MaskOfDeath.onInit()
        RegisterItem(MaskOfDeath.allocate(MaskOfDeath.code), 0, 0, 0, 0, 0)
    end
end)