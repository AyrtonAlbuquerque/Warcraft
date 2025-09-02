OnInit("WorldBounds", function(requires)
    requires "Class"

    WorldBounds = Class()

    WorldBounds.world = GetWorldBounds()
    WorldBounds.region = CreateRegion()

    function WorldBounds.onInit()
        WorldBounds.minX = GetRectMinX(WorldBounds.world)
        WorldBounds.minY = GetRectMinY(WorldBounds.world)
        WorldBounds.maxX = GetRectMaxX(WorldBounds.world)
        WorldBounds.maxY = GetRectMaxY(WorldBounds.world)
        WorldBounds.centerX = (WorldBounds.minX + WorldBounds.maxX) / 2.
        WorldBounds.centerY = (WorldBounds.minY + WorldBounds.maxY) / 2.
        WorldBounds.playMaxX = GetRectMaxX(bj_mapInitialPlayableArea)
        WorldBounds.playMaxY = GetRectMaxY(bj_mapInitialPlayableArea)
        WorldBounds.playMinX = GetRectMinX(bj_mapInitialPlayableArea)
        WorldBounds.playMinY = GetRectMinY(bj_mapInitialPlayableArea)

        RegionAddRect(WorldBounds.region, WorldBounds.world)
    end
end)