OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    EnflamedBow = Class(Item)
    EnflamedBow.code = S2A('I06U')

    EnflamedBow:property("damage", { get = function (self) return 500 end })
    EnflamedBow:property("agility", { get = function (self) return 250 end })

    function EnflamedBow.onInit()
        RegisterItem(EnflamedBow.allocate(EnflamedBow.code), HolyBow.code, SphereOfFire.code, 0, 0, 0)
    end
end)