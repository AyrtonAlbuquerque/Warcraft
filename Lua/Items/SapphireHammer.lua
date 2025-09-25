OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SapphireHammer = Class(Item)
    SapphireHammer.code = S2A('I096')

    SapphireHammer:property("damage", { get = function (self) return 750 end })
    SapphireHammer:property("strength", { get = function (self) return 500 end })
    SapphireHammer:property("spellPower", { get = function (self) return 400 end })

    function SapphireHammer.onInit()
        RegisterItem(SapphireHammer.allocate(SapphireHammer.code), HammerOfNature.code, SaphireShoulderPlate.code, 0, 0, 0)
    end
end)