OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    Courier = Class(Item)
    Courier.code = S2A('I01Z')

    function Courier.onInit()
        RegisterItem(Courier.allocate(Courier.code), 0, 0, 0, 0, 0)
    end
end)