OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    AnkhOfReincarnation = Class(Item)
    AnkhOfReincarnation.code = S2A('I00N')

    function AnkhOfReincarnation.onInit()
        RegisterItem(AnkhOfReincarnation.allocate(AnkhOfReincarnation.code), 0, 0, 0, 0, 0)
    end
end)