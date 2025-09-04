OnInit("Modules", function(requires)
    requires "Class"

    List = Class()

    List:property("size", { get = function(self) return #self._items end })

    function List:__pairs()
        local i = 0
        local items = self._items

        return function()
            i = i + 1

            local item = items[i]

            if item then
                return i, item
            end
        end
    end

    function List:destroy()
        self:clear()
    end

    function List:at(index)
        return self._items[index]
    end

    function List:has(item)
        return self._lookup[item] ~= nil
    end

    function List:insert(item)
        if not self:has(item) then
            table.insert(self._items, item)
            self._lookup[item] = #self._items
        end

        return item
    end

    function List:remove(item)
        if item and self:has(item) then
            local index = self._lookup[item]
            local last = self._items[#self._items]

            self._items[index] = last
            self._lookup[last] = index
            table.remove(self._items)
            self._lookup[item] = nil
        end
    end

    function List:clear()
        self._items = {}
        self._lookup = {}
    end

    function List.create()
        local this = List.allocate()

        this._items = {}
        this._lookup = {}

        return this
    end
end)