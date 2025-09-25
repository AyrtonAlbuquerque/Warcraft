OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HolyHammer = Class(Item)
    HolyHammer.code = S2A('I0A3')

    HolyHammer:property("damage", { get = function (self) return 1000 end })
    HolyHammer:property("strength", { get = function (self) return 750 end })
    HolyHammer:property("spellPower", { get = function (self) return 750 end })

    function HolyHammer.onInit()
        RegisterItem(HolyHammer.allocate(HolyHammer.code), SphereOfDivinity.code, SapphireHammer.code, 0, 0, 0)
    end
end)