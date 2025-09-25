OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    LightningSword = Class(Item)
    LightningSword.code = S2A('I0AY')

    LightningSword:property("damage", { get = function (self) return 2500 end })

    function LightningSword.onInit()
        RegisterItem(LightningSword.allocate(LightningSword.code), 0, 0, 0, 0, 0)
    end
end)