OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    SakuraBlade = Class(Item)
    SakuraBlade.code = S2A('I0AZ')

    SakuraBlade:property("damage", { get = function (self) return 1000 end })

    function SakuraBlade.onInit()
        RegisterItem(SakuraBlade.allocate(SakuraBlade.code), 0, 0, 0, 0, 0)
    end
end)