OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BlackNavaja = Class(Item)
    BlackNavaja.code = S2A('I02P')

    BlackNavaja:property("damage", { get = function (self) return 25 end })
    BlackNavaja:property("evasion", { get = function (self) return 0.12 end })

    function BlackNavaja.onInit()
        RegisterItem(BlackNavaja.allocate(BlackNavaja.code), RustySword.code, RustySword.code, AssassinsDagger.code, 0, 0)
    end
end)