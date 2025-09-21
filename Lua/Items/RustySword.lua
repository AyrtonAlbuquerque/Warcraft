OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RustySword = Class(Item)
    RustySword.code = S2A('I00E')

    RustySword:property("damage", { get = function (self) return 7 end })

    function RustySword.onInit()
        RegisterItem(RustySword.allocate(RustySword.code), 0, 0, 0, 0, 0)
    end
end)