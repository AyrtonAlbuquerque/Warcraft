OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SilverBoots = Class(Item)
    SilverBoots.code = S2A('I012')

    SilverBoots:property("armor", { get = function (self) return 4 end })
    SilverBoots:property("health", { get = function (self) return 200 end })
    SilverBoots:property("movementSpeed", { get = function (self) return 50 end })

    function SilverBoots.onInit()
        RegisterItem(SilverBoots.allocate(SilverBoots.code), BootsOfSpeed.code, HomecomingStone.code, Platemail.code, LifeCrystal.code, 0)
    end
end)