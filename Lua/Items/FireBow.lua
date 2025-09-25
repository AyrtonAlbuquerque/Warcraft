OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    FireBow = Class(Item)
    FireBow.code = S2A('I099')

    FireBow:property("damage", { get = function (self) return 750 end })
    FireBow:property("agility", { get = function (self) return 500 end })
    FireBow:property("spellPower", { get = function (self) return 500 end })

    function FireBow.onInit()
        RegisterItem(FireBow.allocate(FireBow.code), SphereOfFire.code, EnflamedBow.code, 0, 0, 0)
    end
end)