OnInit("Class", function()
    Class = {}

    local initializers = {}

    local function Initializer()
        if initializers then
            for i = 1, #initializers do
                local this = initializers[i]

                if this.onInit and type(this.onInit) == "function" then
                    local ok, exception = pcall(this.onInit)

                    if not ok then
                        print("onInit Error: " .. tostring(exception))
                    end
                end
            end

            initializers = nil
        end
    end

    function Class:property(name, options)
        self.__props[name] = {
            get = options and options.get or nil,
            set = options and options.set or nil,
        }

        return self
    end

    function Class:allocate(...)
        local this = {}
        local class = self

        setmetatable(this, {
            __index = function(instance, key)
                local value = rawget(instance, key)
                local props = class.__props and class.__props[key]

                if value ~= nil then
                    return value
                end

                if key == "destroy" then
                    return function(self)
                        if not self.__destroyed then
                            self.__destroyed = true

                            for i = #instance.__destructors, 1, -1 do
                                rawget(instance.__destructors[i], "destroy")(self)
                            end

                            instance.__destructors = nil
                            Class.deallocate(self)
                        end
                    end
                end

                if props and props.get then
                    return props.get(instance)
                end

                return class[key]
            end,
            __newindex = function(instance, key, value)
                local props = class.__props and class.__props[key]

                if props and props.set then
                    return props.set(instance, value)
                end

                rawset(instance, key, value)
            end

        })

        return this
    end

    function Class.deallocate(self)
        setmetatable(self, { __mode = "k" })
    end

    setmetatable(Class, {
        __index = function(self, key)
            local getter = rawget(self, "_getindex")
            local props = rawget(self, "__props") and rawget(self, "__props")[key]

            if getter then
                return getter(self, key)
            end

            if props and props.get then
                return props.get(self)
            end

            return rawget(Class, key)
        end,
        __newindex = function(self, key, value)
            local setter = rawget(self, "_setindex")
            local props = rawget(self, "__props") and rawget(self, "__props")[key]

            if setter then
                setter(self, key, value)
                return
            end

            if props and props.set then
                return props.set(self, value)
            end

            rawset(self, key, value)
        end,
        __call = function(self, parent)
            local this

            if parent then
                this = setmetatable({ super = parent, __props = {} }, { __index = parent })

                if parent.__props then
                    for key, value in pairs(parent.__props) do
                        this.__props[key] = value
                    end
                end

                this.allocate = function(class, ...)
                    local instance
                    local current = class
                    local destructors = {}
                    local constructor = nil

                    repeat
                        if rawget(current, "destroy") then
                            table.insert(destructors, 1, current)
                        end

                        if not constructor and current.super and rawget(current.super, "create") then
                            constructor = current.super
                        end

                        current = current.super
                    until not current

                    if constructor then
                        instance = constructor:create(...)
                    else
                        instance = Class.allocate(class, ...)
                    end

                    instance.__destroyed = false
                    instance.__destructors = destructors

                    return instance
                end
            else
                this = { __props = {} }
                this.__destroyed = false
                this.__destructors = { this }
            end

            table.insert(initializers, this)
            setmetatable(this, getmetatable(Class))

            return this
        end
    })

    Class.create = Class.allocate
    Class.destroy = Class.deallocate
    OnInit.trig(Initializer)
end)