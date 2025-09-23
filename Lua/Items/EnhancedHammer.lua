OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    EnhancedHammer = Class(Item)
    EnhancedHammer.code = S2A('I02V')

    EnhancedHammer:property("damage", { get = function (self) return 12 end })

    function EnhancedHammer.onInit()
        RegisterItem(EnhancedHammer.allocate(EnhancedHammer.code), RustySword.code, HeavyHammer.code, HeavyHammer.code, 0, 0)
    end
end)