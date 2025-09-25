OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    WindSword = Class(Item)
    WindSword.code = S2A('I04D')

    WindSword:property("damage", { get = function (self) return 25 end })

    function WindSword.onInit()
        RegisterItem(WindSword.allocate(WindSword.code), OrbOfWind.code, GoldenSword.code, 0, 0, 0)
    end
end)