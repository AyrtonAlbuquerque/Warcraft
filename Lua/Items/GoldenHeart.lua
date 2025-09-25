OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GoldenHeart = Class(Item)
    GoldenHeart.code = S2A('I0AV')

    GoldenHeart:property("armor", { get = function (self) return 50 end })
    GoldenHeart:property("health", { get = function (self) return 50000 end })

    function GoldenHeart.onInit()
        RegisterItem(GoldenHeart.allocate(GoldenHeart.code), 0, 0, 0, 0, 0)
    end
end)