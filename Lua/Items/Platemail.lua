OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    Platemail = Class(Item)
    Platemail.code = S2A('I00F')

    Platemail:property("armor", { get = function (self) return 2 end })

    function Platemail.onInit()
        RegisterItem(Platemail.allocate(Platemail.code), 0, 0, 0, 0, 0)
    end
end)