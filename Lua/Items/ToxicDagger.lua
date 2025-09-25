OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ToxicDagger = Class(Item)
    ToxicDagger.code = S2A('I047')

    ToxicDagger:property("damage", { get = function (self) return 30 end })

    function ToxicDagger.onInit()
        RegisterItem(ToxicDagger.allocate(ToxicDagger.code), OrbOfVenom.code, GoldenSword.code, 0, 0 ,0)
    end
end)