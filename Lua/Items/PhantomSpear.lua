OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    PhantomSpear = Class(Item)
    PhantomSpear.code = S2A('I09F')

    PhantomSpear:property("damage", { get = function (self) return 750 end })
    PhantomSpear:property("attackSpeed", { get = function (self) return 2.5 end })
    PhantomSpear:property("movementSpeed", { get = function (self) return 75 end })
    PhantomSpear:property("spellPower", { get = function (self) return 750 end })

    function PhantomSpear.onInit()
        RegisterItem(PhantomSpear.allocate(PhantomSpear.code), GlovesOfGold.code, ThundergodSpear.code, 0, 0, 0)
    end
end)