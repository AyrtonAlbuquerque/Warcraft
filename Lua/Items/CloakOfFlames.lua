OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    CloakOfFlames = Class(Item)
    CloakOfFlames.code = S2A('I00V')

    function CloakOfFlames.onInit()
        RegisterItem(CloakOfFlames.allocate(CloakOfFlames.code), 0, 0, 0, 0, 0)
    end
end)