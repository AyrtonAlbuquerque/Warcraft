OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    AssassinsDagger = Class(Item)
    AssassinsDagger.code = S2A('I01R')

    AssassinsDagger:property("damage", { get = function (self) return 5 end })
    AssassinsDagger:property("evasion", { get = function (self) return 0.1 end })

    function AssassinsDagger.onInit()
        RegisterItem(AssassinsDagger.allocate(AssassinsDagger.code), 0, 0, 0, 0, 0)
    end
end)