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

    setmetatable(Class, {
        __call = function(self, parent)
            local this = setmetatable({ super = parent, __operators = {} }, { 
                __index = function(self, key)
                    local operator = self.__operators[key]
    
                    if operator and operator.get then
                        return operator.get(self)
                    end
    
                    return parent and parent[key]
                end,
                __newindex = function(self, key, value)
                    local operator = self.__operators[key]
    
                    if operator and operator.set then
                        operator.set(self, value)
                        return
                    end
    
                    rawset(self, key, value)
                end
            })
    
            if parent and parent.__operators then
                for key, value in pairs(parent.__operators) do
                    this.__operators[key] = value
                end
            end
    
            function this:property(name, callback)
                self.__operators[name] = callback
            end
    
            function this.allocate(...)
                local instance
                local constructor
                local class = this.super

                while not constructor and class do
                    if class.create then
                        constructor = class.create
                    end

                    class = class.super
                end

                if constructor then
                    instance = constructor(...)
                else
                    instance = {}
                end

                setmetatable(instance, this)

                return instance
            end
    
            this.__index = function(self, key)
                local class = getmetatable(self)
                local operator = class.__operators[key]

                if operator and operator.get then
                    return operator.get(self)
                end

                if key == "destroy" then
                    return function(self)
                        local current = getmetatable(self)
                        
                        while current do
                            if rawget(current, "destroy") then
                                rawget(current, "destroy")(self)
                            end
                            
                            current = current.super
                        end

                        setmetatable(self, { __mode = "k" })
                    end
                end

                return class[key]
            end
    
            this.__newindex = function(self, key, value)
                local class = getmetatable(self)
                local operator = class.__operators[key]

                if operator and operator.set then
                    operator.set(self, value)
                    return
                end

                rawset(self, key, value)
            end
    
            table.insert(initializers, this)

            return this
        end
    })

    OnInit.trig(Initializer)
end)