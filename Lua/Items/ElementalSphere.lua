OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    ElementalSphere = Class(Item)
    ElementalSphere.code = S2A('I0AO')

    ElementalSphere:property("spellPower", { get = function (self) return 2000 end })

    function ElementalSphere.onInit()
        RegisterItem(ElementalSphere.allocate(ElementalSphere.code), SphereOfFire.code, SphereOfWater.code, SphereOfNature.code, SphereOfAir.code, SphereOfDarkness.code)
    end
end)