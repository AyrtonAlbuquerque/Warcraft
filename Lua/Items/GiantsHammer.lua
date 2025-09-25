OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GiantsHammer = Class(Item)
    GiantsHammer.code = S2A('I05E')

    GiantsHammer:property("damage", { get = function (self) return 30 end })

    function GiantsHammer.onInit()
        RegisterItem(GiantsHammer.allocate(GiantsHammer.code), BlackNavaja.code, MaskOfMadness.code, 0, 0, 0)
    end
end)