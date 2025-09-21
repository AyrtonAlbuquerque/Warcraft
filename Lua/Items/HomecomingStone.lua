OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    HomecomingStone = Class(Item)
    HomecomingStone.code = S2A('I00D')

    function HomecomingStone.onInit()
        RegisterItem(HomecomingStone.allocate(HomecomingStone.code), 0, 0, 0, 0, 0)
    end
end)