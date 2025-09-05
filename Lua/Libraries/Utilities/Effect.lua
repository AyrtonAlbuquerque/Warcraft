OnInit("Effect", function(requires)
    requires "Class"
    requires "Modules"
    requires "WorldBounds"

    Effect = Class()

    Effect:property("x", {
        get = function(self) return self._x end,
        set = function(self, value)
            self._x = value

            BlzSetSpecialEffectX(self.effect, value)
            self:update()
        end
    })

    Effect:property("y", {
        get = function(self) return self._y end,
        set = function(self, value)
            self._y = value

            BlzSetSpecialEffectY(self.effect, value)
            self:update()
        end
    })

    Effect:property("z", {
        get = function(self) return self._z end,
        set = function(self, value)
            self._z = value

            BlzSetSpecialEffectZ(self.effect, value)
            self:update()
        end
    })

    Effect:property("yaw", {
        get = function(self) return self._yaw or 0 end,
        set = function(self, value)
            self._yaw = value

            BlzSetSpecialEffectYaw(self.effect, value)
            self:update()
        end
    })

    Effect:property("roll", {
        get = function(self) return self._roll or 0 end,
        set = function(self, value)
            self._roll = value

            BlzSetSpecialEffectRoll(self.effect, value)
            self:update()
        end
    })

    Effect:property("pitch", {
        get = function(self) return self._pitch or 0 end,
        set = function(self, value)
            self._pitch = value

            BlzSetSpecialEffectPitch(self.effect, value)
            self:update()
        end
    })

    Effect:property("model", {
        get = function(self) return self._model end,
        set = function(self, value)
            if self._model ~= value then
                DestroyEffect(self.effect)

                self._model = value
                self.effect = AddSpecialEffect(value, self._x, self._y)

                BlzSetSpecialEffectPosition(self.effect, self._x, self._y, self._z)
                BlzSetSpecialEffectOrientation(self.effect, self._yaw, self._pitch, self._roll)
                BlzSetSpecialEffectScale(self.effect, self._scale)
            end
        end
    })

    Effect:property("scale", {
        get = function(self) return self._scale end,
        set = function(self, value)
            self._scale = value

            BlzSetSpecialEffectScale(self.effect, value)

            for _, attachment in pairs(self.attachments) do
                attachment.scale = value
            end
        end
    })

    Effect:property("alpha", {
        get = function(self) return self._alpha end,
        set = function(self, value)
            self._alpha = value

            BlzSetSpecialEffectAlpha(self.effect, value)

            for _, attachment in pairs(self.attachments) do
                attachment.alpha = value
            end
        end
    })

    Effect:property("animation", {
        get = function(self) return self._animation end,
        set = function(self, value)
            self._animation = value

            BlzPlaySpecialEffect(self.effect, ConvertAnimType(value))

            for _, attachment in pairs(self.attachments) do
                attachment.animation = value
            end
        end
    })

    Effect:property("timeScale", {
        get = function(self) return self._timeScale end,
        set = function(self, value)
            self._timeScale = value

            BlzSetSpecialEffectTimeScale(self.effect, value)

            for _, attachment in pairs(self.attachments) do
                attachment.timeScale = value
            end
        end
    })

    Effect:property("playercolor", {
        get = function(self) return self._playercolor end,
        set = function(self, value)
            self._playercolor = value

            BlzSetSpecialEffectColorByPlayer(self.effect, Player(value))

            for _, attachment in pairs(self.attachments) do
                attachment.playercolor = value
            end
        end
    })

    function Effect:destroy()
        for _, attachment in pairs(self.attachments) do
            attachment:destroy()
        end

        DestroyEffect(self.effect)
        self.attachments:destroy()

        self.effect = nil
    end

    function Effect:orient(yaw, pitch, roll)
        self._yaw = yaw
        self._roll = roll
        self._pitch = pitch

        BlzSetSpecialEffectOrientation(self.effect, yaw, pitch, roll)
        self:update()
    end

    function Effect:move(x, y, z)
        if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
            self._x = x
            self._y = y
            self._z = z

            BlzSetSpecialEffectPosition(self.effect, x, y, z)
            self:update()

            return true
        end

        return false
    end

    function Effect:attach(model, dx, dy, dz, scale)
        local attachment = self.attachments:insert(Effect.create(model, self._x + dx, self._y + dy, self._z + dz, scale))

        attachment.dx = dx
        attachment.dy = dy
        attachment.dz = dz

        self:update()

        return attachment
    end

    function Effect:detach(attachment)
        self.attachments:remove(attachment)
    end

    function Effect:update()
        local dx
        local dy
        local dz
        local x1
        local y1
        local z1
        local x2
        local y2
        local z2

        for _, attachment in pairs(self.attachments) do
            dx = attachment.dx
            dy = attachment.dy
            dz = attachment.dz
            x1 = dx * math.cos(self._yaw) - dy * math.sin(self._yaw)
            y1 = dx * math.sin(self._yaw) + dy * math.cos(self._yaw)
            z1 = dz
            x2 = x1 * math.cos(self._pitch) + z1 * math.sin(self._pitch)
            y2 = y1
            z2 = -x1 * math.sin(self._pitch) + z1 * math.cos(self._pitch)
            dx = x2
            dy = y2 * math.cos(self._roll) - z2 * math.sin(self._roll)
            dz = y2 * math.sin(self._roll) + z2 * math.cos(self._roll)

            attachment.yaw = self._yaw
            attachment.pitch = self._pitch
            attachment.roll = self._roll

            attachment:move(self._x + dx, self._y + dy, self._z + dz)
        end
    end

    function Effect:color(red, green, blue)
        BlzSetSpecialEffectColor(self.effect, red, green, blue)
    end

    function Effect.create(model, x, y, z, scale)
        local this = Effect.allocate()

        this.effect = AddSpecialEffect(model, x, y)
        this._x = x
        this._y = y
        this._z = z
        this._yaw = 0
        this._roll = 0
        this._pitch = 0
        this._scale = scale
        this._model = model
        this._timeScale = 1
        this._animation = 0
        this._playercolor = 0
        this._transparency = 0
        this.attachments = List.create()

        BlzSetSpecialEffectZ(this.effect, z)
        BlzSetSpecialEffectScale(this.effect, scale)

        return this
    end
end)