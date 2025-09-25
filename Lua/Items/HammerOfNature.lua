OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HammerOfNature = Class(Item)
    HammerOfNature.code = S2A('I07F')

    HammerOfNature:property("damage", { get = function (self) return 500 end })
    HammerOfNature:property("strength", { get = function (self) return 250 end })
    HammerOfNature:property("spellPower", { get = function (self) return 250 end })

    function HammerOfNature.onInit()
        RegisterItem(HammerOfNature.allocate(HammerOfNature.code), SphereOfNature.code, GiantsHammer.code, 0, 0, 0)
    end
end)