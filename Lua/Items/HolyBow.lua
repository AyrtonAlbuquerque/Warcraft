OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HolyBow = Class(Item)
    HolyBow.code = S2A('I03S')

    HolyBow:property("damage", { get = function (self) return 10 end })
    HolyBow:property("agility", { get = function (self) return 7 end })

    function HolyBow.onInit()
        RegisterItem(HolyBow.allocate(HolyBow.code), OrbOfLight.code, SimpleBow.code, 0, 0, 0)
    end
end)