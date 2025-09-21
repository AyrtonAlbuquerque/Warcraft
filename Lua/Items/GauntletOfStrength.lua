OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GauntletOfStrength = Class(Item)
    GauntletOfStrength.code = S2A('I00G')

    GauntletOfStrength:property("strength", { get = function (self) return 5 end })

    function GauntletOfStrength.onInit()
        RegisterItem(GauntletOfStrength.allocate(GauntletOfStrength.code), 0, 0, 0, 0, 0)
    end
end)