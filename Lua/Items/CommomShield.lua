OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CommomShield = Class(Item)
    CommomShield.code = S2A('I016')

    CommomShield:property("block", { get = function (self) return 10 end })

    function CommomShield.onInit()
        RegisterItem(CommomShield.allocate(CommomShield.code), 0, 0, 0, 0, 0)
    end
end)