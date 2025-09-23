OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    DemonicMask = Class(Item)
    DemonicMask.code = S2A('I03J')

    DemonicMask:property("damage", { get = function (self) return 25 end })
    DemonicMask:property("lifeSteal", { get = function (self) return 0.12 end })

    function DemonicMask.onInit()
        RegisterItem(DemonicMask.allocate(DemonicMask.code), OrbOfDarkness.code, MaskOfMadness.code, GoldenSword.code, 0, 0)
    end
end)