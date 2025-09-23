OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GoldenSword = Class(Item)
    GoldenSword.code = S2A('I01A')

    GoldenSword:property("damage", { get = function (self) return 24 end })

    function GoldenSword.onInit()
        RegisterItem(GoldenSword.allocate(GoldenSword.code), RustySword.code, RustySword.code, RustySword.code, 0,  0)
    end
end)