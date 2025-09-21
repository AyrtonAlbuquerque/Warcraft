OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    PotionOfRestoration = Class(Item)
    PotionOfRestoration.code = S2A('I00P')

    function PotionOfRestoration.onInit()
        RegisterItem(PotionOfRestoration.allocate(PotionOfRestoration.code), 0, 0, 0, 0, 0)
    end
end)