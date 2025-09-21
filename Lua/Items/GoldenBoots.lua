OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GoldenBoots = Class(Item)
    GoldenBoots.code = S2A('I014')

    GoldenBoots:property("damage", { get = function (self) return 15 end })
    GoldenBoots:property("lifeSteal", { get = function (self) return 0.15 end })
    GoldenBoots:property("movementSpeed", { get = function (self) return 50 end })

    function GoldenBoots.onInit()
        RegisterItem(GoldenBoots.allocate(GoldenBoots.code), BootsOfSpeed.code, HomecomingStone.code, RustySword.code, MaskOfDeath.code, 0)
    end
end)