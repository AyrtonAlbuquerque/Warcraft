OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GlovesOfGold = Class(Item)
    GlovesOfGold.code = S2A('I062')

    GlovesOfGold:property("attackSpeed", { get = function (self) return 2 end })

    function GlovesOfGold.onInit()
        RegisterItem(GlovesOfGold.allocate(GlovesOfGold.code), GlovesOfSilver.code, GlovesOfSilver.code, 0, 0, 0)
    end
end)