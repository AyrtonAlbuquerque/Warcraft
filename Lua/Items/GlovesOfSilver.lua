OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GlovesOfSilver = Class(Item)
    GlovesOfSilver.code = S2A('I03A')

    GlovesOfSilver:property("damage", { get = function (self) return 10 end })
    GlovesOfSilver:property("agility", { get = function (self) return 10 end })
    GlovesOfSilver:property("strength", { get = function (self) return 10 end })
    GlovesOfSilver:property("intelligence", { get = function (self) return 10 end })

    function GlovesOfSilver.onInit()
        RegisterItem(GlovesOfSilver.allocate(GlovesOfSilver.code), GlovesOfSpeed.code, GlovesOfSpeed.code, 0, 0, 0)
    end
end)