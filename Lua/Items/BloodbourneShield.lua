OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    BloodbourneShield = Class(Item)
    BloodbourneShield.code = S2A('I08L')

    BloodbourneShield:property("armor", { get = function (self) return 15 end })
    BloodbourneShield:property("block", { get = function (self) return 250 end })
    BloodbourneShield:property("health", { get = function (self) return 25000 end })

    function BloodbourneShield.onInit()
        RegisterItem(BloodbourneShield.allocate(BloodbourneShield.code), CommanderShield.code, PhilosopherStone.code, 0, 0, 0)
    end
end)