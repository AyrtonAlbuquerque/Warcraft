OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    GlaiveScythe = Class(Item)
    GlaiveScythe.code = S2A('I02D')

    GlaiveScythe:property("agility", { get = function (self) return 7 end })
    GlaiveScythe:property("strength", { get = function (self) return 7 end })
    GlaiveScythe:property("intelligence", { get = function (self) return 7 end })

    function GlaiveScythe.onInit()
        RegisterItem(GlaiveScythe.allocate(GlaiveScythe.code), BraceletOfIntelligence.code, GauntletOfStrength.code, ClawsOfAgility.code, 0, 0)
    end
end)